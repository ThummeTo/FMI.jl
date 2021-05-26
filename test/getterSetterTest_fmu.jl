using FMI
cd(dirname(@__FILE__))
pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

# test reference conversion
@test fmi2String2ValueReference(myFMU, "p_real") == 16777216
@test fmi2String2ValueReference(myFMU, "p_integer") == 16777217
@test fmi2ValueReference2String(myFMU, Cint(16777217)) == ["p_integer"]

# create arrays for in place getter
vR = zeros(Real, 3)
vI = zeros(Integer, 3)
vB = zeros(Bool, 3)

c1 = fmiInstantiate!(myFMU; loggingOn=true)
@test typeof(c1) == FMI.fmi2Component

@test fmiEnterInitializationMode(myFMU) == 0
@test fmiSetReal(myFMU, "p_real", 5.0) == 0
fmiSetReal(myFMU, ["u_real", "p_real"], [7.0, 8.0])
fmiSetInteger(myFMU, "p_integer", 6)
fmiSetInteger(myFMU, ["u_integer"], [4])
fmiSetBoolean(myFMU, "p_boolean", false)
fmiSetBoolean(myFMU, ["u_boolean"], [false])
@test fmiGetReal!(myFMU, ["u_real", "y_real", "p_real"], vR) == 0
@test vR == [7.0, 0.0, 8.0]
@test fmiGetInteger!(myFMU, ["u_integer", "y_integer", "p_integer"], vI) == 0
@test vI == [0, 0, 0]
@test fmiGetBoolean!(myFMU, ["u_boolean", "y_boolean", "p_boolean"], vB) == 0
@test vB == [0, 0, 0]
fmiGetString(myFMU, "")
fmiExitInitializationMode(myFMU)


fmiSetupExperiment(myFMU, 0.0)

fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
