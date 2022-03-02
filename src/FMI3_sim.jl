#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks

using FMIImport: fmi3Instance

############ Model-Exchange ############

# Read next time event from FMU and provide it to the integrator 
function time_choice(c::fmi3Instance, integrator) 
    @debug "time_choice(_, _): Time event @ t=$(integrator.t)"

    discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)
    fmi3EnterContinuousTimeMode(c)
    if Bool(nextEventTimeDefined)
        c.timeEvent = integrator.t >= nextEventTime
        nextEventTime
    else
        Inf
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::fmi3Instance, enterEventMode::Bool, exitInContinuousMode::Bool)
    nominalsChanged = fmi3False
    valuesChanged = fmi3False
    if enterEventMode

        fmi3EnterEventMode(c, c.stepEvent, c.stateEvent, c.rootsFound, Csize_t(c.fmu.modelDescription.numberOfEventIndicators), c.timeEvent)
        # TODO inputEvent handling
        
        discreteStatesNeedUpdate = fmi3True
        while discreteStatesNeedUpdate == fmi3True

            # update discrete states
            discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)
          
            if valuesOfContinuousStatesChanged == fmi3True 
                valuesChanged = true
            end

            if nominalsOfContinuousStatesChanged == fmi3True 
                nominalsChanged = true
            end

            if terminateSimulation == fmi3True
                @error "fmi3UpdateDiscreteStates returned error!"
            end
        end
    end
    

    if exitInContinuousMode
        fmi3EnterContinuousTimeMode(c)
    end
    @debug "handleEvents(_, $(enterEventMode), $(exitInContinuousMode)): rootsFound: $(c.rootsFound)   valuesChanged: $(valuesChanged)   continuousStates: $(fmi3GetContinuousStates(c))", 
    return valuesChanged, nominalsChanged

end

# Returns the event indicators for an FMU.
function condition(c::fmi3Instance, out, x, t, integrator, inputFunction, inputValues::Array{fmi3ValueReference}) # Event when event_f(u,t) == 0
    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(integrator.t))
    end

    c.stateEvent = fmi3False
    fmi3SetTime(c, t)
    fmi3SetContinuousStates(c, x)
    indicators = fmi3GetEventIndicators(c)
    if length(indicators) > 0
        for i in 1:length(indicators)
            if c.z_prev[i] < 0 && indicators[i] >= 0
                c.rootsFound[i] = 1
            elseif c.z_prev[i] > 0 && indicators[i] <= 0
                c.rootsFound[i] = -1
            else
                c.rootsFound[i] = 0
            end
            c.stateEvent |= (c.rootsFound[i] != 0)
            # c.z_prev[i] = indicators[i]
        end
    end
    @debug "condition(_, _, $(x), $(t), _, _, _): eventIndicators $indicators   rootsFound $(c.rootsFound)   stateEvent $(c.stateEvent)"
    copy!(out, indicators)
end

# Handles the upcoming events.
function affectFMU!(c::fmi3Instance, integrator, idx, inputFunction, inputValues::Array{fmi3ValueReference}, force=false)
    # Event found - handle it

    @debug "affectFMU!(_, _, $(idx), _, _): x:$(integrator.u)   [before handle events]"
    
    fmi3SetContinuousStates(c, integrator.u)

    continuousStatesChanged, nominalsChanged = handleEvents(c, true, Bool(sign(idx)))

    @debug "affectFMU!(_, _, $(idx), _, _): continuousStatesChanged=$(continuousStatesChanged)   x_int:$(integrator.u)   x_fmu:$(fmi3GetContinuousStates(c))   [after handle events]"

    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(integrator.t))
    end

    if continuousStatesChanged == fmi3True
        integrator.u = fmi3GetContinuousStates(c)
        @debug "affectFMU!(_, _, $(idx), _, _): Set new state $(integrator.u)"
    end

    if nominalsChanged == fmi3True
        x_nom = fmi3GetNominalsOfContinuousStates(c)
    end
    # timeEventCb = PresetTimeCallback(2.0, (integrator) -> affect!(c, integrator, 0))
end

