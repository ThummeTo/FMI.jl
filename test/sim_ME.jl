#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

t_start = 0.0
t_stop = 8.0

# case 1: ME-FMU with state events

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
@assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

solution, _ = fmiSimulateME(fmuStruct, t_start, t_stop)
@test length(solution.u) > 0
@test length(solution.t) > 0

@test solution.t[1] == t_start 
@test solution.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.u[1] == [0.5, 0.0]
@test sum(abs.(solution.u[end] - [1.06736, -1.03552e-10])) < 0.01
fmiUnload(myFMU)

# case 2: ME-FMU with state and time events

if ENV["EXPORTINGTOOL"] == "Dymola/2020x"
    pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringTimeFrictionPendulum1D.fmu")

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

    ### test without recording values

    solution, _ = fmiSimulateME(fmuStruct, t_start, t_stop)
    @test length(solution.u) > 0
    @test length(solution.t) > 0
    
    @test solution.t[1] == t_start 
    @test solution.t[end] == t_stop 
    
    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.u[end] - [1.05444, 1e-10])) < 0.01

    ### test with recording values
    
    solution, savedValues = fmiSimulateME(fmuStruct, t_start, t_stop; recordValues="mass.f")
    @test length(solution.u) > 0
    @test length(solution.t) > 0
    @test length(savedValues.saveval) > 0
    @test length(savedValues.t) > 0

    @test solution.t[1] == t_start 
    @test solution.t[end] == t_stop 
    @test savedValues.t[1] == t_start 
    @test savedValues.t[end] == t_stop 

    # reference values from Simulation in Dymola2020x (Dassl)
    @test solution.u[1] == [0.5, 0.0]
    @test sum(abs.(solution.u[end] - [1.05444, 1e-10])) < 0.01
    @test savedValues.saveval[1][1] == 0.75
    @test sum(abs.(savedValues.saveval[end][1] - -0.54435 )) < 0.015

    fmiUnload(myFMU)
end

