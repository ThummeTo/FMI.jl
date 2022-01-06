#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::fmi3Component, integrator, timeEvent::Ref{fmi3Boolean})
    discreteStatesNeedUpdate = fmi3False
    terminateSimulation = fmi3False
    nominalsOfContinuousStatesChanged = fmi3False
    valuesOfContinuousStatesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = fmi3Float64(0.0)

    fmi3UpdateDiscreteStates!(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    # eventInfo = fmi2NewDiscreteStates(c)
    fmi3EnterContinuousTimeMode(c)
    if Bool(nextEventTimeDefined)
        timeEvent[] = integrator.t >= nextEventTime
        nextEventTime
    else
        Inf
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::fmi3Component, enterEventMode::Bool, exitInContinuousMode::Bool, stateEvent::fmi3Boolean, timeEvent::fmi3Boolean)

    if enterEventMode
        # TODO check the parameters set hard on stateEvent
        fmi3EnterEventMode(c, false, stateEvent, c.fmu.rootsFound, fmi3GetNumberOfEventIndicators(c.fmu), timeEvent)
    end

    discreteStatesNeedUpdate = fmi3False
    terminateSimulation = fmi3False
    nominalsOfContinuousStatesChanged = fmi3False
    valuesOfContinuousStatesChanged = fmi3False
    nominalsChanged = fmi3False
    valuesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = fmi3Float64(0.0)

    fmi3UpdateDiscreteStates!(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    # eventInfo = fmi2NewDiscreteStates(c)
    println("---------------------")
    println(discreteStatesNeedUpdate)
    println(terminateSimulation)
    println(nominalsOfContinuousStatesChanged)
    println(valuesOfContinuousStatesChanged)
    println(nextEventTimeDefined)
    # valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
    # nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

    nominalsChanged |=nominalsOfContinuousStatesChanged
    valuesChanged |= valuesOfContinuousStatesChanged
    #set inputs here
    #fmiSetReal(myFMU, InputRef, Value)

    while discreteStatesNeedUpdate == fmi3True

        # update discrete states
        # discreteStatesNeedUpdate = fmi3False
        # terminateSimulation = fmi3False
        # nominalsOfContinuousStatesChanged = fmi3False
        # valuesOfContinuousStatesChanged = fmi3False
        # nextEventTimeDefined = fmi3False
        # nextEventTime = fmi3Float64(0.0)

        fmi3UpdateDiscreteStates!(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
        # eventInfo = fmi2NewDiscreteStates(c)
        # valuesOfContinuousStatesChanged = eventInfo.valuesOfContinuousStatesChanged
        # nominalsOfContinuousStatesChanged = eventInfo.nominalsOfContinuousStatesChanged

        if terminateSimulation == fmi3True
            @error "fmi3UpdateDiscreteStates! returned error!"
        end
        nominalsChanged |=nominalsOfContinuousStatesChanged
        valuesChanged |= valuesOfContinuousStatesChanged
    end

    if exitInContinuousMode
        fmi3EnterContinuousTimeMode(c)
    end

    return valuesOfContinuousStatesChanged, nominalsOfContinuousStatesChanged

end

# Returns the event indicators for an FMU.
function condition(c::fmi3Component, out, x, t, integrator, inputFunction, inputValues::Array{fmi3ValueReference}, stateEvent::Ref{fmi3Boolean}) # Event when event_f(u,t) == 0

    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(integrator.t))
    end
    stateEvent[] = false
    fmi3SetTime(c, t)
    fmi3SetContinuousStates(c, x)
    indicators = fmi3GetEventIndicators(c)
    if length(indicators) > 0
        for i in 1:length(indicators)
            if c.fmu.previous_z[i] < 0 && indicators[i] >= 0
                c.fmu.rootsFound[i] = 1
            elseif c.fmu.previous_z[i] >= 0 && indicators[i] < 0
                c.fmu.rootsFound[i] = -1
            else
                c.fmu.rootsFound[i] = 0
            end
            stateEvent[] |= (c.fmu.rootsFound[i] != 0)
            c.fmu.previous_z[i] = indicators[i]
        end
    end
    copy!(out, indicators)
    stateEvent
end

# Handles the upcoming events.
function affectFMU!(c::fmi3Component, integrator, idx, inputFunction, inputValues::Array{fmi3ValueReference}, stateEvent::fmi3Boolean, timeEvent::fmi3Boolean)
    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, false, Bool(sign(idx)), stateEvent, timeEvent)

    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(integrator.t))
    end

    if continuousStatesChanged == fmi3True
        integrator.u = fmi3GetContinuousStates(c)
    end

    if nominalsChanged == fmi3True
        x_nom = fmi3GetNominalsOfContinuousStates(c)
    end
    # timeEventCb = PresetTimeCallback(2.0, (integrator) -> affect!(c, integrator, 0))
end

# Does one step in the simulation.
function stepCompleted(c::fmi3Component, x, t, integrator, inputFunction, inputValues::Array{fmi3ValueReference})

    (status, enterEventMode, terminateSimulation) = fmi3CompletedIntegratorStep(c, fmi3True)
    if enterEventMode == fmi3True
        affect!(c, integrator, 0, inputFunction, inputValues)
    else
        if inputFunction !== nothing
            fmi3SetFloat64(c, inputValues, inputFunction(integrator.t))
        end
    end

end

# Returns the state derivatives of the FMU.
function fx(c::fmi3Component, x, p, t)
    fmi3SetTime(c, t) 
    fmi3SetContinuousStates(c, x)
    dx = fmi3GetContinuousStateDerivatives(c)
