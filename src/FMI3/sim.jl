#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks
import FMIImport.SciMLSensitivity.SciMLBase: RightRootFind, ReturnCode

using FMIImport: fmi3EnterInitializationMode, fmi3ExitInitializationMode, fmi3UpdateDiscreteStates, fmi3GetContinuousStates, fmi3GetNominalsOfContinuousStates, fmi3SetContinuousStates, fmi3GetContinuousStateDerivatives!
using FMIImport.FMICore: fmi3StatusOK, fmi3TypeCoSimulation, fmi3TypeModelExchange
using FMIImport.FMICore: fmi3InstanceState, fmi3InstanceStateInstantiated, fmi3InstanceStateInitializationMode, fmi3InstanceStateEventMode, fmi3InstanceStateContinuousTimeMode, fmi3InstanceStateTerminated, fmi3InstanceStateError, fmi3InstanceStateFatal
using FMIImport: FMU3Solution, FMU3Event

using FMIImport.ChainRulesCore
import FMIImport.ForwardDiff

import ProgressMeter

############ Model-Exchange ############

# Read next time event from FMU and provide it to the integrator 
function time_choice(c::FMU3Instance, integrator, tStart, tStop) 
    #@info "TC"
    
    discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)

    if nextEventTimeDefined == fmi3True

        if nextEventTime >= tStart && nextEventTime <= tStop
            return nextEventTime
        else
            # the time event is outside the simulation range!
            @debug "Next time event @$(c.eventInfo.nextEventTime)s is outside simulation time range ($(tStart), $(tStop)), skipping."
            return nothing 
        end
    else
        return nothing
    end
end

# Handles events and returns the values and nominals of the changed continuous states.
function handleEvents(c::FMU3Instance)
    # @assert c.state == fmi3InstanceStateEventMode "handleEvents(...): Must be in event mode!"
    
    # trigger the loop
    discreteStatesNeedUpdate = fmi3True
    nominalsChanged = fmi3False
    valuesChanged = fmi3False
    nextEventTimeDefined = fmi3False
    nextEventTime = 0.0
    
    while discreteStatesNeedUpdate == fmi3True

        # TODO set inputs
        discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)
        
        if c.state != fmi3InstanceStateEventMode
            fmi3EnterEventMode(c, c.stepEvent, c.stateEvent, c.rootsFound, Csize_t(c.fmu.modelDescription.numberOfEventIndicators), c.timeEvent)
        end
        # TODO inputEvent handling
        discreteStatesNeedUpdate = fmi3True
        while discreteStatesNeedUpdate == fmi3True
            # update discrete states
            discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime = fmi3UpdateDiscreteStates(c)
          
            if valuesOfContinuousStatesChanged == fmi3True 
                valuesChanged = true
            end

            if nominalsOfContinuousStatesChanged == fmi3True 
                nominalsChanged = true
            end

            if terminateSimulation == fmi3True
                @error "fmi3UpdateDiscreteStates returned error!"
            end
        end
    end
    fmi3EnterContinuousTimeMode(c)
    @debug "handleEvents(_, $(enterEventMode), $(exitInContinuousMode)): rootsFound: $(c.rootsFound)   valuesChanged: $(valuesChanged)   continuousStates: $(fmi3GetContinuousStates(c))", 
    return valuesChanged, nominalsChanged

end

# Returns the event indicators for an FMU.
function condition(c::FMU3Instance, out::AbstractArray{<:Real}, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi3ValueReference}) 
    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(c, x, t))
    end

    @assert c.state == fmi3InstanceStateContinuousTimeMode "condition(...): Must be called in mode continuous time."

    fmi3SetContinuousStates(c, x)
    fmi3SetTime(c, t)
    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(c, x, t)) 
    end

    # TODO check implementation of fmi3GetEventIndicators! mit abstract array
    fmi3GetEventIndicators!(c, out, UInt(length(out)))

    # if length(indicators) > 0
    #     for i in 1:length(indicators)
    #         if c.z_prev[i] < 0 && indicators[i] >= 0
    #             c.rootsFound[i] = 1
    #         elseif c.z_prev[i] > 0 && indicators[i] <= 0
    #             c.rootsFound[i] = -1
    #         else
    #             c.rootsFound[i] = 0
    #         end
    #         c.stateEvent |= (c.rootsFound[i] != 0)
    #         # c.z_prev[i] = indicators[i]
    #     end
    # end

    return nothing
end

# Handles the upcoming events.
function affectFMU!(c::FMU3Instance, integrator, idx, inputFunction, inputValues::Array{fmi3ValueReference}, solution::FMU3Solution)
    
    @assert c.state == fmi3InstanceStateContinuousTimeMode "affectFMU!(...): Must be in continuous time mode!"
    
    # there are fx-evaluations before the event is handled, reset the FMU state to the current integrator step
    fmi3SetContinuousStates(c, integrator.u)
    fmi3SetTime(c, integrator.t)
    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(c, integrator.u, integrator.t))
    end

    fmi3EnterEventMode(c, c.stepEvent, c.stateEvent, c.rootsFound, Csize_t(c.fmu.modelDescription.numberOfEventIndicators), c.timeEvent)
    
    # Event found - handle it
    handleEvents(c)

    left_x = nothing 
    right_x = nothing

    if c.eventInfo.valuesOfContinuousStatesChanged == fmi3True
        left_x = integrator.u
        right_x = fmi3GetContinuousStates(c)
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), new state is $(new_u)"
        integrator.u = right_x

        u_modified!(integrator, true)
        #set_proposed_dt!(integrator, 1e-10)
    else 
        u_modified!(integrator, false)
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), no new state."
    end

    if c.eventInfo.nominalsOfContinuousStatesChanged == fmi3True
        x_nom = fmi3GetNominalsOfContinuousStates(c)
    end

    ignore_derivatives() do 
        if idx != -1 # -1 no event, 0, time event, >=1 state event with indicator
            e = FMU3Event(integrator.t, UInt64(idx), left_x, right_x)
            push!(solution.events, e)
        end
    end 

    #fmi3EnterContinuousTimeMode(c)
