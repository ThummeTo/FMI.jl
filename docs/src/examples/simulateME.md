# [Simulation of a ME FMU](@id me)

This small example shows a fast and easy way to simulate a model exchange FMU.

This first command loads the FMI.jl library, so you could work with it.

```
#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
```
The next part sets up the start and stop time.
```
# our simulation setup
t_start = 0.0
t_stop = 8.0
```
The FMI.jl library contains two FMUs to try things out and the examples. One of those are compiled for Windows and Linux, the other one only for Windows.
```
# this FMU runs under Windows/Linux
pathToFMU = joinpath(dirname(@__FILE__), "../model/OpenModelica/v1.17.0/SpringFrictionPendulum1D.fmu")

# this FMU runs only under Windows
if Sys.iswindows()
    pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringFrictionPendulum1D.fmu")
end
```
```fmiLoad``` unpacks the FMU, reads the model description and stores all the necessary information of the FMU in ```myFMU```. You can read a useful part of the informations with ```fmiInfo```. With ```fmiInstatiate!``` am instance of the FMU is created.
```
# load the FMU container
myFMU = fmiLoad(pathToFMU)

# print some useful FMU-information into the REPL
fmiInfo(myFMU)

# make an instance from the FMU
fmiInstantiate!(myFMU; loggingOn=true)
```
To simulate the instance of the FMU you have to setup the experiment and enter and leave the initialization mode to prepare the FMU. This part is optional if you use the option ```setup=true``` in ```fmiSimulateCS```.
```
# setup the experiment, start time = 0.0 (optional for setup=true)
#fmiSetupExperiment(myFMU, t_start)

# enter and exit initialization (optional for setup=true)
#fmiEnterInitializationMode(myFMU)
#fmiExitInitializationMode(myFMU)
```
The next part is the actual simulation. FMI.jl provides you with an easy way to do it. The ```fmiSimulateME``` function expects the FMU or instance of an FMU you want to simulate, the start and stop time of the simulation. Additionally you can facilitate the setup of the simulation with the ```setup``` option. The result of the simulation is the return value of the function.
```
# run the FMU in mode Model-Exchange (ME) with adaptive step sizes, result values are stored in `solution`
solution = fmiSimulateME(myFMU, t_start, t_stop; setup=true)
```
FMI.jl offers a simple way to visualize the simulation results with the ```fmiPlot``` function.
```
# plot the results
fmiPlot(myFMU, solution)
```
Finally, after your simulation is finished, you can unload the FMU and free the allocated memory.
```
# unload the FMU, remove unpacked data on disc ("clean up")
fmiUnload(myFMU)

```