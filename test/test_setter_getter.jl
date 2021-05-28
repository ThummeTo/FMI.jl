#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

pathToFMU = joinpath(dirname(@__FILE__), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)
@test fmiInstantiate!(myFMU; loggingOn=false) != 0

@test fmiSetupExperiment(myFMU, 0.0) == 0

@test fmiEnterInitializationMode(myFMU) == 0

#########################
# Testing Setter/Getter #
#########################

rndReal = 100 * rand()
rndInteger = round(Integer, 100 * rand())
rndBoolean = rand() > 0.5
rndString = Random.randstring(12)

@test fmiSetReal(myFMU, "p_real", rndReal) == 0
@test fmiGetReal(myFMU, "p_real") == rndReal
@test fmiSetReal(myFMU, "p_real", -rndReal) == 0
@test fmiGetReal(myFMU, "p_real") == -rndReal

@test fmiSetInteger(myFMU, "p_integer", rndInteger) == 0
@test fmiGetInteger(myFMU, "p_integer") == rndInteger
@test fmiSetInteger(myFMU, "p_integer", -rndInteger) == 0
@test fmiGetInteger(myFMU, "p_integer") == -rndInteger

@test fmiSetBoolean(myFMU, "p_boolean", rndBoolean) == 0
@test fmiGetBoolean(myFMU, "p_boolean") == rndBoolean
@test fmiSetBoolean(myFMU, "p_boolean", !rndBoolean) == 0
@test fmiGetBoolean(myFMU, "p_boolean") == !rndBoolean

@test fmiSetString(myFMU, "p_string", rndString) == 0
@test fmiGetString(myFMU, "p_string") == rndString

############
# Clean up #
############

@test fmiExitInitializationMode(myFMU) == 0

fmiUnload(myFMU)
