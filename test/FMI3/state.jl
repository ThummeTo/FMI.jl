#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport

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

if fmiCanGetSetState(myFMU)
    @test fmiGet(fmuStruct, "h") == 1
    
    FMUstate = fmiGetState(fmuStruct)

    fmiSet(fmuStruct, "h", 10.0)
    @test fmiGet(fmuStruct, "h") == 10.0
    
    fmiSetState(fmuStruct, FMUstate)
    @test fmiGet(fmuStruct, "h") == 1

    fmiFreeState!(fmuStruct, FMUstate)
else
    @info "The FMU provided from the tool `$(ENV["EXPORTINGTOOL"])` does not support state get, set, serialization and deserialization. Skipping related tests."
end

############
# Clean up #
############

fmiUnload(myFMU)
