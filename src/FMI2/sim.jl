#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks
import FMIImport.SciMLSensitivity.SciMLBase: RightRootFind, ReturnCode

using FMIImport: fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2NewDiscreteStates, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates, fmi2SetContinuousStates, fmi2GetDerivatives!
using FMIImport.FMICore: fmi2StatusOK, fmi2TypeCoSimulation, fmi2TypeModelExchange
using FMIImport.FMICore: fmi2ComponentState, fmi2ComponentStateInstantiated, fmi2ComponentStateInitializationMode, fmi2ComponentStateEventMode, fmi2ComponentStateContinuousTimeMode, fmi2ComponentStateTerminated, fmi2ComponentStateError, fmi2ComponentStateFatal
using FMIImport: FMU2Solution, FMU2Event

import FMIImport: prepareSolveFMU, finishSolveFMU, handleEvents
import FMIImport: undual

using FMIImport.ChainRulesCore

import FMIImport.ReverseDiff 
import LinearAlgebra: eigvals

import ProgressMeter
import ThreadPools

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
function condition(c::FMU2Component, out::AbstractArray{<:Real}, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi2ValueReference}) 

    @assert c.state == fmi2ComponentStateContinuousTimeMode "condition(...): Must be called in mode continuous time."

    c.solution.evals_condition += 1

    t = undual(t)
    x = undual(x)

    fmi2SetContinuousStates(c, x)
    fmi2SetTime(c, t)
    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end
    fmi2GetEventIndicators!(c, out)

    return nothing
end

# Handles the upcoming events.
# Sets a new state for the solver from the FMU (if needed).
function affectFMU!(c::FMU2Component, integrator, idx, inputFunction, inputValues::AbstractArray{fmi2ValueReference}, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "affectFMU!(...): Must be in continuous time mode!"

    c.solution.evals_affect += 1

    # there are fx-evaluations before the event is handled, reset the FMU state to the current integrator step
    fmi2SetContinuousStates(c, integrator.u; force=true)
    fmi2SetTime(c, integrator.t; force=true)
    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(c, integrator.u, integrator.t))
    end

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
function stepCompleted(c::FMU2Component, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi2ValueReference}, progressMeter, tStart, tStop, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "stepCompleted(...): Must be in continuous time mode."
    #@info "Step completed"

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
        affectFMU!(c, integrator, -1, inputFunction, inputValues, solution)
    else
        if inputFunction != nothing
            fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
        end
    end
end

# save FMU values 
function saveValues(c::FMU2Component, recordValues, x, t, integrator, inputFunction, inputValues)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveValues(...): Must be in continuous time mode."

    c.solution.evals_savevalues += 1

    #x_old = fmi2GetContinuousStates(c)
    #t_old = c.t
    
    if !c.fmu.isZeroState
        fmi2SetContinuousStates(c, x)
    end
    fmi2SetTime(c, t) 
    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end

    #fmi2SetContinuousStates(c, x_old)
    #fmi2SetTime(c, t_old)
    
    return (fmiGet(c, recordValues)...,)
end

function saveEventIndicators(c::FMU2Component, recordEventIndicators, x, t, integrator, inputFunction, inputValues)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveEventIndicators(...): Must be in continuous time mode."

    c.solution.evals_saveeventindicators += 1

    #x_old = fmi2GetContinuousStates(c)
    #t_old = c.t
    
    if !c.fmu.isZeroState
        fmi2SetContinuousStates(c, x)
    end
    fmi2SetTime(c, t) 
    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end

    #fmi2SetContinuousStates(c, x_old)
    #fmi2SetTime(c, t_old)

    out = zeros(fmi2Real, c.fmu.modelDescription.numberOfEventIndicators)
    fmi2GetEventIndicators!(c, out)
    
    return (out[recordEventIndicators]...,)
end

function saveEigenvalues(c::FMU2Component, x, t, integrator, inputFunction, inputValues)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveEigenvalues(...): Must be in continuous time mode."

    c.solution.evals_saveeigenvalues += 1

    #x_old = fmi2GetContinuousStates(c)
    #t_old = c.t
    
    if !c.fmu.isZeroState
        fmi2SetContinuousStates(c, x)
    end
    fmi2SetTime(c, t) 
    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end

    #fmi2SetContinuousStates(c, x_old)
    #fmi2SetTime(c, t_old)

    A = ReverseDiff.jacobian(_x -> FMI.fx(c, _x, [], t), x)
    eigs = eigvals(A)

    vals = []
    for e in eigs 
        push!(vals, real(e))
        push!(vals, imag(e))
    end
    
    return (vals...,)
end

