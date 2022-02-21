#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using OrdinaryDiffEq: ODESolution

"""
Plots data from a ME-FMU.

Optional `t_in_solution` controls if the first state in the solution is interpreted as t(ime).
Optional keyword argument `maxLabelLength` controls the maximum length for legend labels (too long labels are cut from front).
"""
function fmiPlot(fmu::FMU3, solution::ODESolution; maxLabelLength=64)
  
    t = solution.t

    numStates = length(solution.u[1])

    fig = Plots.plot(xlabel="t [s]")
    for s in 1:numStates
        vr = fmu.modelDescription.stateValueReferences[s]
        vrName = fmi3ValueReference2String(fmu, vr)[1]

        values = collect(data[s] for data in solution.u)

        # prevent legend labels from getting too long
        label = "$vrName ($vr)"
        labelLength = length(label)
        if labelLength > maxLabelLength
            label = "..." * label[labelLength-maxLabelLength:end]
        end

        Plots.plot!(fig, t, values, label=label)
    end
    fig
end

"""
Extended the original plot-command by plotting FMUs.
"""
function Plots.plot(fmu::FMU3, solution::ODESolution)
    fmiPlot(fmu, solution)
end

"""
Plots data from a CS-FMU.
"""
function fmiPlot(fmu::FMU3, recordValues::fmi3ValueReferenceFormat, savedValues::DiffEqCallbacks.SavedValues; maxLabelLength=64)

    ts = savedValues.t

    recordValues = prepareValueReference(fmu, recordValues)

    numVars = length(recordValues)

    fig = Plots.plot(xlabel="t [s]")
    for i in 1:numVars
        vr = recordValues[i]
        vrName = fmi3ValueReference2String(fmu, vr)[1]
        values = collect(data[i] for data in savedValues.saveval)

        # prevent legend labels from getting too long
        label = "$vrName ($vr)"
        labelLength = length(label)
        if labelLength > maxLabelLength
            label = "..." * label[labelLength-maxLabelLength:end]
        end

        Plots.plot!(fig, ts, values, label=label)
    end
    fig
end

"""
Extended the original plot-command by plotting FMUs.
"""
function Plots.plot(fmu::FMU3, recordValues::fmi3ValueReferenceFormat, savedValues::DiffEqCallbacks.SavedValues)
    fmiPlot(fmu, recordValues, savedValues)
end
