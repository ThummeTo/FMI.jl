#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::fmi2Component, integrator)
    eventInfo = fmi2NewDiscreteStates(c)
    fmi2EnterContinuousTimeMode(c)
    if Bool(eventInfo.nextEventTimeDefined)
        eventInfo.nextEventTime
    else
        Inf
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::fmi2Component, enterEventMode::Bool, exitInContinuousMode::Bool)

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
function condition(c::fmi2Component, out, x, t, integrator, inputFunction, inputValues::Array{fmi2ValueReference}) 

    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(integrator.t))
    end

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    indicators = fmi2GetEventIndicators(c)

    copy!(out, indicators)
end

# Handles the upcoming events.
function affectFMU!(c::fmi2Component, integrator, idx, inputFunction, inputValues::Array{fmi2ValueReference})
    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, true, Bool(sign(idx)))

    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(integrator.t))
    end

    if continuousStatesChanged == fmi2True
        integrator.u = fmi2GetContinuousStates(c)
    end

    if nominalsChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end
end

# Does one step in the simulation.
function stepCompleted(c::fmi2Component, x, t, integrator, inputFunction, inputValues::Array{fmi2ValueReference})

    (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
    if enterEventMode == fmi2True
        affectFMU!(c, integrator, 0, inputFunction, inputValues)
    else
        if inputFunction != nothing
            fmi2SetReal(c, inputValues, inputFunction(integrator.t))
        end
    end
end

# Returns the state derivatives of the FMU.
function fx(c::fmi2Component, x, p, t)
    fmi2SetTime(c, t) 
    fmi2SetContinuousStates(c, x)
    dx = fmi2GetDerivatives(c)
end

# save FMU values 
function saveValues(c::fmi2Component, recordValues, u, t, integrator)
    (fmiGetReal(c, recordValues)...,)
end

"""
Source: FMISpec2.0.2[p.90 ff]: 3.2.4 Pseudocode Example

Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Via the optional keyword arguemnts `inputValues` and `inputFunction`, a custom input function of the time `t` can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(t))`.

Returns:
    - If keyword `recordValues` is not set, a struct of type `ODESolution`.
    - If keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
"""
function fmi2SimulateME(c::fmi2Component, t_start::Real = 0.0, t_stop::Real = 1.0;
    solver = nothing,
    customFx = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    saveat = [],
    setup = true,
    reset = true,
    inputValues::fmi2ValueReferenceFormat = nothing,
    inputFunction = nothing,
    kwargs...)

    recordValues = prepareValueReference(c, recordValues)
    inputValues = prepareValueReference(c, inputValues)
    solution = nothing
    callbacks = []
    savedValues = nothing

    savingValues = (length(recordValues) > 0)

    if savingValues
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})

        savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator), 
                                  savedValues, 
                                  saveat=saveat)
        push!(callbacks, savingCB)
    end

    if solver == nothing
        solver = Tsit5()
    end

    if reset 
        fmi2Reset(c)
    end 

    if setup
        fmi2SetupExperiment(c, t_start, t_stop)
        fmi2EnterInitializationMode(c)
        fmi2ExitInitializationMode(c)
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0
    timeEventHandling = false

    if eventHandling
        eventInfo = fmi2NewDiscreteStates(c)
        timeEventHandling = (eventInfo.nextEventTimeDefined == fmi2True)
    end

    if customFx == nothing
        customFx = (x, p, t) -> fx(c, x, p, t)
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
    
    stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, inputFunction, inputValues);
                                         func_everystep = true,
                                         func_start = true)
    push!(callbacks, stepCb)

    if eventHandling

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, inputFunction, inputValues),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, inputFunction, inputValues),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = DiffEqBase.RightRootFind,
                                           save_positions=(false,false))
        push!(callbacks, eventCb)

        if timeEventHandling
            timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator),
                                            (integrator) -> affectFMU!(c, integrator, 0, inputFunction, inputValues), Float64; 
                                            initial_affect = true,
                                            save_positions=(false,false))
            push!(callbacks, timeEventCb)
        end
    end

    solution = solve(problem, solver; callback = CallbackSet(callbacks...), saveat = saveat, kwargs...)

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

Returns:
    - If keyword `recordValues` is not set, a boolean `success` is returned (simulation success).
    - If keyword `recordValues` is set, a tuple of type (true, DiffEqCallbacks.SavedValues) or (false, nothing).
"""
function fmi2SimulateCS(c::fmi2Component, t_start::Real, t_stop::Real;
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup = true,
                        reset = true,
                        inputValues::fmi2ValueReferenceFormat = nothing,
                        inputFunction = nothing)

    recordValues = prepareValueReference(c, recordValues)
    inputValues = prepareValueReference(c, inputValues)
    variableSteps = c.fmu.modelDescription.CScanHandleVariableCommunicationStepSize 

    success = false
    savedValues = nothing

    # default setup
    if length(saveat) == 0
        saveat = LinRange(t_start, t_stop, 100)
    end
    dt = (t_stop - t_start) / length(saveat)

    # setup if no variable steps
    if variableSteps == false 
        if length(saveat) >= 2 
            dt = saveat[2] - saveat[1]
        end
    end

    if reset 
        fmi2Reset(c)
    end 

    if setup
        fmi2SetupExperiment(c, t_start, t_stop)
        fmi2EnterInitializationMode(c)
        fmi2ExitInitializationMode(c)
    end

    t = t_start

    record = length(recordValues) > 0

    #numDigits = length(string(round(Integer, 1/dt)))

    if record
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...} )

        i = 1

        values = (fmi2GetReal(c, recordValues)...,)
        DiffEqCallbacks.copyat_or_push!(savedValues.t, i, t)
        DiffEqCallbacks.copyat_or_push!(savedValues.saveval, i, values, Val{false})

        while t < t_stop
            if variableSteps
                if length(saveat) > i
                    dt = saveat[i+1] - saveat[i]
                else 
                    dt = t_stop - saveat[i]
                end
            end

            if inputFunction != nothing
                fmi2SetReal(c, inputValues, inputFunction(t))
            end

            fmi2DoStep(c, t, dt)
            t = t + dt 
            i += 1

            values = (fmi2GetReal(c, recordValues)...,)
            DiffEqCallbacks.copyat_or_push!(savedValues.t, i, t)
            DiffEqCallbacks.copyat_or_push!(savedValues.saveval, i, values, Val{false})
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
                fmi2SetReal(c, inputValues, inputFunction(t))
            end

            fmi2DoStep(c, t, dt)
            t = t + dt 
            i += 1
        end

        success = true

        return success
    end
end

###############

"""
Starts a simulation of the FMU instance for the matching FMU type, if both types are available, CS is preferred.

Returns:
    - `success::Bool` for CS-FMUs
    - `ODESolution` for ME-FMUs
    - if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs
    - if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
    
ToDo: Improove Documentation.
"""
function fmi2Simulate(c::fmi2Component, t_start::Real = 0.0, t_stop::Real = 1.0; kwargs...)

    if fmi2IsCoSimulation(c.fmu)
        return fmi2SimulateCS(c, t_start, t_stop; kwargs...)
    elseif fmi2IsModelExchange(c.fmu)
        return fmi2SimulateME(c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
