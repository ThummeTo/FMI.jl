#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport.FMIBase.SciMLBase: solve, RightRootFind, ReturnCode
using FMIImport.FMIBase.DiffEqCallbacks: CallbackSet, SavedValues, copyat_or_push!

import LinearAlgebra: eigvals
import FMIImport.FMIBase.ProgressMeter

import FMIImport: prepareSolveFMU, finishSolveFMU
import FMIImport.FMIBase: setupODEProblem, setupCallbacks, setupSolver!, eval!
import FMIImport.FMIBase: getEmptyReal, getEmptyValueReference, isTrue, isStatusOK
import FMIImport.FMIBase: doStep

"""
    simulate(fmu, instance=nothing, tspan=nothing; kwargs...)
    simulate(fmu, tspan; kwargs...)
    simulate(instance, tspan; kwargs...)

Starts a simulation of the `FMU2` for the instantiated type: CS, ME or SE (this is selected automatically or during loading of the FMU).
You can force a specific simulation mode by calling [`simulateCS`](@ref), [`simulateME`](@ref) or [`simulateSE`](@ref) directly.

# Arguments
- `fmu::FMU`: The FMU to be simulated.
- `c::Union{FMUInstance, Nothing}=nothing`: The instance (FMI3) or component (FMI2) of the FMU, `nothing` if not available. 
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from FMU's model description or (0.0, 1.0) if not specified)

# Keyword arguments
- `recordValues::fmi2ValueReferenceFormat` = nothing: Array of variables (Strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = nothing`: Time points to save (interpolated) values at (default = nothing: save at each solver timestep)
- `setup::Bool`: call fmi2SetupExperiment, fmi2EnterInitializationMode and fmi2ExitInitializationMode before the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `reset::Bool`: call fmi2Reset before each the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `instantiate::Bool`: call fmi2Instantiate! simulate on a new created instance (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `freeInstance::Bool`: call fmi2FreeInstance at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `terminate::Bool`: call fmi2Terminate at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Input variables (Strings or variableIdentifiers) to set at each simulation step 
- `inputFunction = nothing`: Function to get values for the input variables at each simulation step. 
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dict of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `showProgress::Bool = true`: print simulation progress meter in REPL

## Input function pattern 
[`c`: current component, `u`: current state ,`t`: current time, returning array of values to be passed to `fmi2SetReal(..., inputValueReferences, inputFunction(...))` or `fmi3SetFloat64`]:
- `inputFunction(t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, u::AbstractVector{<:Real})`
- `inputFunction(x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`

# Returns:
- A [`FMUSolution`](@ref) struct.

See also [`simulate`](@ref), [`simulateME`](@ref), [`simulateCS`](@ref), [`simulateSE`](@ref).
"""
function simulate(
    fmu::FMU2,
    c::Union{FMU2Component,Nothing} = nothing,
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing;
    kwargs...,
)

    if fmu.type == fmi2TypeCoSimulation
        return simulateCS(fmu, c, tspan; kwargs...)
    elseif fmu.type == fmi2TypeModelExchange
        return simulateME(fmu, c, tspan; kwargs...)
    else
        error(unknownFMUType)
    end
end
function simulate(
    fmu::FMU3,
    c::Union{FMU3Instance,Nothing} = nothing,
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing;
    kwargs...,
)

    if fmu.type == fmi3TypeCoSimulation
        return simulateCS(fmu, c, tspan; kwargs...)
    elseif fmu.type == fmi3TypeModelExchange
        return simulateME(fmu, c, tspan; kwargs...)
    elseif fmu.type == fmi3TypeScheduledExecution
        return simulateSE(fmu, c, tspan; kwargs...)
    else
        error(unknownFMUType)
    end
