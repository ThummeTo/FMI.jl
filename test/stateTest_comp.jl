#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

cd(dirname(@__FILE__))

pathToFMU = joinpath(pwd(), "../model/SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

c1 = fmiInstantiate!(myFMU; loggingOn=true)

fmiEnterInitializationMode(c1)
fmiExitInitializationMode(c1)

fmiSetupExperiment(c1, 0.0)

###########################
# Testing state functions #
###########################

@test fmiGetReal(c1, "mass.s") == 0.5
FMUstate = fmiGetFMUstate(c1)
@test typeof(FMUstate) == FMI.fmi2FMUstate
len = fmiSerializedFMUstateSize(c1, FMUstate)
@test len > 0
serial = fmiSerializeFMUstate(c1, FMUstate)
@test length(serial) == len
@test typeof(serial) == Array{Char,1}

fmiSetReal(c1, "mass.s", 10.0)
FMUstate = fmiGetFMUstate(c1)
@test fmiGetReal(c1, "mass.s") == 10.0

FMUstate2 = fmiDeSerializeFMUstate(c1, serial)
@test typeof(FMUstate2) == FMI.fmi2FMUstate
fmiSetFMUstate(c1, FMUstate2)
@test fmiGetReal(c1, "mass.s") == 0.5
fmiSetFMUstate(c1, FMUstate)
@test fmiGetReal(c1, "mass.s") == 10.0
fmiFreeFMUstate(c1, FMUstate)
fmiFreeFMUstate(c1, FMUstate2)

############
# Clean up #
############

fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
