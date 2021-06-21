#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Test
import Random

exportingToolsWindows = ["Dymola/2020x", "OpenModelica/v1.17.0"]
exportingToolsLinux = ["OpenModelica/v1.17.0"]

function runtests(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool

    @testset "Testing FMUs exported from $exportingTool" begin
        @testset "FMU functions" begin
            include("getterSetterTest_fmu.jl")
            include("independentFunctionsTest_fmu.jl")
            if exportingTool != "OpenModelica/v1.17.0" # state manipulation (optional) is not supported by OpenModelica
                include("stateTest_fmu.jl")
            end
        end
        @testset "FMI-Component functions" begin
            include("getterSetterTest_comp.jl")
            include("independentFunctionsTest_comp.jl")
            if exportingTool != "OpenModelica/v1.17.0" # state manipulation (optional) is not supported by OpenModelica
                include("stateTest_comp.jl")
            end
        end
        @testset "Simulation Tests" begin
            include("test_setter_getter.jl")
            include("test_sim_CS.jl")
            include("test_sim_ME.jl")
        end
    end
end

@testset "FMI.jl" begin
    if Sys.iswindows()
        @info "Automated testing is supported on Windows."
        for exportingTool in exportingToolsWindows
            runtests(exportingTool)
        end
    elseif Sys.islinux()
        @info "Automated testing is supported on Linux."
        for exportingTool in exportingToolsLinux
            runtests(exportingTool)
        end
    elseif Sys.isapple()
        @warn "Test-sets are currrently using Windows- and Linux-FMUs, automated testing for macOS is currently not supported."
    end
end
