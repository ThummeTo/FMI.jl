#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DifferentialEquations.DiffEqCallbacks
import DifferentialEquations.SciMLBase: RightRootFind, ReturnCode

using FMIImport: fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2NewDiscreteStates, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates, fmi2SetContinuousStates, fmi2GetDerivatives!
using FMIImport.FMICore: fmi2StatusOK, fmi2TypeCoSimulation, fmi2TypeModelExchange
using FMIImport.FMICore: fmi2ComponentState, fmi2ComponentStateInstantiated, fmi2ComponentStateInitializationMode, fmi2ComponentStateEventMode, fmi2ComponentStateContinuousTimeMode, fmi2ComponentStateTerminated, fmi2ComponentStateError, fmi2ComponentStateFatal
using FMIImport: FMU2Solution, FMU2Event

import FMIImport: prepareSolveFMU, finishSolveFMU, handleEvents

using FMIImport.FMICore.ChainRulesCore
using FMIImport.FMICore: FMU2InputFunction

import LinearAlgebra: eigvals

import ProgressMeter
import ThreadPools

import FMIImport.FMICore: EMPTY_fmi2Real, EMPTY_fmi2ValueReference

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::FMU2Component, integrator, tStart, tStop)

    #@info "TC"

    c.solution.evals_timechoice += 1

    if c.eventInfo.nextEventTimeDefined == fmi2True

        if c.eventInfo.nextEventTime >= tStart && c.eventInfo.nextEventTime <= tStop
            return c.eventInfo.nextEventTime
        else
            # the time event is outside the simulation range!
            @debug "Next time event @$(c.eventInfo.nextEventTime)s is outside simulation time range ($(tStart), $(tStop)), skipping."
            return nothing 
        end
    else
        return nothing
    end

end

# Returns the event indicators for an FMU.
function condition(c::FMU2Component, out, x, t, integrator, inputFunction) 

    @assert c.state == fmi2ComponentStateContinuousTimeMode "condition(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE

    indicators!(c, out, x, t, inputFunction)

    return nothing
end

# Handles the upcoming events.
# Sets a new state for the solver from the FMU (if needed).
function affectFMU!(c::FMU2Component, integrator, idx, inputFunction, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "affectFMU!(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE

    c.solution.evals_affect += 1

    # there are fx-evaluations before the event is handled, reset the FMU state to the current integrator step
    fx_set(c, integrator.u, integrator.t, inputFunction; force=true)

    fmi2EnterEventMode(c)

    # Event found - handle it
    handleEvents(c)

    left_x = nothing 
    right_x = nothing

    if c.eventInfo.valuesOfContinuousStatesChanged == fmi2True
        left_x = integrator.u
        right_x = fmi2GetContinuousStates(c)
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), new state is $(right_x)"
        integrator.u = right_x

        u_modified!(integrator, true)
    else 
        u_modified!(integrator, false)
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), no new state."
    end

    if c.eventInfo.nominalsOfContinuousStatesChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end

    ignore_derivatives() do 
        if idx != -1 # -1 no event, 0, time event, >=1 state event with indicator
            e = FMU2Event(integrator.t, UInt64(idx), left_x, right_x)
            push!(solution.events, e)
        end
    end 

    #fmi2EnterContinuousTimeMode(c)
end

