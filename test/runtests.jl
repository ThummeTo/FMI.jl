#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using FMIZoo
using Test
import Random

import FMI.FMIImport.FMICore: fmi2StatusOK

exportingToolsWindows = [("Dymola", "2022x")]
exportingToolsLinux = [("Dymola", "2022x")]
fmuStructs = ["FMU", "FMUCOMPONENT"]

# enable assertions for warnings/errors for all default execution configurations 
for exec in [FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_RESET]
    exec.assertOnError = true
    exec.assertOnWarning = true
end

function runtests(exportingTool)
    ENV["EXPORTINGTOOL"] = exportingTool[1]
    ENV["EXPORTINGVERSION"] = exportingTool[2]

    @testset "Testing FMUs exported from $exportingTool" begin

        @info "Sensitivities (sens.jl)"
        @testset "Sensitivities" begin
            include("sens.jl")
        end

        @info "Model Description (model_description.jl)"
        @testset "Model Description" begin
            include("model_description.jl")
        end

        for str in fmuStructs
            @testset "Functions for $str" begin
                ENV["FMUSTRUCT"] = str

                @info "Variable Getters / Setters (getter_setter.jl)"
                @testset "Variable Getters / Setters" begin
                    include("getter_setter.jl")
                end

                @info "State Manipulation (state.jl)"
                @testset "State Manipulation" begin
                    include("state.jl")
                end

                @info "Directional derivatives (dir_ders.jl)"
                @testset "Directional derivatives" begin
                    include("dir_ders.jl")
                end

                @info "Automatic Simulation (sim_auto.jl)"
                @testset "Automatic Simulation (CS or ME)" begin
                    include("sim_auto.jl")
                end

                @info "CS Simulation (sim_CS.jl)"
                @testset "CS Simulation" begin
                    include("sim_CS.jl")
                end

                @info "ME Simulation (sim_ME.jl)"
                @testset "ME Simulation" begin
                    include("sim_ME.jl")
                end

                @info "Support CS and ME simultaneously (cs_me.jl)"
                @testset "Support CS and ME simultaneously" begin
                    include("cs_me.jl")
                end

                @info "Loading/Saving simulation results (load_save.jl)"
                @testset "Loading/Saving simulation results" begin
                    include("load_save.jl")
                end
            end
        end

        @info "Plotting (plots.jl)"
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
