#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Plots

# our simulation setup
t_start = 0.0
t_stop = 8.0

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulum1D.fmu")

# load the FMU container
myFMU = fmiLoad(pathToFMU)

# print some useful FMU-information into the REPL
fmiInfo(myFMU)

# make an instance from the FMU
fmiInstantiate!(myFMU)

recordValues = ["mass.s", "mass.v"]
solution, savedValuesME = fmiSimulateME(myFMU, t_start, t_stop; recordValues=recordValues)
success, savedValuesCS = fmiSimulateCS(myFMU, t_start, t_stop; recordValues=recordValues)

# plot the results
fig = fmiPlot(myFMU, solution)
fmiPlot!(fig, myFMU, solution)

#fig = plot(myFMU, solution)
#plot!(fig, myFMU, solution)

fig = fmiPlot(myFMU, recordValues, savedValuesCS)
fmiPlot!(fig, myFMU, recordValues, savedValuesCS)

#fig = plot(myFMU, recordValues, savedValuesCS)
#plot!(fig, myFMU, recordValues, savedValuesCS)

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)