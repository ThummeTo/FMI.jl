#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Test
import Random

@testset "FMI.jl" begin
    @testset "FMU functions" begin
        include("getterSetterTest_fmu.jl")
        include("independentFunctionsTest_fmu.jl")
        include("stateTest_fmu.jl")
    end
    @testset "fmi2Component functions" begin
        include("getterSetterTest_comp.jl")
        include("independentFunctionsTest_comp.jl")
        include("stateTest_comp.jl")
    end
    @testset "Simulation Tests" begin
        include("test_setter_getter.jl")
        include("test_sim_cs.jl")
        include("test_sim_me.jl")
    end
end