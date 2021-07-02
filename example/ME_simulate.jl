#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI

# our simulation setup
t_start = 0.0
t_stop = 8.0

# this FMU runs under Windows/Linux
pathToFMU = joinpath(dirname(@__FILE__), "../model/OpenModelica/v1.17.0/SpringFrictionPendulum1D.fmu")

# this FMU runs only under Windows
if Sys.iswindows()
    pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringFrictionPendulum1D.fmu")
end

# load the FMU container
myFMU = fmiLoad(pathToFMU)

# print some useful FMU-information into the REPL
fmiInfo(myFMU)

# make an instance from the FMU
fmiInstantiate!(myFMU; loggingOn=true)

# setup the experiment, start time = 0.0 (optional for setup=true)
#fmiSetupExperiment(myFMU, t_start)

# enter and exit initialization (optional for setup=true)
#fmiEnterInitializationMode(myFMU)
#fmiExitInitializationMode(myFMU)

# run the FMU in mode Model-Exchange (ME) with adaptive step sizes, result values are stored in `solution`
solution = fmiSimulateME(myFMU, t_start, t_stop; setup=true)

# plot the results
fmiPlot(myFMU, solution)

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)
