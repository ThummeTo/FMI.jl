cd(dirname(@__FILE__))

pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

c1 = fmiInstantiate!(myFMU; loggingOn=true)

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)


fmiSetupExperiment(myFMU, 0.0)

FMUstate = fmiGetFMUstate(myFMU)
@test typeof(FMUstate) == FMI.fmi2FMUstate
s = fmiSerializedFMUstateSize(myFMU, FMUstate)
vyte = fmiSerializeFMUstate(myFMU, FMUstate)
FMUstate2 = fmiDeSerializeFMUstate(myFMU, vyte)

fmiGetReal(myFMU, "p_real")
FMUstate = fmiGetFMUstate(myFMU)
fmiSetReal(myFMU, "p_real", 10.0)
fmiGetReal(myFMU, "p_real")
fmiSetFMUstate(myFMU, FMUstate2)
fmiGetReal(myFMU, "p_real")
fmi2FreeFMUstate(myFMU, FMUstate)

FMUstate = fmiGetFMUstate(c1)
s = fmiSerializedFMUstateSize(c1, FMUstate)
vyte = fmiSerializeFMUstate(c1, FMUstate)
FMUstate2 = fmiDeSerializeFMUstate(c1, vyte)
fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
