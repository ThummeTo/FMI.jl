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
function fmiPlot(fmu::FMU2, solution::ODESolution; kwargs...)
    fig = Plots.plot(; xlabel="t [s]")
    fmiPlot!(fig, fmu, solution; kwargs...)
    return fig
end
function fmiPlot!(fig, fmu::FMU2, solution::ODESolution; stateIndicies=1:length(fmu.modelDescription.stateValueReferences), maxLabelLength=64, plotkwargs...)
  
    t = solution.t

    numStates = length(solution.u[1])

    for s in 1:numStates
        if s ∈ stateIndicies
            vr = fmu.modelDescription.stateValueReferences[s]
            vrName = fmi2ValueReferenceToString(fmu, vr)[1]

            values = collect(data[s] for data in solution.u)

            # prevent legend labels from getting too long
            label = "$vrName ($vr)"
            labelLength = length(label)
            if labelLength > maxLabelLength
                label = "..." * label[labelLength-maxLabelLength:end]
            end

            Plots.plot!(fig, t, values; label=label, plotkwargs...)
        end 
    end
    return fig
end

"""
Plots data from a CS-FMU.
"""
function fmiPlot(fmu::FMU2, recordValues::fmi2ValueReferenceFormat, savedValues::DiffEqCallbacks.SavedValues; kwargs...)
    fig = Plots.plot(; xlabel="t [s]")
    fmiPlot!(fig, fmu, recordValues, savedValues; kwargs...)
    return fig
end
function fmiPlot!(fig, fmu::FMU2, recordValues::fmi2ValueReferenceFormat, savedValues::DiffEqCallbacks.SavedValues; maxLabelLength=64, plotkwargs...)

    ts = savedValues.t

    recordValues = prepareValueReference(fmu, recordValues)

    numVars = length(recordValues)

    for i in 1:numVars
        vr = recordValues[i]
        vrName = fmi2ValueReferenceToString(fmu, vr)[1]
        values = collect(data[i] for data in savedValues.saveval)

        # prevent legend labels from getting too long
        label = "$vrName ($vr)"
        labelLength = length(label)
        if labelLength > maxLabelLength
            label = "..." * label[labelLength-maxLabelLength:end]
        end

        Plots.plot!(fig, ts, values; label=label, plotkwargs...)
    end
    return fig
end

"""
Extended the original plot-command by plotting FMUs.
"""
function Plots.plot(fmu::FMU2, args...; kwargs...)
    fmiPlot(fmu, args...; kwargs...)
end
function Plots.plot!(fig, fmu::FMU2, args...; kwargs...)
    fmiPlot!(fig, fmu, args...; kwargs...)
end