# Does one step in the simulation.
function stepCompleted(c::fmi3Instance, x, t, integrator, inputFunction, inputValues::Array{fmi3ValueReference})

    fmi3SetContinuousStates(c, x)
    
    indicators = fmi3GetEventIndicators(c)
        if length(indicators) > 0
        c.stateEvent = fmi3False
    
        for i in 1:length(indicators)
            if c.z_prev[i] < 0 && indicators[i] >= 0
                c.rootsFound[i] = 1
            elseif c.z_prev[i] > 0 && indicators[i] <= 0
                c.rootsFound[i] = -1
            else
                c.rootsFound[i] = 0
            end
            c.stateEvent |= (c.rootsFound[i] != 0)
            c.z_prev[i] = indicators[i]
        end
    end

    (status, c.stepEvent, terminateSimulation) = fmi3CompletedIntegratorStep(c, fmi3True)
    @debug "stepCompleted(_, $(x), $(t), _, _, _): stepEvent $(c.stepEvent)"
    @assert terminateSimulation == fmi3False "completed Integratorstep failed!"
    
end

# Returns the state derivatives of the FMU.
function fx(c::fmi3Instance, x, p, t)
    @debug "fx($(x), _, $(t))"
    fmi3SetTime(c, t) 
    fmi3SetContinuousStates(c, x)
    dx = fmi3GetContinuousStateDerivatives(c)
end

# save FMU values 
function saveValues(c::fmi3Instance, recordValues, u, t, integrator)
    fmi3SetTime(c, t) 
    x = integrator.sol(t)
    fmi3SetContinuousStates(c, x)

    (fmi3GetFloat64(c, recordValues)...,)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.3. Code Example

Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Returns a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
If keyword `recordValues` is not set, a tuple of type (ODESolution, nothing) is returned for consitency.
"""
function fmi3SimulateME(c::fmi3Instance, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    solver = nothing,
    customFx = nothing,
    recordValues::fmi3ValueReferenceFormat = nothing,
    saveat = [],
    saveAtEvent::Bool = false,
    setup::Bool = true,
    reset = nothing, # nothing = auto
    inputValues::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing,
    rootSearchInterpolationPoints = 100,
    kwargs...)

    if t_start == nothing
        t_start = c.fmu.modelDescription.defaultStartTime
    end

    if t_stop == nothing
        t_stop = c.fmu.modelDescription.defaultStopTime
    end

    recordValues = prepareValueReference(c, recordValues)
    inputValues = prepareValueReference(c, inputValues)
    solution = nothing
    callbacks = []
    savedValues = nothing

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
        fmi3ExitInitializationMode(c)
    end

    eventHandling = c.fmu.modelDescription.numberOfEventIndicators > 0 
    timeEventHandling = false
    
    if eventHandling
        discreteStatesNeedUpdate = fmi3True
        while discreteStatesNeedUpdate == fmi3True
            discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)
            @assert terminateSimulation == fmi3False ["Initial Event handling failed!"]
            timeEventHandling |= (nextEventTimeDefined == fmi3True)
        end  
    end
    
    if customFx === nothing
        customFx = (x, p, t) -> fx(c, x, p, t)
    end

    fmi3EnterContinuousTimeMode(c)

    if eventHandling
        c.z_prev = fmi3GetEventIndicators(c)
    end

    # First evaluation of the FMU
    x0 = fmi3GetContinuousStates(c)
    x0_nom = fmi3GetNominalsOfContinuousStates(c)

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

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, inputFunction, inputValues),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, inputFunction, inputValues, true),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(saveAtEvent,saveAtEvent),
                                           interp_points=rootSearchInterpolationPoints)#,abstol=1e-16, reltol=1e-12, repeat_nudge=1//100)
        push!(callbacks, eventCb)

        if timeEventHandling
            timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator),
                                            (integrator) -> affectFMU!(c, integrator, 0, inputFunction, inputValues), Float64; 
                                            initial_affect = true,
                                            save_positions=(saveAtEvent,saveAtEvent))
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
function fmi3SimulateCS(c::fmi3Instance, t_start::Real, t_stop::Real;
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
function fmi3SimulateSE(c::fmi3Instance, t_start::Real, t_stop::Real;
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
function fmi3Simulate(c::fmi3Instance, t_start::Real = 0.0, t_stop::Real = 1.0;kwargs...)

    if fmi3IsCoSimulation(c.fmu)
        return fmi3SimulateCS(c, t_start, t_stop; kwargs...)
    elseif fmi3IsModelExchange(c.fmu)
        return fmi3SimulateME(c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
