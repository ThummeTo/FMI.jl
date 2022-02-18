#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI: fmi2VariableNamingConventionStructured, fmi2DependencyKindDependent, fmi2DependencyKindFixed

tool = ENV["EXPORTINGTOOL"]
pathToFMU = joinpath(dirname(@__FILE__), "..", "model", tool, "SpringFrictionPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

@test fmiGetVersion(myFMU) == "2.0"
@test fmiGetTypesPlatform(myFMU) == "default"

@test fmiGetModelName(myFMU) == "SpringFrictionPendulum1D"
@test fmiGetVariableNamingConvention(myFMU) == fmi2VariableNamingConventionStructured
@test fmiIsCoSimulation(myFMU) == true
@test fmiIsModelExchange(myFMU) == true

if tool == "Dymola/2020x"
    @test fmiGetGUID(myFMU) == "{b02421b8-652a-4d48-9ffc-c2b223aa1b94}"
    @test fmiGetGenerationTool(myFMU) == "Dymola Version 2020x (64-bit), 2019-10-10"
    @test fmiGetGenerationDateAndTime(myFMU) == "2021-11-23T13:36:30Z"
    @test fmiGetNumberOfEventIndicators(myFMU) == 24
    @test fmiCanGetSetState(myFMU) == true
    @test fmiCanSerializeFMUstate(myFMU) == true
    @test fmiProvidesDirectionalDerivative(myFMU) == true

    depMtx = fmi2GetDependencies(myFMU)
    @test fmi2DependencyKindFixed in depMtx
    @test fmi2DependencyKindDependent in depMtx

    @test fmi2GetDefaultStartTime(myFMU.modelDescription) ≈ 0.0
    @test fmi2GetDefaultStopTime(myFMU.modelDescription) ≈ 1.0
    @test fmi2GetDefaultTolerance(myFMU.modelDescription) ≈ 1e-4
    @test fmi2GetDefaultStepSize(myFMU.modelDescription) === nothing

elseif tool == "OpenModelica/v1.17.0"
    @test fmiGetGUID(myFMU) == "{8584aa5b-179e-44ed-9ba6-d557ed34541e}"
    @test fmiGetGenerationTool(myFMU) == "OpenModelica Compiler OMCompiler v1.17.0"
    @test fmiGetGenerationDateAndTime(myFMU) == "2021-06-21T11:48:49Z"
    @test fmiGetNumberOfEventIndicators(myFMU) == 14
    @test fmiCanGetSetState(myFMU) == false
    @test fmiCanSerializeFMUstate(myFMU) == false
    @test fmiProvidesDirectionalDerivative(myFMU) == false

    depMtx = fmi2GetDependencies(myFMU)
    @test fmi2DependencyKindDependent in depMtx

    @test fmi2GetDefaultStartTime(myFMU.modelDescription) ≈ 0.0
    @test fmi2GetDefaultStopTime(myFMU.modelDescription) ≈ 1.0
    @test fmi2GetDefaultTolerance(myFMU.modelDescription) ≈ 1e-6
    @test fmi2GetDefaultStepSize(myFMU.modelDescription) === nothing
else
    @warn "Unknown exporting tool `$tool`. Skipping model description tests."
end

fmiUnload(myFMU)
