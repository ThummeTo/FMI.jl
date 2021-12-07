#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks

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
