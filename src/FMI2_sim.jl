#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations, DiffEqCallbacks
import SciMLBase: RightRootFind

using FMIImport: fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2NewDiscreteStates, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates, fmi2SetContinuousStates, fmi2GetDerivatives!
using FMIImport.FMICore: fmi2StatusOK, fmi2TypeCoSimulation, fmi2TypeModelExchange
using FMIImport.FMICore: fmi2ComponentState, fmi2ComponentStateInstantiated, fmi2ComponentStateInitializationMode, fmi2ComponentStateEventMode, fmi2ComponentStateContinuousTimeMode, fmi2ComponentStateTerminated, fmi2ComponentStateError, fmi2ComponentStateFatal
using FMIImport: FMU2Solution, FMU2Event

using ChainRulesCore
import ForwardDiff

import ProgressMeter

############ Model-Exchange ############

# Read next time event from fmu and provide it to the integrator 
function time_choice(c::FMU2Component, integrator, tStart, tStop)

    #@info "TC"

    if c.eventInfo.nextEventTimeDefined == fmi2True

        if c.eventInfo.nextEventTime >= tStart && c.eventInfo.nextEventTime <= tStop
            return c.eventInfo.nextEventTime
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
function handleEvents(c::FMU2Component)

    @assert c.state == fmi2ComponentStateEventMode "handleEvents(...): Must be in event mode!"

    # trigger the loop
    c.eventInfo.newDiscreteStatesNeeded = fmi2True

    valuesOfContinuousStatesChanged = fmi2False
    nominalsOfContinuousStatesChanged = fmi2False
    nextEventTimeDefined = fmi2False
    nextEventTime = 0.0

    while c.eventInfo.newDiscreteStatesNeeded == fmi2True

        # ToDo: Set inputs!

        fmi2NewDiscreteStates!(c, c.eventInfo)

        if c.eventInfo.valuesOfContinuousStatesChanged == fmi2True
            valuesOfContinuousStatesChanged = fmi2True 
        end 

        if c.eventInfo.nominalsOfContinuousStatesChanged == fmi2True
            nominalsOfContinuousStatesChanged = fmi2True
        end

        if c.eventInfo.nextEventTimeDefined == fmi2True
            nextEventTimeDefined = fmi2True
            nextEventTime = c.eventInfo.nextEventTime
        end

        if c.eventInfo.terminateSimulation == fmi2True
            @error "handleEvents(...): FMU throws `terminateSimulation`!"
        end
    end

    c.eventInfo.valuesOfContinuousStatesChanged = valuesOfContinuousStatesChanged
    c.eventInfo.nominalsOfContinuousStatesChanged = nominalsOfContinuousStatesChanged
    c.eventInfo.nextEventTimeDefined = nextEventTimeDefined
    c.eventInfo.nextEventTime = nextEventTime

    fmi2EnterContinuousTimeMode(c)

    return nothing
end

# Returns the event indicators for an FMU.
function condition(c::FMU2Component, out::AbstractArray{<:Real}, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi2ValueReference}) 

    @assert c.state == fmi2ComponentStateContinuousTimeMode "condition(...): Must be called in mode continuous time."

    fmi2SetContinuousStates(c, x)
    fmi2SetTime(c, t)
    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end
    fmi2GetEventIndicators!(c, out)

    return nothing
end

# Handles the upcoming events.
# Sets a new state for the solver from the FMU (if needed).
function affectFMU!(c::FMU2Component, integrator, idx, inputFunction, inputValues::AbstractArray{fmi2ValueReference}, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "affectFMU!(...): Must be in continuous time mode!"

    # there are fx-evaluations before the event is handled, reset the FMU state to the current integrator step
    fmi2SetContinuousStates(c, integrator.u)
    fmi2SetTime(c, integrator.t)
    if inputFunction !== nothing
        fmi2SetReal(c, inputValues, inputFunction(c, integrator.u, integrator.t))
    end

    fmi2EnterEventMode(c)

    # Event found - handle it
    handleEvents(c)

    left_x = nothing 
    right_x = nothing

    if c.eventInfo.valuesOfContinuousStatesChanged == fmi2True
        left_x = integrator.u
        right_x = fmi2GetContinuousStates(c)
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), new state is $(new_u)"
        integrator.u = right_x

        u_modified!(integrator, true)
        #set_proposed_dt!(integrator, 1e-10)
    else 
        @debug "affectFMU!(...): Handled event at t=$(integrator.t), no new state."
    end

    if c.eventInfo.nominalsOfContinuousStatesChanged == fmi2True
        x_nom = fmi2GetNominalsOfContinuousStates(c)
    end

    ignore_derivatives() do 
        if idx != -1 # -1 no event, 0, time event, >=1 state event with indicator
            e = FMU2Event(integrator.t, UInt64(idx), left_x, right_x)
            push!(solution.events, e)
        end
    end 

    #fmi2EnterContinuousTimeMode(c)
