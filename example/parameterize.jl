#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
import FMIZoo

# our simulation setup
t_start = 0.0
t_stop = 8.0

# we use a FMU from the FMIZoo.jl
pathToFMU = FMIZoo.get_model_filename("IO", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU; loggingOn=true)
fmiSetupExperiment(myFMU, 0.0)
fmiEnterInitializationMode(myFMU)

fmiGetString(myFMU, "p_string")

rndReal = 100 * rand()
rndInteger = round(Integer, 100 * rand())
rndBoolean = rand() > 0.5
rndString = "Not random!"

# case A: The fast way ...

fmiSet(myFMU, ["p_real", "p_integer", "p_boolean", "p_string"], [rndReal, rndInteger, rndBoolean, rndString])
fmiGet(myFMU, ["p_real", "p_integer", "p_boolean", "p_string"])

# case B: Maximum control over what happens ...

fmiSetReal(myFMU, "p_real", rndReal)
display("$rndReal == $(fmiGetReal(myFMU, "p_real"))")

fmiSetInteger(myFMU, "p_integer", rndInteger)
display("$rndInteger == $(fmiGetInteger(myFMU, "p_integer"))")

fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
display("$rndBoolean == $(fmiGetBoolean(myFMU, "p_boolean"))")

fmiSetString(myFMU, "p_string", rndString)
display("$rndString == $(fmiGetString(myFMU, "p_string"))")

# clean up

fmiExitInitializationMode(myFMU)

fmiUnload(myFMU)
