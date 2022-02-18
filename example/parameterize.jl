#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI

pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/IO.fmu")

myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU; loggingOn=true)

fmiSetupExperiment(myFMU, 0.0)

fmiEnterInitializationMode(myFMU)

fmiGetString(myFMU, "p_string")

rndReal = 100 * rand()
rndInteger = round(Integer, 100 * rand())
rndBoolean = rand() > 0.5
rndString = "Not random!"

fmiSetReal(myFMU, "p_real", rndReal)
display("$rndReal == $(fmiGetReal(myFMU, "p_real"))")

fmiSetInteger(myFMU, "p_integer", rndInteger)
display("$rndInteger == $(fmiGetInteger(myFMU, "p_integer"))")

fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
display("$rndBoolean == $(fmiGetBoolean(myFMU, "p_boolean"))")

fmiSetString(myFMU, "p_string", rndString)
display("$rndString == $(fmiGetString(myFMU, "p_string"))")

fmiExitInitializationMode(myFMU)

fmiUnload(myFMU)
