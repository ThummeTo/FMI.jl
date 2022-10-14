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

solution = fmiSimulateME(fmuStruct, t_start, t_stop)
@test length(solution.states.u) > 0
@test length(solution.states.t) > 0

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.states.u[1] == [0.5, 0.0]
@test sum(abs.(solution.states.u[end] - [1.06736, -1.03552e-10])) < 0.1
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

solution = fmiSimulateME(fmuStruct, t_start, t_stop; dtmax=0.001) # dtmax to force resolution
@test length(solution.states.u) > 0
@test length(solution.states.t) > 0

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.states.u[1] == [0.5, 0.0]
@test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01

### test with recording values (variable step record values)

solution= fmiSimulateME(fmuStruct, t_start, t_stop; recordValues="mass.f", dtmax=0.001) # dtmax to force resolution
dataLength = length(solution.states.u)
@test dataLength > 0
@test length(solution.states.t) == dataLength
@test length(solution.values.saveval) == dataLength
@test length(solution.values.t) == dataLength

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 
@test solution.values.t[1] == t_start 
@test solution.values.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test sum(abs.(solution.states.u[1] - [0.5, 0.0])) < 1e-4
@test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01
@test abs(solution.values.saveval[1][1] - 0.75) < 1e-4
@test sum(abs.(solution.values.saveval[end][1] - -0.54435 )) < 0.015

### test with recording values (fixed step record values)

tData = t_start:0.1:t_stop
solution = fmiSimulateME(fmuStruct, t_start, t_stop; recordValues="mass.f", saveat=tData, dtmax=0.001) # dtmax to force resolution
@test length(solution.states.u) == length(tData)
@test length(solution.states.t) == length(tData)
@test length(solution.values.saveval) == length(tData)
@test length(solution.values.t) == length(tData)

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 
@test solution.values.t[1] == t_start 
@test solution.values.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test sum(abs.(solution.states.u[1] - [0.5, 0.0])) < 1e-4
@test sum(abs.(solution.states.u[end] - [1.05444, 1e-10])) < 0.01
@test abs(solution.values.saveval[1][1] - 0.75) < 1e-4
@test sum(abs.(solution.values.saveval[end][1] - -0.54435 )) < 0.015

fmiUnload(myFMU)

# case 3a: ME-FMU without events, but with input signal (explicit solver: Tsit5)

function extForce_t(t)
    [sin(t)]
end 

function extForce_cxt(c::FMU2Component, x::Union{AbstractArray{fmi2Real}, Nothing}, t::fmi2Real)
    x1 = 0.0
    if x != nothing 
        x1 = x[1] 
    end
    [sin(t) * x1]
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

for inpfct in [extForce_cxt, extForce_t]
    global solution

    solution = fmiSimulateME(fmuStruct, t_start, t_stop; inputValueReferences=["extForce"], inputFunction=inpfct, solver=Tsit5(), dtmax=0.001) # dtmax to force resolution
    @test length(solution.states.u) > 0
    @test length(solution.states.t) > 0

    @test solution.states.t[1] == t_start 
    @test solution.states.t[end] == t_stop
end 

# reference values `extForce_t` from Simulation in Dymola2020x (Dassl)
@test solution.states.u[1] == [0.5, 0.0]
@test sum(abs.(solution.states.u[end] - [0.613371, 0.188633])) < 0.012
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

# ToDo: test `autodiff=true`
solution = fmiSimulateME(fmuStruct, t_start, t_stop; solver=Rosenbrock23(autodiff=false), dtmax=0.001) # dtmax to force resolution
@test length(solution.states.u) > 0
@test length(solution.states.t) > 0

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 

# reference values (no force) from Simulation in Dymola2020x (Dassl)
@test solution.states.u[1] == [0.5, 0.0]
@test sum(abs.(solution.states.u[end] - [0.509219, 0.314074])) < 0.01
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

solution = fmiSimulateME(fmuStruct, t_start, t_stop; inputValueReferences=["extForce"], inputFunction=extForce_t, solver=Rosenbrock23(autodiff=false), dtmax=0.001) # dtmax to force resolution
@test length(solution.states.u) > 0
@test length(solution.states.t) > 0

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 

# reference values from Simulation in Dymola2020x (Dassl)
@test solution.states.u[1] == [0.5, 0.0]
@test sum(abs.(solution.states.u[end] - [0.613371, 0.188633])) < 0.01
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

solution = fmiSimulateME(fmuStruct, t_start, t_stop; saveat=tData, recordValues=myFMU.modelDescription.stateValueReferences)
@test length(solution.states.u) == length(tData)
@test length(solution.states.t) == length(tData)
@test length(solution.values.saveval) == length(tData)
@test length(solution.values.t) == length(tData)

for i in 1:length(tData)
    @test sum(abs(solution.states.t[i] - solution.states.t[i])) < 1e-6
    @test sum(abs(solution.states.u[i][1] - solution.values.saveval[i][1])) < 1e-6
    @test sum(abs(solution.states.u[i][2] - solution.values.saveval[i][2])) < 1e-6
end

fmiUnload(myFMU)

# case 5: ME-FMU with different (random) start state

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

rand_x0 = rand(2)
solution = fmiSimulateME(fmuStruct, t_start, t_stop; x0=rand_x0)
@test length(solution.states.u) > 0
@test length(solution.states.t) > 0

@test solution.states.t[1] == t_start 
@test solution.states.t[end] == t_stop 

@test solution.states.u[1] == rand_x0
fmiUnload(myFMU)