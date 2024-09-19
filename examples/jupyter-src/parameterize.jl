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

fmu = loadFMU(pathToFMU)
info(fmu)

dict = Dict{String, Any}()
dict

c = fmi2Instantiate!(fmu; loggingOn=true)

fmi2SetupExperiment(c, tStart, tStop)

params = ["p_real", "p_boolean", "p_integer", "p_string"]

fmi2EnterInitializationMode(c)

getValue(c, params)

fmi2ExitInitializationMode(c)

function generateRandomNumbers()
    rndReal = 100 * rand()
    rndBoolean = rand() > 0.5
    rndInteger = round(Integer, 100 * rand())
    rndString = "Random number $(100 * rand())!"

    return rndReal, rndBoolean, rndInteger, rndString
end

paramsVal = generateRandomNumbers()

fmi2Terminate(c)
fmi2Reset(c)
fmi2SetupExperiment(c, tStart, tStop)

setValue(c, params, collect(paramsVal))

fmi2EnterInitializationMode(c)
# getValue(c, params)
fmi2ExitInitializationMode(c)

simData = simulate(c, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)

fmi2Terminate(c)
fmi2Reset(c)
fmi2SetupExperiment(c, tStart, tStop)

rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()

fmi2SetReal(c, "p_real", rndReal)
fmi2SetBoolean(c, "p_boolean", rndBoolean)
fmi2SetInteger(c, "p_integer", rndInteger)
fmi2SetString(c, "p_string", rndString)

fmi2EnterInitializationMode(c)
# fmi2GetReal(c, "u_real")
# fmi2GetBoolean(c, "u_boolean")
# fmi2GetInteger(c, "u_integer")
# fmi2GetString(c, "p_string")
fmi2ExitInitializationMode(c)

simData = simulate(c, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)

unloadFMU(fmu)