end

# save FMU values 
function saveValues(c::fmi3Component, recordValues, u, t, integrator)
    (fmi3GetFloat64(c, recordValues)...,)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.3. Code Example

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
    reset = nothing, # nothing = auto
    inputValues::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing,
    kwargs...)

    recordValues = prepareValueReference(c, recordValues)
    inputValues = prepareValueReference(c, inputValues)
    solution = nothing
    callbacks = []
    savedValues = nothing
    discreteStatesNeedUpdate = fmi3False
    terminateSimulation = fmi3False
    nominalsOfContinuousStatesChanged = fmi3False
    valuesOfContinuousStatesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = fmi3Float64(0.0)
    stateEvent = fmi3False
    timeEvent = fmi3False

    savingValues = (length(recordValues) > 0)
    hasInputs = (length(inputValues) > 0)

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

    # auto correct reset if only setup is given
    if reset === nothing 
        reset = setup
    end
    @assert !(setup==false && reset==true) "fmi3SimulateME(...): keyword argument `setup=false`, but `reset=true`. This may cause a FMU crash."


    if reset
        fmi3Reset(c)
    end

    if setup
        fmi3EnterInitializationMode(c, t_start, t_stop)
        c.fmu.previous_z = fmi3GetEventIndicators(c)
        fmi3ExitInitializationMode(c)
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0 
    timeEventHandling = false

    if eventHandling
        println("test EventHandling")
        fmi3UpdateDiscreteStates!(c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
        timeEventHandling = (nextEventTimeDefined == fmi3True)
    end
    
    if customFx === nothing
        customFx = (x, p, t) -> fx(c, x, p, t)
    end

    fmi3EnterContinuousTimeMode(c)

    # First evaluation of the FMU
    x0 = fmi3GetContinuousStates(c)
    x0_nom = fmi3GetNominalsOfContinuousStates(c)

    # can only be called in ContinuousTimeMode
    fmi3SetContinuousStates(c, x0)
    
    # handleEvents(c, false, false)

    # # Get states of handling initial Events
    # x0 = fmi3GetContinuousStates(c)
    # x0_nom = fmi3GetNominalsOfContinuousStates(c)

    # fmi3EnterContinuousTimeMode(c)

    p = []
    problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)
    
    # callback functions

    # use step callback always if we have inputs or need evenet handling
    if hasInputs || eventHandling
        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, inputFunction, inputValues);
                                            func_everystep = true,
                                            func_start = true)
        push!(callbacks, stepCb)
    end

    if eventHandling

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, inputFunction, inputValues, Ref(stateEvent)),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, inputFunction, inputValues, stateEvent, timeEvent),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(false,false))
        push!(callbacks, eventCb)

        if timeEventHandling
            timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator, Ref(timeEvent)),
                                            (integrator) -> affectFMU!(c, integrator, 0, inputFunction, inputValues, stateEvent, timeEvent), Float64; 
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

"""
Source: FMISpec3.0, Version D5ef1c1: 4.3. Code Examples

Starts a simulation of the Co-Simulation FMU instance.

Returns a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false`.
If keyword `recordValues` is not set, a tuple of type (success::Bool, nothing) is returned for consitency.

ToDo: Improve Documentation.
"""
function fmi3SimulateCS(c::fmi3Component, t_start::Real, t_stop::Real;
                        recordValues::fmi3ValueReferenceFormat = nothing,
                        saveat = [],
                        setup::Bool = true,
                        reset = nothing,
                        inputValues::fmi3ValueReferenceFormat = nothing,
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

    # auto correct reset if only setup is given
    if reset === nothing 
        reset = setup
    end
    @assert !(setup==false && reset==true) "fmi3SimulateME(...): keyword argument `setup=false`, but `reset=true`. This may cause a FMU crash."


    if reset
        fmi3Reset(c)
    end

    if setup
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

            if inputFunction !== nothing
                fmi3SetFloat64(c, inputValues, inputFunction(t))
            end

            fmi3DoStep(c, t, dt, fmi3True, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @error "fmi3DoStep returned error!"
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

            if inputFunction !== nothing
                fmi3SetFloat64(c, inputValues, inputFunction(t))
            end

            fmi3DoStep(c, t, dt, fmi3True, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @error "fmi3DoStep returned error!"
            end
            if earlyReturn == fmi3True
                @warn "early Return"
            end
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1
        end

        success = true
        return success
    end
end

# TODO simulate ScheduledExecution
function fmi3SimulateSE(c::fmi3Component, t_start::Real, t_stop::Real;
    recordValues::fmi3ValueReferenceFormat = nothing,
    saveat = [],
    setup::Bool = true,
    reset = nothing,
    inputValues::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing)
    @assert false "Not implemented"
end

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available, CS is preferred.

Returns:
    - a tuple of (success::Bool, DiffEqCallbacks.SavedValues) with success = `true` or `false` for CS-FMUs
    - a tuple of (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
    - if keyword `recordValues` is not set, a tuple of type (..., nothing)
    
ToDo: Improve Documentation.
"""
function fmi3Simulate(c::fmi3Component, t_start::Real = 0.0, t_stop::Real = 1.0;kwargs...)

    if fmi3IsCoSimulation(c.fmu)
        return fmi3SimulateCS(c, t_start, t_stop; kwargs...)
    elseif fmi3IsModelExchange(c.fmu)
        return fmi3SimulateME(c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
