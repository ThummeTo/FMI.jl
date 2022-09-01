#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMU2Solution
import ForwardDiff

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
    stateEvents::Union{Bool, Nothing}=nothing, 
    timeEvents::Union{Bool, Nothing}=nothing, 
    stateIndices=nothing, 
    valueIndices=nothing, 
    maxLabelLength=64, 
    plotkwargs...)

    numStateEvents = 0
    numTimeEvents = 0
    for e in solution.events
        if e.indicator > 0
            numStateEvents += 1
        else
            numTimeEvents += 1
        end
    end
  
    if states === nothing 
        states = (solution.states !== nothing)
    end

    if values === nothing 
        values = (solution.values !== nothing)
    end

    if stateEvents === nothing 
        stateEvents = false
        for e in solution.events 
            if e.indicator > 0
                stateEvents = true 
                break 
            end 
        end 

        if numStateEvents > 100
            @info "fmiPlot(...): Number of state events ($(numStateEvents)) exceeding 100, disabling automatic plotting of state events (can be forced with keyword `stateEvents=true`)."
            stateEvents = false 
        end
    end

    if timeEvents === nothing 
        timeEvents = false
        for e in solution.events 
            if e.indicator == 0
                timeEvents = true 
                break 
            end 
        end 

        if numTimeEvents > 100
            @info "fmiPlot(...): Number of time events ($(numTimeEvents)) exceeding 100, disabling automatic plotting of time events (can be forced with keyword `timeEvents=true`)."
            timeEvents = false 
        end
    end

    if stateIndices === nothing 
        stateIndices = 1:length(solution.fmu.modelDescription.stateValueReferences)
    end

    if valueIndices === nothing 
        if solution.values !== nothing
            valueIndices = 1:length(solution.values.saveval[1])
        end
    end

    plot_min = Inf
    plot_max = -Inf

    # plot states
    if states 
        t = collect(ForwardDiff.value(e) for e in solution.states.t)
        numValues = length(solution.states.u[1])

        for v in 1:numValues
            if v ∈ stateIndices
                vr = solution.fmu.modelDescription.stateValueReferences[v]
                vrNames = fmi2ValueReferenceToString(solution.fmu, vr)
                vrName = vrNames[1]
    
                vals = collect(ForwardDiff.value(data[v]) for data in solution.states.u)

                plot_min = min(plot_min, vals...)
                plot_max = max(plot_max, vals...)
    
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
        t = collect(ForwardDiff.value(e) for e in solution.values.t)
        numValues = length(solution.values.saveval[1])

        for v in 1:numValues
            if v ∈ valueIndices
                vr = solution.valueReferences[v]
                vrNames = fmi2ValueReferenceToString(solution.fmu, vr)
                vrName = vrNames[1]
    
                vals = collect(ForwardDiff.value(data[v]) for data in solution.values.saveval)

                plot_min = min(plot_min, vals...)
                plot_max = max(plot_max, vals...)
    
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

    if stateEvents
        first = true
        for e in solution.events
            if e.indicator > 0
                Plots.plot!(fig, [e.t, e.t], [plot_min, plot_max]; label=(first ? "State event(s)" : nothing), style=:dash, color=:blue)
                first = false
            end
        end
    end

    if timeEvents
        first = true
        for e in solution.events
            if e.indicator == 0
                Plots.plot!(fig, [e.t, e.t], [plot_min, plot_max]; label=(first ? "Time event(s)" : nothing), style=:dash, color=:red)
                first = false
            end
        end
    end
    
    return fig
end

"""
Extended the original plot-command by plotting FMUs.

For further information seek `?fmiPlot`.
"""
function Plots.plot(solution::FMU2Solution, args...; kwargs...)
    fmiPlot(solution, args...; kwargs...)
end
function Plots.plot!(fig, solution::FMU2Solution, args...; kwargs...)
    fmiPlot!(fig, solution, args...; kwargs...)
end
