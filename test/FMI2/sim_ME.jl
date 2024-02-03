#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations
using Sundials

# to use autodiff!
using FMISensitivity
using FMI.FMIImport.FMICore: sense_setindex!

t_start = 0.0
t_stop = 8.0
dtmax_inputs = 1e-3
rand_x0 = rand(2)

kwargs = Dict(:dtmin => 1e-64, :abstol => 1e-8, :reltol => 1e-6, :dt => 1e-32)
solvers = [Tsit5(), Rodas5(autodiff=false)] # [Tsit5(), FBDF(autodiff=false), FBDF(autodiff=true), Rodas5(autodiff=false), Rodas5(autodiff=true)]

extForce_t = function(t::Real, u::AbstractArray{<:Real})
    sense_setindex!(u, sin(t), 1)
end 

extForce_cxt = function(c::Union{FMU2Component, Nothing}, x::Union{AbstractArray{<:Real}, Nothing}, t::Real, u::AbstractArray{<:Real})
    x1 = 0.0
    if x != nothing 
        x1 = x[1] 
    end
    sense_setindex!(u, sin(t) * x1, 1)
end 

for solver in solvers

    @info "Testing solver: $(solver)"

    # case 1: ME-FMU with state events

    fmu = fmiLoad("SpringFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); solver=solver, kwargs...)
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop 

    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [1.06736, -1.03552e-10])) < 0.1
    fmiUnload(fmu)

    # case 2: ME-FMU with state and time events

    fmu = fmiLoad("SpringTimeFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    ### test without recording values

    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); solver=solver, kwargs...) 
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop 

    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01

    ### test with recording values (variable step record values)

    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); recordValues="mass.f", solver=solver, kwargs...) 
    dataLength = length(solution.states.u)
    @test dataLength > 0
    @test length(solution.states.t) == dataLength
    @test length(solution.values.saveval) == dataLength
    @test length(solution.values.t) == dataLength

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop 
    @test solution.values.t[1] == t_start 
    @test solution.values.t[end] == t_stop 

    # value/state getters 
    @test solution.states.t == fmi2GetSolutionTime(solution)
    @test collect(s[1] for s in solution.values.saveval) == fmi2GetSolutionValue(solution, 1; isIndex=true)
    @test collect(u[1] for u in solution.states.u      ) == fmi2GetSolutionState(solution, 1; isIndex=true)
    @test isapprox(fmi2GetSolutionState(solution, 2; isIndex=true), fmi2GetSolutionDerivative(solution, 1; isIndex=true); atol=1e-1) # tolerance is large, because Rosenbrock23 solution derivative is not that accurate (other solvers reach 1e-4 for this example)
    @info "Max error of solver polynominal derivative: $(max(abs.(fmi2GetSolutionState(solution, 2; isIndex=true) .- fmi2GetSolutionDerivative(solution, 1; isIndex=true))...))"

    # reference values from Simulation in Dymola2020x (Dassl)
    @test sum(abs.(solution.states.u[1] - [0.5, 0.0])) < 1e-4
    @test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01
    @test abs(solution.values.saveval[1][1] - 0.75) < 1e-4
    @test sum(abs.(solution.values.saveval[end][1] - -0.54435 )) < 0.015

    ### test with recording values (fixed step record values)

    tData = t_start:0.1:t_stop
    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); recordValues="mass.f", saveat=tData, solver=solver, kwargs...) 
    @test length(solution.states.u) == length(tData)
    @test length(solution.states.t) == length(tData)
    @test length(solution.values.saveval) == length(tData)
    @test length(solution.values.t) == length(tData)

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop 
    @test solution.values.t[1] == t_start 
    @test solution.values.t[end] == t_stop 

    # reference values from Simulation in Dymola2020x (Dassl)
    @test sum(abs.(solution.states.u[1] - [0.5, 0.0])) < 1e-4
    @test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01
    @test abs(solution.values.saveval[1][1] - 0.75) < 1e-4
    @test sum(abs.(solution.values.saveval[end][1] - -0.54435 )) < 0.015

    fmiUnload(fmu)

    # case 3a: ME-FMU without events, but with input signal

    fmu = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    for inpfct in [extForce_cxt, extForce_t]
        
        solution = fmiSimulateME(fmuStruct, (t_start, t_stop); inputValueReferences=["extForce"], inputFunction=inpfct, solver=solver, dtmax=dtmax_inputs, kwargs...) # dtmax to force resolution
        @test length(solution.states.u) > 0
        @test length(solution.states.t) > 0

        @test solution.states.t[1] == t_start 
        @test solution.states.t[end] == t_stop
    end 

    # reference values `extForce_t` from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [0.613371, 0.188633])) < 0.012
    fmiUnload(fmu)

    # case 3b: ME-FMU without events, but with input signal (autodiff)

    fmu = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    # there are issues with AD in Julia < 1.7.0
    # ToDo: Fix Linux FMU
    if VERSION >= v"1.7.0" && !Sys.islinux()
        solution = fmiSimulateME(fmuStruct, (t_start, t_stop); solver=solver, dtmax=dtmax_inputs, kwargs...) # dtmax to force resolution

        @test length(solution.states.u) > 0
        @test length(solution.states.t) > 0

        @test solution.states.t[1] == t_start 
        @test solution.states.t[end] == t_stop 

        # reference values (no force) from Simulation in Dymola2020x (Dassl)
        @test solution.states.u[1] == [0.5, 0.0]
        @test sum(abs.(solution.states.u[end] - [0.509219, 0.314074])) < 0.01
    end

    fmiUnload(fmu)

    # case 4: ME-FMU without events, but saving value interpolation

    fmu = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); saveat=tData, recordValues=:states, solver=solver, kwargs...)
    @test length(solution.states.u) == length(tData)
    @test length(solution.states.t) == length(tData)
    @test length(solution.values.saveval) == length(tData)
    @test length(solution.values.t) == length(tData)

    for i in 1:length(tData)
        @test sum(abs(solution.states.t[i] - solution.states.t[i])) < 1e-6
        @test sum(abs(solution.states.u[i][1] - solution.values.saveval[i][1])) < 1e-6
        @test sum(abs(solution.states.u[i][2] - solution.values.saveval[i][2])) < 1e-6
    end

    fmiUnload(fmu)

    # case 5: ME-FMU with different (random) start state

    fmu = fmiLoad("SpringFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

    comp = fmiInstantiate!(fmu; loggingOn=false)
    @test comp != 0

    # choose FMU or FMUComponent
    fmuStruct = nothing
    envFMUSTRUCT = ENV["FMUSTRUCT"]
    if envFMUSTRUCT == "FMU"
        fmuStruct = fmu
    elseif envFMUSTRUCT == "FMUCOMPONENT"
        fmuStruct = comp
    end
    @assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

    solution = fmiSimulateME(fmuStruct, (t_start, t_stop); x0=rand_x0, solver=solver, kwargs...)
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop 

    @test solution.states.u[1] == rand_x0
    fmiUnload(fmu)
end