end

# Does one step in the simulation.
function stepCompleted(c::FMU3Instance, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi3ValueReference}, progressMeter, tStart, tStop, solution::FMU3Solution)

    @assert c.state == fmi3InstanceStateContinuousTimeMode "stepCompleted(...): Must be in continuous time mode."
    #@info "Step completed"
    if progressMeter !== nothing
        stat = 1000.0*(t-tStart)/(tStop-tStart)
        if !isnan(stat)
            stat = floor(Integer, stat)
            ProgressMeter.update!(progressMeter, stat)
        end
    end

    # if length(indicators) > 0
    #     c.stateEvent = fmi3False
    
    #     for i in 1:length(indicators)
    #         if c.z_prev[i] < 0 && indicators[i] >= 0
    #             c.rootsFound[i] = 1
    #         elseif c.z_prev[i] > 0 && indicators[i] <= 0
    #             c.rootsFound[i] = -1
    #         else
    #             c.rootsFound[i] = 0
    #         end
    #         c.stateEvent |= (c.rootsFound[i] != 0)
    #         c.z_prev[i] = indicators[i]
    #     end
    # end
    (status, enterEventMode, terminateSimulation) = fmi3CompletedIntegratorStep(c, fmi3True)
    
    if terminateSimulation == fmi3True
        @error "stepCompleted(...): FMU requested termination!"
    end

    if enterEventMode == fmi3True
        affectFMU!(c, integrator, -1, inputFunction, inputValues, solution)
    else
        if inputFunction !== nothing
            fmi3SetFloat64(c, inputValues, inputFunction(c, x, t)) 
        end
    end
end

# save FMU values 
function saveValues(c::FMU3Instance, recordValues, x, t, integrator, inputFunction, inputValues)

    @assert c.state == fmi3InstanceStateContinuousTimeMode "saveValues(...): Must be in continuous time mode."

    #x_old = fmi3GetContinuousStates(c)
    #t_old = c.t
    
    fmi3SetContinuousStates(c, x)
    fmi3SetTime(c, t) 
    if inputFunction !== nothing
        fmi3SetFloat64(c, inputValues, inputFunction(c, x, t)) 
    end

    #fmi3SetContinuousStates(c, x_old)
    #fmi3SetTime(c, t_old)
    
    return (fmi3GetFloat64(c, recordValues)...,)
end

# Returns the state derivatives of the FMU.
function fx(c::FMU3Instance, 
    dx::AbstractArray{<:Real},
    x::AbstractArray{<:Real}, 
    p::Tuple,
    t::Real)

    # if isa(t, ForwardDiff.Dual) 
    #     t = ForwardDiff.value(t)
    # end 
    @debug "fx($(x), _, $(t))"
    fmi3SetTime(c, t) 
    fmi3SetContinuousStates(c, x)
    dx = fmi3GetContinuousStateDerivatives(c)

    # if all(isa.(dx, ForwardDiff.Dual))
    #     dx_tmp = collect(ForwardDiff.value(e) for e in dx)
    #     fmi3GetContinuousStateDerivatives!(c, dx_tmp)
    #     T, V, N = fd_eltypes(dx)
    #     dx[:] = collect(ForwardDiff.Dual{T, V, N}(dx_tmp[i], ForwardDiff.partials(dx[i])    ) for i in 1:length(dx))
    # else 
    #     fmi3GetContinuousStateDerivatives!(c, dx)
    # end

    # y, dx = FMIImport.eval!(c, dx, nothing, nothing, x, nothing, nothing, t)

    return dx
end

# same function as in FMI2_sim.jl
function fd_eltypes(e::ForwardDiff.Dual{T, V, N}) where {T, V, N}
    return (T, V, N)
end
function fd_eltypes(e::AbstractArray{<:ForwardDiff.Dual{T, V, N}}) where {T, V, N}
    return (T, V, N)
end

