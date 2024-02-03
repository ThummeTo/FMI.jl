#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

pathToFMU = get_model_filename("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

# load FMU in temporary directory
fmuStruct, myFMU = getFMUStruct(pathToFMU)
@test isfile(myFMU.zipPath) == true
@test isdir(splitext(myFMU.zipPath)[1]) == true
fmiUnload(myFMU)

# load FMU in source directory 
fmuDir = joinpath(splitpath(pathToFMU)[1:end-1]...)
fmuStruct, myFMU = getFMUStruct(pathToFMU; unpackPath=fmuDir)
@test isfile(splitext(pathToFMU)[1] * ".zip") == true
@test isdir(splitext(pathToFMU)[1]) == true

t_start = 0.0
t_stop = 8.0
dt = 1e-2

# test without recording values (but why?)
sol = fmiSimulate(fmuStruct, (t_start, t_stop); dt=dt)
@test sol.success

# test with recording values
solution = fmiSimulate(fmuStruct, (t_start, t_stop); dt=dt, recordValues=["mass.s", "mass.v"], setup=true)
@test solution.success
@test length(solution.values.saveval) == length(t_start:dt:t_stop)
@test length(solution.values.saveval[1]) == 2

t = solution.values.t
s = collect(d[1] for d in solution.values.saveval)
v = collect(d[2] for d in solution.values.saveval)
@test t[1] == t_start
@test t[end] == t_stop

# reference values from Simulation in Dymola2020x (Dassl)
@test s[1] == 0.5
@test v[1] == 0.0

if ENV["EXPORTINGTOOL"] == "Dymola/2020x" # ToDo: Linux FMU was corrupted
    @test s[end] ≈ 0.509219 atol=1e-1
    @test v[end] ≈ 0.314074 atol=1e-1
end

fmiUnload(myFMU)
