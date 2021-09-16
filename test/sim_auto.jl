#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulum1D.fmu")

# load FMU in temporary directory
myFMU = fmiLoad(pathToFMU)
@test isfile(myFMU.zipPath) == true
@test isdir(splitext(myFMU.zipPath)[1]) == true
fmiUnload(myFMU)

# load FMU in source directory 
fmuDir = joinpath(splitpath(pathToFMU)[1:end-1]...)
myFMU = fmiLoad(pathToFMU; unpackPath=fmuDir)
@test isfile(splitext(pathToFMU)[1] * ".zip") == true
@test isdir(splitext(pathToFMU)[1]) == true

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

t_start = 0.0
t_stop = 8.0

data = fmiSimulate(fmuStruct, t_start, t_stop; recordValues=["mass.s", "mass.v"], setup=true)
@test length(data.dataPoints) == 100
@test length(data.dataPoints[1]) == 3

t = collect(d[1] for d in data.dataPoints)
s = collect(d[2] for d in data.dataPoints)
v = collect(d[3] for d in data.dataPoints)
@test t[1] == t_start 
@test t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test s[1] == 0.5
@test v[1] == 0.0
#@test abs(s[end] - 0.509219) < 0.01
#@test abs(v[end] - 0.314074) < 0.01

data = fmiSimulate(fmuStruct, t_start, t_stop; setup=true)
@test data == nothing   # nothing was recorded, recordValues=[]

fmiUnload(myFMU)
