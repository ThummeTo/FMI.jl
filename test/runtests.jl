using FMI
using Test
import Random

@testset "FMI.jl" begin
    # Write your tests here.
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
    @testset "Tobi Tests" begin
        include("test_setter_getter.jl")
        include("test_sim_cs.jl")
        include("test_sim_me.jl")
    end
end
