#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
import FMIZoo

# our simulation setup
dt = 0.01
t_start = 0.0
t_stop = 8.0
saveat = t_start:dt:t_stop

# we use a FMU from the FMIZoo.jl
pathToFMU = FMIZoo.get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

# load the FMU container
myFMU = fmiLoad(pathToFMU)

# print some useful FMU-information into the REPL
fmiInfo(myFMU)

# make an instance from the FMU, this is optional if you are not interessted into instances
# fmiInstantiate!(myFMU; loggingOn=true)

# run the FMU in mode Co-Simulation (CS) with adaptive step size (CVODE) but fixed save points dt,
# result values are stored in `savedValues`
recordValues = ["mass.s", "mass.v"]
savedValues = fmiSimulateCS(myFMU, t_start, t_stop; recordValues=recordValues)

# plot the results
using Plots
fmiPlot(savedValues)

# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)