function fx(c::FMU2Component, 
    dx::AbstractArray{<:Real},
    x::AbstractArray{<:Real}, 
    p::AbstractArray, 
    t::Real)

    c.solution.evals_fx_inplace += 1

    if c.fmu.executionConfig.concat_y_dx
        dx[:] = c(;dx=dx, x=x, t=t)
    else
        _, dx[:] = c(;dx=dx, x=x, t=t)
    end

    return dx
end

function fx(c::FMU2Component, 
    x::AbstractArray{<:Real}, 
    p::AbstractArray, 
    t::Real)

    c.solution.evals_fx_outofplace += 1

    dx = nothing

    if c.fmu.executionConfig.concat_y_dx
        dx = c(;x=x, t=t)
    else
        _, dx = c(;x=x, t=t)
    end

    return dx
end

"""
    fmi2SimulateME(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)

Wrapper for `fmi2SimulateME(fmu::FMU2, c::Union{FMU2Component, Nothing}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)` without a provided FMU2.
(FMU2 `fmu` is taken from `c`)
"""
function fmi2SimulateME(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)
    fmi2SimulateME(c.fmu, c, tspan; kwargs...)
end 

# sets up the ODEProblem for simulating a ME-FMU
function setupODEProblem(c::FMU2Component, x0::AbstractArray{fmi2Real}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; p=[], customFx=nothing)
    
    p = []
    
    if c.fmu.executionConfig.inPlace
        if customFx === nothing
            customFx = (dx, x, p, t) -> fx(c, dx, x, p, t)
        end

        ff = ODEFunction{true}(customFx, 
                               tgrad=nothing)
        c.problem = ODEProblem{true}(ff, x0, tspan, p)
    else 
        if customFx === nothing
            customFx = (x, p, t) -> fx(c, x, p, t)
        end

        ff = ODEFunction{false}(customFx, 
                               tgrad=nothing)
        c.problem = ODEProblem{false}(ff, x0, tspan, p)
    end

    return c.problem
end

