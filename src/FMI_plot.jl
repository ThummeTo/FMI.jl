#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Plots
using OrdinaryDiffEq: ODESolution

function fmiPlot(fmu::FMU2, solution::ODESolution, t_in_solution = false)
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

        Plots.plot!(fig, t, values, label="$vrName ($vr)")
    end
    fig
end
function Plots.plot(fmu::FMU2, solution::ODESolution, t_in_solution)
    fmiPlot(fmu, solution, t_in_solution)
end

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
function Plots.plot(sd::fmi2SimulationResult)
    fmiPlot(sd)
end