# same function as in FMI2_sim.jl
function _fx_fd(comp, dx, x, p, t) 

    ȧrgs = []
    args = []

    push!(ȧrgs, NoTangent())
    push!(args, fx)

    push!(ȧrgs, NoTangent())
    push!(args, comp)

    T = nothing
    V = nothing

    dx_set = length(dx) > 0 && all(isa.(dx, ForwardDiff.Dual))
    x_set = length(x) > 0 && all(isa.(x, ForwardDiff.Dual))
    p_set = length(p) > 0 && all(isa.(p, ForwardDiff.Dual))
    t_set = isa(t, ForwardDiff.Dual)

    if dx_set
        T, V, N = fd_eltypes(dx)
        push!(ȧrgs, collect(ForwardDiff.partials(e) for e in dx))
        push!(args, collect(ForwardDiff.value(e) for e in dx))
        #@info "dx_set num=$(length(dx)) partials=$(length(ForwardDiff.partials(dx[1])))"
    else 
        push!(ȧrgs, NoTangent())
        push!(args, dx)
    end

    if x_set
        T, V, N = fd_eltypes(x)
        push!(ȧrgs, collect(ForwardDiff.partials(e) for e in x))
        push!(args, collect(ForwardDiff.value(e) for e in x))
        #@info "x_set num=$(length(x)) partials=$(length(ForwardDiff.partials(x[1])))"
    else 
        push!(ȧrgs, NoTangent())
        push!(args, x)
    end

    if p_set
        T, V, N = fd_eltypes(p)
        push!(ȧrgs, collect(ForwardDiff.partials(e) for e in p))
        push!(args, collect(ForwardDiff.value(e) for e in p))
    else 
        push!(ȧrgs, NoTangent())
        push!(args, p)
    end

    if t_set
        T, V, N = fd_eltypes(t)
        push!(ȧrgs, ForwardDiff.partials(t))
        push!(args, ForwardDiff.value(t))
    else 
        push!(ȧrgs, NoTangent())
        push!(args, t)
    end
  
    ȧrgs = (ȧrgs...,)
    args = (args...,)
        
    y, _, sdx, sx, sp, st = ChainRulesCore.frule(ȧrgs, args...)

    ys = []

    #[collect( ForwardDiff.Dual{Tx, Vx, Nx}(y[i], ForwardDiff.partials(x_partials[i], t_partials[i])) for i in 1:length(y) )...]
    for i in 1:length(y)
        is = NoTangent()
        
        if dx_set
            is = sdx[i]#.values
        end
        if x_set
            is = sx[i]#.values
        end

        if p_set
            is = sp[i]#.values
        end
        if t_set
            is = st[i]#.values
        end

        #display("dx: $dx")
        #display("sdx: $sdx")

        #partials = (isdx, isx, isp, ist)

        #display(partials)
        

        #V = Float64 
        #N = length(partials)
        #display("$T $V $N")

        #display(is)

        @assert is != ZeroTangent() && is != NoTangent() "is: $(is)"

        push!(ys, ForwardDiff.Dual{T, V, N}(y[i], is    )   ) #  ForwardDiff.Partials{N, V}(partials)
    end 

    ys
end

# same functionhead as in FMI2_sim.jl
# frule for fx
function ChainRulesCore.frule((Δself, Δcomp, Δdx, Δx, Δp, Δt), 
    ::typeof(fx), 
    comp, #::FMU3Instance,
    dx, 
    x,#::AbstractArray{<:Real},
    p,
    t)

    y = fx(comp, dx, x, p, t)
    function fx_pullforward(Δdx, Δx, Δt)

        # if t >= 0.0 
        #     fmi3SetTime(comp, t)
        # end

        # if all(isa.(x, ForwardDiff.Dual))
        #     xf = collect(ForwardDiff.value(e) for e in x)
        #     fmi3SetContinuousStates(comp, xf)
        # else
        #     fmi3SetContinuousStates(comp, x)
        # end

        c̄omp = ZeroTangent()
        d̄x = ZeroTangent()
        x̄ = ZeroTangent()
        p̄ = ZeroTangent()
        t̄ = ZeroTangent() 

        if Δdx != NoTangent()
            d̄x = Δdx
        end

        if Δx != NoTangent()
            if comp.A === nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
                comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
            end 
            comp.jacobianUpdate!(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)
            x̄ = comp.A * Δx
        end

        if Δt != NoTangent()
            dt = 1e-6
            dx1 = fmi3GetContinuousStateDerivatives(comp)
            fmi3SetTime(comp, t + dt)
            dx2 = fmi3GetContinuousStateDerivatives(comp)
            ∂t = (dx2-dx1)/dt 
            t̄ = ∂t * Δt
        end

        return (c̄omp, d̄x, x̄, p̄, t̄)
    end
    return (y, fx_pullforward(Δdx, Δx, Δt)...)
end