"""
    fmi2SimulateME(fmu::FMU2, 
                c::Union{FMU2Component, Nothing}=nothing, 
                tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
                [tolerance::Union{Real, Nothing} = nothing,
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
                kwargs...])

Simulate ME-FMU for the given simulation time interval.

State- and Time-Events are handled correctly.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances.
- `c::Union{FMU2Component, Nothing}=nothing`: Mutable struct representing an instantiated instance of a FMU.
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from `fmu`'s model description or (0.0, 1.0))

- `tolerance::Union{Real, Nothing} = nothing`: tolerance for the solver (default = nothing: use default value from `fmu`'s model description or -if not available- default from DifferentialEquations.jl)
- `dt::Union{Real, Nothing} = nothing`: stepszie for the solver (default = nothing: use default value from `fmu`'s model description or -if not available- default from DifferentialEquations.jl)
- `solver = nothing`: Any Julia-supported ODE-solver (default = nothing: use DifferentialEquations.jl default solver)
- `customFx`: [deprecated] custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat` = nothing: Array of variables (Strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `recordEventIndicators::Union{AbstractArray{<:Integer, 1}, UnitRange{<:Integer}, Nothing} = nothing`: Array or Range of event indicators to record
- `recordEigenvalues::Bool=false`: compute and record eigenvalues
- `saveat = nothing`: Time points to save (interpolated) values at (default = nothing: save at each solver timestep)
- `x0::Union{AbstractArray{<:Real}, Nothing} = nothing`: inital fmu State (default = nothing: use current or default-inital fmu state)
- `setup::Union{Bool, Nothing} = nothing`: call fmi2SetupExperiment, fmi2EnterInitializationMode and fmi2ExitInitializationMode before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `reset::Union{Bool, Nothing} = nothing`: call fmi2Reset before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `instantiate::Union{Bool, Nothing} = nothing`: call fmi2Instantiate! before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `freeInstance::Union{Bool, Nothing} = nothing`: call fmi2FreeInstance after each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `terminate::Union{Bool, Nothing} = nothing`: call fmi2Terminate after each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Input variables (Strings or variableIdentifiers) to set at each simulation step 
- `inputFunction = nothing`: Function to get values for the input variables at each simulation step. 
    
    ## Pattern [`c`: current component, `u`: current state ,`t`: current time, returning array of values to be passed to `fmi2SetReal(..., inputValueReferences, inputFunction(...))`]:
    - `inputFunction(t::fmi2Real)`
    - `inputFunction(c::FMU2Component, t::fmi2Real)`
    - `inputFunction(c::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing})`
    - `inputFunction(u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`
    - `inputFunction(c::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`

- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dict of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: sets the maximum stepszie for the solver (default = nothing: use `(Simulation-time-span-length)/100.0`)
- `callbacksBefore = [], callbacksAfter = []`: functions that are to be called before and after internal time-event-, state-event- and step-event-callbacks are called
- `showProgress::Bool = true`: print simulation progressmeter in REPL
- `kwargs...`: keyword arguments that get passed onto the solvers solve call

# Returns:
- If keyword `recordValues` has value `nothing`, a struct of type `ODESolution`.
- If keyword `recordValues` is set, a tuple of type `(ODESolution, DiffEqCallbacks.SavedValues)`.

See also [`fmi2Simulate`](@ref), [`fmi2SimulateCS`](@ref).
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

    # input function handling 
    _inputFunction = nothing
    if inputFunction != nothing
        if hasmethod(inputFunction, Tuple{fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(t)
        elseif hasmethod(inputFunction, Tuple{Union{FMU2Component, Nothing}, fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(c, t)
        elseif hasmethod(inputFunction, Tuple{Union{FMU2Component, Nothing}, AbstractArray{fmi2Real,1}})
            _inputFunction = (c, u, t) -> inputFunction(c, u)
        elseif hasmethod(inputFunction, Tuple{AbstractArray{fmi2Real,1}, fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(u, t)
        else 
            _inputFunction = inputFunction
        end
        @assert hasmethod(_inputFunction, Tuple{FMU2Component, Union{AbstractArray{fmi2Real,1}, Nothing}, fmi2Real}) "The given input function does not fit the needed input function pattern for ME-FMUs, which are: \n- `inputFunction(t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing})`\n- `inputFunction(u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`"
    end

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

    # argument `tolerance=nothing` here, because ME-FMUs doesn't support tolerance control (no solver included)
    # tolerance for the solver is set-up later in this function
    inputs = nothing
    if hasInputs
        inputValueReferences
        inputValues = _inputFunction(nothing, nothing, t_start)
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
    
    setupODEProblem(c, x0, (t_start, t_stop); customFx=customFx)

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating ME-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    # callback functions

    if c.fmu.hasTimeEvents && c.fmu.executionConfig.handleTimeEvents
        timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator, t_start, t_stop),
                                        (integrator) -> affectFMU!(c, integrator, 0, _inputFunction, inputValueReferences, fmusol), Float64; 
                                        initial_affect = (c.eventInfo.nextEventTime == t_start),
                                        save_positions=(false,false))
        push!(cbs, timeEventCb)
    end

    if c.fmu.hasStateEvents && c.fmu.executionConfig.handleStateEvents

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, _inputFunction, inputValueReferences),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, _inputFunction, inputValueReferences, fmusol),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(false,false),
                                           interp_points=fmu.executionConfig.rootSearchInterpolationPoints)
        push!(cbs, eventCb)
    end

    # use step callback always if we have inputs or need event handling (or just want to see our simulation progress)
    if hasInputs || c.fmu.hasStateEvents || c.fmu.hasTimeEvents || showProgress
        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, _inputFunction, inputValueReferences, progressMeter, t_start, t_stop, fmusol);
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
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction, inputValueReferences), 
                                    fmusol.values)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction, inputValueReferences), 
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
            savingCB = SavingCallback((u,t,integrator) -> saveEventIndicators(c, recordEventIndicators, u, t, integrator, _inputFunction, inputValueReferences), 
                                    fmusol.eventIndicators)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveEventIndicators(c, recordEventIndicators, u, t, integrator, _inputFunction, inputValueReferences), 
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
            savingCB = SavingCallback((u,t,integrator) -> saveEigenvalues(c, u, t, integrator, _inputFunction, inputValueReferences), 
                                    fmusol.eigenvalues)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveEigenvalues(c, u, t, integrator, _inputFunction, inputValueReferences), 
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

export fmi2SimulateME

# function fmi2SimulateME(fmu::FMU2, 
#     c::Union{AbstractArray{<:Union{FMU2Component, Nothing}}, Nothing}=nothing, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
#     x0::Union{AbstractArray{<:AbstractArray{<:Real}}, AbstractArray{<:Real}, Nothing} = nothing,
#     parameters::Union{AbstractArray{<:Dict{<:Any, <:Any}}, Dict{<:Any, <:Any}, Nothing} = nothing,
#     kwargs...)

#     return ThreadPool.foreach((c, x0, parameters) -> fmi2SimulateME(fmu, c; x0=x0, parameters=parameters, kwargs...), zip()) 
# end

############ Co-Simulation ############

"""
    fmi2SimulateCS(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)

Wrapper for `fmi2SimulateCS(fmu::FMU2, c::Union{FMU2Component, Nothing}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)` without a provided FMU2.
(FMU2 `fmu` is taken from `c`)
"""
function fmi2SimulateCS(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)
    fmi2SimulateCS(c.fmu, c, tspan; kwargs...)
end 

"""
    fmi2SimulateCS(fmu::FMU2, 
                c::Union{FMU2Component, Nothing}=nothing, 
                tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
                [tolerance::Union{Real, Nothing} = nothing,
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
                parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing])

