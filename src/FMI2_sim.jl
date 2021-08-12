#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks, Zygote

############ Model-Exchange ############

"""
Handles events and returns the values and nominals of the changed continuous states.
"""
function handleEvents(c::fmi2Component, initialEventMode)

    if initialEventMode == false
        fmi2EnterEventMode(c)
    end

    eventInfo = fmi2NewDiscreteStates(c)

    eventInfo.newDiscreteStatesNeeded = fmi2True
    valuesOfContinuousStatesChanged = fmi2False
    nominalsOfContinuousStatesChanged = fmi2False

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

    fmi2EnterContinuousTimeMode(c)

    return valuesOfContinuousStatesChanged, nominalsOfContinuousStatesChanged

end

"""
Returns the event indicators for an FMU.
"""
function condition(c::fmi2Component, out, x, t, integrator) # Event when event_f(u,t) == 0

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    indicators = fmi2GetEventIndicators(c)

    copy!(out, indicators)

end

"""
Handles the upcoming events.
"""
function affect!(c::fmi2Component, integrator, idx)
    # Event found - handle it
    continuousStatesChanged, nominalsChanged = handleEvents(c, false)

    if continuousStatesChanged == fmi2True
        integrator.u = fmi2GetContinuousStates(c)
    end

    if nominalsChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end
end

"""
Does one step in the simulation.
"""
function stepCompleted(c::fmi2Component, x, t, integrator)

     (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
     if enterEventMode == fmi2True
        affect!(c, integrator, 0)
     end

end

"""
Returns the state derivatives of the FMU.
"""
function fx(c::fmi2Component, x, p, t)
    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    dx = fmi2GetDerivatives(c)
end

"""
Source: FMISpec2.0.2[p.90 ff]: 3.2.4 Pseudocode Example

Simulates an fmu instance for the set simulation time.
Events are handled correctly.

Returns an ODESolution.
"""
function fmi2SimulateME(c::fmi2Component, t_start::Real = 0.0, t_stop::Real = 1.0;
                        solver = nothing,
                        customFx = nothing,
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup = true)

    recordValues = prepareValueReference(c, recordValues)

    if length(recordValues) > 0
        @warn "fmi2SimulateME(...): Recording values via `recordValues` not implemented, yet."
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

    eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator),
                                       (integrator, idx) -> affect!(c, integrator, idx),
                                       Int64(c.fmu.modelDescription.numberOfEventIndicators))

    stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator);
                                     func_everystep=true,
                                     func_start=true)

     # First evaluation of the FMU
     x0 = fmi2GetContinuousStates(c)
     x0_nom = fmi2GetNominalsOfContinuousStates(c)

     fmi2SetContinuousStates(c, x0)
     handleEvents(c, true)

     # Get states of handling initial Events
     x0 = fmi2GetContinuousStates(c)
     x0_nom = fmi2GetNominalsOfContinuousStates(c)

     p = []
     problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)
     solution = solve(problem, solver, callback=CallbackSet(eventCb, stepCb), saveat=saveat)
end

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.
"""
function fmi2SimulateCS(c::fmi2Component, t_start::Real, t_stop::Real;
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup = true)

    recordValues = prepareValueReference(c, recordValues)
    variableSteps = c.fmu.modelDescription.CScanHandleVariableCommunicationStepSize 

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

    sd = nothing
    record = length(recordValues) > 0

    #numDigits = length(string(round(Integer, 1/dt)))

    if record
        sd = fmi2SimulationResult()
        sd.valueReferences = recordValues
        sd.dataPoints = []
        sd.fmu = c.fmu

        values = fmi2GetReal(c, sd.valueReferences)
        push!(sd.dataPoints, (t, values...))

        i = 1
        while t < t_stop
            if variableSteps
                dt = saveat[i+1] - saveat[i]
            end

            fmi2DoStep(c, t, dt)
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1

            values = fmi2GetReal(c, sd.valueReferences)
            push!(sd.dataPoints, (t, values...))
        end
    else
        i = 1
        while t < t_stop
            if variableSteps
                dt = saveat[i+1] - saveat[i]
            end

            fmi2DoStep(c, t, dt)
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1
        end
    end

    sd
end

###############

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available the CoSimulation Simulation is started.
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
