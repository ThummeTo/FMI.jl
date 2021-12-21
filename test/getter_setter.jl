#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "IO.fmu")

myFMU = fmiLoad(pathToFMU)
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

@test fmiSetReal(fmuStruct, realValueReferences[1], rndReal) == 0
@test fmiGetReal(fmuStruct, realValueReferences[1]) == rndReal
@test fmiSetReal(fmuStruct, realValueReferences[1], -rndReal) == 0
@test fmiGetReal(fmuStruct, realValueReferences[1]) == -rndReal

@test fmiSetInteger(fmuStruct, integerValueReferences[1], rndInteger) == 0
@test fmiGetInteger(fmuStruct, integerValueReferences[1]) == rndInteger
@test fmiSetInteger(fmuStruct, integerValueReferences[1], -rndInteger) == 0
@test fmiGetInteger(fmuStruct, integerValueReferences[1]) == -rndInteger

@test fmiSetBoolean(fmuStruct, booleanValueReferences[1], rndBoolean) == 0
@test fmiGetBoolean(fmuStruct, booleanValueReferences[1]) == rndBoolean
@test fmiSetBoolean(fmuStruct, booleanValueReferences[1], !rndBoolean) == 0
@test fmiGetBoolean(fmuStruct, booleanValueReferences[1]) == !rndBoolean

@test fmiSetString(fmuStruct, stringValueReferences[1], rndString) == 0
@test fmiGetString(fmuStruct, stringValueReferences[1]) == rndString

# this is not supported by OMEdit-FMUs in the repository
if ENV["EXPORTINGTOOL"] != "OpenModelica/v1.17.0"
    @test fmiGetStartValue(fmuStruct, "p_enumeration") == "myEnumeration1"
    @test fmiGetStartValue(fmuStruct, "p_string") == "Hello World!"
    @test fmiGetStartValue(fmuStruct, "p_real") == 0.0
end 

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
cacheString = [FMI.fmi2String(""), FMI.fmi2String("")]

@test fmiSetReal(fmuStruct, realValueReferences, rndReal) == 0
@test fmiGetReal(fmuStruct, realValueReferences) == rndReal
fmiGetReal!(fmuStruct, realValueReferences, cacheReal)
@test cacheReal == rndReal
@test fmiSetReal(fmuStruct, realValueReferences, -rndReal) == 0
@test fmiGetReal(fmuStruct, realValueReferences) == -rndReal
fmiGetReal!(fmuStruct, realValueReferences, cacheReal)
@test cacheReal == -rndReal

@test fmiSetInteger(fmuStruct, integerValueReferences, rndInteger) == 0
@test fmiGetInteger(fmuStruct, integerValueReferences) == rndInteger
fmiGetInteger!(fmuStruct, integerValueReferences, cacheInteger)
@test cacheInteger == rndInteger
@test fmiSetInteger(fmuStruct, integerValueReferences, -rndInteger) == 0
@test fmiGetInteger(fmuStruct, integerValueReferences) == -rndInteger
fmiGetInteger!(fmuStruct, integerValueReferences, cacheInteger)
@test cacheInteger == -rndInteger

@test fmiSetBoolean(fmuStruct, booleanValueReferences, rndBoolean) == 0
@test fmiGetBoolean(fmuStruct, booleanValueReferences) == rndBoolean
fmiGetBoolean!(fmuStruct, booleanValueReferences, cacheBoolean)
@test cacheBoolean == rndBoolean
not_rndBoolean = collect(!b for b in rndBoolean)
@test fmiSetBoolean(fmuStruct, booleanValueReferences, not_rndBoolean) == 0
@test fmiGetBoolean(fmuStruct, booleanValueReferences) == not_rndBoolean
fmiGetBoolean!(fmuStruct, booleanValueReferences, cacheBoolean)
@test cacheBoolean == not_rndBoolean

@test fmiSetString(fmuStruct, stringValueReferences, rndString) == 0
@test fmiGetString(fmuStruct, stringValueReferences) == rndString
fmiGetString!(fmuStruct, stringValueReferences, cacheString)
@test cacheString == rndString

if envFMUSTRUCT == "FMUCOMPONENT"
    dirs = fmi2GetRealOutputDerivatives(fmuStruct, realValueReferences, ones(2))
    @test dirs isa AbstractArray{<:Real}
    @test dirs |> length == 2

    st = fmi2SetRealInputDerivatives(fmuStruct, realValueReferences, ones(2), zeros(2))
    @test_broken st == FMI.fmi2OK
end
# this is not suppoerted by OMEdit-FMUs in the repository
if ENV["EXPORTINGTOOL"] != "OpenModelica/v1.17.0"
    @test fmiGetStartValue(fmuStruct, ["p_enumeration", "p_string", "p_real"]) == ["myEnumeration1", "Hello World!", 0.0]
end 

############
# Clean up #
############

@test fmiExitInitializationMode(fmuStruct) == 0

fmiUnload(myFMU)
