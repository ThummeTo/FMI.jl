#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI

pathToFMU = joinpath(dirname(@__FILE__), "../model/SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

#create an instance and simulate it
comp1 = fmiInstantiate!(myFMU; loggingOn=true)
fmiSetupExperiment(comp1, 0.0)
fmiEnterInitializationMode(comp1)
fmiExitInitializationMode(comp1)

dt = 0.01
t_start = 0.0
t_stop = 8.0

data1 = fmiSimulateCS(comp1, dt, t_start, t_stop, ["mass.s"])
fmiPlot(data1)

#create another instance, change the spring stiffness and simulate it
comp2 = fmiInstantiate!(myFMU; loggingOn=true)
fmiSetupExperiment(comp2, 0.0)
fmiEnterInitializationMode(comp2)
springConstant = fmiGetReal(comp2, "spring.c") * 0.1
fmiSetReal(comp2, "spring.c", springConstant)
fmiExitInitializationMode(comp2)
data2 = fmiSimulateCS(comp2, dt, t_start, t_stop, ["mass.s"])
fmiPlot(data2)



fmiUnload(myFMU)
