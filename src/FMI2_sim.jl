#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks
import SciMLBase: RightRootFind

using FMIImport: fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2NewDiscreteStates, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates, fmi2SetContinuousStates, fmi2GetDerivatives!
using FMIImport.FMICore: fmi2StatusOK, fmi2TypeCoSimulation, fmi2TypeModelExchange

using ChainRulesCore
import ForwardDiff

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::FMU2Component, integrator)
    eventInfo = fmi2NewDiscreteStates(c)
    fmi2EnterContinuousTimeMode(c)
    if Bool(eventInfo.nextEventTimeDefined)
        eventInfo.nextEventTime
    else
        Inf
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::FMU2Component, enterEventMode::Bool, exitInContinuousMode::Bool)

    if enterEventMode
        fmi2EnterEventMode(c)
    end

    eventInfo = fmi2NewDiscreteStates(c)

    valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
    nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

    while eventInfo.newDiscreteStatesNeeded == fmi2True
        # update discrete states
        eventInfo = fmi2NewDiscreteStates(c)
        valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
        nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

        if eventInfo.terminateSimulation == fmi2True
            @error "Event info returned error!"
        end
    end

    if exitInContinuousMode
        fmi2EnterContinuousTimeMode(c)
    end

    return valuesOfContinuousStatesChanged, nominalsOfContinuousStatesChanged
end

# Returns the event indicators for an FMU.
function condition(c::FMU2Component, out::SubArray{<:Real}, x, t, integrator, inputFunction, inputValues::Array{fmi2ValueReference}) 

    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(integrator.t))
    end

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    
    fmi2GetEventIndicators!(c, out)
end

# Handles the upcoming events.
# Sets a new state for the solver from the FMU (if needed).
function affectFMU!(c::FMU2Component, integrator, idx, inputFunction, inputValues::Array{fmi2ValueReference})

    # there are fx-evaluations before the event is handled, reset the FMU state to the current integrator step
    fmi2SetContinuousStates(c, integrator.u)

    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, true, Bool(sign(idx)))

    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(integrator.t))
    end

    if continuousStatesChanged == fmi2True
        new_u = fmi2GetContinuousStates(c)
        @debug "affectFMU!(...): Handled event, new state is $(new_u)"
        integrator.u = new_u
    end

    if nominalsChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end
end