# This callback is called every time the integrator finishes an (accpeted) integration step.
function stepCompleted(c::FMU2Component, x, t, integrator, inputFunction, progressMeter, tStart, tStop, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "stepCompleted(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE
    
    c.solution.evals_stepcompleted += 1

    if progressMeter !== nothing
        stat = 1000.0*(t-tStart)/(tStop-tStart)
        if !isnan(stat)
            stat = floor(Integer, stat)
            ProgressMeter.update!(progressMeter, stat)
        end
    end

    (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
    
    if terminateSimulation == fmi2True
        @error "stepCompleted(...): FMU requested termination!"
    end

    if enterEventMode == fmi2True
        affectFMU!(c, integrator, -1, inputFunction, solution)
    else
        if !isnothing(inputFunction)
            u = eval!(inputFunction, c, x, t)
            u_refs = inputFunction.vrs
            fmi2SetReal(c, u_refs, u)
        end
    end
end

# save FMU values 
function saveValues(c::FMU2Component, recordValues, x, t, integrator, inputFunction)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveValues(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE

    c.solution.evals_savevalues += 1

    fx_set(c, x, t, inputFunction)
    
    # ToDo: Replace by inplace statement!
    return (fmiGet(c, recordValues)...,)
end

function saveEventIndicators(c::FMU2Component, recordEventIndicators, x, t, integrator, inputFunction)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveEventIndicators(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE

    c.solution.evals_saveeventindicators += 1

    out = zeros(fmi2Real, c.fmu.modelDescription.numberOfEventIndicators)
    condition!(c, out, x, t, inputFunction)

    # ToDo: Replace by inplace statement!
    return (out[recordEventIndicators]...,)
end

function saveEigenvalues(c::FMU2Component, x, t, integrator, inputFunction)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveEigenvalues(...):\n" * FMICore.ERR_MSG_CONT_TIME_MODE

    c.solution.evals_saveeigenvalues += 1

    fx_set(c, x, t, inputFunction)

    # ToDo: Replace this by an directional derivative call!
    A = ReverseDiff.jacobian(_x -> FMI.fx(c, _x, [], t), x)
    eigs = eigvals(A)

    vals = []
    for e in eigs 
        push!(vals, real(e))
        push!(vals, imag(e))
    end
    
    # ToDo: Replace by inplace statement!
    return (vals...,)
end

function fx(c::FMU2Component, 
    dx::AbstractArray{<:Real},
    x::AbstractArray{<:Real}, 
    p::Tuple,
    t::Real,
    inputFunction::Union{Nothing, FMU2InputFunction})

    c.solution.evals_fx_inplace += 1

    u = EMPTY_fmi2Real
    u_refs = EMPTY_fmi2ValueReference
    if !isnothing(inputFunction)
        u = eval!(inputFunction, c, x, t)
        u_refs = inputFunction.vrs
    end

    # for zero state FMUs, don't request a `dx`
    if c.fmu.isZeroState
        c(;x=x, u=u, u_refs=u_refs, t=t)
    else
        c(;dx=dx, x=x, u=u, u_refs=u_refs, t=t)
    end
    
    return nothing
end

function fx(c::FMU2Component, 
    x::AbstractArray{<:Real}, 
    p::Tuple,
    t::Real,
    inputFunction::Union{Nothing, FMU2InputFunction})

    c.solution.evals_fx_outofplace += 1

    dx = zeros(fmi2Real, length(x))

    fx(c, dx, x, p, t)
    c.solution.evals_fx_inplace -= 1 # correct statisitics, because fx-call above -> this was in fact an out-of-place evaluation

    return dx
end

function fx_set(c::FMU2Component, 
    x::AbstractArray{<:Real}, 
    t::Real,
    inputFunction::Union{Nothing, FMU2InputFunction}; force::Bool=false)

    u = EMPTY_fmi2Real
    u_refs = EMPTY_fmi2ValueReference
    if !isnothing(inputFunction)
        u = eval!(inputFunction, c, x, t)
        u_refs = inputFunction.vrs
    end

    oldForce = c.force
    c.force = force
    c(;x=x, u=u, u_refs=u_refs, t=t)
    c.force = oldForce

    return nothing
end

function indicators!(c::FMU2Component, 
    ec,
    x::AbstractArray{<:Real}, 
    t::Real,
    inputFunction::Union{Nothing, FMU2InputFunction})

    c.solution.evals_condition += 1

    u = EMPTY_fmi2Real
    u_refs = EMPTY_fmi2ValueReference
    if !isnothing(inputFunction)
        u = eval!(inputFunction, c, x, t)
        u_refs = inputFunction.vrs
    end

    c(;x=x, u=u, u_refs=u_refs, t=t, ec=ec)
    
    return nothing
end

# wrapper
function fmi2SimulateME(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)
    fmi2SimulateME(c.fmu, c, tspan; kwargs...)
end 

# sets up the ODEProblem for simulating a ME-FMU
function setupODEProblem(c::FMU2Component, x0::AbstractArray{fmi2Real}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; p=(), customFx=nothing, inputFunction::Union{FMU2InputFunction, Nothing}=nothing)
    
    if customFx === nothing
        customFx = (dx, x, p, t) -> fx(c, dx, x, p, t, inputFunction)
    end

    ff = ODEFunction{true}(customFx, 
                            tgrad=nothing)
    c.problem = ODEProblem{true}(ff, x0, tspan, p)

    return c.problem
end

"""
ToDo: Update DocString

Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Via the optional keyword arguemnts `inputValues` and `inputFunction`, a custom input function `f(c, u, t)`, `f(c, t)`, `f(u, t)`, `f(c, u)` or `f(t)` with `c` current component, `u` current state and `t` current time can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(...))`.

Keywords:
    - solver: Any Julia-supported ODE-solver (default is the DifferentialEquations.jl default solver, currently `AutoTsit5(Rosenbrock23())`)
    - customFx: [deprecated] Ability to give a custom state derivative function ẋ=f(x,t)
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - recordEventIndicators: Array or Range of event indicators (identified by integers) to record
    - recordEigenvalues: Boolean value, if eigenvalues shall be computed and recorded
    - saveat: Time points to save values at (interpolated)
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Union{Bool, :auto}, if FMU should be reset before simulation (default reset=:auto)
    - inputValueReferences: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - parameters: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization 
    - `callbacks`: custom callbacks to add

Returns:
    - `FMU2Solution` containing simulations results and statisitics
"""
function fmi2SimulateME(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    solver = nothing,
    customFx = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    recordEventIndicators::Union{AbstractArray{<:Integer, 1}, UnitRange{<:Integer}, Nothing} = nothing,
    recordEigenvalues::Bool=false,
    saveat = nothing,
    x0::Union{AbstractArray{<:Real}, Nothing} = nothing,
    setup::Union{Bool, Nothing} = nothing,
    reset::Union{Bool, Nothing} = nothing,
    instantiate::Union{Bool, Nothing} = nothing,
    freeInstance::Union{Bool, Nothing} = nothing,
    terminate::Union{Bool, Nothing} = nothing,
    inputValueReferences::fmi2ValueReferenceFormat = nothing,
    inputFunction = nothing,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
    dtmax::Union{Real, Nothing} = nothing,
    callbacksBefore = [],
    callbacksAfter = [],
    showProgress::Bool = true,
    kwargs...)

    @assert fmi2IsModelExchange(fmu) "fmi2SimulateME(...): This function supports Model Excahnge FMUs only."
    #@assert fmu.type == fmi2TypeModelExchange "fmi2SimulateME(...): This FMU supports Model Exchange, but was instantiated in CS mode. Use `fmiLoad(...; type=:ME)`."

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    
    savingValues = (length(recordValues) > 0)
    savingEventIndicators = !isnothing(recordEventIndicators) 
    hasInputs = (length(inputValueReferences) > 0)
    hasParameters = (parameters !== nothing)
    hasStartState = (x0 !== nothing)

    t_start, t_stop = (tspan == nothing ? (nothing, nothing) : tspan)

    cbs = []

    for cb in callbacksBefore
        push!(cbs, cb)
    end

    if t_start === nothing 
        t_start = fmi2GetDefaultStartTime(fmu.modelDescription)
        
        if t_start === nothing 
            t_start = 0.0
            @info "No `t_start` choosen, no `t_start` availabel in the FMU, auto-picked `t_start=0.0`."
        end
    end
    
    if t_stop === nothing 
        t_stop = fmi2GetDefaultStopTime(fmu.modelDescription)

        if t_stop === nothing
            t_stop = 1.0
            @warn "No `t_stop` choosen, no `t_stop` availabel in the FMU, auto-picked `t_stop=1.0`."
        end
    end

    if tolerance === nothing 
        tolerance = fmi2GetDefaultTolerance(fmu.modelDescription)
        # if no tolerance is given, pick auto-setting from DifferentialEquations.jl 
    end

    if dt === nothing 
        dt = fmi2GetDefaultStepSize(fmu.modelDescription)
        # if no dt is given, pick auto-setting from DifferentialEquations.jl
    end

    if dtmax === nothing
        dtmax = (t_stop-t_start)/100.0
    end

    # input function handling 
    _inputFunction = nothing
    if inputFunction != nothing
        _inputFunction = FMU2InputFunction(inputFunction, inputValueReferences)
    end

    # argument `tolerance=nothing` here, because ME-FMUs doesn't support tolerance control (no solver included)
    # tolerance for the solver is set-up later in this function
    inputs = nothing
    if hasInputs
        inputValues = eval!(_inputFunction, nothing, nothing, t_start)
        inputs = Dict(inputValueReferences .=> inputValues)
    end

    c, x0 = prepareSolveFMU(fmu, c, fmi2TypeModelExchange, instantiate, freeInstance, terminate, reset, setup, parameters, t_start, t_stop, nothing; x0=x0, inputs=inputs, handleEvents=FMI.handleEvents)
    fmusol = c.solution

    # Zero state FMU: add dummy state
    if c.fmu.isZeroState
        x0 = [0.0]
    end

    # from here on, we are in event mode, if `setup=false` this is the job of the user
    #@assert c.state == fmi2ComponentStateEventMode "FMU needs to be in event mode after setup."

    # if x0 === nothing
    #     x0 = fmi2GetContinuousStates(c)
    #     x0_nom = fmi2GetNominalsOfContinuousStates(c)
    # end

    # initial event handling
    #handleEvents(c) 
    #fmi2EnterContinuousTimeMode(c)

    c.fmu.hasStateEvents = (c.fmu.modelDescription.numberOfEventIndicators > 0)
    c.fmu.hasTimeEvents = (c.eventInfo.nextEventTimeDefined == fmi2True)
    
    setupODEProblem(c, x0, (t_start, t_stop); customFx=customFx, inputFunction=_inputFunction)

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating ME-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    # callback functions

    if c.fmu.hasTimeEvents && c.fmu.executionConfig.handleTimeEvents
        timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator, t_start, t_stop),
                                        (integrator) -> affectFMU!(c, integrator, 0, _inputFunction, fmusol), Float64; 
                                        initial_affect = (c.eventInfo.nextEventTime == t_start),
                                        save_positions=(false,false))
        push!(cbs, timeEventCb)
    end

    if c.fmu.hasStateEvents && c.fmu.executionConfig.handleStateEvents

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, _inputFunction),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, _inputFunction, fmusol),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(false,false),
                                           interp_points=fmu.executionConfig.rootSearchInterpolationPoints)
        push!(cbs, eventCb)
    end

    # use step callback always if we have inputs or need event handling (or just want to see our simulation progress)
    if hasInputs || c.fmu.hasStateEvents || c.fmu.hasTimeEvents || showProgress
        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, _inputFunction, progressMeter, t_start, t_stop, fmusol);
                                            func_everystep = true,
                                            func_start = true)
        push!(cbs, stepCb)
    end

    if savingValues 
        dtypes = collect(fmi2DataTypeForValueReference(c.fmu.modelDescription, vr) for vr in recordValues)
        fmusol.values = SavedValues(fmi2Real, Tuple{dtypes...})
        fmusol.valueReferences = copy(recordValues)

        savingCB = nothing
        if saveat === nothing
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction), 
                                    fmusol.values)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction), 
                                    fmusol.values, 
                                    saveat=saveat)
        end

        push!(cbs, savingCB)
    end

    if savingEventIndicators
        dtypes = collect(fmi2Real for ei in recordEventIndicators)
        fmusol.eventIndicators = SavedValues(fmi2Real, Tuple{dtypes...})
        fmusol.recordEventIndicators = copy(recordEventIndicators)

        savingCB = nothing
        if saveat === nothing
            savingCB = SavingCallback((u,t,integrator) -> saveEventIndicators(c, recordEventIndicators, u, t, integrator, _inputFunction), 
                                    fmusol.eventIndicators)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveEventIndicators(c, recordEventIndicators, u, t, integrator, _inputFunction), 
                                    fmusol.eventIndicators, 
                                    saveat=saveat)
        end

        push!(cbs, savingCB)
    end

    if recordEigenvalues
        dtypes = collect(Float64 for _ in 1:2*length(c.fmu.modelDescription.stateValueReferences))
        fmusol.eigenvalues = SavedValues(fmi2Real, Tuple{dtypes...})
        
        savingCB = nothing
        if saveat === nothing
            savingCB = SavingCallback((u,t,integrator) -> saveEigenvalues(c, u, t, integrator, _inputFunction), 
                                    fmusol.eigenvalues)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveEigenvalues(c, u, t, integrator, _inputFunction), 
                                    fmusol.eigenvalues, 
                                    saveat=saveat)
        end

        push!(cbs, savingCB)
    end

    for cb in callbacksAfter
        push!(cbs, cb)
    end

    # if auto_dt == true
    #     @assert solver !== nothing "fmi2SimulateME(...): `auto_dt=true` but no solver specified, this is not allowed."
    #     tmpIntegrator = init(c.problem, solver)
    #     dt = auto_dt_reset!(tmpIntegrator)
    # end

    solveKwargs = Dict{Symbol, Any}()

    if dt !== nothing
        solveKwargs[:dt] = dt
    end

    if tolerance !== nothing
        solveKwargs[:reltol] = tolerance
    end

    if saveat !== nothing
        solveKwargs[:saveat] = saveat
    end

    if isnothing(solver)
        fmusol.states = solve(c.problem; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    else
        fmusol.states = solve(c.problem, solver; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    end

    fmusol.success = (fmusol.states.retcode == ReturnCode.Success)
    
    if !fmusol.success
        @warn "FMU simulation failed with solver return code `$(fmusol.states.retcode)`, please check log for hints."
    end

    # ZeroStateFMU: remove dummy state
    if c.fmu.isZeroState
        c.solution.states = nothing
    end

    # cleanup progress meter
    if showProgress 
        ProgressMeter.finish!(progressMeter)
    end

    finishSolveFMU(fmu, c, freeInstance, terminate)

    return fmusol
end

# function fmi2SimulateME(fmu::FMU2, 
#     c::Union{AbstractArray{<:Union{FMU2Component, Nothing}}, Nothing}=nothing, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
#     x0::Union{AbstractArray{<:AbstractArray{<:Real}}, AbstractArray{<:Real}, Nothing} = nothing,
#     parameters::Union{AbstractArray{<:Dict{<:Any, <:Any}}, Dict{<:Any, <:Any}, Nothing} = nothing,
#     kwargs...)

#     return ThreadPool.foreach((c, x0, parameters) -> fmi2SimulateME(fmu, c; x0=x0, parameters=parameters, kwargs...), zip()) 
# end

# wrapper
function fmi2SimulateCS(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)
    fmi2SimulateCS(c.fmu, c, tspan; kwargs...)
end 

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.

Via the optional keyword arguments `inputValues` and `inputFunction`, a custom input function `f(c, t)` or `f(t)` with time `t` and component `c` can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(...))`.

Keywords:
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - saveat: Time points to save values at (interpolated)
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Boolean, if FMU should be reset before simulation (default reset=setup)
    - inputValueReferences: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - parameters: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization 
Returns:
    - If keyword `recordValues` is not set, a boolean `success` is returned (simulation success).
    - If keyword `recordValues` is set, a tuple of type (true, DiffEqCallbacks.SavedValues) or (false, nothing).
"""
function fmi2SimulateCS(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
                        tolerance::Union{Real, Nothing} = nothing,
                        dt::Union{Real, Nothing} = nothing,
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup::Union{Bool, Nothing} = nothing,
                        reset::Union{Bool, Nothing} = nothing,
                        instantiate::Union{Bool, Nothing} = nothing,
                        freeInstance::Union{Bool, Nothing} = nothing,
                        terminate::Union{Bool, Nothing} = nothing,
                        inputValueReferences::fmi2ValueReferenceFormat = nothing,
                        inputFunction = nothing,
                        showProgress::Bool=true,
                        parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing)

    @assert fmi2IsCoSimulation(fmu) "fmi2SimulateCS(...): This function supports Co-Simulation FMUs only."
    #@assert fmu.type == fmi2TypeCoSimulation "fmi2SimulateCS(...): This FMU supports Co-Simulation, but was instantiated in ME mode. Use `fmiLoad(...; type=:CS)`."

    # input function handling 
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = (length(inputValueReferences) > 0)

    _inputFunction = nothing
    u = EMPTY_fmi2Real
    u_refs = EMPTY_fmi2ValueReference
    if hasInputs
        _inputFunction = FMU2InputFunction(inputFunction, inputValueReferences)
        u_refs = _inputFunction.vrs
    end

    # outputs 
    y_refs = EMPTY_fmi2ValueReference
    y = EMPTY_fmi2Real
    if !isnothing(recordValues)
        y_refs = prepareValueReference(fmu, recordValues)
        y = zeros(fmi2Real, length(y_refs))
    end
    

    t_start, t_stop = (tspan == nothing ? (nothing, nothing) : tspan)
    
    # pull default values from the model description - if not given by user
    variableSteps = fmi2IsCoSimulation(fmu) && fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize 
    t_start = t_start === nothing ? fmi2GetDefaultStartTime(fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start
    t_stop = t_stop === nothing ? fmi2GetDefaultStopTime(fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop
    tolerance = tolerance === nothing ? fmi2GetDefaultTolerance(fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 0.0 : tolerance
    dt = dt === nothing ? fmi2GetDefaultStepSize(fmu.modelDescription) : dt
    dt = dt === nothing ? 1e-3 : dt

    inputs = nothing
    if hasInputs
        inputValues = eval!(_inputFunction, nothing, nothing, t_start)
        inputs = Dict(inputValueReferences .=> inputValues)
    end
    c, _ = prepareSolveFMU(fmu, c, fmi2TypeCoSimulation, instantiate, freeInstance, terminate, reset, setup, parameters, t_start, t_stop, tolerance; inputs=inputs)
    fmusol = c.solution

    # default setup
    if length(saveat) == 0
        saveat = t_start:dt:t_stop
    end

    # setup if no variable steps
    if variableSteps == false 
        if length(saveat) >= 2 
            dt = saveat[2] - saveat[1]
        end
    end

    t = t_start

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating CS-FMU ...", color=:blue, dt=1.0) 
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    first_step = true

    fmusol.values = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(y_refs))...} )
    fmusol.valueReferences = copy(y_refs)

    i = 1

    while t < t_stop
        if variableSteps
            if length(saveat) > (i+1)
                dt = saveat[i+1] - saveat[i]
            else 
                dt = t_stop - t
            end
        end

        if !first_step
            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1
        else
            first_step = false
        end

        if hasInputs
            u = eval!(_inputFunction, c, nothing, t)
        end

        c(u=u, u_refs=u_refs, y=y, y_refs=y_refs)

        svalues = (y...,)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.t, i, t)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.saveval, i, svalues, Val{false})

        if progressMeter !== nothing 
            ProgressMeter.update!(progressMeter, floor(Integer, 1000.0*(t-t_start)/(t_stop-t_start)) )
        end
    end

    if progressMeter !== nothing 
        ProgressMeter.finish!(progressMeter)
    end

    fmusol.success = true # ToDo: Check successful simulation!

    finishSolveFMU(fmu, c, freeInstance, terminate)

    return fmusol
end

##### CS & ME #####

# wrapper
function fmi2Simulate(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)
    fmi2Simulate(c.fmu, c, tspan; kwargs...)
end 

# function (c::FMU2Component)(; t::Tuple{Float64, Float64}, kwargs...)
#     fmi2Simulate(c, t; kwargs...)
# end

# function (f::FMU2)(; t::Tuple{Float64, Float64}, kwargs...)
#     fmi2Simulate(c.fmu, t; kwargs...)
# end

"""
Starts a simulation of the FMU instance for the matching FMU type, if both types are available, CS is preferred.

Keywords:
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Boolean, if FMU should be reset before simulation (default reset=setup)
    - inputValues: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - saveat: [ME only] Time points to save values at (interpolated)
    - solver: [ME only] Any Julia-supported ODE-solver (default is default from DifferentialEquations.jl)
    - customFx: [ME only, deprecated] Ability to give a custom state derivative function ẋ=f(x,t)

Returns:
    - `success::Bool` for CS-FMUs
    - `ODESolution` for ME-FMUs
    - if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs
    - if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
"""
function fmi2Simulate(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)

    if fmu.type == fmi2TypeCoSimulation
        return fmi2SimulateCS(fmu, c, tspan; kwargs...)
    elseif fmu.type == fmi2TypeModelExchange
        return fmi2SimulateME(fmu, c, tspan; kwargs...)
    else
        error(unknownFMUType)
    end
end
