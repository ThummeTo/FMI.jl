#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# case 1: CS-FMU Simulation

fmuStruct, myFMU = getFMUStruct("SpringPendulum1D")

t_start = 0.0
t_stop = 8.0

# test without recording values (but why?)
solution = fmiSimulateCS(fmuStruct, (t_start, t_stop); dt=1e-2)
@test solution.success

# test with recording values
solution = fmiSimulateCS(fmuStruct, (t_start, t_stop); dt=1e-2, recordValues=["mass.s", "mass.v"])
@test solution.success
@test length(solution.values.saveval) == t_start:1e-2:t_stop |> length
@test length(solution.values.saveval[1]) == 2

t = solution.values.t
s = collect(d[1] for d in solution.values.saveval)
v = collect(d[2] for d in solution.values.saveval)
@test t[1] == t_start
@test t[end] == t_stop

# reference values from Simulation in Dymola2020x (Dassl)
@test s[1] == 0.5
@test v[1] == 0.0

if ENV["EXPORTINGTOOL"] == "Dymola/2020x" # ToDo: Linux FMU was corrupted
    @test s[end] ≈ 0.509219 atol=1e-1
    @test v[end] ≈ 0.314074 atol=1e-1
end

fmiUnload(myFMU)

# case 2: CS-FMU with input signal

extForce_t = function (t::Real, u::AbstractArray{<:Real})
    u[1] = sin(t)
end 

extForce_ct = function (c::Union{FMU2Component, Nothing}, t::Real, u::AbstractArray{<:Real})
    u[1] = sin(t)
end  

fmuStruct, myFMU = getFMUStruct("SpringPendulumExtForce1D")

for inpfct in [extForce_ct, extForce_t]
    global solution

    solution = fmiSimulateCS(fmuStruct, (t_start, t_stop); dt=1e-2, recordValues=["mass.s", "mass.v"], inputValueReferences=["extForce"], inputFunction=inpfct)
    @test solution.success
    @test length(solution.values.saveval) > 0
    @test length(solution.values.t) > 0

    @test t[1] == t_start
    @test t[end] == t_stop
end

# reference values from Simulation in Dymola2020x (Dassl)
@test [solution.values.saveval[1]...] == [0.5, 0.0]
@test sum(abs.([solution.values.saveval[end]...] - [0.613371, 0.188633])) < 0.2
fmiUnload(myFMU)

