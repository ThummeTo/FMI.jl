# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo

tStart = 0.0
tStop = 1.0
tSave = collect(tStart:tStop)

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)

fmiInstantiate!(myFMU; loggingOn=true)

fmiSetupExperiment(myFMU, tStart, tStop)

params = ["p_real", "p_boolean", "p_integer", "p_string"]

fmiEnterInitializationMode(myFMU)

fmiGet(myFMU, params)

fmiExitInitializationMode(myFMU)

function generateRandomNumbers()
    rndReal = 100 * rand()
    rndBoolean = rand() > 0.5
    rndInteger = round(Integer, 100 * rand())
    rndString = "Random number $(100 * rand())!"

    return rndReal, rndBoolean, rndInteger, rndString
end

paramsVal = generateRandomNumbers()

fmiTerminate(myFMU)
fmiReset(myFMU)
fmiSetupExperiment(myFMU, tStart, tStop)

fmiSet(myFMU, params, collect(paramsVal))

fmiEnterInitializationMode(myFMU)
# fmiGet(myFMU, params)
fmiExitInitializationMode(myFMU)

simData = fmiSimulate(myFMU, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)

fmiTerminate(myFMU)
fmiReset(myFMU)
fmiSetupExperiment(myFMU, tStart, tStop)

rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()

fmiSetReal(myFMU, "p_real", rndReal)
fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
fmiSetInteger(myFMU, "p_integer", rndInteger)
fmiSetString(myFMU, "p_string", rndString)

fmiEnterInitializationMode(myFMU)
# fmiGetReal(myFMU, "u_real")
# fmiGetBoolean(myFMU, "u_boolean")
# fmiGetInteger(myFMU, "u_integer")
# fmiGetString(myFMU, "p_string")
fmiExitInitializationMode(myFMU)

simData = fmiSimulate(myFMU, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)

fmiUnload(myFMU)
