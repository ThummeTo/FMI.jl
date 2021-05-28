cd(dirname(@__FILE__))

pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

c1 = fmiInstantiate!(myFMU; loggingOn=true)

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)


fmiSetupExperiment(myFMU, 0.0)

@test fmiGetReal(myFMU, "p_real") == 0
FMUstate = fmiGetFMUstate(myFMU)
@test typeof(FMUstate) == FMI.fmi2FMUstate
len = fmiSerializedFMUstateSize(myFMU, FMUstate)
@test len > 0
bytes = fmiSerializeFMUstate(myFMU, FMUstate)
@test length(bytes) == len
@test typeof(bytes) == Array{Char,1}


fmiSetReal(myFMU, "p_real", 10.0)
FMUstate = fmiGetFMUstate(myFMU)
FMUstate2 = fmiDeSerializeFMUstate(myFMU, bytes)
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
