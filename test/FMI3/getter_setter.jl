#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import FMI.FMIImport.FMICore

###############
# Prepare FMU #
###############

myFMU = fmiLoad("Feedthrough", "ModelicaReferenceFMUs", "0.0.20", "3.0")
inst = fmi3InstantiateCoSimulation!(myFMU; loggingOn=true)
@test inst != 0

# choose FMU or FMUComponent
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = inst
end
@assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

@test fmi3EnterInitializationMode(fmuStruct) == 0
@test fmi3ExitInitializationMode(fmuStruct) == 0

realValueReferences = ["Float32_continuous_input", "Float64_continuous_input"]
integerValueReferences = ["Int32_input", "Int64_input"]
booleanValueReferences = ["Boolean_input", "Boolean_output"]
stringValueReferences = ["String_parameter", "String_parameter"]

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
        [Float32(rndReal),                rndInteger,                rndBoolean,                rndString])
@test fmiGet(fmuStruct, 
                [realValueReferences[1], integerValueReferences[1], booleanValueReferences[1], stringValueReferences[1]]) == 
                [Float32(rndReal),                rndInteger,                FMICore.fmi3Boolean(rndBoolean),                rndString]

#@test fmiGetStartValue(fmuStruct, "p_enumeration") == "myEnumeration1"
# println(fmi3ModelVariablesForValueReference(inst.fmu.modelDescription, UInt32(29)))
@test fmiGetStartValue(fmuStruct, "String_parameter") == "Set me!"
@test fmiGetStartValue(fmuStruct, "Float32_continuous_input") == 0.0 

##################
# Testing Arrays #
##################

rndReal = [100 * rand(), 100 * rand()]
rndInteger = [round(Integer, 100 * rand()), round(Integer, 100 * rand())]
rndBoolean = [(rand() > 0.5), (rand() > 0.5)]
tmp = Random.randstring(8)
rndString = [tmp, tmp]

cacheReal = [0.0, 0.0]
cacheInteger =  [FMI.fmi3Int32(0), FMI.fmi3Int32(0)]
cacheBoolean = [FMI.fmi3Boolean(false), FMI.fmi3Boolean(false)]
cacheString = [pointer(""), pointer("")]

#@test fmiGetStartValue(fmuStruct, ["p_enumeration", "p_string", "p_real"]) == ["myEnumeration1", "Hello World!", 0.0] 
@test fmiGetStartValue(fmuStruct, ["String_parameter", "Float32_continuous_input"]) == ["Set me!", 0.0] 

############
# Clean up #
############

fmiUnload(myFMU)
