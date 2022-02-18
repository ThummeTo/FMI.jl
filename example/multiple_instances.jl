#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Plots

pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

t_start = 0.0
t_stop = 8.0
rvs = ["mass.s"]

#create an instance and simulate it
comp1 = fmiInstantiate!(myFMU; loggingOn=true)
param1 = Dict("spring.c"=>10.0, "mass.s"=>1.0)
_, data1 = fmiSimulateCS(comp1, t_start, t_stop; recordValues=rvs, parameters=param1)
plot(myFMU, rvs, data1)

#create another instance, change the spring stiffness and simulate it
comp2 = fmiInstantiate!(myFMU; loggingOn=true)
param2 = Dict("spring.c"=>1.0, "mass.s"=>2.0)
_, data2 = fmiSimulateCS(comp2, t_start, t_stop; recordValues=rvs, parameters=param2)
fmiPlot(myFMU, rvs, data2)

fmiUnload(myFMU)