Simulate CS-FMU for the given simulation time interval.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances.
- `c::Union{FMU2Component, Nothing}=nothing`: Mutable struct representing an instantiated instance of a FMU.
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from `fmu`'s model description or (0.0, 1.0))

- `tolerance::Union{Real, Nothing} = nothing`: tolerance for the solver (default = nothing: use default value from `fmu`'s model description or 0.0)
- `dt::Union{Real, Nothing} = nothing`: stepszie for the solver (default = nothing: use default value from `fmu`'s model description or 1e-3)
- `recordValues::fmi2ValueReferenceFormat` = nothing: Array of variables (Strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = nothing`: Time points to save values at (default = nothing: save at each communication timestep)
- `setup::Union{Bool, Nothing} = nothing`: call fmi2SetupExperiment, fmi2EnterInitializationMode and fmi2ExitInitializationMode before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `reset::Union{Bool, Nothing} = nothing`: call fmi2Reset before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `instantiate::Union{Bool, Nothing} = nothing`: call fmi2Reset before each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `freeInstance::Union{Bool, Nothing} = nothing`: call fmi2FreeInstance after each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `terminate::Union{Bool, Nothing} = nothing`: call fmi2Terminate after each step (default = nothing: use value from `fmu`'s `FMU2ExecutionConfiguration`)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Input variables (Strings or variableIdentifiers) to set at each communication step 
- `inputFunction = nothing`: Function to get values for the input variables at each communication step. 
    
    ## Pattern [`c`: current component, `t`: current time, returning array of values to be passed to `fmi2SetReal(..., inputValueReferences, inputFunction(...))`]:
    - `inputFunction(t::fmi2Real)`
    - `inputFunction(c::FMU2Component, t::fmi2Real)`

- `showProgress::Bool = true`: print simulation progressmeter in REPL
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dict of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization

# Returns:
- `fmusol::FMU2Solution`, containing bool `fmusol.success` and if keyword `recordValues` is set, the saved values as `fmusol.values`.

See also [`fmi2Simulate`](@ref), [`fmi2SimulateME`](@ref).
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
    _inputFunction = nothing
    if inputFunction != nothing
        if hasmethod(inputFunction, Tuple{fmi2Real})
            _inputFunction = (c, t) -> inputFunction(t)
        else 
            _inputFunction = inputFunction
        end
        @assert hasmethod(_inputFunction, Tuple{FMU2Component, fmi2Real}) "The given input function does not fit the needed input function pattern for CS-FMUs, which are: \n- `inputFunction(t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, t::fmi2Real)`"
    end

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = (length(inputValueReferences) > 0)

    t_start, t_stop = (tspan == nothing ? (nothing, nothing) : tspan)
    
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
        inputValueReferences
        inputValues = _inputFunction(c, t_start)
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

    record = length(recordValues) > 0

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating CS-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    if record
        fmusol.values = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...} )
        fmusol.valueReferences = copy(recordValues)

        i = 1

        svalues = (fmi2GetReal(c, recordValues)...,)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.t, i, t)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.saveval, i, svalues, Val{false})

        while t < t_stop
            if variableSteps
                if length(saveat) > i
                    dt = saveat[i+1] - saveat[i]
                else 
                    dt = t_stop - saveat[i]
                end
            end

            if _inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, _inputFunction(c, t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1

            svalues = (fmi2GetReal(c, recordValues)...,)
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

    else
        i = 1
        while t < t_stop
            if variableSteps
                if length(saveat) > i
                    dt = saveat[i+1] - saveat[i]
                else 
                    dt = t_stop - saveat[i]
                end
            end

            if _inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, _inputFunction(c, t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1

            if progressMeter !== nothing 
                ProgressMeter.update!(progressMeter, floor(Integer, 1000.0*(t-t_start)/(t_stop-t_start)) )
            end
        end

        if progressMeter !== nothing 
            ProgressMeter.finish!(progressMeter)
        end

        fmusol.success = true # ToDo: Check successful simulation!
    end

    finishSolveFMU(fmu, c, freeInstance, terminate)

    return fmusol
end

export fmi2SimulateCS

##### CS & ME #####

"""
    fmi2Simulate(c::FMU2Component, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)

Wrapper for `fmi2Simulate(fmu::FMU2, c::Union{FMU2Component, Nothing}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing; kwargs...)` without a provided FMU2.
(FMU2 `fmu` is taken from `c`)
"""
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
    fmi2Simulate(args...)

Starts a simulation of the `FMU2` for the matching type (`fmi2SimulateCS(args...)` or `fmi2SimulateME(args...)`); if both types are available, CS is preferred.

See also [`fmi2SimulateCS`](@ref), [`fmi2SimulateME`](@ref).
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

export fmi2Simulate