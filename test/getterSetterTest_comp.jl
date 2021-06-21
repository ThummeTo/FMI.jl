#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "IO.fmu")

myFMU = fmiLoad(pathToFMU)

# create arrays for in place getter
vR = zeros(Real, 3)
vI = zeros(Integer, 3)
vB = [false, false, false]
vS = ["test","test"]

c1 = fmiInstantiate!(myFMU; loggingOn=true)

#########################
# Testing Setter/Getter #
#########################

fmiEnterInitializationMode(c1)
@test fmiSetReal(c1, "p_real", 5.0) == 0
@test fmiSetReal(c1, ["u_real", "p_real"], [7.0, 8.0]) == 0
@test fmiSetInteger(c1, "p_integer", 6) == 0
@test fmiSetInteger(c1, ["u_integer"], [4]) == 0
@test fmiSetBoolean(c1, "p_boolean", false) == 0
@test fmiSetBoolean(c1, ["u_boolean"], [true]) == 0
@test fmiSetString(c1, "p_string", "New String") == 0
fmiGetReal!(c1, ["p_real", "y_real", "u_real"], vR)
@test vR == [8.0, 7.0, 7.0]
p = fmiGetReal(c1, "p_real")
@test p == 8.0
fmiGetInteger!(c1, ["u_integer", "y_integer", "p_integer"], vI)
@test vI == [4, 4, 6]
i = fmiGetInteger(c1, "y_integer")
@test i == 4
fmiGetBoolean!(c1, ["u_boolean", "y_boolean", "p_boolean"], vB)
@test vB == [true, true, false]
b = fmiGetBoolean(c1, "p_boolean")
@test b == false
fmiGetString!(c1, ["p_string", "p_string"], vS)
@test vS == ["New String", "New String"]
string = fmiGetString(c1, "p_string")
@test string == "New String"
fmiExitInitializationMode(c1)

############
# Clean up #
############

fmiReset(c1)
fmiTerminate(c1)
fmiUnload(myFMU)
