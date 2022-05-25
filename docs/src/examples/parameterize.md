# Manually parameterize an FMU
Tutorial by Johannes Stoljar, Tobias Thummerer

## License
Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar

Licensed under the MIT license. See [LICENSE](https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](http://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Units*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how the manually parameterization of an FMU works if very specific adjustments during system initialization is needed. For this purpose, an IO-FMU model is loaded and the various commands for parameterization are shown on the basis of this model. With this example the user shall be guided how to make certain settings at an FMU. Please note, that parameterization of a simulation is possible in a much easier fashion: Using `fmiSimulate`, `fmiSimulateME` or `fmiSimulateCS` together with a parameter dictionary for the keyword `parameters`.

## Target group
The example is primarily intended for users who work in the field of simulation exchange. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/main/example/CS_simulate.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/main/example/CS_simulate.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/CS_simulate.md) corresponding to the notebook.  


## Getting started

### Installation prerequisites
|     | Description                       | Command                   | Alternative                                    |   
|:----|:----------------------------------|:--------------------------|:-----------------------------------------------|
| 1.  | Enter Package Manager via         | ]                         |                                                |
| 2.  | Install FMI via                   | add FMI                   | add " https://github.com/ThummeTo/FMI.jl "     |
| 3.  | Install FMIZoo via                | add FMIZoo                | add " https://github.com/ThummeTo/FMIZoo.jl "  |

## Code section

To run the example, the previously installed packages must be included. 


```julia
# imports
using FMI
using FMIZoo
```

### Simulation setup

Next, the start time and end time of the simulation are set.


```julia
tStart = 0.0
tStop = 8.0
```




    8.0



### Import FMU

In the next lines of code the FMU model from *FMIZoo.jl* is loaded and the information about the FMU is shown.


```julia
# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)
```

    ┌ Info: fmi2Unzip(...): Successfully unzipped 29 files at `/tmp/fmijl_E6omKF/IO`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/OUODz/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_E6omKF/IO/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/OUODz/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/OUODz/src/FMI2_ext.jl:193


    #################### Begin information for FMU ####################
    	Model name:			IO
    	FMI-Version:			2.0
    	GUID:				{ac3b4a99-4908-40f7-89da-2d5c08b3c4ac}
    	Generation tool:		Dymola Version 2022x (64-bit), 2021-10-08
    	Generation time:		2022-03-17T07:40:55Z
    	Var. naming conv.:		structured
    	Event indicators:		4
    	Inputs:				3
    		352321536 ["u_real"]
    		352321537 ["u_boolean"]
    		352321538 ["u_integer"]
    	Outputs:			3
    		335544320 ["y_real"]
    		335544321 ["y_boolean"]
    		335544322 ["y_integer"]
    	States:				0
    	Supports Co-Simulation:		true
    		Model identifier:	IO
    		Get/Set State:		true
    		Serialize State:	true
    		Dir. Derivatives:	true
    		Var. com. steps:	true
    		Input interpol.:	true
    		Max order out. der.:	1
    	Supports Model-Exchange:	true
    		Model identifier:	IO
    		Get/Set State:		true
    		Serialize State:	true
    		Dir. Derivatives:	true
    ##################### End information for FMU #####################


### Instantiate and Setup FMU

Next it is necessary to create an instance of the FMU. This is achieved by the command `fmiInstantiate!()`.


```julia
fmiInstantiate!(myFMU; loggingOn=true)
```




    FMU:            IO
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000003ae6b10
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing



In the following code block, start and end time for the simulation is set by the `fmiSetupExperiment()` command.


```julia
fmiSetupExperiment(myFMU, tStart, tStop)
```




    0x00000000



### Parameterize FMU

To parameterize an FMU, the FMU must be in the initialization mode, which is reached with the `fmiEnterInitializationMode()` command.


```julia
fmiEnterInitializationMode(myFMU)
```




    0x00000000



