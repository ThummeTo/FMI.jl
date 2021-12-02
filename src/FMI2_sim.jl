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

    #set inputs here
    #fmiSetReal(myFMU, InputRef, Value)

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
function condition(c::fmi2Component, out, x, t, integrator) # Event when event_f(u,t) == 0

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    indicators = fmi2GetEventIndicators(c)

    copy!(out, indicators)

end

# Handles the upcoming events.
function affectFMU!(c::fmi2Component, integrator, idx)
    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, true, Bool(sign(idx)))

    if continuousStatesChanged == fmi2True
        integrator.u = fmi2GetContinuousStates(c)
    end

    if nominalsChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end
    timeEventCb = PresetTimeCallback(2.0, (integrator) -> affect!(c, integrator, 0))
end

# Does one step in the simulation.
function stepCompleted(c::fmi2Component, x, t, integrator)

     (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
     if enterEventMode == fmi2True
        affect!(c, integrator, 0)
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
    Tuple(fmiGetReal(c, recordValues)...,)
end

"""
Source: FMISpec2.0.2[p.90 ff]: 3.2.4 Pseudocode Example

Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Returns a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
If keyword `recordValues` is not set, a tuple of type (ODESolution, nothing) is returned for consitency.
"""
function fmi2SimulateME(c::fmi2Component, t_start::Real = 0.0, t_stop::Real = 1.0;
    solver = nothing,
    customFx = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    saveat = [],
    setup = true,
    kwargs...)

    recordValues = prepareValueReference(c, recordValues)
    solution = nothing
    callbacks = []
    savedValues = nothing

    if length(recordValues) > 0
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})

        savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator), 
                                  savedValues, 
                                  saveat=saveat)
        push!(callbacks, savingCB)
    end

    if solver == nothing
        solver = Tsit5()
    end

    if customFx == nothing
        customFx = (x, p, t) -> fx(c, x, p, t)
    end

    if setup
        fmi2Reset(c)
        fmi2SetupExperiment(c, t_start, t_stop)
        fmi2EnterInitializationMode(c)
        fmi2ExitInitializationMode(c)
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0
    
    # First evaluation of the FMU
    x0 = fmi2GetContinuousStates(c)
    x0_nom = fmi2GetNominalsOfContinuousStates(c)

    fmi2SetContinuousStates(c, x0)
    
    handleEvents(c, false, false)

    # Get states of handling initial Events
    x0 = fmi2GetContinuousStates(c)
    x0_nom = fmi2GetNominalsOfContinuousStates(c)

    p = []
    problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)
    
    if eventHandling

        eventInfo = fmi2NewDiscreteStates(c)
        fmi2EnterContinuousTimeMode(c)

        timeEvents = (eventInfo.nextEventTimeDefined == fmi2True)
      
        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = DiffEqBase.RightRootFind)
        push!(callbacks, eventCb)

        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator);
                                         func_everystep = true,
                                         func_start = true)
        push!(callbacks, stepCb)

        if timeEvents
            timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator),
                                            (integrator) -> affectFMU!(c, integrator, 0), Float64; initial_affect = true)
        
            push!(callbacks, timeEventCb)
        end
    end

    if length(callbacks) > 0
        solution = solve(problem, solver, callback = CallbackSet(callbacks...), saveat = saveat; kwargs...)
    else 
        solution = solve(problem, solver, saveat = saveat; kwargs...)
    end

    return solution, savedValues
end

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.

Returns a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false`.
If keyword `recordValues` is not set, a tuple of type (success::Bool, nothing) is returned for consitency.

ToDo: Improove Documentation.
"""
function fmi2SimulateCS(c::fmi2Component, t_start::Real, t_stop::Real;
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup = true)

    recordValues = prepareValueReference(c, recordValues)
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

    if setup
        fmi2Reset(c)
        fmi2SetupExperiment(c, t_start, t_stop)
        fmi2EnterInitializationMode(c)
        fmi2ExitInitializationMode(c)
    end

    t = t_start

    record = length(recordValues) > 0

    #numDigits = length(string(round(Integer, 1/dt)))

    if record
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})

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

            fmi2DoStep(c, t, dt)
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1

            values = (fmi2GetReal(c, recordValues)...,)
            DiffEqCallbacks.copyat_or_push!(savedValues.t, i, t)
            DiffEqCallbacks.copyat_or_push!(savedValues.saveval, i, values, Val{false})
        end

        success = true
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

            fmi2DoStep(c, t, dt)
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1
        end

        success = true
    end

    success, savedValues
end

###############

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available, CS is preferred.

Returns:
    - a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false` for CS-FMUs
    - a tuple of (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
    - if keyword `recordValues` is not set, a tuple of type (..., nothing)
    
ToDo: Improove Documentation.
"""
function fmi2Simulate(c::fmi2Component, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi2ValueReferenceFormat = nothing,
                      saveat = [],
                      setup = true)

    if fmi2IsCoSimulation(c.fmu)
        return fmi2SimulateCS(c, t_start, t_stop; recordValues=recordValues, saveat=saveat, setup=setup)
    elseif fmi2IsModelExchange(c.fmu)
        return fmi2SimulateME(c, t_start, t_stop; recordValues=recordValues, saveat=saveat, setup=setup)
    else
        error(unknownFMUType)
    end
end
