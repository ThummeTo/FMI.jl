#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using FMIZoo
using Test
import Random

exportingToolsWindows = [("Dymola", "2022x")]
exportingToolsLinux = [("Dymola", "2022x")]
fmuStructs = ["FMU", "FMUCOMPONENT"]

function runtestsFMI2(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool[1]
    ENV["EXPORTINGVERSION"] = exportingTool[2]

    @testset "Testing FMUs exported from $exportingTool" begin

        @testset "Sensitivities" begin
            include("FMI2/sens.jl")
        end

        for str in fmuStructs
            @testset "Functions for $str" begin
                ENV["FMUSTRUCT"] = str
                @testset "Variable Getters / Setters" begin
                    include("FMI2/getter_setter.jl")
                end
                @testset "State Manipulation" begin
                    include("FMI2/state.jl")
                end
                @testset "Directional derivatives" begin
                    include("FMI2/dir_ders.jl")
                end
                @testset "Automatic Simulation (CS or ME)" begin
                    include("FMI2/sim_auto.jl")
                end
                @testset "CS Simulation" begin
                    include("FMI2/sim_CS.jl")
                end
                @testset "ME Simulation" begin
                    include("FMI2/sim_ME.jl")
                end
                @testset "Support CS and ME simultaneously" begin
                    include("FMI2/cs_me.jl")
                end
                @testset "Loading/Saving simulation results" begin
                    include("FMI2/load_save.jl")
                end
            end
        end

        @testset "Plotting" begin
            include("FMI2/plots.jl")
        end
    end
end

function runtestsFMI3(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool[1]
    ENV["EXPORTINGVERSION"] = exportingTool[2]

    @testset "Testing FMUs exported from $exportingTool" begin

        @testset "FMI3/Sensitivities" begin
            # include("sens.jl")
        end

        for str in fmuStructs
            @testset "Functions for $str" begin
                ENV["FMUSTRUCT"] = str
                @testset "Variable Getters / Setters" begin
                    #include("FMI3/getter_setter.jl")
                end
                @testset "State Manipulation" begin
                    # include("FMI3/state.jl")
                end
                @testset "Directional derivatives" begin
                    #include("FMI3/dir_ders.jl")
                end
                @testset "Automatic Simulation (CS or ME)" begin
                    #include("FMI3/sim_auto.jl")
                end
                @testset "CS Simulation" begin
                    # include("FMI3/sim_CS.jl")
                end
                @testset "ME Simulation" begin
                    include("FMI3/sim_ME.jl")
                end
                @testset "Support CS and ME simultaneously" begin
                    # include("FMI3/cs_me.jl")
                end
                @testset "Loading/Saving simulation results" begin
                    #include("FMI3/load_save.jl")
                end
            end
        end

        @testset "Plotting" begin
            #include("FMI3/plots.jl")
        end
    end
end

@testset "FMI.jl" begin
    if Sys.iswindows()
        @info "Automated testing is supported on Windows."
        for exportingTool in exportingToolsWindows
            # runtestsFMI2(exportingTool)
            runtestsFMI3(exportingTool)
        end
    elseif Sys.islinux()
        @info "Automated testing is supported on Linux."
        for exportingTool in exportingToolsLinux
            # runtestsFMI2(exportingTool)
            runtestsFMI3(exportingTool)
        end
    elseif Sys.isapple()
        @warn "Test-sets are currrently using Windows- and Linux-FMUs, automated testing for macOS is currently not supported."
    end
end
