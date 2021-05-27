using FMI
using Test

@testset "FMI.jl" begin
    # Write your tests here.
    @testset "FMI.jl FMU functions" begin
        include("getterSetterTest_fmu.jl")
    end
    @testset "FMI.jl fmi2Component functions" begin
        include("getterSetterTest_comp.jl")
    end
end
