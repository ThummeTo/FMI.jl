#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using JLD2
using CSV
using DataFrames
using MAT

# our simulation setup
t_start = 0.0
t_stop = 8.0

# load the FMU container
fmuStruct, myFMU = getFMUStruct("SpringFrictionPendulum1D")

recordValues = ["mass.s", "mass.v"]
solutionME = fmiSimulateME(myFMU, (t_start, t_stop); recordValues=recordValues, solver=FBDF(autodiff=false))
solutionCS = fmiSimulateCS(myFMU, (t_start, t_stop); recordValues=recordValues)

# ME

fmiSaveSolution(solutionME, "solutionME.jld2")

#@warn "Loading solution tests are disabled for now."
#anotherSolutionME = solutionME
anotherSolutionME = fmiLoadSolution("solutionME.jld2")

@test solutionME.success == true 
@test solutionME.success == anotherSolutionME.success
@test solutionME.states.u == anotherSolutionME.states.u
@test solutionME.states.t == anotherSolutionME.states.t
@test solutionME.values.saveval == anotherSolutionME.values.saveval
@test solutionME.values.t == anotherSolutionME.values.t

# ME-BONUS: events
@test solutionME.events == anotherSolutionME.events

# test csv
x = collect.(solutionME.values.saveval)
v = [tup[k] for tup in x, k in 1:length(x[1])]
fmiSaveSolutionCSV(solutionME, "solutionME.csv")
csv_df = CSV.read("solutionME.csv", DataFrame)

@test v[:,1] == csv_df[!, 2]
@test solutionME.values.t == csv_df[!, 1]

# test mat
fmiSaveSolutionMAT(solutionME, "solutionME.mat")
vars = matread("solutionME.mat")
@test vars["time"] == solutionME.values.t
for i in 1:length(solutionME.valueReferences)
    key = replace(fmi2ValueReferenceToString(solutionME.component.fmu, solutionME.valueReferences[i])[1], "." => "_")
    @test vars[key] == v[:,i]
end

# CS 

fmiSaveSolution(solutionCS, "solutionCS.jld2")

#@warn "Loading solution tests are disabled for now."
#anotherSolutionCS = solutionCS
anotherSolutionCS = fmiLoadSolution("solutionCS.jld2")

@test solutionCS.success == true 
@test solutionCS.success == anotherSolutionCS.success
@test solutionCS.values.saveval == anotherSolutionCS.values.saveval
@test solutionCS.values.t == anotherSolutionCS.values.t

# test csv
x = collect.(solutionCS.values.saveval)
v = [tup[k] for tup in x, k in 1:length(x[1])]
fmiSaveSolutionCSV(solutionCS, "solutionCS.csv")
csv_df = CSV.read("solutionCS.csv", DataFrame)

@test v[:,1] == csv_df[!, 2]
@test solutionCS.values.t == csv_df[!, 1]


# test mat
fmiSaveSolutionMAT(solutionCS, "solutionME.mat")
vars = matread("solutionME.mat")
@test vars["time"] == solutionCS.values.t
for i in 1:length(solutionCS.valueReferences)
    key = replace(fmi2ValueReferenceToString(solutionCS.component.fmu, solutionCS.valueReferences[i])[1], "." => "_")
    @test vars[key] == v[:,i]
end

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)