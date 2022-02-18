#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI

# our simulation setup
dt = 0.01
t_start = 0.0
t_stop = 8.0
saveat = t_start:dt:t_stop

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

# run the FMU in mode Co-Simulation (CS) with adaptive step size (CVODE) but fixed save points dt,
# result values are stored in `savedValues`
recordValues = ["mass.s", "mass.v"]
success, savedValues = fmiSimulateCS(myFMU, t_start, t_stop; recordValues=recordValues)

# plot the results
fmiPlot(myFMU, recordValues, savedValues)

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)
