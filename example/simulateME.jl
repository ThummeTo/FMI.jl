#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI

pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringFrictionPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

display("Event Indicators: $(myFMU.modelDescription.numberOfEventIndicators)")

fmiInstantiate!(myFMU; loggingOn=true)

fmiSetupExperiment(myFMU, 0.0)

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)

dt = 0.01
t_start = 0.0
t_stop = 8.0

ts = t_start:dt:t_stop
ss = []

solution = fmiSimulateME(myFMU, dt, t_start, t_stop)
fmiPlot(myFMU, solution)

fmiUnload(myFMU)
