#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

myFMU = fmiLoad("IO", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]; type=:CS)
comp = fmiInstantiate!(myFMU; loggingOn=false)
@test comp != 0

# choose FMU or FMUComponent
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
@assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

@test fmiSetupExperiment(fmuStruct, 0.0) == 0

@test fmiEnterInitializationMode(fmuStruct) == 0

realValueReferences = ["p_real", "u_real"]
integerValueReferences = ["p_integer", "u_integer"]
booleanValueReferences = ["p_boolean", "u_boolean"]
stringValueReferences = ["p_string", "p_string"]

#########################
# Testing Single Values #
#########################

rndReal = 100 * rand()
rndInteger = round(Integer, 100 * rand())
rndBoolean = rand() > 0.5
rndString = Random.randstring(12)

cacheReal = 0.0
cacheInteger = 0
cacheBoolean = false
cacheString = ""

fmiSet(fmuStruct, 
        [realValueReferences[1], integerValueReferences[1], booleanValueReferences[1], stringValueReferences[1]], 
        [rndReal,                rndInteger,                rndBoolean,                rndString])
@test fmiGet(fmuStruct, 
                [realValueReferences[1], integerValueReferences[1], booleanValueReferences[1], stringValueReferences[1]]) == 
                [rndReal,                rndInteger,                rndBoolean,                rndString]

#@test fmiGetStartValue(fmuStruct, "p_enumeration") == "myEnumeration1"
@test fmiGetStartValue(fmuStruct, "p_string") == "Hello World!"
@test fmiGetStartValue(fmuStruct, "p_real") == 0.0 

##################
# Testing Arrays #
##################

rndReal = [100 * rand(), 100 * rand()]
rndInteger = [round(Integer, 100 * rand()), round(Integer, 100 * rand())]
rndBoolean = [(rand() > 0.5), (rand() > 0.5)]
tmp = Random.randstring(8)
rndString = [tmp, tmp]

cacheReal = [0.0, 0.0]
cacheInteger =  [FMI.fmi2Integer(0), FMI.fmi2Integer(0)]
cacheBoolean = [FMI.fmi2Boolean(false), FMI.fmi2Boolean(false)]
cacheString = [pointer(""), pointer("")]

#@test fmiGetStartValue(fmuStruct, ["p_enumeration", "p_string", "p_real"]) == ["myEnumeration1", "Hello World!", 0.0] 
@test fmiGetStartValue(fmuStruct, ["p_string", "p_real"]) == ["Hello World!", 0.0] 

####################################
# Testing input/output derivatives #
####################################

@test fmiSetRealInputDerivatives(fmuStruct, ["u_real"], ones(FMI.fmi2Integer, 1), zeros(1)) == 0

@test fmiExitInitializationMode(fmuStruct) == 0
@test fmiDoStep(fmuStruct, 0.1) == 0

dirs = fmiGetRealOutputDerivatives(fmuStruct, ["y_real"], ones(FMI.fmi2Integer, 1))
@test dirs == 0.0 # ToDo: Force a `dirs != 0.0`

############
# Clean up #
############

fmiUnload(myFMU)
