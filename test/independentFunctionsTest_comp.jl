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

c1 = fmiInstantiate!(myFMU; loggingOn=true)
@test typeof(c1) == FMI.fmi2Component
@test fmiEnterInitializationMode(c1) == 0
@test fmiExitInitializationMode(c1) == 0
@test fmiSetupExperiment(c1) == 0

@test fmiReset(c1) == 0
@test fmiTerminate(c1) == 0

############
# Clean up #
############

fmiUnload(myFMU)