Within this mode it is then possible to change the different parameters. In this example, for each data type (`real`, `integer`, `boolean` and `string)` a corresponding parameter is selected. At the beginning the initial state of these parameters is displayed with `fmiGet()`.


```julia
params = ["p_real", "p_integer", "p_boolean", "p_string"]
fmiGet(myFMU, params)
```




    4-element Vector{Any}:
     0.0
     0
     0
      "Hello World!"



In the next step, a function is defined that generates a random value for each parameter. For the parameter `p_string` a random number is inserted into the string. All parameters are combined to a vector and output.


```julia
function generateRandomNumbers()
    rndReal = 100 * rand()
    rndInteger = round(Integer, 100 * rand())
    rndBoolean = rand() > 0.5
    rndString = "Random number $(100 * rand())!"

    randValues = [rndReal, rndInteger, rndBoolean, rndString]
    println(randValues)
    return randValues
end
```




    generateRandomNumbers (generic function with 1 method)



The previously defined function is called and the results are displayed in the console.


```julia
paramsVal = generateRandomNumbers();
```

    Any[41.68976766058903, 91, false, "Random number 18.117421661942835!"]


#### First variant

With this variant it is quickly possible to set all parameters at once. Even different data types can be set with only one command. The command `fmiSet()` selects itself which function is chosen for which data type. After setting the parameters, it is checked whether the corresponding parameters were set correctly. For this the function `fmiGet()` is used as above and afterwards with the macro `@assert` also tested whether the correct values are set.


```julia
fmiSet(myFMU, params, paramsVal)
values = fmiGet(myFMU, params)
print(values)

@assert paramsVal == values
```

    Any[41.68976766058903, 91, 0, "Random number 18.117421661942835!"]

#### Second variant

To make sure that the functions work it is necessary to generate random numbers again. As shown already, we call the defined function `generateRandomNumbers()` and output the values.


```julia
rndReal, rndInteger, rndBoolean, rndString = generateRandomNumbers();
```

    Any[32.87773039642885, 58, false, "Random number 22.4054218867213!"]


In the second variant, the value for each data type is set separately by the corresponding command. By this variant one has the maximum control and can be sure that also the correct data type is set. To illustrate the functionality of the parameterization with the separate functions, the corresponding get function is also called separately for each data type:
* `fmiSetReal()` <---> `fmiGetReal()`
* `fmiSetInteger()` <---> `fmiGetInteger()`
* `fmiSetBoolean()` <---> `fmiGetBoolean()`
* `fmiSetString()` <---> `fmiGetString()`.


```julia
fmiSetReal(myFMU, "p_real", rndReal)
display("$rndReal == $(fmiGetReal(myFMU, "p_real"))")

fmiSetInteger(myFMU, "p_integer", rndInteger)
display("$rndInteger == $(fmiGetInteger(myFMU, "p_integer"))")

fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
display("$rndBoolean == $(fmiGetBoolean(myFMU, "p_boolean"))")

fmiSetString(myFMU, "p_string", rndString)
display("$rndString == $(fmiGetString(myFMU, "p_string"))")
```


    "32.87773039642885 == 32.87773039642885"



    "58 == 58"



    "false == 0"



    "Random number 22.4054218867213! == Random number 22.4054218867213!"


After seeing that both variants set the parameters correctly, the initialization mode is terminated with the function `fmiExitInitializationMode()`.


```julia
fmiExitInitializationMode(myFMU)
```




    0x00000000



From here on, you may want to simulate the FMU. Please note, that with the default `executionConfig`, it is necessary to prevent a new instantiation using the keyword `instantiate=false`. Otherwise, a new instance is allocated for the simulation-call and the parameters set for the previous instance are not transfered.

Example:
`fmiSimulate(...; instantiate=false, ...)`

### Unload FMU

The FMU will be unloaded and all unpacked data on disc will be removed.


```julia
fmiUnload(myFMU)
```

### Summary

Based on this tutorial it can be seen that there are two different variants to set and get parameters.These examples should make it clear to the user how parameters can also be set with different data types.
