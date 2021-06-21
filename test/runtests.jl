#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Test
import Random

function runtests(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool

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
        include("test_sim_CS.jl")
        include("test_sim_ME.jl")
    end
end

@testset "FMI.jl" begin
    if Sys.iswindows()
        @testset "Dymola 2020x" begin
            @info "Automated testing for Dymola 2020x FMUs"
            runtests("Dymola/2020x")
        end
        @testset "OpenModelica v1.17.0" begin
            @info "Automated testing for OpenModelica v1.17.0 FMUs"
            runtests("OpenModelica/v1.17.0")
        end
    elseif Sys.islinux()
        @testset "OpenModelica v1.17.0" begin
            @info "Automated testing for OpenModelica v1.17.0 FMUs"
            ENV["EXPORTINGTOOL"] = "OpenModelica/v1.17.0"
            runtests("OpenModelica/v1.17.0")
        end
    elseif Sys.isapple()
        @warn "Test-sets are currrently using Windows-FMUs, automated testing for macOS is currently not supported."
    end
end
