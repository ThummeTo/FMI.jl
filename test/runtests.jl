#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Test
import Random

exportingToolsWindows = ["Dymola/2020x", "OpenModelica/v1.17.0"]
exportingToolsLinux = ["OpenModelica/v1.17.0"]
fmuStructs = ["FMU", "FMUCOMPONENT"]

function runtests(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool

    @testset "Testing FMUs exported from $exportingTool" begin
        for str in fmuStructs
            @testset "Functions for $str" begin
                ENV["FMUSTRUCT"] = str
                @testset "Variable Getters / Setters" begin
                    include("getter_setter.jl")
                end
                @testset "State Manipulation" begin
                    include("state.jl")
                end
                @testset "Directional derivatives" begin
                    include("dir_ders.jl")
                end
                @testset "Automatic Simulation (CS or ME)" begin
                    include("sim_auto.jl")
                end
                @testset "CS Simulation" begin
                    include("sim_CS.jl")
                end
                @testset "ME Simulation" begin
                    include("sim_ME.jl")
                end
                @testset "Support CS and ME simultaneously" begin
                    include("cs_me.jl")
                end
            end
        end

        @testset "Plotting" begin
            include("plots.jl")
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
