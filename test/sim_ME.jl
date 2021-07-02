#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

t_start = 0.0
t_stop = 8.0

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringFrictionPendulum1D.fmu")

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

solution = fmiSimulateME(fmuStruct, t_start, t_stop)
@test length(solution.u) > 0
@test length(solution.t) > 0
# TODO: Time series comparision

fmiUnload(myFMU)
