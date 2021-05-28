using FMI
using Test

@testset "FMI.jl" begin
    # Write your tests here.
    @testset "FMU functions" begin
        include("getterSetterTest_fmu.jl")
        include("independentFunctionsTest_fmu.jl")
    end
    @testset "fmi2Component functions" begin
        include("getterSetterTest_comp.jl")
        include("independentFunctionsTest_comp.jl")
    end
end
