#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Plots

# our simulation setup
t_start = 0.0
t_stop = 8.0

# load the FMU container
myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

# print some useful FMU-information into the REPL
fmiInfo(myFMU)

# make an instance from the FMU
fmiInstantiate!(myFMU)

recordValues = ["mass.s", "mass.v"]
solutionME = fmiSimulateME(myFMU, (t_start, t_stop); recordValues=recordValues)
solutionCS = fmiSimulateCS(myFMU, (t_start, t_stop); recordValues=recordValues)

# plot the results
fig = fmiPlot(solutionME)

fig = Plots.plot()
fmiPlot!(fig, solutionME)

fig = fmiPlot(solutionCS)

fig = Plots.plot()
fmiPlot!(fig, solutionCS)

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)