# rrule for fx
function ChainRulesCore.rrule(::typeof(fx), 
    comp::FMU3Instance,
    dx, 
    x,
    p,
    t)

    y = fx(comp, dx, x, p, t)
    function fx_pullback(ȳ)

        if t >= 0.0
            fmi3SetTime(comp, t)
        end

        fmi3SetContinuousStates(comp, x)

        if comp.A === nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
            comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
        end 
        comp.jacobianUpdate!(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

        n_dx_x = @thunk(comp.A' * ȳ)

        f̄ = NoTangent()
        c̄omp = ZeroTangent()
        d̄x = ZeroTangent()
        x̄ = n_dx_x
        p̄ = ZeroTangent()
        t̄ = ZeroTangent()

        return f̄, c̄omp, d̄x, x̄, p̄, t̄
    end
    return (y, fx_pullback)
end

# frule for fx
# function ChainRulesCore.frule((Δself, Δcomp, Δdx, Δx, Δp, Δt), 
#                               ::typeof(fx), 
#                               comp, #::FMU3Instance,
#                               dx, 
#                               x,#::AbstractArray{<:Real},
#                               p,
#                               t)

#     y = fx(comp, dx, x, p, t)
#     function fx_pullforward(Δx)

#         if t >= 0.0 
#             fmi3SetTime(comp, t)
#         end

#         if all(isa.(x, ForwardDiff.Dual))
#             xf = collect(ForwardDiff.value(e) for e in x)
#             fmi3SetContinuousStates(comp, xf)
#         else
#             fmi3SetContinuousStates(comp, x)
#         end

#         if comp.A == nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
#             comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
#         end 
#         comp.jacobianUpdate!(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

#         n_dx_x = comp.A * Δx

#         c̄omp = ZeroTangent()
#         d̄x = ZeroTangent()
#         x̄ = n_dx_x 
#         p̄ = ZeroTangent()
#         t̄ = ZeroTangent()

#         return (c̄omp, d̄x, x̄, p̄, t̄)
#     end
#     return (y, fx_pullforward(Δx)...)
# end

import FMIImport: fmi3VariabilityConstant, fmi3InitialApprox, fmi3InitialExact
function setBeforeInitialization(mv::FMIImport.fmi3Variable)
    return mv.variability != fmi3VariabilityConstant && mv.initial ∈ (fmi3InitialApprox, fmi3InitialExact)
end

import FMIImport: fmi3CausalityInput, fmi3CausalityParameter, fmi3VariabilityTunable
function setInInitialization(mv::FMIImport.fmi3Variable)
    return mv.causality == fmi3CausalityInput || (mv.causality != fmi3CausalityParameter && mv.variability == fmi3VariabilityTunable) || (mv.variability != fmi3VariabilityConstant && mv.initial == fmi3InitialExact)
end

function prepareFMU(fmu::FMU3, c::Union{Nothing, FMU3Instance}, type::fmi3Type, instantiate::Union{Nothing, Bool}, terminate::Union{Nothing, Bool}, reset::Union{Nothing, Bool}, setup::Union{Nothing, Bool}, parameters::Union{Dict{<:Any, <:Any}, Nothing}, t_start, t_stop, tolerance;
    x0::Union{AbstractArray{<:Real}, Nothing}=nothing, inputFunction=nothing, inputValueReferences=nothing)

    if instantiate === nothing 
        instantiate = fmu.executionConfig.instantiate
    end

    if terminate === nothing 
        terminate = fmu.executionConfig.terminate
    end

    if reset === nothing 
        reset = fmu.executionConfig.reset 
    end

    if setup === nothing 
        setup = fmu.executionConfig.setup 
    end 

    c = nothing

    # instantiate (hard)
    if instantiate
        if type == fmi3TypeCoSimulation
            c = fmi3InstantiateCoSimulation!(fmu)
        elseif type == fmi3TypeModelExchange
            c = fmi3InstantiateModelExchange!(fmu)
        else
            c = fmi3InstantiateScheduledExecution!(fmu)
        end
    else
        if c === nothing
            if length(fmu.instances) > 0
                c = fmu.instances[end]
            else
                @warn "Found no FMU instance, but executionConfig doesn't force allocation. Allocating one. Use `fmi2Instantiate(fmu)` to prevent this message."
                if type == fmi3TypeCoSimulation
                    c = fmi3InstantiateCoSimulation!(fmu)
                elseif type == fmi3TypeModelExchange
                    c = fmi3InstantiateModelExchange!(fmu)
                else
                    c = fmi3InstantiateScheduledExecution!(fmu)
                end
            end
        end
    end

    @assert c !== nothing "No FMU instance available, allocate one or use `fmu.executionConfig.instantiate=true`."

    # soft terminate (if necessary)
    if terminate
        retcode = fmi3Terminate(c; soft=true)
        @assert retcode == fmi3StatusOK "fmi3Simulate(...): Termination failed with return code $(retcode)."
    end

    # soft reset (if necessary)
    if reset
        retcode = fmi3Reset(c; soft=true)
        @assert retcode == fmi3StatusOK "fmi3Simulate(...): Reset failed with return code $(retcode)."
    end 

    # setup experiment (hard)
    # TODO this part is handled by fmi3EnterInitializationMode
    # if setup
    #     retcode = fmi2SetupExperiment(c, t_start, t_stop; tolerance=tolerance)
    #     @assert retcode == fmi3StatusOK "fmi3Simulate(...): Setting up experiment failed with return code $(retcode)."
    # end

    # parameters
    if parameters !== nothing
        retcodes = fmi3Set(c, collect(keys(parameters)), collect(values(parameters)); filter=setBeforeInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial parameters failed with return code $(retcode)."
    end

    # inputs
    inputs = nothing
    if inputFunction !== nothing && inputValueReferences !== nothing
        # set inputs
        inputs = Dict{fmi3ValueReference, Any}()

        inputValues = nothing
        if hasmethod(inputFunction, Tuple{FMU3Instance, fmi3Float64}) # CS
          inputValues = inputFunction(c, t_start)
        else # ME
            inputValues = inputFunction(c, nothing, t_start)
        end

        for i in 1:length(inputValueReferences)
            vr = inputValueReferences[i]
            inputs[vr] = inputValues[i]
        end
    end

    # inputs
    if inputs !== nothing
        retcodes = fmi3Set(c, collect(keys(inputs)), collect(values(inputs)); filter=setBeforeInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # start state
    if x0 !== nothing
        #retcode = fmi3SetContinuousStates(c, x0)
        #@assert retcode == fmi3StatusOK "fmi3Simulate(...): Setting initial state failed with return code $(retcode)."
        retcodes = fmi3Set(c, fmu.modelDescription.stateValueReferences, x0; filter=setBeforeInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # enter (hard)
    if setup
        retcode = fmi3EnterInitializationMode(c, t_start, t_stop; tolerance = tolerance)
        @assert retcode == fmi3StatusOK "fmi3Simulate(...): Entering initialization mode failed with return code $(retcode)."
    end

    # parameters
    if parameters !== nothing
        retcodes = fmi3Set(c, collect(keys(parameters)), collect(values(parameters)); filter=setInInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial parameters failed with return code $(retcode)."
    end

    if inputs !== nothing
        retcodes = fmi3Set(c, collect(keys(inputs)), collect(values(inputs)); filter=setInInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # start state
    if x0 !== nothing
        #retcode = fmi3SetContinuousStates(c, x0)
        #@assert retcode == fmi3StatusOK "fmi3Simulate(...): Setting initial state failed with return code $(retcode)."
        retcodes = fmi3Set(c, fmu.modelDescription.stateValueReferences, x0; filter=setInInitialization)
        @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # exit setup (hard)
    if setup
        retcode = fmi3ExitInitializationMode(c)
        @assert retcode == fmi3StatusOK "fmi3Simulate(...): Exiting initialization mode failed with return code $(retcode)."
    end

    if type == fmi3TypeModelExchange
        if x0 === nothing
            x0 = fmi3GetContinuousStates(c)
        end
    end

    return c, x0
end

function prepareFMU(fmu::Vector{FMU3}, c::Vector{Union{Nothing, FMU3Instance}}, type::Vector{fmi3Type}, instantiate::Union{Nothing, Bool}, freeInstance::Union{Nothing, Bool}, terminate::Union{Nothing, Bool}, reset::Union{Nothing, Bool}, setup::Union{Nothing, Bool}, parameters::Union{Vector{Union{Dict{<:Any, <:Any}, Nothing}}, Nothing}, t_start, t_stop, tolerance;
    x0::Union{Vector{Union{Array{<:Real}, Nothing}}, Nothing}=nothing, initFct=nothing)

    ignore_derivatives() do
        for i in 1:length(fmu)

            if instantiate === nothing
                instantiate = fmu[i].executionConfig.instantiate
            end

            if freeInstance === nothing 
                freeInstance = fmu[i].executionConfig.freeInstance
            end

            if terminate === nothing 
                terminate = fmu[i].executionConfig.terminate
            end

            if reset === nothing
                reset = fmu[i].executionConfig.reset
            end

            if setup === nothing
                setup = fmu[i].executionConfig.setup
            end

            # instantiate (hard)
            if instantiate
                # remove old one if we missed it (callback)
                if c[i] !== nothing
                    if freeInstance
                        fmi3FreeInstance!(c[i])
                        @debug "[AUTO-RELEASE INST]"
                    end
                end

                if type[i] == fmi3TypeCoSimulation
                    c[i] = fmi3InstantiateCoSimulation!(fmu[i])
                elseif type[i] == fmi3TypeModelExchange
                    c[i] = fmi3InstantiateModelExchange!(fmu[i])
                else
                    c[i] = fmi3InstantiateScheduledExecution!(fmu[i])
                end
                @debug "[NEW INST]"
            else
                if c[i] === nothing
                    c[i] = fmu[i].instances[end]
                end
            end

            # soft terminate (if necessary)
            if terminate
                retcode = fmi3Terminate(c[i]; soft=true)
                @assert retcode == fmi3StatusOK "fmi3Simulate(...): Termination failed with return code $(retcode)."
            end

            # soft reset (if necessary)
            if reset
                retcode = fmi3Reset(c[i]; soft=true)
                @assert retcode == fmi3StatusOK "fmi3Simulate(...): Reset failed with return code $(retcode)."
            end

            # enter setup (hard)
            if setup
                # retcode = fmi2SetupExperiment(c[i], t_start, t_stop; tolerance=tolerance)
                # @assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting up experiment failed with return code $(retcode)."

                retcode = fmi3EnterInitializationMode(c[i], t_start, t_stop; tolerance=tolerance)
                @assert retcode == fmi3StatusOK "fmi3Simulate(...): Entering initialization mode failed with return code $(retcode)."
            end

            if x0 !== nothing
                if x0[i] !== nothing
                    retcode = fmi3SetContinuousStates(c[i], x0[i])
                    @assert retcode == fmi3StatusOK "fmi3Simulate(...): Setting initial state failed with return code $(retcode)."
                end
            end

            if parameters !== nothing
                if parameters[i] !== nothing
                    retcodes = fmi3Set(c[i], collect(keys(parameters[i])), collect(values(parameters[i])) )
                    @assert all(retcodes .== fmi3StatusOK) "fmi3Simulate(...): Setting initial parameters failed with return code $(retcode)."
                end
            end

            if initFct !== nothing
                initFct()
            end

            # exit setup (hard)
            if setup
                retcode = fmi3ExitInitializationMode(c[i])
                @assert retcode == fmi3StatusOK "fmi3Simulate(...): Exiting initialization mode failed with return code $(retcode)."
            end

            if type == fmi3TypeModelExchange
                if x0 === nothing
                    if x0[i] === nothing
                        x0[i] = fmi3GetContinuousStates(c[i])
                    end
                end
            end
        end

    end # ignore_derivatives

    return c, x0
end

function finishFMU(fmu::FMU3, c::FMU3Instance, terminate::Union{Nothing, Bool}, freeInstance::Union{Nothing, Bool})

    if c === nothing 
        return 
    end

    if terminate === nothing 
        terminate = fmu.executionConfig.terminate
    end

    if freeInstance === nothing 
        freeInstance = fmu.executionConfig.freeInstance
    end

    # soft terminate (if necessary)
    if terminate
        retcode = fmi3Terminate(c; soft=true)
        @assert retcode == fmi3StatusOK "fmi3Simulate(...): Termination failed with return code $(retcode)."
    end

    # freeInstance (hard)
    if freeInstance
        fmi3FreeInstance!(c)
    end
end

# wrapper
function fmi3SimulateME(c::FMU3Instance, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi3SimulateME(c.fmu, c, t_start, t_stop; kwargs...)
end 

# sets up the ODEProblem for simulating a ME-FMU
function setupODEProblem(c::FMU3Instance, x0::AbstractArray{fmi3Float64}, t_start::fmi3Float64, t_stop::fmi3Float64; p=(), customFx=nothing)
    if customFx === nothing
        customFx = (dx, x, p, t) -> fx(c, dx, x, p, t)
    end

    p = ()
    c.problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)

    return c.problem
end

"""
Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Via the optional keyword arguemnts `inputValues` and `inputFunction`, a custom input function `f(c, u, t)`, `f(c, t)`, `f(u, t)`, `f(c, u)` or `f(t)` with `c` current instance, `u` current state and `t` current time can be defined, that should return a array of values for `fmi3SetFloat64(..., inputValues, inputFunction(...))`.

Keywords:
    - solver: Any Julia-supported ODE-solver (default is Tsit5)
    - customFx: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - saveat: Time points to save values at (interpolated)
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Union{Bool, :auto}, if FMU should be reset before simulation (default reset=:auto)
    - inputValueReferences: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - parameters: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization 
    - `callbacks`: custom callbacks to add

Returns:
    - If keyword `recordValues` is not set, a struct of type `ODESolution`.
    - If keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).
"""
function fmi3SimulateME(fmu::FMU3, c::Union{FMU3Instance, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    solver = nothing,
    customFx = nothing,
    recordValues::fmi3ValueReferenceFormat = nothing,
    saveat = nothing,
    x0::Union{AbstractArray{<:Real}, Nothing} = nothing,
    setup::Union{Bool, Nothing} = nothing,
    reset::Union{Bool, Nothing} = nothing,
    instantiate::Union{Bool, Nothing} = nothing,
    freeInstance::Union{Bool, Nothing} = nothing,
    terminate::Union{Bool, Nothing} = nothing,
    inputValueReferences::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
    dtmax::Union{Real, Nothing} = nothing,
    callbacks = [],
    showProgress::Bool = true,
    kwargs...)
    @warn "ME-simulation is not working properly right now!"
    
    @assert fmi3IsModelExchange(fmu) "fmi3SimulateME(...): This function supports Model Exchange FMUs only."
    #@assert fmu.type == fmi3TypeModelExchange "fmi3SimulateME(...): This FMU supports Model Exchange, but was instantiated in CS mode. Use `fmiLoad(...; type=:ME)`." # TODO why not using this??

    # input function handling 
    _inputFunction = nothing
    if inputFunction !== nothing
        if hasmethod(inputFunction, Tuple{fmi3Float64})
            _inputFunction = (c, u, t) -> inputFunction(t)
        elseif  hasmethod(inputFunction, Tuple{Union{FMU3Instance, Nothing}, fmi3Float64})
            _inputFunction = (c, u, t) -> inputFunction(c, t)
        elseif  hasmethod(inputFunction, Tuple{Union{FMU3Instance, Nothing}, AbstractArray{fmi3Float64,1}})
            _inputFunction = (c, u, t) -> inputFunction(c, u)
        elseif  hasmethod(inputFunction, Tuple{AbstractArray{fmi3Float64,1}, fmi3Float64})
            _inputFunction = (c, u, t) -> inputFunction(u, t)
        else 
            _inputFunction = inputFunction
        end
        @assert hasmethod(_inputFunction, Tuple{FMU3Instance, Union{AbstractArray{fmi3Float64,1}, Nothing}, fmi3Float64}) "The given input function does not fit the needed input function pattern for ME-FMUs, which are: \n- `inputFunction(t::fmi3Float64)`\n- `inputFunction(comp::FMU3Instance, t::fmi3Float64)`\n- `inputFunction(comp::FMU3Instance, u::Union{AbstractArray{fmi3Float64,1}, Nothing})`\n- `inputFunction(u::Union{AbstractArray{fmi3Float64,1}, Nothing}, t::fmi3Float64)`\n- `inputFunction(comp::FMU3Instance, u::Union{AbstractArray{fmi3Float64,1}, Nothing}, t::fmi3Float64)`"
    end

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    
    fmusol = FMU3Solution(fmu)

    savingValues = (length(recordValues) > 0)
    hasInputs = (length(inputValueReferences) > 0)
    hasParameters = (parameters !== nothing)
    hasStartState = (x0 !== nothing)

    cbs = []

    for cb in callbacks
        push!(cbs, cb)
    end

    if t_start === nothing 
        t_start = fmi3GetDefaultStartTime(fmu.modelDescription)
        
        if t_start === nothing 
            t_start = 0.0
            @info "No `t_start` choosen, no `t_start` availabel in the FMU, auto-picked `t_start=0.0`."
        end
    end
    
    if t_stop === nothing 
        t_stop = fmi3GetDefaultStopTime(fmu.modelDescription)

        if t_stop === nothing
            t_stop = 1.0
            @warn "No `t_stop` choosen, no `t_stop` availabel in the FMU, auto-picked `t_stop=1.0`."
        end
    end

    if tolerance === nothing 
        tolerance = fmi3GetDefaultTolerance(fmu.modelDescription)
        # if no tolerance is given, pick auto-setting from DifferentialEquations.jl 
    end

    if dt === nothing 
        dt = fmi3GetDefaultStepSize(fmu.modelDescription)
        # if no dt is given, pick auto-setting from DifferentialEquations.jl
    end

    if dtmax === nothing
        dtmax = (t_stop-t_start)/100.0
    end

    # argument `tolerance=nothing` here, because ME-FMUs doesn't support tolerance control (no solver included)
    # tolerance for the solver is set-up later in this function
    c, x0 = prepareFMU(fmu, c, fmi3TypeModelExchange, instantiate, terminate, reset, setup, parameters, t_start, t_stop, nothing; x0=x0, inputFunction=_inputFunction, inputValueReferences=inputValueReferences)

    # from here on, we are in event mode, if `setup=false` this is the job of the user
    #@assert c.state == fmi3InstanceStateEventMode "FMU needs to be in event mode after setup."

    # if x0 === nothing
    #     x0 = fmi3GetContinuousStates(c)
    #     x0_nom = fmi3GetNominalsOfContinuousStates(c)
    # end

    # initial event handling
    # fmi3EnterEventMode(c, c.stepEvent, c.stateEvent, c.rootsFound, Csize_t(c.fmu.modelDescription.numberOfEventIndicators), c.timeEvent)
    handleEvents(c) 
    #fmi3EnterContinuousTimeMode(c)

    c.fmu.hasStateEvents = (c.fmu.modelDescription.numberOfEventIndicators > 0)
    # c.fmu.hasTimeEvents = (c.eventInfo.nextEventTimeDefined == fmi2True)
    c.fmu.hasTimeEvents = fmi3False
    
    setupODEProblem(c, x0, t_start, t_stop; customFx=customFx)

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating ME-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    # callback functions

    if c.fmu.hasTimeEvents
        timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator, t_start, t_stop),
                                        (integrator) -> affectFMU!(c, integrator, 0, _inputFunction, inputValueReferences, fmusol), Float64; 
                                        initial_affect = false, # (c.eventInfo.nextEventTime == t_start)
                                        save_positions=(false,false))
        push!(cbs, timeEventCb)
    end

    if c.fmu.hasStateEvents

        eventCb = VectorContinuousCallback((out, x, t, integrator) -> condition(c, out, x, t, integrator, _inputFunction, inputValueReferences),
                                           (integrator, idx) -> affectFMU!(c, integrator, idx, _inputFunction, inputValueReferences, fmusol),
                                           Int64(c.fmu.modelDescription.numberOfEventIndicators);
                                           rootfind = RightRootFind,
                                           save_positions=(false,false))
        push!(cbs, eventCb)
    end

    # use step callback always if we have inputs or need event handling (or just want to see our simulation progress)
    if hasInputs || c.fmu.hasStateEvents || c.fmu.hasTimeEvents || showProgress
        stepCb = FunctionCallingCallback((x, t, integrator) -> stepCompleted(c, x, t, integrator, _inputFunction, inputValueReferences, progressMeter, t_start, t_stop, fmusol);
                                            func_everystep = true,
                                            func_start = true)
        push!(cbs, stepCb)
    end

    if savingValues
        fmusol.values = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...})
        fmusol.valueReferences = copy(recordValues)

        if saveat === nothing
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction, inputValueReferences), 
                                    fmusol.values)
        else
            savingCB = SavingCallback((u,t,integrator) -> saveValues(c, recordValues, u, t, integrator, _inputFunction, inputValueReferences), 
                                    fmusol.values, 
                                    saveat=saveat)
        end

        push!(cbs, savingCB)
    end

    # if auto_dt == true
    #     @assert solver !== nothing "fmi2SimulateME(...): `auto_dt=true` but no solver specified, this is not allowed."
    #     tmpIntegrator = init(c.problem, solver)
    #     dt = auto_dt_reset!(tmpIntegrator)
    # end

    solveKwargs = Dict{Symbol, Any}()

    if dt !== nothing
        solveKwargs[:dt] = dt
    end

    if tolerance !== nothing
        solveKwargs[:reltol] = tolerance
    end

    if saveat !== nothing
        solveKwargs[:saveat] = saveat
    end

    if solver === nothing
        fmusol.states = solve(c.problem; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    else
        fmusol.states = solve(c.problem, solver; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    end

    fmusol.success = (fmusol.states.retcode == SciMLBase.ReturnCode.Success)

    # cleanup progress meter
    if showProgress 
        ProgressMeter.finish!(progressMeter)
    end

    finishFMU(fmu, c, terminate, freeInstance)

    return fmusol
end


# wrapper
function fmi3SimulateCS(c::FMU3Instance, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi3SimulateCS(c.fmu, c, t_start, t_stop; kwargs...)
end

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.

Via the optional keyword arguments `inputValues` and `inputFunction`, a custom input function `f(c, t)` or `f(t)` with time `t` and instance `c` can be defined, that should return a array of values for `fmi3SetFloat64(..., inputValues, inputFunction(...))`.

Keywords:
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - saveat: Time points to save values at (interpolated)
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Boolean, if FMU should be reset before simulation (default reset=setup)
    - inputValueReferences: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - parameters: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization 
Returns:
    - If keyword `recordValues` is not set, a boolean `success` is returned (simulation success).
    - If keyword `recordValues` is set, a tuple of type (true, DiffEqCallbacks.SavedValues) or (false, nothing).
"""
function fmi3SimulateCS(fmu::FMU3, c::Union{FMU3Instance, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    recordValues::fmi3ValueReferenceFormat = nothing,
    saveat = [],
    setup::Union{Bool, Nothing} = nothing,
    reset::Union{Bool, Nothing} = nothing,
    instantiate::Union{Bool, Nothing} = nothing,
    freeInstance::Union{Bool, Nothing} = nothing,
    terminate::Union{Bool, Nothing} = nothing,
    inputValueReferences::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing,
    showProgress::Bool=true,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing)

    @assert fmi3IsCoSimulation(fmu) "fmi3SimulateCS(...): This function supports Co-Simulation FMUs only."
    
    # input function handling 
    _inputFunction = nothing
    if inputFunction != nothing
        if hasmethod(inputFunction, Tuple{fmi3Float64})
            _inputFunction = (c, t) -> inputFunction(t)
        else 
            _inputFunction = inputFunctiont
        end
        @assert hasmethod(_inputFunction, Tuple{FMU3Instance, fmi3Float64}) "The given input function does not fit the needed input function pattern for CS-FMUs, which are: \n- `inputFunction(t::fmi3Float64)`\n- `inputFunction(comp::FMU3Instance, t::fmi3Float64)`"
    end

    fmusol = FMU3Solution(fmu)


    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = (length(inputValueReferences) > 0)
    
    variableSteps = fmi3IsCoSimulation(fmu) && fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize 
    
    t_start = t_start === nothing ? fmi3GetDefaultStartTime(fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start
    t_stop = t_stop === nothing ? fmi3GetDefaultStopTime(fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop
    tolerance = tolerance === nothing ? fmi3GetDefaultTolerance(fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 0.0 : tolerance
    dt = dt === nothing ? fmi3GetDefaultStepSize(fmu.modelDescription) : dt
    dt = dt === nothing ? 1e-3 : dt

    c, _ = prepareFMU(fmu, c, fmi3TypeCoSimulation, instantiate, terminate, reset, setup, parameters, t_start, t_stop, tolerance; inputFunction=_inputFunction, inputValueReferences=inputValueReferences)

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

    record = length(recordValues) > 0

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating CS-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    #numDigits = length(string(round(Integer, 1/dt)))
    noSetFMUStatePriorToCurrentPoint = fmi3False
    eventEncountered = fmi3False
    terminateSimulation = fmi3False
    earlyReturn = fmi3False
    lastSuccessfulTime = fmi3Float64(0.0)

    if record
        fmusol.values = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...} )
        fmusol.valueReferences = copy(recordValues)

        i = 1

        svalues = (fmi3GetFloat64(c, recordValues)...,)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.t, i, t)
        DiffEqCallbacks.copyat_or_push!(fmusol.values.saveval, i, svalues, Val{false})

        while t < t_stop
            if variableSteps
                if length(saveat) > i
                    dt = saveat[i+1] - saveat[i]
                else 
                    dt = t_stop - saveat[i]
                end
            end

            if _inputFunction !== nothing
                fmi3SetFloat64(fmu, inputValueReferences, _inputFunction(c, t))
            end

            fmi3DoStep!(fmu, t, dt, true, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @error "fmi3DoStep returned error!"
            end
            if earlyReturn == fmi3True
                @warn "early Return"
            end
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1

            svalues = (fmi3GetFloat64(c, recordValues)...,)
            DiffEqCallbacks.copyat_or_push!(fmusol.values.t, i, t)
            DiffEqCallbacks.copyat_or_push!(fmusol.values.saveval, i, svalues, Val{false})

            if progressMeter !== nothing 
                ProgressMeter.update!(progressMeter, floor(Integer, 1000.0*(t-t_start)/(t_stop-t_start)) )
            end
        end

        if progressMeter !== nothing 
            ProgressMeter.finish!(progressMeter)
        end

        fmusol.success = true

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

            if _inputFunction !== nothing
                fmi3SetFloat64(fmu, inputValues, _inputFunction(c, t))
            end

            fmi3DoStep!(fmu, t, dt, true, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
            if eventEncountered == fmi3True
                @warn "Event handling"
            end
            if terminateSimulation == fmi3True
                @error "fmi3DoStep returned error!"
            end
            if earlyReturn == fmi3True
                @warn "early Return"
            end
            t = t + dt #round(t + dt, digits=numDigits)
            i += 1

            if progressMeter !== nothing 
                ProgressMeter.update!(progressMeter, floor(Integer, 1000.0*(t-t_start)/(t_stop-t_start)) )
            end
        end

        if progressMeter !== nothing 
            ProgressMeter.finish!(progressMeter)
        end

        fmusol.success = true
    end
    
    finishFMU(fmu, c, terminate, freeInstance)

    return fmusol
end

# TODO simulate ScheduledExecution
function fmi3SimulateSE(fmu::FMU3, c::Union{FMU3Instance, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    recordValues::fmi3ValueReferenceFormat = nothing,
    saveat = [],
    setup::Union{Bool, Nothing} = nothing,
    reset::Union{Bool, Nothing} = nothing,
    instantiate::Union{Bool, Nothing} = nothing,
    freeInstance::Union{Bool, Nothing} = nothing,
    terminate::Union{Bool, Nothing} = nothing,
    inputValueReferences::fmi3ValueReferenceFormat = nothing,
    inputFunction = nothing,
    showProgress::Bool=true,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing)    @assert false "Not implemented"
end

##### CS & ME #####

# wrapper
function fmi3Simulate(c::FMU3Instance, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi3Simulate(c.fmu, c, t_start, t_stop; kwargs...)
end 

"""
Starts a simulation of the FMU instance for the matching FMU type, if both types are available, CS is preferred.

Keywords:
    - recordValues: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
    - setup: Boolean, if FMU should be setup (default=true)
    - reset: Boolean, if FMU should be reset before simulation (default reset=setup)
    - inputValues: Array of input variables (strings or variableIdentifiers) to set at every simulation step 
    - inputFunction: Function to retrieve the values to set the inputs to 
    - saveat: [ME only] Time points to save values at (interpolated)
    - solver: [ME only] Any Julia-supported ODE-solver (default is Tsit5)
    - customFx: [ME only, deperecated] Ability to give a custom state derivative function ẋ=f(x,t)

Returns:
    - `success::Bool` for CS-FMUs
    - `ODESolution` for ME-FMUs
    - if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs
    - if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs
"""
function fmi3Simulate(fmu::FMU3, c::Union{FMU3Instance, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)

    if fmu.type == fmi3TypeCoSimulation
        return fmi3SimulateCS(fmu, c, t_start, t_stop; kwargs...)
    elseif fmu.type == fmi3TypeModelExchange
        return fmi3SimulateME(fmu, c, t_start, t_stop; kwargs...)
    elseif fmu.type == fmi3TypeScheduledExecution
        return fmi3SimulateSE(fmu, c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
