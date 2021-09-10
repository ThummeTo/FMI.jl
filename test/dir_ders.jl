#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulum1D.fmu")

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
@assert fmuStruct != nothing "Unknwon fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

t_start = 0.0
t_stop = 8.0

@test fmiSetupExperiment(fmuStruct) == 0
@test fmiEnterInitializationMode(fmuStruct) == 0
@test fmiExitInitializationMode(fmuStruct) == 0

@warn "Tests for directional derivatives not implemented yet!"

fmiUnload(myFMU)
