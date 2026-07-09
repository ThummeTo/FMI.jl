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

fmuStructs = ("FMU", "INSTANCE")

# enable assertions for warnings/errors for all default execution configurations 
for exec in FMU_EXECUTION_CONFIGURATIONS
    exec.assertOnError = true
    exec.assertOnWarning = true
end

function getFMUStruct(
    modelname,
    mode,
    tool=ENV["EXPORTINGTOOL"],
    version=ENV["EXPORTINGVERSION"],
    fmiversion=ENV["FMIVERSION"],
    fmustruct=ENV["FMUSTRUCT"];
    kwargs...,
)

    # choose FMU or FMUInstance
    if endswith(modelname, ".fmu")
        fmu = FMIImport.loadFMU(modelname; kwargs...)
    else
        fmu = FMIImport.loadFMU(modelname, tool, version, fmiversion; kwargs...)
    end

    if fmustruct == "FMU"
        return fmu, fmu

    elseif fmustruct == "INSTANCE"
        inst, _ = FMIBase.prepareSolveFMU(fmu, nothing, mode; loggingOn=true)
        @test !isnothing(inst)
        return inst, fmu

    else
        @assert false "Unknown fmuStruct, variable `FMUSTRUCT` = `$(fmustruct)`"
    end
end

toolversions = [("Dymola", "2023x")] # ("SimulationX", "4.5.2")

@testset "FMI.jl" begin
    if Sys.iswindows() || Sys.islinux()
        @info "Automated testing is supported on Windows/Linux."

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
            Aqua.test_all(
                FMI;
                ambiguities=false,
                piracies=false,
                persistent_tasks=(tmax=60,),
            )
        end

    elseif Sys.isapple()
        @warn "Test-sets are currently using Windows- and Linux-FMUs, automated testing for macOS is currently not supported."
    end
end
