# Parameterize

This example shows you how to parameterize a FMU before simulation. For the actual simulation visit [Tutorials](@ref Simulation) or the [Co-Simulation](@ref cs) or [Model Exchange](@ref me) examples.

This first command loads the FMI.jl library, so you could work with it.
```
#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Plots
```
The path to the FMU which we want to parameterize is created. [`fmiLoad`](@ref) unpacks the FMU, reads the model description and stores all the necessary information of the FMU in ```myFMU```. With [`fmiInstantiate!`](@ref) an instance of the FMU is created.
```
pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/IO.fmu")

myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU; loggingOn=true)
```
To parameterize the instance of the FMU you have to setup the experiment and enter the initialization mode.
```
fmiSetupExperiment(myFMU, 0.0)

fmiEnterInitializationMode(myFMU)
```
First we read the initial value of the variable ```p_string```. Then we create random values for all data types and a different string.
```
fmiGetString(myFMU, "p_string")

rndReal = 100 * rand()
rndInteger = round(Integer, 100 * rand())
rndBoolean = rand() > 0.5
rndString = "Not random!"
```
Second we set the variables of the FMU to these new random values and check if they have been stored in the corresponding variables.
```
fmiSetReal(myFMU, "p_real", rndReal)
display("$rndReal == $(fmiGetReal(myFMU, "p_real"))")

fmiSetInteger(myFMU, "p_integer", rndInteger)
display("$rndInteger == $(fmiGetInteger(myFMU, "p_integer"))")

fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
display("$rndBoolean == $(fmiGetBoolean(myFMU, "p_boolean"))")

fmiSetString(myFMU, "p_string", rndString)
display("$rndString == $(fmiGetString(myFMU, "p_string"))")
```
Last we exit the initialization mode and unload the FMU and free the allocated memory.
```
fmiExitInitializationMode(myFMU)

fmiUnload(myFMU)
```
