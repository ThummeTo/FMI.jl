#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks, Zygote

"""Handle events and return the values and nominals of the changed continuous states"""
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
            error("Event info returned an error")
        end
    end

    fmi2EnterContinuousTimeMode(c)

    return valuesOfContinuousStatesChanged, nominalsOfContinuousStatesChanged

end

"""Returns the event indicators for an FMU"""
function condition(c::fmi2Component, out, x, t, integrator) # Event when event_f(u,t) == 0

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    indicators = fmi2GetEventIndicators(c)

    copy!(out, indicators)

end

"""Handles the upcoming events"""
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

"""Does one step in the simulation"""
function stepCompleted(c::fmi2Component, x, t, integrator)

     (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
     if enterEventMode == fmi2True
        affect!(c, integrator, 0)
     end

end

"""Returns the derivatives of the FMU"""
function fx(c::fmi2Component, x, p, t)

    fmi2SetTime(c, t)
    fmi2SetContinuousStates(c, x)
    dx = fmi2GetDerivatives(c)

end

""" Source: FMISpec2.0.2[p.90 ff]: 3.2.4 Pseudocode Example
    simulates an fmu instance for the set simulation time """
function fmi2SimulateME(c::fmi2Component, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, solver = Tsit5(), customFx = nothing)

    if customFx == nothing
        customFx = (x, p, t) -> fx(c, x, p, t)
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
     solution = solve(problem, solver, callback=CallbackSet(eventCb, stepCb))
     #data = solution(ts)
end

function fmi2SimulateME(fmu::FMU2, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, solver = Tsit5(), customFx = nothing)
    fmi2SimulateME(fmu.components[end], dt, t_start, t_stop, solver, customFx)
end
