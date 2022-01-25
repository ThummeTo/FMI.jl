#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# case 1: CS-FMU Simulation

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

# test without recording values (but why?)
success = fmiSimulateCS(fmuStruct; dt=1e-5)
@test success

# test with recording values
success, savedValues = fmiSimulateCS(fmuStruct; dt=1e-5, recordValues=["mass.s", "mass.v"])
@test success
@test length(savedValues.saveval) == fmi2GetDefaultStartTime(myFMU.modelDescription):1e-5:fmi2GetDefaultStopTime(myFMU.modelDescription) |> length
@test length(savedValues.saveval[1]) == 2

t = savedValues.t
s = collect(d[1] for d in savedValues.saveval)
v = collect(d[2] for d in savedValues.saveval)
@test t[1] == fmi2GetDefaultStartTime(myFMU.modelDescription) 
@test t[end] == fmi2GetDefaultStopTime(myFMU.modelDescription) 

# reference values from Simulation in Dymola2020x (Dassl)
@test s[1] == 0.5
@test v[1] == 0.0

if ENV["EXPORTINGTOOL"] == "Dymola/2020x" # ToDo: Linux FMU was corrupted
    @test s[end] ≈ 1.700334 atol=0.01
    @test v[end] ≈ -0.04006 atol=0.01
end

fmiUnload(myFMU)

# case 2: CS-FMU with input signal

function extForce(t)
    [sin(t)]
end 

if ENV["EXPORTINGTOOL"] == "Dymola/2020x"
    pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulumExtForce1D.fmu")

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

    success, solution = fmiSimulateCS(fmuStruct; dt=1e-2, recordValues=["mass.s", "mass.v"], inputValues=["extForce"], inputFunction=extForce)
    @test success
    @test length(solution.saveval) > 0
    @test length(solution.t) > 0

    @test t[1] == fmi2GetDefaultStartTime(myFMU.modelDescription) 
    @test t[end] == fmi2GetDefaultStopTime(myFMU.modelDescription) 

    # reference values from Simulation in Dymola2020x (Dassl)
    @test [solution.saveval[1]...] == [0.5, 0.0]
    @test sum(abs.([solution.saveval[end]...] - [0.613371, 0.188633])) < 0.05
    fmiUnload(myFMU)
end

