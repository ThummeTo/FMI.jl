#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# testing different modes for ME (model exchange) mode

using DifferentialEquations
using Sundials

# to use autodiff!
using FMISensitivity
using FMI.FMIImport.FMIBase: sense_setindex!

t_start = 0.0
t_stop = 8.0
dtmax_inputs = 1e-3
rand_x0 = rand(2)

kwargs = Dict(:dtmin => 1e-64, :abstol => 1e-8, :reltol => 1e-6, :dt => 1e-32)
solvers = [Tsit5(), Rodas5(autodiff = false)] # [Tsit5(), FBDF(autodiff=false), FBDF(autodiff=true), Rodas5(autodiff=false), Rodas5(autodiff=true)]

extForce_t! = function (t::Real, u::AbstractArray{<:Real})
    sense_setindex!(u, sin(t), 1)
end

extForce_cxt! = function (
    c::Union{FMUInstance,Nothing},
    x::Union{AbstractArray{<:Real},Nothing},
    t::Real,
    u::AbstractArray{<:Real},
)
    x1 = 0.0
    if x != nothing
        x1 = x[1]
    end
    sense_setindex!(u, sin(t) * x1, 1)
end

for solver in solvers

    global fmuStruct, fmu, solution

    @info "Testing solver: $(solver)"

    # case 1: ME-FMU with state events

    fmuStruct, fmu = getFMUStruct("SpringFrictionPendulum1D", :ME)

    solution = simulateME(fmuStruct, (t_start, t_stop); solver = solver, kwargs...)
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start
    @test solution.states.t[end] == t_stop

    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [1.06736, -1.03552e-10])) < 0.1
    unloadFMU(fmu)

    # case 2: ME-FMU with state and time events

    fmuStruct, fmu = getFMUStruct("SpringTimeFrictionPendulum1D", :ME)

    ### test without recording values

    solution = simulateME(fmuStruct, (t_start, t_stop); solver = solver, kwargs...)
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start
    @test solution.states.t[end] == t_stop

    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01

    ### test with recording values (variable step record values)

    solution = simulateME(
        fmuStruct,
        (t_start, t_stop);
        recordValues = "mass.f",
        solver = solver,
        kwargs...,
    )
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
    @test solution.states.t == getTime(solution)
    @test collect(s[1] for s in solution.values.saveval) ==
          getValue(solution, 1; isIndex = true)
    @test collect(u[1] for u in solution.states.u) == getState(solution, 1; isIndex = true)
    @test isapprox(
        getState(solution, 2; isIndex = true),
        getStateDerivative(solution, 1; isIndex = true);
        atol = 1e-1,
    ) # tolerance is large, because Rosenbrock23 solution derivative is not that accurate (other solvers reach 1e-4 for this example)
    @info "Max error of solver polynominal derivative: $(max(abs.(getState(solution, 2; isIndex=true) .- getStateDerivative(solution, 1; isIndex=true))...))"

    # reference values from Simulation in Dymola2020x (Dassl)
    @test sum(abs.(solution.states.u[1] - [0.5, 0.0])) < 1e-4
    @test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01
    @test abs(solution.values.saveval[1][1] - 0.75) < 1e-4
    @test sum(abs.(solution.values.saveval[end][1] - -0.54435)) < 0.015

    ### test with recording values (fixed step record values)

    tData = t_start:0.1:t_stop
    solution = simulateME(
        fmuStruct,
        (t_start, t_stop);
        recordValues = "mass.f",
        saveat = tData,
        solver = solver,
        kwargs...,
    )
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
    @test sum(abs.(solution.values.saveval[end][1] - -0.54435)) < 0.015

    unloadFMU(fmu)

    # case 3a: ME-FMU without events, but with input signal

    fmuStruct, fmu = getFMUStruct("SpringPendulumExtForce1D", :ME)

    for inpfct! in [extForce_cxt!, extForce_t!]

        solution = simulateME(
            fmuStruct,
            (t_start, t_stop);
            inputValueReferences = ["extForce"],
            inputFunction = inpfct!,
            solver = solver,
            dtmax = dtmax_inputs,
            kwargs...,
        ) # dtmax to force resolution
        @test length(solution.states.u) > 0
        @test length(solution.states.t) > 0

        @test solution.states.t[1] == t_start
        @test solution.states.t[end] == t_stop
    end

    # reference values `extForce_t` from Simulation in Dymola2020x (Dassl)
    @test solution.states.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.states.u[end] - [0.613371, 0.188633])) < 0.012
    unloadFMU(fmu)

    # case 3b: ME-FMU without events, but with input signal (autodiff)

    fmuStruct, fmu = getFMUStruct("SpringPendulumExtForce1D", :ME)

    # there are issues with AD in Julia < 1.7.0
    # ToDo: Fix Linux FMU
    if VERSION >= v"1.7.0" && !Sys.islinux()
        solution = simulateME(
            fmuStruct,
            (t_start, t_stop);
            solver = solver,
            dtmax = dtmax_inputs,
            kwargs...,
        ) # dtmax to force resolution

        @test length(solution.states.u) > 0
        @test length(solution.states.t) > 0

        @test solution.states.t[1] == t_start
        @test solution.states.t[end] == t_stop

        # reference values (no force) from Simulation in Dymola2020x (Dassl)
        @test solution.states.u[1] == [0.5, 0.0]
        @test sum(abs.(solution.states.u[end] - [0.509219, 0.314074])) < 0.01
    end

    unloadFMU(fmu)

    # case 4: ME-FMU without events, but saving value interpolation

    fmuStruct, fmu = getFMUStruct("SpringPendulumExtForce1D", :ME)

    solution = simulateME(
        fmuStruct,
        (t_start, t_stop);
        saveat = tData,
        recordValues = :states,
        solver = solver,
        kwargs...,
    )
    @test length(solution.states.u) == length(tData)
    @test length(solution.states.t) == length(tData)
    @test length(solution.values.saveval) == length(tData)
    @test length(solution.values.t) == length(tData)

    @test isapprox(solution.states.t, solution.states.t; atol = 1e-6)
    @test isapprox(
        collect(u[1] for u in solution.states.u),
        collect(u[1] for u in solution.values.saveval);
        atol = 1e-6,
    )
    @test isapprox(
        collect(u[2] for u in solution.states.u),
        collect(u[2] for u in solution.values.saveval);
        atol = 1e-6,
    )

    unloadFMU(fmu)

    # case 5: ME-FMU with different (random) start state

    fmuStruct, fmu = getFMUStruct("SpringFrictionPendulum1D", :ME)

    solution =
        simulateME(fmuStruct, (t_start, t_stop); x0 = rand_x0, solver = solver, kwargs...)
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start
    @test solution.states.t[end] == t_stop

    @test solution.states.u[1] == rand_x0
    unloadFMU(fmu)
end
