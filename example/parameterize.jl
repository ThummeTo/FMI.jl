# imports
using FMI
using FMIZoo

tStart = 0.0
tStop = 8.0

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)

fmiInstantiate!(myFMU; loggingOn=true)

fmiSetupExperiment(myFMU, tStart, tStop)

fmiEnterInitializationMode(myFMU)

params = ["p_real", "p_integer", "p_boolean", "p_string"]
fmiGet(myFMU, params)

function generateRandomNumbers()
    rndReal = 100 * rand()
    rndInteger = round(Integer, 100 * rand())
    rndBoolean = rand() > 0.5
    rndString = "Random number $(100 * rand())!"

    randValues = [rndReal, rndInteger, rndBoolean, rndString]
    println(randValues)
    return randValues
end

paramsVal = generateRandomNumbers();

fmiSet(myFMU, params, paramsVal)
values = fmiGet(myFMU, params)
print(values)

@assert paramsVal == values

rndReal, rndInteger, rndBoolean, rndString = generateRandomNumbers();

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
