# Manually parameterize an FMU
Tutorial by Johannes Stoljar, Tobias Thummerer

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](http://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Units*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how the manually parameterization of an FMU works if very specific adjustments during system initialization is needed. For this purpose, an IO-FMU model is loaded and the various commands for parameterization are shown on the basis of this model. With this example the user shall be guided how to make certain settings at an FMU. Please note, that parameterization of a simulation is possible in a much easier fashion: Using `fmiSimulate`, `fmiSimulateME` or `fmiSimulateCS` together with a parameter dictionary for the keyword `parameters`.

## Target group
The example is primarily intended for users who work in the field of simulation exchange. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.md) corresponding to the notebook.  


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
tStop = 1.0
tSave = collect(tStart:tStop)
```




    2-element Vector{Float64}:
     0.0
     1.0



### Import FMU

In the next lines of code the FMU model from *FMIZoo.jl* is loaded and the information about the FMU is shown.


```julia
# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)
```

    #################### Begin information for FMU ####################
    	Model name:			IO
    	FMI-Version:			2.0
    	GUID:				{889089a6-481b-41a6-a282-f6ce02a33aa6}
    	Generation tool:		Dymola Version 2022x (64-bit), 2021-10-08
    	Generation time:		2022-05-19T06:53:52Z
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
    InstanceName:   IO
    Address:        Ptr{Nothing} @0x0000000004b69680
    State:          0
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing



In the following code block, start and end time for the simulation is set by the `fmiSetupExperiment()` command.


```julia
fmiSetupExperiment(myFMU, tStart, tStop)
```




    0x00000000



### Parameterize FMU

In this example, for each data type (`real`, `boolean`, `integer` and `string`) a corresponding input or parameter is selected. From here on, the inputs and parameters will be referred to as parameters for simplicity.


```julia
params = ["p_real", "p_boolean", "p_integer", "p_string"]
```




    4-element Vector{String}:
     "p_real"
     "p_boolean"
     "p_integer"
     "p_string"



At the beginning we want to display the initial state of these parameters, for which the FMU must be in initialization mode. The next function `fmiEnterInitializationMode()` informs the FMU to enter the initialization mode. Before calling this function, the variables can be set. Furthermore, `fmiSetupExperiment()` must be called at least once before calling `fmiEnterInitializationMode()`, in order that the start time is defined.


```julia
fmiEnterInitializationMode(myFMU)
```




    0x00000000



The initial state of these parameters are displayed with the function `fmiGet()`.


```julia
fmiGet(myFMU, params)
```




    4-element Vector{Any}:
     0.0
     0
     0
      "Hello World!"



The initialization mode is terminated with the function `fmiExitInitializationMode()`. (For the model exchange FMU type, this function switches off all initialization equations, and enters the event mode implicitly.)


```julia
fmiExitInitializationMode(myFMU)
```




    0x00000000



In the next step, a function is defined that generates a random value for each parameter. For the parameter `p_string` a random number is inserted into the string. All parameters are combined to a tuple and output.


```julia
function generateRandomNumbers()
    rndReal = 100 * rand()
    rndBoolean = rand() > 0.5
    rndInteger = round(Integer, 100 * rand())
    rndString = "Random number $(100 * rand())!"

    return rndReal, rndBoolean, rndInteger, rndString
