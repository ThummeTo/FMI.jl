#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI: fmi2VariableNamingConventionStructured, fmi2DependencyKindDependent, fmi2DependencyKindFixed

myFMU = fmiLoad("SpringDFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

@test fmiGetVersion(myFMU) == "2.0"
@test fmiGetTypesPlatform(myFMU) == "default"

@test fmiGetModelName(myFMU) == "SpringFrictionPendulum1D"
@test fmiGetVariableNamingConvention(myFMU) == fmi2VariableNamingConventionStructured
@test fmiIsCoSimulation(myFMU) == true
@test fmiIsModelExchange(myFMU) == true

@test fmiGetGUID(myFMU) == "{df491d8d-0598-4495-913e-5b025e54d7f2}"
@test fmiGetGenerationTool(myFMU) == "Dymola Version 2022x (64-bit), 2021-10-08"
@test fmiGetGenerationDateAndTime(myFMU) == "2022-03-03T15:09:18Z"
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

fmiUnload(myFMU)
