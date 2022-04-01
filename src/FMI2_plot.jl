#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using OrdinaryDiffEq: ODESolution
using FMIImport: FMU2Solution

"""
Plots data from a ME-FMU.

Optional `t_in_solution` controls if the first state in the solution is interpreted as t(ime).
Optional keyword argument `maxLabelLength` controls the maximum length for legend labels (too long labels are cut from front).
"""
function fmiPlot(solution::FMU2Solution; kwargs...)
    fig = Plots.plot(; xlabel="t [s]")
    fmiPlot!(fig, solution; kwargs...)
    return fig
end
function fmiPlot!(fig, solution::FMU2Solution; 
    states::Union{Bool, Nothing}=nothing, 
    values::Union{Bool, Nothing}=nothing, 
    stateIndices=nothing, 
    valueIndices=nothing, 
    maxLabelLength=64, 
    plotkwargs...)
  
    if states === nothing 
        states = (solution.states !== nothing)
    end

    if values === nothing 
        values = (solution.values !== nothing)
    end

    if stateIndices === nothing 
        stateIndices = 1:length(solution.fmu.modelDescription.stateValueReferences)
    end

    if valueIndices === nothing 
        if solution.values !== nothing
            valueIndices = 1:length(solution.values.saveval[1])
        end
    end

    # plot states
    if states 
        t = solution.states.t
        numValues = length(solution.states.u[1])

        for v in 1:numValues
            if v ∈ stateIndices
                vr = solution.fmu.modelDescription.stateValueReferences[v]
                vrNames = fmi2ValueReferenceToString(solution.fmu, vr)
                vrName = vrNames[1]
    
                vals = collect(data[v] for data in solution.states.u)
    
                # prevent legend labels from getting too long
                label = "$vrName ($vr)"
                labelLength = length(label)
                if labelLength > maxLabelLength
                    label = "..." * label[labelLength-maxLabelLength:end]
                end
    
                Plots.plot!(fig, t, vals; label=label, plotkwargs...)
            end 
        end
    end 

    # plot recorded values
    if values
        t = solution.values.t
        numValues = length(solution.values.saveval[1])

        for v in 1:numValues
            if v ∈ valueIndices
                vr = solution.valueReferences[v]
                vrNames = fmi2ValueReferenceToString(solution.fmu, vr)
                vrName = vrNames[1]
    
                vals = collect(data[v] for data in solution.values.saveval)
    
                # prevent legend labels from getting too long
                label = "$vrName ($vr)"
                labelLength = length(label)
                if labelLength > maxLabelLength
                    label = "..." * label[labelLength-maxLabelLength:end]
                end
    
                Plots.plot!(fig, t, vals; label=label, plotkwargs...)
            end 
        end
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
