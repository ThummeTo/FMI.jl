#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

###############
# Prepare FMU #
###############

myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

comp = fmiInstantiate!(myFMU; loggingOn=true)
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

@test fmiEnterInitializationMode(fmuStruct) == 0
@test fmiExitInitializationMode(fmuStruct) == 0

@test fmiSetupExperiment(fmuStruct, 0.0) == 0

###########################
# Testing state functions #
###########################

if fmiCanGetSetState(myFMU) && fmiCanSerializeFMUstate(myFMU)
    @test fmiGetReal(fmuStruct, "mass.s") == 0.5
    FMUstate = fmiGetFMUstate(fmuStruct)
    @test typeof(FMUstate) == FMI.fmi2FMUstate
    len = fmiSerializedFMUstateSize(fmuStruct, FMUstate)
    @test len > 0
    serial = fmiSerializeFMUstate(fmuStruct, FMUstate)
    @test length(serial) == len
    @test typeof(serial) == Array{Char,1}

    fmiSetReal(fmuStruct, "mass.s", 10.0)
    FMUstate = fmiGetFMUstate(fmuStruct)
    @test fmiGetReal(fmuStruct, "mass.s") == 10.0

    FMUstate2 = fmiDeSerializeFMUstate(fmuStruct, serial)
    @test typeof(FMUstate2) == FMI.fmi2FMUstate
    fmiSetFMUstate(fmuStruct, FMUstate2)
    @test fmiGetReal(fmuStruct, "mass.s") == 0.5
    fmiSetFMUstate(fmuStruct, FMUstate)
    @test fmiGetReal(fmuStruct, "mass.s") == 10.0
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
