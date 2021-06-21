#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "IO.fmu")

myFMU = fmiLoad(pathToFMU)

#################################
# Testing independent functions #
#################################

@test fmiGetVersion(myFMU) == "2.0"
@test fmiGetTypesPlatform(myFMU) == "default"

c1 = fmiInstantiate!(myFMU; loggingOn=true)
@test typeof(c1) == FMI.fmi2Component
@test fmiEnterInitializationMode(myFMU) == 0
@test fmiExitInitializationMode(myFMU) == 0
@test fmiSetupExperiment(myFMU) == 0

@test fmiReset(myFMU) == 0
@test fmiTerminate(myFMU) == 0

############
# Clean up #
############

fmiUnload(myFMU)