end

# This callback is called every time the integrator finishes an (accpeted) integration step.
function stepCompleted(c::FMU2Component, x, t, integrator, inputFunction, inputValues::AbstractArray{fmi2ValueReference}, progressMeter, tStart, tStop, solution::FMU2Solution)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "stepCompleted(...): Must be in continuous time mode."
    #@info "Step completed"
    if progressMeter !== nothing 
        ProgressMeter.update!(progressMeter, floor(Integer, 1000.0*(t-tStart)/(tStop-tStart)) )
    end

    (status, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
    
    if terminateSimulation == fmi2True
        @error "stepCompleted(...): FMU requested termination!"
    end

    if enterEventMode == fmi2True
        affectFMU!(c, integrator, -1, inputFunction, inputValues, solution)
    else
        if inputFunction != nothing
            fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
        end
    end
end

# save FMU values 
function saveValues(c::FMU2Component, recordValues, x, t, integrator, inputFunction, inputValues)

    @assert c.state == fmi2ComponentStateContinuousTimeMode "saveValues(...): Must be in continuous time mode."

    #x_old = fmi2GetContinuousStates(c)
    #t_old = c.t
    
    fmi2SetContinuousStates(c, x)
    fmi2SetTime(c, t) 
    if inputFunction != nothing
        fmi2SetReal(c, inputValues, inputFunction(c, x, t)) 
    end

    #fmi2SetContinuousStates(c, x_old)
    #fmi2SetTime(c, t_old)
    
    return (fmiGetReal(c, recordValues)...,)
end

function fx(c::FMU2Component, 
    dx::AbstractArray{<:Real},
    x::AbstractArray{<:Real}, 
    p::AbstractArray, 
    t::Real)

    if isa(t, ForwardDiff.Dual) 
        t = ForwardDiff.value(t)
    end 

    fmi2SetContinuousStates(c, x)
    fmi2SetTime(c, t)

    if all(isa.(dx, ForwardDiff.Dual))
        dx_tmp = collect(ForwardDiff.value(e) for e in dx)
        fmi2GetDerivatives!(c, dx_tmp)
        T, V, N = fd_eltypes(dx)
        dx[:] = collect(ForwardDiff.Dual{T, V, N}(dx_tmp[i], ForwardDiff.partials(dx[i])    ) for i in 1:length(dx))
    else 
        fmi2GetDerivatives!(c, dx)
    end

    return dx
end

# ForwardDiff-Dispatch for fx
function fx(comp::FMU2Component,
            dx::AbstractArray{<:Real},
            x::AbstractArray{<:ForwardDiff.Dual{Tx, Vx, Nx}},
            p::AbstractArray,
            t::Real) where {Tx, Vx, Nx}

    return _fx_fd(comp, dx, x, p, t)
end

# function _fx_fd(TVNx, comp, dx, x, p, t) 
  
#     Tx, Vx, Nx = TVNx
    
#     ȧrgs = [NoTangent(), NoTangent(), collect(ForwardDiff.partials(e) for e in dx), collect(ForwardDiff.partials(e) for e in x), collect(ForwardDiff.partials(e) for e in p), ForwardDiff.partials(t)]
#     args = [fx,          comp,        collect(ForwardDiff.value(e) for e in dx), collect(ForwardDiff.value(e) for e in x),    collect(ForwardDiff.value(e) for e in p),    ForwardDiff.value(t),  ]

#     ȧrgs = (ȧrgs...,)
#     args = (args...,)
     
#     y, _, sdx, sx, _, _ = ChainRulesCore.frule(ȧrgs, args...)

#     if Vx != Float64
#         Vx = Float64
#     end

#     [collect( ForwardDiff.Dual{Tx, Vx, Nx}(y[i], sx[i]) for i in 1:length(sx) )...]
# end

function fd_eltypes(e::ForwardDiff.Dual{T, V, N}) where {T, V, N}
    return (T, V, N)
end
function fd_eltypes(e::AbstractArray{<:ForwardDiff.Dual{T, V, N}}) where {T, V, N}
    return (T, V, N)
end
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

# frule for fx
function ChainRulesCore.frule((Δself, Δcomp, Δdx, Δx, Δp, Δt), 
                              ::typeof(fx), 
                              comp, #::FMU2Component,
                              dx, 
                              x,#::AbstractArray{<:Real},
                              p,
                              t)

    y = fx(comp, dx, x, p, t)
    function fx_pullforward(Δdx, Δx, Δt)
       
        # if t >= 0.0 
        #     fmi2SetTime(comp, t)
        # end
        
        # if all(isa.(x, ForwardDiff.Dual))
        #     xf = collect(ForwardDiff.value(e) for e in x)
        #     fmi2SetContinuousStates(comp, xf)
        # else
        #     fmi2SetContinuousStates(comp, x)
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
            if comp.A == nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
                comp.A = zeros(length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
            end 
            comp.jacobianUpdate!(comp.A, comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)
            x̄ = comp.A * Δx
        end

        if Δt != NoTangent()
            dt = 1e-6
            dx1 = fmi2GetDerivatives(comp)
            fmi2SetTime(comp, t + dt)
            dx2 = fmi2GetDerivatives(comp)
            ∂t = (dx2-dx1)/dt 
            t̄ = ∂t * Δt
        end
       
        return (c̄omp, d̄x, x̄, p̄, t̄)
    end
    return (y, fx_pullforward(Δdx, Δx, Δt)...)
end

# rrule for fx
function ChainRulesCore.rrule(::typeof(fx), 
                              comp::FMU2Component,
                              dx, 
                              x,
                              p,
                              t)

    y = fx(comp, dx, x, p, t)
    function fx_pullback(ȳ)

        if t >= 0.0
            fmi2SetTime(comp, t)
        end

        fmi2SetContinuousStates(comp, x)

        if comp.A == nothing || size(comp.A) != (length(comp.fmu.modelDescription.derivativeValueReferences), length(comp.fmu.modelDescription.stateValueReferences))
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
#                               comp, #::FMU2Component,
#                               dx, 
#                               x,#::AbstractArray{<:Real},
#                               p,
#                               t)

#     y = fx(comp, dx, x, p, t)
#     function fx_pullforward(Δx)
       
#         if t >= 0.0 
#             fmi2SetTime(comp, t)
#         end
        
#         if all(isa.(x, ForwardDiff.Dual))
#             xf = collect(ForwardDiff.value(e) for e in x)
#             fmi2SetContinuousStates(comp, xf)
#         else
#             fmi2SetContinuousStates(comp, x)
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

import FMIImport: fmi2VariabilityConstant, fmi2InitialApprox, fmi2InitialExact
function setBeforeInitialization(mv::FMIImport.fmi2ScalarVariable)
    return mv.variability != fmi2VariabilityConstant && mv.initial ∈ (fmi2InitialApprox, fmi2InitialExact)
end

import FMIImport: fmi2CausalityInput, fmi2CausalityParameter, fmi2VariabilityTunable
function setInInitialization(mv::FMIImport.fmi2ScalarVariable)
    return mv.causality == fmi2CausalityInput || (mv.causality != fmi2CausalityParameter && mv.variability == fmi2VariabilityTunable) || (mv.variability != fmi2VariabilityConstant && mv.initial == fmi2InitialExact)
end

function prepareFMU(fmu::FMU2, c::Union{Nothing, FMU2Component}, type::fmi2Type, instantiate::Union{Nothing, Bool}, terminate::Union{Nothing, Bool}, reset::Union{Nothing, Bool}, setup::Union{Nothing, Bool}, parameters::Union{Dict{<:Any, <:Any}, Nothing}, t_start, t_stop, tolerance;
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
        c = fmi2Instantiate!(fmu; type=type)
    else
        if c === nothing
            c = fmu.components[end]
        end
    end

    # soft terminate (if necessary)
    if terminate
        retcode = fmi2Terminate(c; soft=true)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Termination failed with return code $(retcode)."
    end

    # soft reset (if necessary)
    if reset
        retcode = fmi2Reset(c; soft=true)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Reset failed with return code $(retcode)."
    end 

    # setup experiment (hard)
    if setup
        retcode = fmi2SetupExperiment(c, t_start, t_stop; tolerance=tolerance)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting up experiment failed with return code $(retcode)."
    end

    # parameters
    if parameters !== nothing
        retcodes = fmi2Set(c, collect(keys(parameters)), collect(values(parameters)); filter=setBeforeInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial parameters failed with return code $(retcode)."
    end

    # inputs
    inputs = nothing
    if inputFunction != nothing && inputValueReferences != nothing
        # set inputs
        inputs = Dict{fmi2ValueReference, Any}()

        inputValues = nothing
        if hasmethod(inputFunction, Tuple{FMU2Component, fmi2Real}) # CS
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
        retcodes = fmi2Set(c, collect(keys(inputs)), collect(values(inputs)); filter=setBeforeInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # start state
    if x0 !== nothing
        #retcode = fmi2SetContinuousStates(c, x0)
        #@assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting initial state failed with return code $(retcode)."
        retcodes = fmi2Set(c, fmu.modelDescription.stateValueReferences, x0; filter=setBeforeInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # enter (hard)
    if setup
        retcode = fmi2EnterInitializationMode(c)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Entering initialization mode failed with return code $(retcode)."
    end

    # parameters
    if parameters !== nothing
        retcodes = fmi2Set(c, collect(keys(parameters)), collect(values(parameters)); filter=setInInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial parameters failed with return code $(retcode)."
    end
        
    if inputs !== nothing
        retcodes = fmi2Set(c, collect(keys(inputs)), collect(values(inputs)); filter=setInInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # start state
    if x0 !== nothing
        #retcode = fmi2SetContinuousStates(c, x0)
        #@assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting initial state failed with return code $(retcode)."
        retcodes = fmi2Set(c, fmu.modelDescription.stateValueReferences, x0; filter=setInInitialization)
        @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial inputs failed with return code $(retcode)."
    end

    # exit setup (hard)
    if setup
        retcode = fmi2ExitInitializationMode(c)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Exiting initialization mode failed with return code $(retcode)."
    end

    if type == fmi2TypeModelExchange
        if x0 == nothing
            x0 = fmi2GetContinuousStates(c)
        end
    end

    return c, x0
end

function prepareFMU(fmu::Vector{FMU2}, c::Vector{Union{Nothing, FMU2Component}}, type::Vector{fmi2Type}, instantiate::Union{Nothing, Bool}, freeInstance::Union{Nothing, Bool}, terminate::Union{Nothing, Bool}, reset::Union{Nothing, Bool}, setup::Union{Nothing, Bool}, parameters::Union{Vector{Union{Dict{<:Any, <:Any}, Nothing}}, Nothing}, t_start, t_stop, tolerance;
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
                if c[i] != nothing
                    if freeInstance
                        fmi2FreeInstance!(c[i])
                        @debug "[AUTO-RELEASE INST]"
                    end
                end

                c[i] = fmi2Instantiate!(fmu[i]; type=type[i])
                @debug "[NEW INST]"
            else
                if c[i] === nothing
                    c[i] = fmu[i].components[end]
                end
            end

            # soft terminate (if necessary)
            if terminate
                retcode = fmi2Terminate(c[i]; soft=true)
                @assert retcode == fmi2StatusOK "fmi2Simulate(...): Termination failed with return code $(retcode)."
            end

            # soft reset (if necessary)
            if reset
                retcode = fmi2Reset(c[i]; soft=true)
                @assert retcode == fmi2StatusOK "fmi2Simulate(...): Reset failed with return code $(retcode)."
            end

            # enter setup (hard)
            if setup
                retcode = fmi2SetupExperiment(c[i], t_start, t_stop; tolerance=tolerance)
                @assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting up experiment failed with return code $(retcode)."

                retcode = fmi2EnterInitializationMode(c[i])
                @assert retcode == fmi2StatusOK "fmi2Simulate(...): Entering initialization mode failed with return code $(retcode)."
            end

            if x0 !== nothing
                if x0[i] !== nothing
                    retcode = fmi2SetContinuousStates(c[i], x0[i])
                    @assert retcode == fmi2StatusOK "fmi2Simulate(...): Setting initial state failed with return code $(retcode)."
                end
            end

            if parameters !== nothing
                if parameters[i] !== nothing
                    retcodes = fmi2Set(c[i], collect(keys(parameters[i])), collect(values(parameters[i])) )
                    @assert all(retcodes .== fmi2StatusOK) "fmi2Simulate(...): Setting initial parameters failed with return code $(retcode)."
                end
            end

            if initFct !== nothing
                initFct()
            end

            # exit setup (hard)
            if setup
                retcode = fmi2ExitInitializationMode(c[i])
                @assert retcode == fmi2StatusOK "fmi2Simulate(...): Exiting initialization mode failed with return code $(retcode)."
            end

            if type == fmi2TypeModelExchange
                if x0 === nothing
                    if x0[i] === nothing
                        x0[i] = fmi2GetContinuousStates(c[i])
                    end
                end
            end
        end

    end # ignore_derivatives

    return c, x0
end

function finishFMU(fmu::FMU2, c::FMU2Component, terminate::Union{Nothing, Bool}, freeInstance::Union{Nothing, Bool})

    if c == nothing 
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
        retcode = fmi2Terminate(c; soft=true)
        @assert retcode == fmi2StatusOK "fmi2Simulate(...): Termination failed with return code $(retcode)."
    end

    # freeInstance (hard)
    if freeInstance
        fmi2FreeInstance!(c)
    end
end

# wrapper
function fmi2SimulateME(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi2SimulateME(c.fmu, c, t_start, t_stop; kwargs...)
end 

"""
Simulates a FMU instance for the given simulation time interval.
State- and Time-Events are handled correctly.

Via the optional keyword arguemnts `inputValues` and `inputFunction`, a custom input function `f(c, u, t)`, `f(c, t)`, `f(u, t)`, `f(c, u)` or `f(t)` with `c` current component, `u` current state and `t` current time can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(...))`.

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
function fmi2SimulateME(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
    tolerance::Union{Real, Nothing} = nothing,
    dt::Union{Real, Nothing} = nothing,
    solver = nothing,
    customFx = nothing,
    recordValues::fmi2ValueReferenceFormat = nothing,
    saveat = nothing,
    x0::Union{AbstractArray{<:Real}, Nothing} = nothing,
    setup::Union{Bool, Nothing} = nothing,
    reset::Union{Bool, Nothing} = nothing,
    instantiate::Union{Bool, Nothing} = nothing,
    freeInstance::Union{Bool, Nothing} = nothing,
    terminate::Union{Bool, Nothing} = nothing,
    inputValueReferences::fmi2ValueReferenceFormat = nothing,
    inputFunction = nothing,
    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
    dtmax::Union{Real, Nothing} = nothing,
    callbacks = [],
    showProgress::Bool = true,
    kwargs...)

    @assert fmi2IsModelExchange(fmu) "fmi2SimulateME(...): This function supports Model Excahnge FMUs only."
    #@assert fmu.type == fmi2TypeModelExchange "fmi2SimulateME(...): This FMU supports Model Exchange, but was instantiated in CS mode. Use `fmiLoad(...; type=:ME)`."

    # input function handling 
    _inputFunction = nothing
    if inputFunction != nothing
        if hasmethod(inputFunction, Tuple{fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(t)
        elseif  hasmethod(inputFunction, Tuple{Union{FMU2Component, Nothing}, fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(c, t)
        elseif  hasmethod(inputFunction, Tuple{Union{FMU2Component, Nothing}, AbstractArray{fmi2Real,1}})
            _inputFunction = (c, u, t) -> inputFunction(c, u)
        elseif  hasmethod(inputFunction, Tuple{AbstractArray{fmi2Real,1}, fmi2Real})
            _inputFunction = (c, u, t) -> inputFunction(u, t)
        else 
            _inputFunction = inputFunction
        end
        @assert hasmethod(_inputFunction, Tuple{FMU2Component, Union{AbstractArray{fmi2Real,1}, Nothing}, fmi2Real}) "The given input function does not fit the needed input function pattern for ME-FMUs, which are: \n- `inputFunction(t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing})`\n- `inputFunction(u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, u::Union{AbstractArray{fmi2Real,1}, Nothing}, t::fmi2Real)`"
    end

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    
    fmusol = FMU2Solution(fmu)

    savingValues = (length(recordValues) > 0)
    hasInputs = (length(inputValueReferences) > 0)
    hasParameters = (parameters !== nothing)
    hasStartState = (x0 !== nothing)

    cbs = []

    for cb in callbacks
        push!(cbs, cb)
    end

    if t_start === nothing 
        t_start = fmi2GetDefaultStartTime(fmu.modelDescription)
        
        if t_start === nothing 
            t_start = 0.0
            @info "No `t_start` choosen, no `t_start` availabel in the FMU, auto-picked `t_start=0.0`."
        end
    end
    
    if t_stop === nothing 
        t_stop = fmi2GetDefaultStopTime(fmu.modelDescription)

        if t_stop === nothing
            t_stop = 1.0
            @warn "No `t_stop` choosen, no `t_stop` availabel in the FMU, auto-picked `t_stop=1.0`."
        end
    end

    if tolerance === nothing 
        tolerance = fmi2GetDefaultTolerance(fmu.modelDescription)
        # if no tolerance is given, pick auto-setting from DifferentialEquations.jl 
    end

    if dt === nothing 
        dt = fmi2GetDefaultStepSize(fmu.modelDescription)
        # if no dt is given, pick auto-setting from DifferentialEquations.jl
    end

    if dtmax === nothing
        dtmax = (t_stop-t_start)/100.0
    end

    c, x0 = prepareFMU(fmu, c, fmi2TypeModelExchange, instantiate, terminate, reset, setup, parameters, t_start, t_stop, tolerance; x0=x0, inputFunction=_inputFunction, inputValueReferences=inputValueReferences)

    # from here on, we are in event mode, if `setup=false` this is the job of the user
    #@assert c.state == fmi2ComponentStateEventMode "FMU needs to be in event mode after setup."

    # if x0 === nothing
    #     x0 = fmi2GetContinuousStates(c)
    #     x0_nom = fmi2GetNominalsOfContinuousStates(c)
    # end

    # initial event handling
    handleEvents(c) 
    #fmi2EnterContinuousTimeMode(c)

    c.fmu.hasStateEvents = (c.fmu.modelDescription.numberOfEventIndicators > 0)
    c.fmu.hasTimeEvents = (c.eventInfo.nextEventTimeDefined == fmi2True)
    
    if customFx === nothing
        customFx = (dx, x, p, t) -> fx(c, dx, x, p, t)
    end

    p = []
    problem = ODEProblem(customFx, x0, (t_start, t_stop), p,)

    progressMeter = nothing
    if showProgress 
        progressMeter = ProgressMeter.Progress(1000; desc="Simulating ME-FMU ...", color=:blue, dt=1.0) #, barglyphs=ProgressMeter.BarGlyphs("[=> ]"))
        ProgressMeter.update!(progressMeter, 0) # show it!
    end

    # callback functions

    if c.fmu.hasTimeEvents
        timeEventCb = IterativeCallback((integrator) -> time_choice(c, integrator, t_start, t_stop),
                                        (integrator) -> affectFMU!(c, integrator, 0, _inputFunction, inputValueReferences, fmusol), Float64; 
                                        initial_affect = (c.eventInfo.nextEventTime == t_start),
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
    #     tmpIntegrator = init(problem, solver)
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
        fmusol.states = solve(problem; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    else
        fmusol.states = solve(problem, solver; callback = CallbackSet(cbs...), dtmax=dtmax, solveKwargs..., kwargs...)
    end

    fmusol.success = (fmusol.states.retcode == :Success)

    # cleanup progress meter
    if showProgress 
        ProgressMeter.finish!(progressMeter)
    end

    finishFMU(fmu, c, terminate, freeInstance)

    return fmusol
end

# wrapper
function fmi2SimulateCS(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi2SimulateCS(c.fmu, c, t_start, t_stop; kwargs...)
end 

############ Co-Simulation ############

"""
Starts a simulation of the Co-Simulation FMU instance.

Via the optional keyword arguments `inputValues` and `inputFunction`, a custom input function `f(c, t)` or `f(t)` with time `t` and component `c` can be defined, that should return a array of values for `fmi2SetReal(..., inputValues, inputFunction(...))`.

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
function fmi2SimulateCS(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
                        tolerance::Union{Real, Nothing} = nothing,
                        dt::Union{Real, Nothing} = nothing,
                        recordValues::fmi2ValueReferenceFormat = nothing,
                        saveat = [],
                        setup::Union{Bool, Nothing} = nothing,
                        reset::Union{Bool, Nothing} = nothing,
                        instantiate::Union{Bool, Nothing} = nothing,
                        freeInstance::Union{Bool, Nothing} = nothing,
                        terminate::Union{Bool, Nothing} = nothing,
                        inputValueReferences::fmi2ValueReferenceFormat = nothing,
                        inputFunction = nothing,
                        showProgress::Bool=true,
                        parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing)

    @assert fmi2IsCoSimulation(fmu) "fmi2SimulateCS(...): This function supports Co-Simulation FMUs only."
    #@assert fmu.type == fmi2TypeCoSimulation "fmi2SimulateCS(...): This FMU supports Co-Simulation, but was instantiated in ME mode. Use `fmiLoad(...; type=:CS)`."

    # input function handling 
    _inputFunction = nothing
    if inputFunction != nothing
        if hasmethod(inputFunction, Tuple{fmi2Real})
            _inputFunction = (c, t) -> inputFunction(t)
        else 
            _inputFunction = inputFunctiont
        end
        @assert hasmethod(_inputFunction, Tuple{FMU2Component, fmi2Real}) "The given input function does not fit the needed input function pattern for CS-FMUs, which are: \n- `inputFunction(t::fmi2Real)`\n- `inputFunction(comp::FMU2Component, t::fmi2Real)`"
    end

    fmusol = FMU2Solution(fmu)

    recordValues = prepareValueReference(fmu, recordValues)
    inputValueReferences = prepareValueReference(fmu, inputValueReferences)
    hasInputs = (length(inputValueReferences) > 0)
    
    variableSteps = fmi2IsCoSimulation(fmu) && fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize 
    
    t_start = t_start === nothing ? fmi2GetDefaultStartTime(fmu.modelDescription) : t_start
    t_start = t_start === nothing ? 0.0 : t_start
    t_stop = t_stop === nothing ? fmi2GetDefaultStopTime(fmu.modelDescription) : t_stop
    t_stop = t_stop === nothing ? 1.0 : t_stop
    tolerance = tolerance === nothing ? fmi2GetDefaultTolerance(fmu.modelDescription) : tolerance
    tolerance = tolerance === nothing ? 0.0 : tolerance
    dt = dt === nothing ? fmi2GetDefaultStepSize(fmu.modelDescription) : dt
    dt = dt === nothing ? 1e-3 : dt

    c, _ = prepareFMU(fmu, c, fmi2TypeCoSimulation, instantiate, terminate, reset, setup, parameters, t_start, t_stop, tolerance; inputFunction=_inputFunction, inputValueReferences=inputValueReferences)

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

    if record
        fmusol.values = SavedValues(Float64, Tuple{collect(Float64 for i in 1:length(recordValues))...} )
        fmusol.valueReferences = copy(recordValues)

        i = 1

        svalues = (fmi2GetReal(c, recordValues)...,)
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

            if _inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, _inputFunction(c, t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
            i += 1

            svalues = (fmi2GetReal(c, recordValues)...,)
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

            if _inputFunction != nothing
                fmi2SetReal(c, inputValueReferences, _inputFunction(c, t))
            end

            fmi2DoStep(c, dt; currentCommunicationPoint=t)
            t = t + dt 
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

##### CS & ME #####

# wrapper
function fmi2Simulate(c::FMU2Component, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)
    fmi2Simulate(c.fmu, c, t_start, t_stop; kwargs...)
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
function fmi2Simulate(fmu::FMU2, c::Union{FMU2Component, Nothing}=nothing, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing; kwargs...)

    if fmu.type == fmi2TypeCoSimulation
        return fmi2SimulateCS(fmu, c, t_start, t_stop; kwargs...)
    elseif fmu.type == fmi2TypeModelExchange
        return fmi2SimulateME(fmu, c, t_start, t_stop; kwargs...)
    else
        error(unknownFMUType)
    end
end
