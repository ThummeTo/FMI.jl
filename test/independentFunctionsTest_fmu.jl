cd(dirname(@__FILE__))
pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

# independent
@test fmiGetVersion(myFMU) == "2.0"
@test fmiGetTypesPlatform(myFMU) == "default"

c1 = fmiInstantiate!(myFMU; loggingOn=true)
@test typeof(c1) == FMI.fmi2Component
@test fmiEnterInitializationMode(myFMU) == 0
@test fmiExitInitializationMode(myFMU) == 0
@test fmiSetupExperiment(myFMU) == 0

@test fmiReset(myFMU) == 0
@test fmiTerminate(myFMU) == 0
fmiUnload(myFMU)