end
```




    generateRandomNumbers (generic function with 1 method)



The previously defined function is called and the results are displayed in the console.


```julia
paramsVal = generateRandomNumbers()
```




    (36.57788862808048, true, 18, "Random number 23.494541660802692!")



#### First variant

To show the first variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmiTerminate(myFMU)
fmiReset(myFMU)
fmiSetupExperiment(myFMU, tStart, tStop)
```

    [[32mOK[0m][CvodeStatistics][IO]: Sundials CVode Statistics
        Stop time                                : 0.00 s
        Simulation time                          : 1.88 s
        Number of external steps                 : 0
        Number of internal steps                 : 0
        Number of non-linear iterations          : 0
        Number of non-linear convergence failures: 0
        Number of f function evaluations         : 0
        Number of g function evaluations         : 0
        Number of Jacobian-evaluations (direct)  : 83275904
        Maximum integration order                : 0
        Suggested tolerance scale factor         : 1.0
        Grouping used                            : no
    
    [[32mOK[0m][][IO]: Rejected count
        Number of external steps                 : 0
        Number of internal steps                 : 0
        Number of f function evaluations         : 0
        Number of Jac function evaluations       : 0
    





    0x00000000



In the next step it is possible to set the parameters for the FMU. With the first variant it is quickly possible to set all parameters at once. Even different data types can be set with only one command. The command `fmiSet()` selects itself which function is chosen for which data type.  As long as the output of the function gives the status code 0, setting the parameters has worked.


```julia
fmiSet(myFMU, params, collect(paramsVal))
```




    4-element Vector{UInt32}:
     0x00000000
     0x00000000
     0x00000000
     0x00000000



After setting the parameters, it can be checked whether the corresponding parameters were set correctly. For this the function `fmiGet()` can be used as above. To be able to call the function `fmiGet()` the FMU must be in initialization mode.


```julia
fmiEnterInitializationMode(myFMU)
# fmiGet(myFMU, params)
fmiExitInitializationMode(myFMU)
```




    0x00000000



Now the FMU has been initialized correctly, the FMU can be simulated. The `fmiSimulate()` command is used for this purpose. It must be pointed out that the keywords `instantiate=false`, `setup=false` must be set. The keyword `instantiate=false` prevents the simulation command from creating a new FMU instance, otherwise our parameterization will be lost. The keyword `setup=false` prevents the FMU from calling the initialization mode again. The additionally listed keyword `freeInstance=false` prevents that the instance is removed after the simulation. This is only needed in this example, because we want to continue working on the created instance. Another keyword is the `recordValues=parmas[1:3]`, which saves: `p_real`, `p_boolean` and `p_integer` as output. It should be noted that the `fmiSimulate()` function is not capable of outputting string values, so `p_string` is omitted.


```julia
simData = fmiSimulate(myFMU, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)
```




    Model name:
    	IO
    Success:
    	true
    Jacobian-Evaluations:
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    Values [2]:
    	0.0	(36.57788862808048, 1.0, 18.0)
    	1.0	(36.57788862808048, 1.0, 18.0)
    Events [0]:




#### Second variant

To show the second variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmiTerminate(myFMU)
fmiReset(myFMU)
fmiSetupExperiment(myFMU, tStart, tStop)
```

    [[32mOK[0m][CvodeStatistics][IO]: Sundials CVode Statistics
        Stop time                                : 1.00 s
        Simulation time                          : 4.27 s
        Number of external steps                 : 1
        Number of internal steps                 : 3
        Number of non-linear iterations          : 3
        Number of non-linear convergence failures: 0
        Number of f function evaluations         : 7
        Number of g function evaluations         : 4
        Number of Jacobian-evaluations (direct)  : 1
        Maximum integration order                : 1
        Suggested tolerance scale factor         : 1.0
        Grouping used                            : no
    
    [[32mOK[0m][][IO]: Rejected count
        Number of external steps                 : 0
        Number of internal steps                 : 0
        Number of f function evaluations         : 0
        Number of Jac function evaluations       : 0
    





    0x00000000



To make sure that the functions work it is necessary to generate random numbers again. As shown already, we call the defined function `generateRandomNumbers()` and output the values.


```julia
rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()
```




    (39.629981455563076, false, 11, "Random number 83.90723453564333!")



In the second variant, the value for each data type is set separately by the corresponding command. By this variant one has the maximum control and can be sure that also the correct data type is set. 


```julia
fmiSetReal(myFMU, "p_real", rndReal)
fmiSetBoolean(myFMU, "p_boolean", rndBoolean)
fmiSetInteger(myFMU, "p_integer", rndInteger)
fmiSetString(myFMU, "p_string", rndString)
```




    0x00000000



To illustrate the functionality of the parameterization with the separate functions, the corresponding get function can be also called separately for each data type:
* `fmiSetReal()` &#8660; `fmiGetReal()`
* `fmiSetBoolean()` &#8660; `fmiGetBoolean()`
* `fmiSetInteger()` &#8660; `fmiGetInteger()`
* `fmiSetString()` &#8660; `fmiGetString()`.

As before, the FMU must be in initialization mode.


```julia
fmiEnterInitializationMode(myFMU)
# fmiGetReal(myFMU, "u_real")
# fmiGetBoolean(myFMU, "u_boolean")
# fmiGetInteger(myFMU, "u_integer")
# fmiGetString(myFMU, "p_string")
fmiExitInitializationMode(myFMU)
```




    0x00000000



From here on, you may want to simulate the FMU. Please note, that with the default `executionConfig`, it is necessary to prevent a new instantiation using the keyword `instantiate=false`. Otherwise, a new instance is allocated for the simulation-call and the parameters set for the previous instance are not transfered.


```julia
simData = fmiSimulate(myFMU, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)
```




    Model name:
    	IO
    Success:
    	true
    Jacobian-Evaluations:
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    Values [2]:
    	0.0	(39.629981455563076, 0.0, 11.0)
    	1.0	(39.629981455563076, 0.0, 11.0)
    Events [0]:




### Unload FMU

The FMU will be unloaded and all unpacked data on disc will be removed.


```julia
fmiUnload(myFMU)
```

### Summary

Based on this tutorial it can be seen that there are two different variants to set and get parameters.These examples should make it clear to the user how parameters can also be set with different data types. As a small reminder, the sequence of commands for the manual parameterization of an FMU is summarized again. 

`fmiLoad()` &#8594; `fmiInstantiate!()` &#8594; `fmiSetupExperiment()` &#8594; `fmiSetXXX()` &#8594; `fmiEnterInitializationMode()` &#8594; `fmiGetXXX()` &#8594; `fmiExitInitializationMode()` &#8594; `fmiSimualte()` &#8594; `fmiUnload()`
