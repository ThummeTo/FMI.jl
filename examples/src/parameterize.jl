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
# just replace this line with a local path if you want to use your own FMU
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

fmu = fmiLoad(pathToFMU)
fmiInfo(fmu)

dict = Dict{String, Any}()
dict

fmiInstantiate!(fmu; loggingOn=true)

fmiSetupExperiment(fmu, tStart, tStop)

params = ["p_real", "p_boolean", "p_integer", "p_string"]

fmiEnterInitializationMode(fmu)

fmiGet(fmu, params)

fmiExitInitializationMode(fmu)

function generateRandomNumbers()
    rndReal = 100 * rand()
    rndBoolean = rand() > 0.5
    rndInteger = round(Integer, 100 * rand())
    rndString = "Random number $(100 * rand())!"

    return rndReal, rndBoolean, rndInteger, rndString
end

paramsVal = generateRandomNumbers()

fmiTerminate(fmu)
fmiReset(fmu)
fmiSetupExperiment(fmu, tStart, tStop)

fmiSet(fmu, params, collect(paramsVal))

fmiEnterInitializationMode(fmu)
# fmiGet(fmu, params)
fmiExitInitializationMode(fmu)

simData = fmiSimulate(fmu, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)

fmiTerminate(fmu)
fmiReset(fmu)
fmiSetupExperiment(fmu, tStart, tStop)

rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()

fmiSetReal(fmu, "p_real", rndReal)
fmiSetBoolean(fmu, "p_boolean", rndBoolean)
fmiSetInteger(fmu, "p_integer", rndInteger)
fmiSetString(fmu, "p_string", rndString)

fmiEnterInitializationMode(fmu)
# fmiGetReal(fmu, "u_real")
# fmiGetBoolean(fmu, "u_boolean")
# fmiGetInteger(fmu, "u_integer")
# fmiGetString(fmu, "p_string")
fmiExitInitializationMode(fmu)

simData = fmiSimulate(fmu, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)

fmiUnload(fmu)