# Does one step in the simulation.
function stepCompleted(c::FMU2Component, x, t, integrator, inputFunction, inputValues::Array{fmi2ValueReference})

    (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
    if enterEventMode == fmi2True
        affectFMU!(c, integrator, 0, inputFunction, inputValues)
    else
        if inputFunction != nothing
            fmi2SetReal(c, inputValues, inputFunction(integrator.t))
        end
    end
end

function fx(c::FMU2Component, 
    dx::Array{<:Real},
    x::Array{<:Real}, 
    p::Array, 
    t::Real)

    if isa(t, ForwardDiff.Dual) 
        t = ForwardDiff.value(t)
    end 

    fmi2SetTime(c, t) 
    fmi2SetContinuousStates(c, x)

    if all(isa.(dx, ForwardDiff.Dual))
        dx = collect(ForwardDiff.value(e) for e in dx)
    end

    fmi2GetDerivatives!(c, dx)
    return dx
end

# function fx(c::FMU2Component, 
#     x::Array{<:Real}, 
#     p::Array, 
#     t::Real)

#     dx = zeros(length(x))
#     fx(c, dx, x, p, t)
#     dx
# end

# ForwardDiff-Dispatch for fx
function fx(comp::FMU2Component,
            dx::Array{<:Real},
            x::Array{<:ForwardDiff.Dual{Tx, Vx, Nx}},
            p::Array,
            t::Real) where {Tx, Vx, Nx}

    return _fx_fd((Tx, Vx, Nx), comp, dx, x, p, t)
end

function _fx_fd(TVNx, comp, dx, x, p, t) 
  
    Tx, Vx, Nx = TVNx
    
    ȧrgs = [NoTangent(), NoTangent(), collect(ForwardDiff.partials(e) for e in dx), collect(ForwardDiff.partials(e) for e in x), collect(ForwardDiff.partials(e) for e in p), ForwardDiff.partials(t)]
    args = [fx,          comp,        collect(ForwardDiff.value(e) for e in dx), collect(ForwardDiff.value(e) for e in x),    collect(ForwardDiff.value(e) for e in p),    ForwardDiff.value(t),  ]

    ȧrgs = (ȧrgs...,)
    args = (args...,)
     
    y, _, sdx, sx, _, _ = ChainRulesCore.frule(ȧrgs, args...)

    if Vx != Float64
        Vx = Float64
    end

    [collect( ForwardDiff.Dual{Tx, Vx, Nx}(y[i], sx[i]) for i in 1:length(sx) )...]
end

# rrule for fx
function ChainRulesCore.rrule(::typeof(fx), 
                              comp::FMU2Component,
                              dx, 
                              x,
                              p,
                              t)

    y = fx(comp, dx, x, p, t)
    function fx_pullback(ȳ)

        if t >= 0.0
            fmi2SetTime(comp, t)
        end

        fmi2SetContinuousStates(comp, x)

        if comp.A == nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
            comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
        end 
        comp.jacobianFct(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

        n_dx_x = @thunk(comp.A' * ȳ)

        f̄ = NoTangent()
        c̄omp = ZeroTangent()
        d̄x = ZeroTangent()
        x̄ = n_dx_x
        p̄ = ZeroTangent()
        t̄ = ZeroTangent()
        
        return f̄, c̄omp, d̄x, x̄, p̄, t̄
    end
    return (y, fx_pullback)
end

# frule for fx
function ChainRulesCore.frule((Δself, Δcomp, Δdx, Δx, Δp, Δt), 
                              ::typeof(fx), 
                              comp, #::FMU2Component,
                              dx, 
                              x,#::Array{<:Real},
                              p,
                              t)

    y = fx(comp, dx, x, p, t)
    function fx_pullforward(Δx)
       
        if t >= 0.0 
            fmi2SetTime(comp, t)
        end
        
        if all(isa.(x, ForwardDiff.Dual))
            xf = collect(ForwardDiff.value(e) for e in x)
            fmi2SetContinuousStates(comp, xf)
        else
            fmi2SetContinuousStates(comp, x)
        end
       
        if comp.A == nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
            comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
        end 
        comp.jacobianFct(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

        n_dx_x = comp.A * Δx

        c̄omp = ZeroTangent()
        d̄x = ZeroTangent()
        x̄ = n_dx_x 
        p̄ = ZeroTangent()
        t̄ = ZeroTangent()
       
        return (c̄omp, d̄x, x̄, p̄, t̄)
    end
    return (y, fx_pullforward(Δx)...)
end

# save FMU values 
function saveValues(c::FMU2Component, recordValues, u, t, integrator)
    fmi2SetTime(c, t) 
    x = integrator.sol(t)
    fmi2SetContinuousStates(c, x)
    
    (fmiGetReal(c, recordValues)...,)
end

"""
Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Via the optional keyword arguemnts `inputValues` and `inputFunction`, a custom input function of the time `t` can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(t))`.

Keywords:
    - solver: Any Julia-supported ODE-solver (default is Tsit5)
    - customFx: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - saveat: Time points to save values at (interpolated)
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Union{Bool, :auto}, if FMU should be reset before simulation (default reset=:auto)
    - inputValueReferences: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - parameters: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization 

Returns:
    - If keyword `recordValues` is not set, a struct of type `ODESolution`.
    - If keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
"""
function fmi2SimulateME(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    solver = nothing,
    customFx = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    saveat = [],
    setup::Bool = true,
    reset::Union{Bool, Nothing} = nothing, # nothing = auto
    inputValueReferences::fmi2ValueReferenceFormat = nothing,
    inputFunction = nothing,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
    dtmax::Union{Real, Nothing} = nothing,
    kwargs...)

    recordValues = prepareValueReference(c, recordValues)
    inputValueReferences = prepareValueReference(c, inputValueReferences)
    solution = nothing
    callbacks = []
    savedValues = nothing

    savingValues = (length(recordValues) > 0)
    hasInputs = (length(inputValueReferences) > 0)
    hasParameters = (parameters != nothing)

    t_start = t_start === nothing ? fmi2GetDefaultStartTime(c.fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start
    t_stop = t_stop === nothing ? fmi2GetDefaultStopTime(c.fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop
    tolerance = tolerance === nothing ? fmi2GetDefaultTolerance(c.fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 1e-4 : tolerance
    dt = dt === nothing ? fmi2GetDefaultStepSize(c.fmu.modelDescription) : dt
    dt = dt === nothing ? 1e-5 : dt 

    if dtmax == nothing
        dtmax = (t_stop-t_start)/100.0
    end

    if savingValues
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})

        savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator), 
                                  savedValues, 
                                  saveat=saveat)
        push!(callbacks, savingCB)
    end

    if solver === nothing
        solver = Tsit5()
    end

    if reset == nothing 
        reset = setup 
    end

    @assert !(setup==false && reset==true) "fmi2SimulateME(...): keyword argument `setup=false`, but `reset=true`. This may cause a FMU crash."

    if reset 
        if c.state == fmi2ComponentStateModelInitialized
            retcode = fmi2Terminate(c)
            @assert retcode == fmi2StatusOK "fmi2SimulateME(...): Termination failed with return code $(retcode)."
        end
        if c.state == fmi2ComponentStateModelSetableFMUstate
            retcode = fmi2Reset(c)
            @assert retcode == fmi2StatusOK "fmi2SimulateME(...): Reset failed with return code $(retcode)."
        end
    end 

    if setup
        retcode = fmi2SetupExperiment(c, t_start, t_stop)
        @assert retcode == fmi2StatusOK "fmi2SimulateME(...): Setting up experiment failed with return code $(retcode)."

        retcode = fmi2EnterInitializationMode(c)
        @assert retcode == fmi2StatusOK "fmi2SimulateME(...): Entering initialization mode failed with return code $(retcode)."

        if hasParameters
            fmi2Set(c, collect(keys(parameters)), collect(values(parameters)) )
        end

        retcode = fmi2ExitInitializationMode(c)
        @assert retcode == fmi2StatusOK "fmi2SimulateME(...): Exiting initialization mode failed with return code $(retcode)."
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0
    timeEventHandling = false

    if eventHandling
        eventInfo = fmi2NewDiscreteStates(c)
        timeEventHandling = (eventInfo.nextEventTimeDefined == fmi2True)
    end

    if customFx == nothing
        customFx = (dx, x, p, t) -> fx(c, dx, x, p, t)
    end
    
    # First evaluation of the FMU
    x0 = fmi2GetContinuousStates(c)
    x0_nom = fmi2GetNominalsOfContinuousStates(c)

    fmi2SetContinuousStates(c, x0)
    
    handleEvents(c, false, false)

    # Get states of handling initial Events
    x0 = fmi2GetContinuousStates(c)
    x0_nom = fmi2GetNominalsOfContinuousStates(c)

    fmi2EnterContinuousTimeMode(c)

    p = []
    problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)

    # callback functions
    
    # use step callback always if we have inputs or need evenet handling
    if hasInputs || eventHandling
        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, inputFunction, inputValueReferences);
                                            func_everystep = true,
                                            func_start = true)
        push!(callbacks, stepCb)
    end

    if eventHandling

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, inputFunction, inputValueReferences),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, inputFunction, inputValueReferences),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(false,false))
        push!(callbacks, eventCb)

        if timeEventHandling
            timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator),
                                            (integrator) -> affectFMU!(c, integrator, 0, inputFunction, inputValueReferences), Float64; 
                                            initial_affect = true, # ToDo: or better 'false'?
                                            save_positions=(false,false))
            push!(callbacks, timeEventCb)
        end
    end

    solution = solve(problem, solver; callback = CallbackSet(callbacks...), saveat = saveat, tol=tolerance, dt=dt, dtmax=dtmax, kwargs...)

    if savingValues
        return solution, savedValues
    else 
        return solution
    end
