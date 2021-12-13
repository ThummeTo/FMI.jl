#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::fmi3Component, integrator)
    discreteStatesNeedUpdate = fmi3False
    terminateSimulation = fmi3False
    nominalsOfContinuousStatesChanged = fmi3False
    valuesOfContinuousStatesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = fmi3Float64(0.0)

    fmi3UpdateDiscreteStates(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    # eventInfo = fmi2NewDiscreteStates(c)
    fmi3EnterContinuousTimeMode(c)
    if Bool(nextEventTimeDefined)
        nextEventTime
    else
        Inf
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::fmi3Component, enterEventMode::Bool, exitInContinuousMode::Bool)

    if enterEventMode
        fmi3EnterEventMode(c)
    end

    discreteStatesNeedUpdate = fmi3False
    terminateSimulation = fmi3False
    nominalsOfContinuousStatesChanged = fmi3False
    valuesOfContinuousStatesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = fmi3Float64(0.0)

    fmi3UpdateDiscreteStates(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    # eventInfo = fmi2NewDiscreteStates(c)

    # valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
    # nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

    #set inputs here
    #fmiSetReal(myFMU, InputRef, Value)

    while discreteStatesNeedUpdate == fmi3True

        # update discrete states
        discreteStatesNeedUpdate = fmi3False
        terminateSimulation = fmi3False
        nominalsOfContinuousStatesChanged = fmi3False
        valuesOfContinuousStatesChanged = fmi3False
        nextEventTimeDefined = fmi3False
        nextEventTime = fmi3Float64(0.0)

        fmi3UpdateDiscreteStates(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    
        # eventInfo = fmi2NewDiscreteStates(c)
        # valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
        # nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

        if terminateSimulation == fmi3True
            @error "fmi3UpdateDiscreteStates returned error!"
        end
    end

    if exitInContinuousMode
        fmi3EnterContinuousTimeMode(c)
    end

    return valuesOfContinuousStatesChanged, nominalsOfContinuousStatesChanged

end

# Returns the event indicators for an FMU.
function condition(c::fmi3Component, out, x, t, integrator) # Event when event_f(u,t) == 0

    fmi3SetTime(c, t)
    fmi3SetContinuousStates(c, x)
    indicators = fmi3GetEventIndicators(c)

    copy!(out, indicators)

end

# Handles the upcoming events.
function affectFMU!(c::fmi3Component, integrator, idx)
    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, true, Bool(sign(idx)))

    if continuousStatesChanged == fmi3True
        integrator.u = fmi3GetContinuousStates(c)
    end

    if nominalsChanged == fmi3True
        x_nom = fmi3GetNominalsOfContinuousStates(c)
    end
    timeEventCb = PresetTimeCallback(2.0, (integrator) -> affect!(c, integrator, 0))
end

# Does one step in the simulation.
function stepCompleted(c::fmi3Component, x, t, integrator)

     (status, enterEventMode, terminateSimulation) = fmi3CompletedIntegratorStep(c, fmi3True)
     if enterEventMode == fmi3True
        affect!(c, integrator, 0)
     end

end

# Returns the state derivatives of the FMU.
function fx(c::fmi3Component, x, p, t)
    fmi3SetTime(c, t)
    fmi3SetContinuousStates(c, x)
    dx = fmi3GetDerivatives(c)
end

# save FMU values 
function saveValues(c::fmi3Component, recordValues, u, t, integrator)
    Tuple(fmi3GetFloat64(c, recordValues)...,)
end

"""
Source: FMISpec2.0.2[p.90 ff]: 3.2.4 Pseudocode Example

Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Returns a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
If keyword `recordValues` is not set, a tuple of type (ODESolution, nothing) is returned for consitency.
"""
function fmi3SimulateME(c::fmi3Component, t_start::Real = 0.0, t_stop::Real = 1.0;
    solver = nothing,
    customFx = nothing,
    recordValues::fmi3ValueReferenceFormat = nothing,
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
        fmi3Reset(c)
        fmi3EnterInitializationMode(c, t_start, t_stop)
        fmi3ExitInitializationMode(c)
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0
    
    # First evaluation of the FMU
    x0 = fmi3GetContinuousStates(c)
    x0_nom = fmi3GetNominalsOfContinuousStates(c)

    fmi3SetContinuousStates(c, x0)
    
    handleEvents(c, false, false)

    # Get states of handling initial Events
    x0 = fmi3GetContinuousStates(c)
    x0_nom = fmi3GetNominalsOfContinuousStates(c)

    p = []
    problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)
    
    if eventHandling
        discreteStatesNeedUpdate = fmi3False
        terminateSimulation = fmi3False
        nominalsOfContinuousStatesChanged = fmi3False
        valuesOfContinuousStatesChanged = fmi3False
        nextEventTimeDefined = fmi3False
        nextEventTime = fmi3Float64(0.0)

        fmi3UpdateDiscreteStates(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    
        # eventInfo = fmi2NewDiscreteStates(c)
        fmi3EnterContinuousTimeMode(c)

        timeEvents = (nextEventTimeDefined == fmi3True)
      
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

"""
Starts a simulation of the Co-Simulation FMU instance.

Returns a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false`.
If keyword `recordValues` is not set, a tuple of type (success::Bool, nothing) is returned for consitency.

ToDo: Improove Documentation.
"""
function fmi3SimulateCS(c::fmi3Component, t_start::Real, t_stop::Real;
                        recordValues::fmi3ValueReferenceFormat = nothing,
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
        fmi3Reset(c)
        fmi3EnterInitializationMode(c, t_start, t_stop)
        fmi3ExitInitializationMode(c)
    end

    t = t_start

    record = length(recordValues) > 0

    #numDigits = length(string(round(Integer, 1/dt)))
    noSetFMUStatePriorToCurrentPoint = fmi3False
    eventEncountered = fmi3False
    terminateSimulation = fmi3False
    earlyReturn = fmi3False
    lastSuccessfulTime = fmi3Float64(0.0)

    if record
        savedValues = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})

        i = 1

        values = (fmi3GetFloat64(c, recordValues)...,)
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

            fmi3DoStep(c, t, dt, fmi3True, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @warn "terminate Simulation"
            end
            if earlyReturn == fmi3True
                @warn "early Return"
            end
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1

            values = (fmi3GetFloat64(c, recordValues)...,)
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

            fmi3DoStep(c, t, dt, fmi3True, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @warn "terminate Simulation"
            end
            if earlyReturn == fmi3True
                @warn "early Return"
            end
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1
        end

        success = true
    end

    success, savedValues
end

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available, CS is preferred.

Returns:
    - a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false` for CS-FMUs
    - a tuple of (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
    - if keyword `recordValues` is not set, a tuple of type (..., nothing)
    
ToDo: Improove Documentation.
"""
function fmi3Simulate(c::fmi3Component, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi3ValueReferenceFormat = nothing,
                      saveat = [],
                      setup = true)

    if fmi3IsCoSimulation(c.fmu)
        return fmi3SimulateCS(c, t_start, t_stop; recordValues=recordValues, saveat=saveat, setup=setup)
    elseif fmi3IsModelExchange(c.fmu)
        return fmi3SimulateME(c, t_start, t_stop; recordValues=recordValues, saveat=saveat, setup=setup)
    else
        error(unknownFMUType)
    end
end
