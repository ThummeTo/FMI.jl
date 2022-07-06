#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

myFMU = fmiLoad("BouncingBall", "ModelicaReferenceFMUs", "0.0.16", "3.0")

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

###########################
# Testing state functions #
###########################

if fmiCanGetSetState(myFMU) && fmiCanSerializeFMUstate(myFMU)
    @test fmi3GetFloat64(fmuStruct, "h") == 1.0
    FMUstate = fmiGetFMUstate(fmuStruct)
    @test typeof(FMUstate) == FMI.fmi3FMUState
    len = fmiSerializedFMUstateSize(fmuStruct, FMUstate)
    @test len > 0
    serial = fmiSerializeFMUstate(fmuStruct, FMUstate)
    @test length(serial) == len
    @test typeof(serial) == Array{UInt8,1}

    fmi3SetFloat64(fmuStruct, "h", 10.0)
    FMUstate = fmiGetFMUstate(fmuStruct)
    @test fmi3GetFloat64(fmuStruct, "h") == 10.0

    FMUstate2 = fmiDeSerializeFMUstate(fmuStruct, serial)
    @test typeof(FMUstate2) == FMI.fmi3FMUState
    fmiSetFMUstate(fmuStruct, FMUstate2)
    @test fmi3GetFloat64(fmuStruct, "h") == 1.0
    fmiSetFMUstate(fmuStruct, FMUstate)
    @test fmi3GetFloat64(fmuStruct, "h") == 10.0
    fmiFreeFMUstate!(fmuStruct, FMUstate)
    fmiFreeFMUstate!(fmuStruct, FMUstate2)
else
    @info "The FMU provided from the tool `$(ENV["EXPORTINGTOOL"])` does not support state get, set, serialization and deserialization. Skipping related tests."
end

############
# Clean up #
############

@test fmiTerminate(myFMU) == 0
fmiUnload(myFMU)
