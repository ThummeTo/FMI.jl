# Simulate multiple instances

This example shows how to work with multiple instances of a FMU.

This first command loads the FMI.jl library, so you could work with it.
```
#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
```
The path to the FMU which we want to create multiple instances of is set. [`fmiLoad`](@ref) unpacks the FMU, reads the model description and stores all the necessary information of the FMU in ```myFMU```. With [`fmiInstantiate!`](@ref) a first instance of the FMU is created.
```
pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

#create an instance and simulate it
comp1 = fmiInstantiate!(myFMU; loggingOn=true)
```
To simulate the instance of the FMU you have to setup the experiment and enter and leave the initialization mode to prepare the FMU. This part is optional if you use the option ```setup=true``` in [`fmiSimulateCS`](@ref).
```
fmiSetupExperiment(comp1, 0.0)
fmiEnterInitializationMode(comp1)
fmiExitInitializationMode(comp1)
```

The next part sets up the start and stop time.
```
t_start = 0.0
t_stop = 8.0
```
The next part is the actual simulation. You can provide an array of variable names which you want to track. The return value of the function is that data.
```
data1 = fmiSimulateCS(comp1, t_start, t_stop; recordValues=["mass.s"])
```
The result of the simulation can be visualized using the [`fmiPlot`](@ref) function.
```
fmiPlot(data1)
```
In the second part of the example we create a second instance of the FMU and change the spring stiffness. Then we simulate and plot it. If you compare the two plots you can see the different simulation results due to the adjusted spring stiffness.
```
#create another instance, change the spring stiffness and simulate it
comp2 = fmiInstantiate!(myFMU; loggingOn=true)
fmiSetupExperiment(comp2, 0.0)
fmiEnterInitializationMode(comp2)
springConstant = fmiGetReal(comp2, "spring.c") * 0.1
fmiSetReal(comp2, "spring.c", springConstant)
fmiExitInitializationMode(comp2)
data2 = fmiSimulateCS(comp2, t_start, t_stop; recordValues=["mass.s"])
fmiPlot(data2)



fmiUnload(myFMU)
```