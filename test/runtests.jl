#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using FMIZoo
using Test
using Aqua
import Random

using FMI.FMIImport
using FMI.FMIImport.FMIBase
using FMI.FMIImport.FMIBase.FMICore

import FMI.FMIImport.FMIBase: FMU_EXECUTION_CONFIGURATIONS

using FMI.FMIImport

using DifferentialEquations: FBDF

fmuStructs = ("FMU", "FMUCOMPONENT")

# enable assertions for warnings/errors for all default execution configurations 
for exec in FMU_EXECUTION_CONFIGURATIONS
    exec.assertOnError = true
    exec.assertOnWarning = true
end

function getFMUStruct(modelname, mode, tool=ENV["EXPORTINGTOOL"], version=ENV["EXPORTINGVERSION"], fmiversion=ENV["FMIVERSION"], fmustruct=ENV["FMUSTRUCT"]; kwargs...)
    
    # choose FMU or FMUComponent
    if endswith(modelname, ".fmu")
        fmu = loadFMU(modelname; kwargs...)
    else
        fmu = loadFMU(modelname, tool, version, fmiversion; kwargs...) 
    end

    if fmustruct == "FMU"
        return fmu, fmu

    elseif fmustruct == "FMUCOMPONENT"
        inst, _ = FMI.prepareSolveFMU(fmu, nothing, mode; loggingOn=true)
        @test !isnothing(inst)
        return inst, fmu

    else
        @assert false "Unknown fmuStruct, variable `FMUSTRUCT` = `$(fmustruct)`"
    end
end

@testset "FMI.jl" begin
    if Sys.iswindows() || Sys.islinux()
        @info "Automated testing is supported on Windows/Linux."
        
        ENV["EXPORTINGTOOL"] = "Dymola"
        ENV["EXPORTINGVERSION"] = "2023x"

        for fmiversion in (2.0, 3.0)
            ENV["FMIVERSION"] = fmiversion

            @testset "Testing FMI $(ENV["FMIVERSION"]) FMUs exported from $(ENV["EXPORTINGTOOL"]) $(ENV["EXPORTINGVERSION"])" begin

                for fmustruct in fmuStructs
                    ENV["FMUSTRUCT"] = fmustruct

                    @testset "Functions for $(ENV["FMUSTRUCT"])" begin
        
                        @info "CS Simulation (sim_CS.jl)"
                        @testset "CS Simulation" begin
                            include("sim_CS.jl")
                        end
        
                        @info "ME Simulation (sim_ME.jl)"
                        @testset "ME Simulation" begin
                            include("sim_ME.jl")
                        end

                        @info "SE Simulation (sim_SE.jl)"
                        @testset "SE Simulation" begin
                            include("sim_SE.jl")
                        end
        
                        @info "Simulation FMU without states (sim_zero_state.jl)"
                        @testset "Simulation FMU without states" begin
                            include("sim_zero_state.jl")
                        end
                    end

                    # if VERSION >= v"1.9.0"
                    #     @info "Performance (performance.jl)"
                    #     @testset "Performance" begin
                    #         include("FMI2/performance.jl")
                    #     end
                    # else
                        @info "Julia Version $(VERSION), skipping performance tests ..."
                    #end
                end
            end
        end

        @testset "Aqua.jl" begin
            @info "Aqua: Method ambiguity"
            @testset "Method ambiguities" begin
                Aqua.test_ambiguities([FMI])
            end
    
            @info "Aqua: Piracies"
            @testset "Piracies" begin
                Aqua.test_piracies(FMI) # ; broken = true)
            end
    
            @info "Aqua: Testing all (method ambiguities and piracies are tested separately)"
            Aqua.test_all(FMI; ambiguities = false, piracies = false)
        end

    elseif Sys.isapple()
        @warn "Test-sets are currently using Windows- and Linux-FMUs, automated testing for macOS is currently not supported."
    end
end
