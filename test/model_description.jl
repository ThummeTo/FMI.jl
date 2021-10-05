#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

tool = ENV["EXPORTINGTOOL"]
pathToFMU = joinpath(dirname(@__FILE__), "..", "model", tool, "SpringFrictionPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

@test fmiGetVersion(myFMU) == "2.0"
@test fmiGetTypesPlatform(myFMU) == "default"

@test fmiGetModelName(myFMU) == "SpringFrictionPendulum1D"
@test fmiGetVariableNamingConvention(myFMU) == "structured"
@test fmiIsCoSimulation(myFMU) == true
@test fmiIsModelExchange(myFMU) == true

if tool == "Dymola/2020x"
    @test fmiGetGUID(myFMU) == "{a357de9f-764f-41f1-81c4-b2d344c98a37}"
    @test fmiGetGenerationTool(myFMU) == "Dymola Version 2020x (64-bit), 2019-10-10"
    @test fmiGetGenerationDateAndTime(myFMU) == "2021-05-06T08:23:56Z"
    @test fmiGetNumberOfEventIndicators(myFMU) == 24
    @test fmiCanGetSetState(myFMU) == true
    @test fmiCanSerializeFMUstate(myFMU) == true
    @test fmiProvidesDirectionalDerivative(myFMU) == true

    depMtx = fmi2GetDependencies(myFMU)
    @test fmi2DependencyFixed::fmi2Dependency in depMtx
    @test fmi2DependencyDependent::fmi2Dependency in depMtx
elseif tool == "OpenModelica/v1.17.0"
    @test fmiGetGUID(myFMU) == "{8584aa5b-179e-44ed-9ba6-d557ed34541e}"
    @test fmiGetGenerationTool(myFMU) == "OpenModelica Compiler OMCompiler v1.17.0"
    @test fmiGetGenerationDateAndTime(myFMU) == "2021-06-21T11:48:49Z"
    @test fmiGetNumberOfEventIndicators(myFMU) == 14
    @test fmiCanGetSetState(myFMU) == false
    @test fmiCanSerializeFMUstate(myFMU) == false
    @test fmiProvidesDirectionalDerivative(myFMU) == false

    depMtx = fmi2GetDependencies(myFMU)
    @test fmi2DependencyDependent::fmi2Dependency in depMtx
else
    @warn "Unknown exporting tool `$tool`. Skipping model description tests."
end

fmiUnload(myFMU)
