#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using JLD2
using CSV
using DataFrames

# our simulation setup
t_start = 0.0
t_stop = 8.0

# load the FMU container
myFMU = fmiLoad("SpringFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

recordValues = ["mass.s", "mass.v"]
solutionME = fmiSimulateME(myFMU, (t_start, t_stop); recordValues=recordValues)
solutionCS = fmiSimulateCS(myFMU, (t_start, t_stop); recordValues=recordValues)

# ME

fmiSaveSolution(solutionME, "solutionME.jld2")
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
y = []
for i in 1:length(x)
    push!(y, x[i][1])
end
fmiSaveSolutionCSV(solutionME, "solutionME.csv")
csv_df = CSV.read("solutionME.csv", DataFrame)

@test y == csv_df[!, 2]
@test solutionME.values.t == csv_df[!, 1]


# CS 

fmiSaveSolution(solutionCS, "solutionCS.jld2")
anotherSolutionCS = fmiLoadSolution("solutionCS.jld2")

@test solutionCS.success == true 
@test solutionCS.success == anotherSolutionCS.success
@test solutionCS.values.saveval == anotherSolutionCS.values.saveval
@test solutionCS.values.t == anotherSolutionCS.values.t

# test csv
x = collect.(solutionCS.values.saveval)
y = []
for i in 1:length(x)
    push!(y, x[i][1])
end
fmiSaveSolutionCSV(solutionCS, "solutionCS.csv")
csv_df = CSV.read("solutionCS.csv", DataFrame)

@test y == csv_df[!, 2]
@test solutionCS.values.t == csv_df[!, 1]

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)