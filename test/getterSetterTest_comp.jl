using FMI
cd(dirname(@__FILE__))
pathToFMU = joinpath(pwd(), "../model/IO.fmu")

myFMU = fmiLoad(pathToFMU)

c1 = fmiInstantiate!(myFMU; loggingOn=true)
# test reference conversion
@test fmi2String2ValueReference(c1, "p_real") == 16777216
@test fmi2String2ValueReference(c1, "p_integer") == 16777217
@test fmi2ValueReference2String(c1, Cint(16777217)) == ["p_integer"]

# create arrays for in place getter
vR = zeros(Real, 3)
vI = zeros(Integer, 3)
vB = zeros(Bool, 3)


fmiEnterInitializationMode(c1)
fmiExitInitializationMode(c1)

fmiGetReal(c1, ["u_real", "y_real", "p_real"])
fmiGetInteger(c1, ["u_integer", "y_integer", "p_integer"])
fmiGetBoolean(c1, ["u_boolean", "y_boolean", "p_boolean"])
fmiGetString(c1, "")
fmiSetReal(c1, "p_real", Real(10.0))
fmiSetReal(c1, ["u_real", "y_real"], [1.0, 2.0])
fmiSetInteger(c1, "p_integer", 10)
fmiSetInteger(c1, ["u_integer", "y_integer"], [20, 30])
fmiSetBoolean(c1, "p_boolean", true)
fmiSetBoolean(c1, ["y_boolean", "u_boolean"], [true, false])
fmiGetInteger!(c1, ["u_integer", "y_integer", "p_integer"], vI)
fmiGetInteger!(c1, ["u_integer", "y_integer"], vI)
fmiGetBoolean!(c1, ["u_boolean", "y_boolean", "p_boolean"], vB)

fmiGetReal!(c1, ["u_real", "y_real", "p_real"], vR)
fmiReset(c1)
fmiSetReal(c1, "y_real", 10.0)
fmiGetReal(c1, ["u_real", "y_real", "p_real"])
fmiReset(c1)


fmi2EnterInitializationMode(c1)
fmi2SetReal(c1, "p_real", 15.0)
fmi2SetReal(c1, ["u_real", "y_real"], [12.0, 20.0])
fmi2SetInteger(c1, "p_integer", 5)
fmi2SetInteger(c1, ["u_integer", "y_integer"], [1, 2])
fmi2SetBoolean(c1, "p_boolean", true)
fmi2SetBoolean(c1, ["y_boolean", "u_boolean"], [false, true])
fmi2GetReal(c1, ["u_real", "y_real", "p_real"])
fmi2GetInteger(c1, ["u_integer", "y_integer", "p_integer"])
fmi2GetBoolean(c1, ["u_boolean", "y_boolean", "p_boolean"])
fmi2GetString(c1, "")
fmi2GetReal!(myFMU, ["u_real", "y_real", "p_real"], vR)
fmi2GetInteger!(myFMU, ["u_integer", "y_integer", "p_integer"], vI)
fmi2GetBoolean!(myFMU, ["u_boolean", "y_boolean", "p_boolean"], vB)
fmi2ExitInitializationMode(c1)

fmi2EnterInitializationMode(myFMU)
fmi2GetReal!(myFMU, ["u_real", "y_real", "p_real"], vR)
fmi2GetInteger!(myFMU, ["u_integer", "y_integer", "p_integer"], vI)
fmi2GetBoolean!(myFMU, ["u_boolean", "y_boolean", "p_boolean"], vB)
fmi2GetString(myFMU, "")
fmi2SetReal(myFMU, "p_real", 5.0)
fmi2SetReal(myFMU, ["u_real", "y_real"], [7.0, 8.0])
fmi2SetInteger(myFMU, "p_integer", 6)
fmi2SetInteger(myFMU, ["u_integer", "y_integer"], [4, 3])
fmi2SetBoolean(myFMU, "p_boolean", false)
fmi2SetBoolean(myFMU, ["y_boolean", "u_boolean"], [true, false])
fmi2ExitInitializationMode(myFMU)

fmiEnterInitializationMode(myFMU)
fmiGetReal(myFMU, ["u_real", "y_real", "p_real"])
fmiGetInteger(myFMU, ["u_integer", "y_integer", "p_integer"])
fmiGetBoolean(myFMU, ["u_boolean", "y_boolean", "p_boolean"])
fmiGetString(myFMU, "")
fmiSetReal(myFMU, "p_real", 11.0)
fmiSetReal(myFMU, ["u_real", "y_real"], [60.0, 35.0])
fmiSetInteger(myFMU, "p_integer", 86)
fmiSetInteger(myFMU, ["u_integer", "y_integer"], [40, 70])
fmiSetBoolean(myFMU, "p_boolean", false)
fmiSetBoolean(myFMU, ["y_boolean", "u_boolean"], [false, false])
fmiGetReal!(myFMU, ["u_real", "y_real", "p_real"], vR)
fmiGetInteger!(myFMU, ["u_integer", "y_integer", "p_integer"], vI)
fmiGetBoolean!(myFMU, ["u_boolean", "y_boolean", "p_boolean"], vB)
fmiExitInitializationMode(myFMU)


fmiSetupExperiment(myFMU, 0.0)
fmi2SetupExperiment(c1, 0.0)

fmiGetReal(c1, ["u_real", "y_real", "p_real"])
fmiGetInteger(c1, ["u_integer", "y_integer", "p_integer"])
fmiGetBoolean(c1, ["u_boolean", "y_boolean", "p_boolean"])
fmiGetString(c1, "")
fmiSetReal(c1, "p_real", Real(10.0))
fmiSetReal(c1, ["u_real", "y_real"], [1.0, 2.0])
fmiSetInteger(c1, "p_integer", 10)
fmiSetInteger(c1, ["u_integer", "y_integer"], [20, 30])
fmiSetBoolean(c1, "p_boolean", true)
fmiSetBoolean(c1, ["y_boolean", "u_boolean"], [true, false])
fmiGetReal(c1, ["u_real", "y_real", "p_real"])
fmiReset(c1)

fmiReset(myFMU)
fmiTerminate(myFMU)
fmiUnload(myFMU)
