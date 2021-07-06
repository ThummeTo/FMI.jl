#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Plots
using OrdinaryDiffEq: ODESolution

"""
Plots ODE-Solution from FMU (ODE states are interpreted as the FMU states).

Optional `t_in_solution` controls if the first state in the solution is interpreted as t(ime).
Optional keyword argument `maxLabelLength` controls the maximum length for legend labels (too long labels are cut from front).
"""
function fmiPlot(fmu::FMU2, solution::ODESolution, t_in_solution = false; maxLabelLength=64)
    t = nothing
    offset = 0
    if t_in_solution
        t = collect(data[1] for data in solution.u)
        offset = 1
    else
        t = solution.t
        offset = 0
    end

    numStates = length(solution.u[1]) - offset

    fig = Plots.plot(xlabel="t [s]")
    for s in 1:numStates
        vr = fmu.modelDescription.stateValueReferences[s]
        vrName = fmi2ValueReference2String(fmu, vr)[1]

        values = collect(data[s+offset] for data in solution.u)

        # prevent legend labels from getting too long
        label = "$vrName ($vr)"
        labelLength = length(label)
        if labelLength > maxLabelLength
            label = "..." * label[labelLength-maxLabelLength, end]
        end

        Plots.plot!(fig, t, values, label=label)
    end
    fig
end

# extend the original plot-command by plotting FMUs
function Plots.plot(fmu::FMU2, solution::ODESolution, t_in_solution = false)
    fmiPlot(fmu, solution, t_in_solution)
end

"""
Plots fmi2SimulationResult.
"""
function fmiPlot(sd::fmi2SimulationResult)
    ts = fmi2SimulationResultGetTime(sd)

    numVars = length(sd.dataPoints[1])-1

    fig = Plots.plot(xlabel="t [s]")
    for i in 1:numVars
        vr = sd.valueReferences[i]
        vrName = fmi2ValueReference2String(sd.fmu, vr)[1]
        values = fmi2SimulationResultGetValuesAtIndex(sd, i+1)
        Plots.plot!(fig, ts, values, label="$vrName ($vr)")
    end
    fig
end

# extend the original plot-command by plotting FMUs.
function Plots.plot(sd::fmi2SimulationResult)
    fmiPlot(sd)
end
