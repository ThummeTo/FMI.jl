#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution
import FMIImport.FMICore: unsense

"""
    fmiPlot(solution::FMUSolution; kwargs...)

Create a figure and [`fmiPlot!`](@ref)'s the `solution` of a FMU simulation with the `kwargs` into it and returns the figure. 
(requires Package Plots in Julia Environment)

See also [`fmiPlot!`](@ref)
"""
function fmiPlot(solution::FMUSolution; kwargs...)
    fig = Plots.plot(; xlabel="t [s]")
    fmiPlot!(fig, solution; kwargs...)
    return fig
end
export fmiPlot

"""
    fmiPlot!(fig::Plots.Plot, solution::FMUSolution; 
                [states::Union{Bool, Nothing}=nothing,
                values::Union{Bool, Nothing}=nothing,
                stateEvents::Union{Bool, Nothing}=nothing,
                timeEvents::Union{Bool, Nothing}=nothing,
                stateIndices=nothing,
                valueIndices=nothing,
                maxLabelLength=64,
                plotkwargs...])

Plot the `solution` of a FMU simulation into `fig` and return the figure.

# Arguments
- `fig::Plots.Plot`: Figure to plot into
- `solution::FMUSolution`: Struct containing information about the solutions values, success, states and events of a specific FMU simulation.
- `states::Union{Bool, Nothing}=nothing`: controls if states should be plotted (default = nothing: plot states from `solution`, as long as they exist)
- `values::Union{Bool, Nothing}=nothing`: controls if values should be plotted (default = nothing: plot values from `solution`, as long as they exist)
- `stateEvents::Union{Bool, Nothing}=nothing`: controls if stateEvents should be plotted (default = nothing: plot stateEvents from `solution`, if at least one and at most 100 exist)
- `timeEvents::Union{Bool, Nothing}=nothing`: controls if timeEvents should be plotted (default = nothing: plot timeEvents from `solution`, if at least one and at most 100 exist)
- `stateIndices=nothing`: controls which states will be plotted by index in state vector (default = nothing: plot all states)
- `valueIndices=nothing`: controls which values will be plotted by index (default = nothing: plot all values)
- `maxLabelLength=64`: controls the maximum length for legend labels (too long labels are cut from front)
- `plotkwargs...`: Arguments, that are passed on to Plots.plot!

See also [`fmiPlot`](@ref)
"""
function fmiPlot!(fig::Plots.Plot, solution::FMUSolution;
    states::Union{Bool, Nothing}=nothing,
    values::Union{Bool, Nothing}=nothing,
    stateEvents::Union{Bool, Nothing}=nothing,
    timeEvents::Union{Bool, Nothing}=nothing,
    stateIndices=nothing,
    valueIndices=nothing,
    maxLabelLength=64,
    plotkwargs...)

    component = nothing
    if isa(solution, FMU2Solution)
        component = solution.component
    elseif isa(solution, FMU3Solution)
        component = solution.fmu.instances[end] # ToDo: This is very poor!
    else
        @assert false "Invalid solution type."
    end

    numStateEvents = 0
    numTimeEvents = 0
    for e in solution.events
        if e.indicator > 0
            numStateEvents += 1
        else
            numTimeEvents += 1
        end
    end

    if isnothing(states)
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
        stateIndices = 1:length(component.fmu.modelDescription.stateValueReferences)
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
        t = collect(unsense(e) for e in solution.states.t)
        numValues = length(solution.states.u[1])

        for v in 1:numValues
            if v ∈ stateIndices
                vr = component.fmu.modelDescription.stateValueReferences[v]
                vrNames = fmi2ValueReferenceToString(component.fmu, vr)
                vrName = length(vrNames) > 0 ? vrNames[1] : "?"

                vals = collect(unsense(data[v]) for data in solution.states.u)

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
        t = collect(unsense(e) for e in solution.values.t)
        numValues = length(solution.values.saveval[1])

        for v in 1:numValues
            if v ∈ valueIndices
                vr = "[unknown]"
                vrName = "[unknown]"
                if solution.valueReferences != nothing && v <= length(solution.valueReferences)
                    vr = solution.valueReferences[v]
                    vrNames = fmi2ValueReferenceToString(component.fmu, vr)
                    vrName = length(vrNames) > 0 ? vrNames[1] : "?"
                end
    
                vals = collect(unsense(data[v]) for data in solution.values.saveval)

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
export fmiPlot!

"""
    Plots.plot(solution::FMUSolution; kwargs...)
    Plots.plot!(fig::Plots.Plot, solution::FMUSolution; kwargs...)

Plot FMUs using the original plot-command from Plots.

See also [`fmiPlot`](@ref), [`fmiPlot!`](@ref).
""" Plots.plot, Plots.plot!
function Plots.plot(solution::FMUSolution; kwargs...)
    fmiPlot(solution; kwargs...)
end
function Plots.plot!(fig::Plots.Plot, solution::FMUSolution; kwargs...)
    fmiPlot!(fig, solution; kwargs...)
end
