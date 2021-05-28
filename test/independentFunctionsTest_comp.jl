cd(dirname(@__FILE__))
pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

c1 = fmiInstantiate!(myFMU; loggingOn=true)
@test typeof(c1) == FMI.fmi2Component
@test fmiEnterInitializationMode(c1) == 0
@test fmiExitInitializationMode(c1) == 0
@test fmiSetupExperiment(c1) == 0

@test fmiReset(c1) == 0
@test fmiTerminate(c1) == 0
fmiUnload(myFMU)
