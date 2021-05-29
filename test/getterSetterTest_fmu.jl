#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

cd(dirname(@__FILE__))
pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

#########################
# Testing Setter/Getter #
#########################

# test reference conversion
@test fmi2String2ValueReference(myFMU, "p_real") == 16777216
@test fmi2String2ValueReference(myFMU, "p_integer") == 16777217
@test fmi2ValueReference2String(myFMU, Cint(16777217)) == ["p_integer"]

# create arrays for in place getter
vR = zeros(Real, 3)
vI = zeros(Integer, 3)
vB = zeros(Bool, 3)
vS = ["test","test"]

c1 = fmiInstantiate!(myFMU; loggingOn=true)

fmiEnterInitializationMode(myFMU)
@test fmiSetReal(myFMU, "p_real", 5.0) == 0
@test fmiSetReal(myFMU, ["u_real", "p_real"], [7.0, 8.0]) == 0

@test fmiSetInteger(myFMU, "p_integer", 6) == 0
@test fmiSetInteger(myFMU, ["u_integer"], [4]) == 0

@test fmiSetBoolean(myFMU, "p_boolean", false) == 0
@test fmiSetBoolean(myFMU, ["u_boolean"], [true]) == 0

@test fmiSetString(myFMU, ["p_string"], ["OldString"]) == 0
@test fmiSetString(myFMU, "p_string", "New String") == 0

fmiGetReal!(myFMU, ["p_real", "y_real", "u_real"], vR)
@test vR == [8.0, 7.0, 7.0]
@test fmiGetReal(myFMU, "p_real") == 8.0

fmiGetInteger!(myFMU, ["u_integer", "y_integer", "p_integer"], vI)
@test vI == [4, 4, 6]
@test fmiGetInteger(myFMU, "y_integer") == 4

fmiGetBoolean!(myFMU, ["u_boolean", "y_boolean", "p_boolean"], vB)
@test vB == [true, true, false]
@test fmiGetBoolean(myFMU, "p_boolean") == false

fmiGetString!(myFMU, ["p_string", "p_string"], vS)
@test vS == ["New String", "New String"]
@test fmiGetString(myFMU, "p_string") == "New String"
fmiExitInitializationMode(myFMU)

############
# Clean up #
############

fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