end

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.

Via the optional keyword arguments `inputValues` and `inputFunction`, a custom input function of the time `t` can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(t))`.

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
function fmi2SimulateCS(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
                        tolerance::Union{Real, Nothing} = nothing,
                        dt::Union{Real, Nothing} = nothing,
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup::Bool = true,
                        reset = nothing,
                        inputValueReferences::fmi2ValueReferenceFormat = nothing,
                        inputFunction = nothing,
                        parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing)

    recordValues = prepareValueReference(c, recordValues)
    inputValueReferences = prepareValueReference(c, inputValueReferences)
    
    variableSteps = fmi2IsCoSimulation(c.fmu) && c.fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize 
    hasParameters = (parameters != nothing)

    t_start = t_start === nothing ? fmi2GetDefaultStartTime(c.fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start
    t_stop = t_stop === nothing ? fmi2GetDefaultStopTime(c.fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop
    tolerance = tolerance === nothing ? fmi2GetDefaultTolerance(c.fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 0.0 : tolerance
    dt = dt === nothing ? fmi2GetDefaultStepSize(c.fmu.modelDescription) : dt
    dt = dt === nothing ? 1e-3 : dt

    success = false
    savedValues = nothing

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

    # auto correct reset if only setup is given
    if reset == nothing 
        reset = setup
    end
    @assert !(setup==false && reset==true) "fmi2SimulateME(...): keyword argument `setup=false`, but `reset=true`. This may cause a FMU crash."

    if reset 
        if c.state == fmi2ComponentStateModelInitialized
            fmi2Terminate(c)
        end
        if c.state == fmi2ComponentStateModelSetableFMUstate
            fmi2Reset(c)
        end
    end 

    if setup
        fmi2SetupExperiment(c, t_start, t_stop; tolerance=tolerance)
        fmi2EnterInitializationMode(c)

        if hasParameters
            fmi2Set(c, collect(keys(parameters)), collect(values(parameters)) )
        end

        fmi2ExitInitializationMode(c)
    end

    t = t_start

    record = length(recordValues) > 0

    if record
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...} )

        i = 1

        svalues = (fmi2GetReal(c, recordValues)...,)
        DiffEqCallbacks.copyat_or_push!(savedValues.t, i, t)
        DiffEqCallbacks.copyat_or_push!(savedValues.saveval, i, svalues, Val{false})

        while t < t_stop
            if variableSteps
                if length(saveat) > i
                    dt = saveat[i+1] - saveat[i]
                else 
                    dt = t_stop - saveat[i]
                end
            end

            if inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, inputFunction(t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1

            svalues = (fmi2GetReal(c, recordValues)...,)
            DiffEqCallbacks.copyat_or_push!(savedValues.t, i, t)
            DiffEqCallbacks.copyat_or_push!(savedValues.saveval, i, svalues, Val{false})
        end

        success = true

        return success, savedValues
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

            if inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, inputFunction(t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1
        end

        success = true

        return success
    end
end

##### CS & ME #####

"""
Starts a simulation of the FMU instance for the matching FMU type, if both types are available, CS is preferred.

Keywords:
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Boolean, if FMU should be reset before simulation (default reset=setup)
    - inputValues: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - saveat: [ME only] Time points to save values at (interpolated)
    - solver: [ME only] Any Julia-supported ODE-solver (default is Tsit5)
    - customFx: [ME only, deperecated] Ability to give a custom state derivative function ẋ=f(x,t)

Returns:
    - `success::Bool` for CS-FMUs
    - `ODESolution` for ME-FMUs
    - if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs
    - if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
"""
function fmi2Simulate(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)

    if c.fmu.type == fmi2TypeCoSimulation
        return fmi2SimulateCS(c, t_start, t_stop; kwargs...)
    elseif c.fmu.type == fmi2TypeModelExchange
        return fmi2SimulateME(c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
