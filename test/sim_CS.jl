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
@assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

t_start = 0.0
t_stop = 8.0

# test without recording values (but why?)
success, _ = fmiSimulateCS(fmuStruct, t_start, t_stop)
@test success

# test with recording values
success, savedValues = fmiSimulateCS(fmuStruct, t_start, t_stop; recordValues=["mass.s", "mass.v"])
@test success
@test length(savedValues.saveval) == 100
@test length(savedValues.saveval[1]) == 2

t = savedValues.t
s = collect(d[1] for d in savedValues.saveval)
v = collect(d[2] for d in savedValues.saveval)
@test t[1] == t_start 
@test t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test s[1] == 0.5
@test v[1] == 0.0

if ENV["EXPORTINGTOOL"] == "Dymola/2020x" # ToDo: Linux FMU was corrupted
    @test abs(s[end] - 0.509219) < 0.01
    @test abs(v[end] - 0.314074) < 0.01
end

fmiUnload(myFMU)

