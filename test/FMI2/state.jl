#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport

###############
# Prepare FMU #
###############

myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

comp = fmi2Instantiate!(myFMU; loggingOn=true)
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

@test fmi2SetupExperiment(fmuStruct, 0.0) == fmi2StatusOK
@test fmi2EnterInitializationMode(fmuStruct) == fmi2StatusOK
@test fmi2ExitInitializationMode(fmuStruct) == fmi2StatusOK

###########################
# Testing state functions #
###########################

if fmiCanGetSetState(myFMU) 
    @test fmiGet(fmuStruct, "mass.s") == 0.5
    
    FMUstate = fmiGetState(fmuStruct)

    fmiSet(fmuStruct, "mass.s", 10.0)
    @test fmiGet(fmuStruct, "mass.s") == 10.0
    
    fmiSetState(fmuStruct, FMUstate)
    @test fmiGet(fmuStruct, "mass.s") == 0.5

    fmiFreeState!(fmuStruct, FMUstate)
else
    @info "The FMU provided from the tool `$(ENV["EXPORTINGTOOL"])` does not support state get and set. Skipping related tests."
end

############
# Clean up #
############

fmiUnload(myFMU)
