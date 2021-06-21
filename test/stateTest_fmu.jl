#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

fmiInstantiate!(myFMU; loggingOn=true)

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)


fmiSetupExperiment(myFMU, 0.0)

###########################
# Testing state functions #
###########################

@test fmiGetReal(myFMU, "mass.s") == 0.5
FMUstate = fmiGetFMUstate(myFMU)
@test typeof(FMUstate) == FMI.fmi2FMUstate
len = fmiSerializedFMUstateSize(myFMU, FMUstate)
@test len > 0
serial = fmiSerializeFMUstate(myFMU, FMUstate)
@test length(serial) == len
@test typeof(serial) == Array{Char,1}

fmiSetReal(myFMU, "mass.s", 10.0)
FMUstate = fmiGetFMUstate(myFMU)
@test fmiGetReal(myFMU, "mass.s") == 10.0

FMUstate2 = fmiDeSerializeFMUstate(myFMU, serial)
@test typeof(FMUstate2) == FMI.fmi2FMUstate
fmiSetFMUstate(myFMU, FMUstate2)
@test fmiGetReal(myFMU, "mass.s") == 0.5
fmiSetFMUstate(myFMU, FMUstate)
@test fmiGetReal(myFMU, "mass.s") == 10.0
fmiFreeFMUstate(myFMU, FMUstate)
fmiFreeFMUstate(myFMU, FMUstate2)

############
# Clean up #
############

fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
