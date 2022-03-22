#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations: Tsit5, Rosenbrock23

t_start = 0.0
t_stop = 8.0

# case 1: ME-FMU with state events

myFMU = fmiLoad("SpringFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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
@test sum(abs.(solution.u[end] - [1.06736, -1.03552e-10])) < 0.1
fmiUnload(myFMU)

# case 2: ME-FMU with state and time events

myFMU = fmiLoad("SpringTimeFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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

### test with recording values (variable step record values)

solution, savedValues = fmiSimulateME(fmuStruct, t_start, t_stop; recordValues="mass.f")
dataLength = length(solution.u)
@test dataLength > 0
@test length(solution.t) == dataLength
@test length(savedValues.saveval) == dataLength
@test length(savedValues.t) == dataLength

@test solution.t[1] == t_start 
@test solution.t[end] == t_stop 
@test savedValues.t[1] == t_start 
@test savedValues.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test sum(abs.(solution.u[1] - [0.5, 0.0])) < 1e-4
@test sum(abs.(solution.u[end] - [1.05444, 1e-10])) < 0.01
@test abs(savedValues.saveval[1][1] - 0.75) < 1e-4
@test sum(abs.(savedValues.saveval[end][1] - -0.54435 )) < 0.015

### test with recording values (fixed step record values)

tData = t_start:0.1:t_stop
solution, savedValues = fmiSimulateME(fmuStruct, t_start, t_stop; recordValues="mass.f", saveat=tData)
@test length(solution.u) == length(tData)
@test length(solution.t) == length(tData)
@test length(savedValues.saveval) == length(tData)
@test length(savedValues.t) == length(tData)

@test solution.t[1] == t_start 
@test solution.t[end] == t_stop 
@test savedValues.t[1] == t_start 
@test savedValues.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test sum(abs.(solution.u[1] - [0.5, 0.0])) < 1e-4
@test sum(abs.(solution.u[end] - [1.05444, 1e-10])) < 0.01
@test abs(savedValues.saveval[1][1] - 0.75) < 1e-4
@test sum(abs.(savedValues.saveval[end][1] - -0.54435 )) < 0.015

fmiUnload(myFMU)

# case 3a: ME-FMU without events, but with input signal (explicit solver: Tsit5)

function extForce(t)
    [sin(t)]
end 

myFMU = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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

solution = fmiSimulateME(fmuStruct, t_start, t_stop; inputValueReferences=["extForce"], inputFunction=extForce, dtmax=0.001, solver=Tsit5())
@test length(solution.u) > 0
@test length(solution.t) > 0

@test solution.t[1] == t_start 
@test solution.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.u[1] == [0.5, 0.0]
@test sum(abs.(solution.u[end] - [0.613371, 0.188633])) < 0.012
fmiUnload(myFMU)

# case 3b: ME-FMU without events, but with input signal (implicit solver: Rosenbrock23, autodiff)

myFMU = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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

# ToDo: autodiff=true not working currently!
# solution = fmiSimulateME(fmuStruct, t_start, t_stop; inputValueReferences=["extForce"], inputFunction=extForce, dtmax=0.001, solver=Rosenbrock23(autodiff=true))
# @test length(solution.u) > 0
# @test length(solution.t) > 0

# @test solution.t[1] == t_start 
# @test solution.t[end] == t_stop 

# # reference values from Simulation in Dymola2020x (Dassl)
# @test solution.u[1] == [0.5, 0.0]
# @test sum(abs.(solution.u[end] - [0.613371, 0.188633])) < 0.01
fmiUnload(myFMU)

# case 3c: ME-FMU without events, but with input signal (implicit solver: Rosenbrock23, no autodiff)

myFMU = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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

solution = fmiSimulateME(fmuStruct, t_start, t_stop; inputValueReferences=["extForce"], inputFunction=extForce, dtmax=0.001, solver=Rosenbrock23(autodiff=false))
@test length(solution.u) > 0
@test length(solution.t) > 0

@test solution.t[1] == t_start 
@test solution.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.u[1] == [0.5, 0.0]
@test sum(abs.(solution.u[end] - [0.613371, 0.188633])) < 0.01
fmiUnload(myFMU)

# case 4: ME-FMU without events, but saving value interpolation

myFMU = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

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

solution, savedValues = fmiSimulateME(fmuStruct, t_start, t_stop; saveat=tData, recordValues=myFMU.modelDescription.stateValueReferences)
@test length(solution.u) == length(tData)
@test length(solution.t) == length(tData)
@test length(savedValues.saveval) == length(tData)
@test length(savedValues.t) == length(tData)

for i in 1:length(tData)
    @test sum(abs(solution.t[i] - solution.t[i])) < 1e-6
    @test sum(abs(solution.u[i][1] - savedValues.saveval[i][1])) < 1e-6
    @test sum(abs(solution.u[i][2] - savedValues.saveval[i][2])) < 1e-6
end

fmiUnload(myFMU)