end
simulate(c::FMUInstance, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulate(c.fmu, c, tspan; kwargs...)
simulate(fmu::FMU, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulate(fmu, nothing, tspan; kwargs...)
export simulate

"""
    simulateME(fmu, instance=nothing, tspan=nothing; kwargs...)
    simulateME(fmu, tspan; kwargs...)
    simulateME(instance, tspan; kwargs...)

Simulate ME-FMU for the given simulation time interval.
State- and Time-Events are handled correctly.

# Arguments
- `fmu::FMU`: The FMU to be simulated.
- `c::Union{FMUInstance, Nothing}=nothing`: The instance (FMI3) or component (FMI2) of the FMU, `nothing` if not available. 
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from FMU's model description or (0.0, 1.0) if not specified)

# Keyword arguments
- `solver = nothing`: Any Julia-supported ODE-solver (default = nothing: use DifferentialEquations.jl default solver)
- `recordValues::fmi2ValueReferenceFormat` = nothing: Array of variables (Strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `recordEventIndicators::Union{AbstractArray{<:Integer, 1}, UnitRange{<:Integer}, Nothing} = nothing`: Array or Range of event indicators to record
- `recordEigenvalues::Bool=false`: compute and record eigenvalues
- `saveat = nothing`: Time points to save (interpolated) values at (default = nothing: save at each solver timestep)
- `x0::Union{AbstractArray{<:Real}, Nothing} = nothing`: initial fmu State (default = nothing: use current or default-initial fmu state)
- `setup::Bool`: call fmi2SetupExperiment, fmi2EnterInitializationMode and fmi2ExitInitializationMode before the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `reset::Bool`: call fmi2Reset before each the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `instantiate::Bool`: call fmi2Instantiate! simulate on a new created instance (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `freeInstance::Bool`: call fmi2FreeInstance at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `terminate::Bool`: call fmi2Terminate at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Input variables (Strings or variableIdentifiers) to set at each simulation step 
- `inputFunction = nothing`: Function to get values for the input variables at each simulation step. 
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dict of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `callbacksBefore = []`: callbacks to call *before* the internal callbacks for state- and time-events are called
- `callbacksAfter = []`: callbacks to call *after* the internal callbacks for state- and time-events are called
- `showProgress::Bool = true`: print simulation progress meter in REPL
- `solveKwargs...`: keyword arguments that get passed onto the solvers solve call

## Input function pattern 
[`c`: current component, `u`: current state ,`t`: current time, returning array of values to be passed to `fmi2SetReal(..., inputValueReferences, inputFunction(...))` or `fmi3SetFloat64`]:
- `inputFunction(t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, u::AbstractVector{<:Real})`
- `inputFunction(x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`

# Returns:
- A [`FMUSolution`](@ref) struct.

See also [`simulate`](@ref), [`simulateCS`](@ref), [`simulateSE`](@ref).
"""
function simulateME(
    fmu::FMU,
    c::Union{FMUInstance,Nothing},
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing;
    solver = nothing, # [ToDo] type
    recordValues::fmi2ValueReferenceFormat = nothing,
    recordEventIndicators::Union{AbstractArray{<:Integer,1},UnitRange{<:Integer},Nothing} = nothing,
    recordEigenvalues::Bool = false,
    saveat = nothing, # [ToDo] type
    x0::Union{AbstractArray{<:Real},Nothing} = nothing,
    setup::Bool = fmu.executionConfig.setup,
    reset::Bool = fmu.executionConfig.reset,
    instantiate::Bool = fmu.executionConfig.instantiate,
    freeInstance::Bool = fmu.executionConfig.freeInstance,
    terminate::Bool = fmu.executionConfig.terminate,
    inputValueReferences::fmi2ValueReferenceFormat = nothing,
    inputFunction = nothing,
    parameters::Union{Dict{<:Any,<:Any},Nothing} = nothing,
    callbacksBefore::AbstractVector = [], # [ToDo] type
    callbacksAfter::AbstractVector = [], # [ToDo] type
    showProgress::Bool = true,
    solveKwargs...,
)

    @assert isModelExchange(fmu) "simulateME(...): This function supports Model Exchange FMUs only."

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = length(inputValueReferences) > 0

    solveKwargs = Dict{Symbol,Any}(solveKwargs...)
    tspan = setupSolver!(fmu, tspan, solveKwargs)
    t_start, t_stop = tspan

    if !isnothing(saveat)
        solveKwargs[:saveat] = saveat
    end

    progressMeter = nothing
    if showProgress
        progressMeter = ProgressMeter.Progress(
            1000;
            desc = "Simulating ME-FMU ...",
            color = :blue,
            dt = 1.0,
        ) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    # input function handling 
    _inputFunction = nothing
    if !isnothing(inputFunction)
        _inputFunction = FMUInputFunction(inputFunction, inputValueReferences)
    end

    inputs = nothing
    if hasInputs
        inputValues = eval!(_inputFunction, nothing, nothing, t_start)
        inputs = Dict(inputValueReferences .=> inputValues)
    end
    c, x0 = prepareSolveFMU(
        fmu,
        c,
        :ME;
        parameters = parameters,
        t_start = t_start,
        t_stop = t_stop,
        x0 = x0,
        inputs = inputs,
        instantiate = instantiate,
        freeInstance = freeInstance,
        terminate= terminate,
        reset = reset,
        setup = setup,
    )

    # Zero state FMU: add dummy state
    if c.fmu.isZeroState
        x0 = [0.0]
    end

    @assert !isnothing(x0) "x0 is nothing after prepare!"

    c.problem = setupODEProblem(c, x0, tspan; inputFunction = _inputFunction)
    cbs = setupCallbacks(
        c,
        recordValues,
        recordEventIndicators,
        recordEigenvalues,
        _inputFunction,
        inputValueReferences,
        progressMeter,
        t_start,
        t_stop,
        saveat,
    )

    #solveKwargs = Dict(solveKwargs...)
    #setupSolver(fmu, solveKwargs)

    for cb in callbacksBefore
        insert!(cbs, 1, cb)
    end

    for cb in callbacksAfter
        push!(cbs, cb)
    end

    # from here on, we are in event mode, if `setup=false` this is the job of the user
    #@assert c.state == fmi2ComponentStateEventMode "FMU needs to be in event mode after setup."

    # if x0 === nothing
    #     x0 = fmi2GetContinuousStates(c)
    #     x0_nom = fmi2GetNominalsOfContinuousStates(c)
    # end

    # initial event handling
    #handleEvents(c) 
    #fmi2EnterContinuousTimeMode(c)

    # callback functions

    if isnothing(solver)
        c.solution.states = solve(c.problem; callback = CallbackSet(cbs...), solveKwargs...)
    else
        c.solution.states =
            solve(c.problem, solver; callback = CallbackSet(cbs...), solveKwargs...)
    end

    c.solution.success = (c.solution.states.retcode == ReturnCode.Success)

    if !c.solution.success
        logWarning(
            fmu,
            "FMU simulation failed with solver return code `$(c.solution.states.retcode)`, please check log for hints.",
        )
    end

    # ZeroStateFMU: remove dummy state
    if c.fmu.isZeroState
        c.solution.states = nothing
    end

    # cleanup progress meter
    if showProgress
        ProgressMeter.finish!(progressMeter)
    end

    finishSolveFMU(fmu, c; freeInstance = freeInstance, terminate = terminate)

    return c.solution
end
simulateME(c::FMUInstance, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateME(c.fmu, c, tspan; kwargs...)
simulateME(fmu::FMU, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateME(fmu, nothing, tspan; kwargs...)
export simulateME

############ Co-Simulation ############
function auto_interval(t)
    """
    Find a nice interval that divides t into 500 - 1000 steps
    from https://github.com/CATIA-Systems/FMPy/blob/4166f08dd991cb6b5df2522ba125669e635327fe/fmpy/util.py#L1042
    """
    # Initial interval estimation
    h = 10 ^ (round(log10(t)) - 3)
    
    # Number of samples
    n_samples = t / h
    
    # Adjust interval based on number of samples
    if n_samples >= 2500
        h *= 5
    elseif n_samples >= 2000
        h *= 4
    elseif n_samples >= 1000
        h *= 2
    elseif n_samples <= 200
        h /= 5
    elseif n_samples <= 250
        h /= 4
    elseif n_samples <= 500
        h /= 2
    end
    
    return h
end
"""
    simulateCS(fmu, instance=nothing, tspan=nothing; kwargs...)
    simulateCS(fmu, tspan; kwargs...)
    simulateCS(instance, tspan; kwargs...)

Simulate CS-FMU for the given simulation time interval.
State- and Time-Events are handled internally by the FMU.

# Arguments
- `fmu::FMU`: The FMU to be simulated.
- `c::Union{FMUInstance, Nothing}=nothing`: The instance (FMI3) or component (FMI2) of the FMU, `nothing` if not available. 
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from FMU's model description or (0.0, 1.0) if not specified)

# Keyword arguments
- `tolerance::Union{Real, Nothing} = nothing`: The tolerance for the internal FMU solver.
- `recordValues::fmi2ValueReferenceFormat` = nothing: Array of variables (Strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = nothing`: Time points to save (interpolated) values at (default = nothing: save at each solver timestep)
- `setup::Bool`: call fmi2SetupExperiment, fmi2EnterInitializationMode and fmi2ExitInitializationMode before the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `reset::Bool`: call fmi2Reset before each the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `instantiate::Bool`: call fmi2Instantiate! simulate on a new created instance (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `freeInstance::Bool`: call fmi2FreeInstance at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `terminate::Bool`: call fmi2Terminate at the end of the simulation (default = nothing: use value from `fmu`'s `FMUExecutionConfiguration`)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Input variables (Strings or variableIdentifiers) to set at each simulation step 
- `inputFunction = nothing`: Function to get values for the input variables at each simulation step. 
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dict of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `showProgress::Bool = true`: print simulation progress meter in REPL

## Input function pattern 
[`c`: current component, `u`: current state ,`t`: current time, returning array of values to be passed to `fmi2SetReal(..., inputValueReferences, inputFunction(...))` or `fmi3SetFloat64`]:
- `inputFunction(t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, u::AbstractVector{<:Real})`
- `inputFunction(x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`
- `inputFunction(c::Union{FMUInstance, Nothing}, x::AbstractVector{<:Real}, t::Real, u::AbstractVector{<:Real})`

# Returns:
- A [`FMUSolution`](@ref) struct.

See also [`simulate`](@ref), [`simulateME`](@ref), [`simulateSE`](@ref).
"""
function simulateCS(
    fmu::FMU,
    c::Union{FMUInstance,Nothing},
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing;
    tolerance::Union{Real,Nothing} = nothing,
    dt::Union{Real,Nothing} = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    saveat = [],
    setup::Bool = fmu.executionConfig.setup,
    reset::Bool = fmu.executionConfig.reset,
    instantiate::Bool = fmu.executionConfig.instantiate,
    freeInstance::Bool = fmu.executionConfig.freeInstance,
    terminate::Bool = fmu.executionConfig.terminate,
    inputValueReferences::fmiValueReferenceFormat = nothing,
    inputFunction = nothing,
    showProgress::Bool = true,
    parameters::Union{Dict{<:Any,<:Any},Nothing} = nothing,
)

    @assert isCoSimulation(fmu) "simulateCS(...): This function supports Co-Simulation FMUs only."

    # input function handling 
    @debug "Simulating CS-FMU: Preparing input function ..."
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = (length(inputValueReferences) > 0)

    _inputFunction = nothing
    u = getEmptyReal(fmu)
    u_refs = getEmptyValueReference(fmu)
    if hasInputs
        _inputFunction = FMUInputFunction(inputFunction, inputValueReferences)
        u_refs = _inputFunction.vrs
    end

    # outputs 
    @debug "Simulating CS-FMU: Preparing outputs ..."
    y_refs = getEmptyValueReference(fmu)
    y = getEmptyReal(fmu)
    if !isnothing(recordValues)
        y_refs = prepareValueReference(fmu, recordValues)
        y = zeros(fmi2Real, length(y_refs))
    end

    t_start, t_stop = (tspan == nothing ? (nothing, nothing) : tspan)

    # pull default values from the model description - if not given by user
    @debug "Simulating CS-FMU: Pulling default values ..."
    variableSteps =
        isCoSimulation(fmu) &&
        isTrue(fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize)

    t_start = t_start === nothing ? getDefaultStartTime(fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start

    t_stop = t_stop === nothing ? getDefaultStopTime(fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop

    tolerance =
        tolerance === nothing ? getDefaultTolerance(fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 0.0 : tolerance

    dt = dt === nothing ? getDefaultStepSize(fmu.modelDescription) : dt
    dt = dt === nothing ? auto_interval(t_stop-t_start) : dt

    @debug "Simulating CS-FMU: Preparing inputs ..."
    inputs = nothing
    if hasInputs
        inputValues = eval!(_inputFunction, nothing, nothing, t_start)
        inputs = Dict(inputValueReferences .=> inputValues)
    end

    @debug "Simulating CS-FMU: Preparing solve ..."
    c, _ = prepareSolveFMU(
        fmu,
        c,
        :CS;
        instantiate = instantiate,
        freeInstance = freeInstance,
        terminate = terminate,
        reset = reset,
        setup = setup,
        parameters = parameters,
        t_start = t_start,
        t_stop = t_stop,
        tolerance = tolerance,
        inputs = inputs,
    )
    fmusol = c.solution

    # default setup
    if length(saveat) == 0
        saveat = t_start:dt:t_stop
    end

    # setup if no variable steps
    if variableSteps == false
        if length(saveat) >= 2
            dt = saveat[2] - saveat[1]
        end
    end

    t = t_start

    progressMeter = nothing
    if showProgress
        progressMeter =
            ProgressMeter.Progress(1000; desc = "Sim. CS-FMU ...", color = :blue, dt = 1.0)
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    first_step = true

    fmusol.values =
        SavedValues(Float64, Tuple{collect(Float64 for i = 1:length(y_refs))...})
    fmusol.valueReferences = copy(y_refs)

    i = 1

    fmusol.success = true

    @debug "Starting simulation from $(t_start) to $(t_stop), variable steps: $(variableSteps)"

    while t < t_stop

        if variableSteps
            if length(saveat) > (i + 1)
                dt = saveat[i+1] - saveat[i]
            else
                dt = t_stop - t
            end
        end

        if !first_step
            ret = doStep(c, dt; currentCommunicationPoint = t)

            if !isStatusOK(fmu, ret)
                fmusol.success = false
            end

            t = t + dt
            i += 1
        else
            first_step = false
        end

        if hasInputs
            u = eval!(_inputFunction, c, nothing, t)
        end

        c(u = u, u_refs = u_refs, y = y, y_refs = y_refs)

        svalues = (y...,)
        copyat_or_push!(fmusol.values.t, i, t)
        copyat_or_push!(fmusol.values.saveval, i, svalues, Val{false})

        if !isnothing(progressMeter)
            ProgressMeter.update!(
                progressMeter,
                floor(Integer, 1000.0 * (t - t_start) / (t_stop - t_start)),
            )
        end

    end

    if !fmusol.success
        logWarning(fmu, "FMU simulation failed, please check log for hints.")
    end

    if !isnothing(progressMeter)
        ProgressMeter.finish!(progressMeter)
    end

    finishSolveFMU(fmu, c; freeInstance = freeInstance, terminate = terminate)

    return fmusol
end
simulateCS(c::FMUInstance, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateCS(c.fmu, c, tspan; kwargs...)
simulateCS(fmu::FMU, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateCS(fmu, nothing, tspan; kwargs...)
export simulateCS

# [TODO] simulate ScheduledExecution
"""
    simulateSE(fmu, instance=nothing, tspan=nothing; kwargs...)
    simulateSE(fmu, tspan; kwargs...)
    simulateSE(instance, tspan; kwargs...)

To be implemented ...

# Arguments
- `fmu::FMU3`: The FMU to be simulated. Note: SE is only available in FMI3.
- `c::Union{FMU3Instance, Nothing}=nothing`: The instance (FMI3) of the FMU, `nothing` if not available. 
- `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Simulation-time-span as tuple (default = nothing: use default value from FMU's model description or (0.0, 1.0) if not specified)

# Keyword arguments
- To be implemented ...

# Returns:
- A [`FMUSolution`](@ref) struct.

See also [`simulate`](@ref), [`simulateME`](@ref), [`simulateCS`](@ref).
"""
function simulateSE(
    fmu::FMU2,
    c::Union{FMU2Component,Nothing},
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing,
)
    @assert false "This is a FMI2-FMU, scheduled execution is not supported in FMI2."
end
function simulateSE(
    fmu::FMU3,
    c::Union{FMU3Instance,Nothing},
    tspan::Union{Tuple{Float64,Float64},Nothing} = nothing,
)
    # [ToDo]   
    @assert false "Not implemented yet. Please open an issue if this is needed."
end
simulateSE(c::FMUInstance, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateSE(c.fmu, c, tspan; kwargs...)
simulateSE(fmu::FMU, tspan::Tuple{Float64,Float64}; kwargs...) =
    simulateSE(fmu, nothing, tspan; kwargs...)
export simulateSE
