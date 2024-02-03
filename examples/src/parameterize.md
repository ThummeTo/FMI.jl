# Parameterize a FMU
Tutorial by Tobias Thummerer, Johannes Stoljar

Last update: 09.08.2023

🚧 This tutorial is under revision and will be replaced by an up-to-date version soon 🚧

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Introduction
This example shows how to parameterize a FMU. We will show to possible ways to parameterize: The default option using the parameterization feature of `fmiSimulate`, `fmiSimulateME` or `fmiSimulateCS`. Second, a custom parameterization routine for advanced users. 

## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameterize.md) corresponding to the notebook.  

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
# just replace this line with a local path if you want to use your own FMU
pathToFMU = get_model_filename("IO", "Dymola", "2022x")

fmu = fmiLoad(pathToFMU)
fmiInfo(fmu)
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
    

### Option A: Integrated parameterization feature of *FMI.jl*
If you are using the commands for simulation integrated in *FMI.jl*, the parameters and initial conditions are set at the correct locations during the initialization process of your FMU. This is the recommended way of parameterizing your model, if you don't have very uncommon requirements regarding initialization.


```julia
dict = Dict{String, Any}()
dict
```




    Dict{String, Any}()



### Option B: Custom parameterization routine
If you have special requirements for initialization and parameterization, you can write your very own parameterization routine.

### Instantiate and Setup FMU

Next it is necessary to create an instance of the FMU. This is achieved by the command `fmiInstantiate!()`.


```julia
fmiInstantiate!(fmu; loggingOn=true)
```




    FMU:            IO
    InstanceName:   IO
    Address:        Ptr{Nothing} @0x000002a763a0f0c0
    State:          0
    Logging:        1
    FMU time:       -Inf
    FMU states:     nothing



In the following code block, start and end time for the simulation is set by the `fmiSetupExperiment()` command.


```julia
fmiSetupExperiment(fmu, tStart, tStop)
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
fmiEnterInitializationMode(fmu)
```




    0x00000000



The initial state of these parameters are displayed with the function `fmiGet()`.


```julia
fmiGet(fmu, params)
```




    4-element Vector{Any}:
     0.0
     0
     0
      "Hello World!"



The initialization mode is terminated with the function `fmiExitInitializationMode()`. (For the model exchange FMU type, this function switches off all initialization equations, and enters the event mode implicitly.)


```julia
fmiExitInitializationMode(fmu)
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




    (92.20068774124326, false, 61, "Random number 58.626327800852664!")



#### First variant

To show the first variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmiTerminate(fmu)
fmiReset(fmu)
fmiSetupExperiment(fmu, tStart, tStop)
```




    0x00000000



In the next step it is possible to set the parameters for the FMU. With the first variant it is quickly possible to set all parameters at once. Even different data types can be set with only one command. The command `fmiSet()` selects itself which function is chosen for which data type.  As long as the output of the function gives the status code 0, setting the parameters has worked.


```julia
fmiSet(fmu, params, collect(paramsVal))
```




    4-element Vector{UInt32}:
     0x00000000
     0x00000000
     0x00000000
     0x00000000



After setting the parameters, it can be checked whether the corresponding parameters were set correctly. For this the function `fmiGet()` can be used as above. To be able to call the function `fmiGet()` the FMU must be in initialization mode.


```julia
fmiEnterInitializationMode(fmu)
# fmiGet(fmu, params)
fmiExitInitializationMode(fmu)
```




    0x00000000



Now the FMU has been initialized correctly, the FMU can be simulated. The `fmiSimulate()` command is used for this purpose. It must be pointed out that the keywords `instantiate=false`, `setup=false` must be set. The keyword `instantiate=false` prevents the simulation command from creating a new FMU instance, otherwise our parameterization will be lost. The keyword `setup=false` prevents the FMU from calling the initialization mode again. The additionally listed keyword `freeInstance=false` prevents that the instance is removed after the simulation. This is only needed in this example, because we want to continue working on the created instance. Another keyword is the `recordValues=parmas[1:3]`, which saves: `p_real`, `p_boolean` and `p_integer` as output. It should be noted that the `fmiSimulate()` function is not capable of outputting string values, so `p_string` is omitted.


```julia
simData = fmiSimulate(fmu, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false, freeInstance=false, terminate=false, reset=false)
```

    [34mSimulating CS-FMU ...   0%|█                             |  ETA: N/A[39m

    [34mSimulating CS-FMU ... 100%|██████████████████████████████| Time: 0:00:01[39m
    




    Model name:
    	IO
    Success:
    	true
    f(x)-Evaluations:
    	In-place: 0
    	Out-of-place: 0
    Jacobian-Evaluations:
    	∂ẋ_∂p: 0
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂p: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    	∂e_∂p: 0
    	∂e_∂x: 0
    	∂e_∂u: 0
    	∂xr_∂xl: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    	∂e_∂t: 0
    Callback-Evaluations:
    	Condition (event-indicators): 0
    	Time-Choice (event-instances): 0
    	Affect (event-handling): 0
    	Save values: 0
    	Steps completed: 0
    Values [2]:
    	0.0	(92.20068774124326, 0.0, 61.0)
    	1.0	(92.20068774124326, 0.0, 61.0)
    Events [0]:
    



#### Second variant

To show the second variant, it is necessary to terminate and reset the FMU instance. Then, as before, the setup command must be called for the FMU. 


```julia
fmiTerminate(fmu)
fmiReset(fmu)
fmiSetupExperiment(fmu, tStart, tStop)
```




    0x00000000



To make sure that the functions work it is necessary to generate random numbers again. As shown already, we call the defined function `generateRandomNumbers()` and output the values.


```julia
rndReal, rndBoolean, rndInteger, rndString = generateRandomNumbers()
```




    (33.92892352785205, false, 26, "Random number 97.72885957174317!")



In the second variant, the value for each data type is set separately by the corresponding command. By this variant one has the maximum control and can be sure that also the correct data type is set. 


```julia
fmiSetReal(fmu, "p_real", rndReal)
fmiSetBoolean(fmu, "p_boolean", rndBoolean)
fmiSetInteger(fmu, "p_integer", rndInteger)
fmiSetString(fmu, "p_string", rndString)
```




    0x00000000



To illustrate the functionality of the parameterization with the separate functions, the corresponding get function can be also called separately for each data type:
* `fmiSetReal()` &#8660; `fmiGetReal()`
* `fmiSetBoolean()` &#8660; `fmiGetBoolean()`
* `fmiSetInteger()` &#8660; `fmiGetInteger()`
* `fmiSetString()` &#8660; `fmiGetString()`.

As before, the FMU must be in initialization mode.


```julia
fmiEnterInitializationMode(fmu)
# fmiGetReal(fmu, "u_real")
# fmiGetBoolean(fmu, "u_boolean")
# fmiGetInteger(fmu, "u_integer")
# fmiGetString(fmu, "p_string")
fmiExitInitializationMode(fmu)
```




    0x00000000



From here on, you may want to simulate the FMU. Please note, that with the default `executionConfig`, it is necessary to prevent a new instantiation using the keyword `instantiate=false`. Otherwise, a new instance is allocated for the simulation-call and the parameters set for the previous instance are not transfered.


```julia
simData = fmiSimulate(fmu, (tStart, tStop); recordValues=params[1:3], saveat=tSave, 
                        instantiate=false, setup=false)
```




    Model name:
    	IO
    Success:
    	true
    f(x)-Evaluations:
    	In-place: 0
    	Out-of-place: 0
    Jacobian-Evaluations:
    	∂ẋ_∂p: 0
    	∂ẋ_∂x: 0
    	∂ẋ_∂u: 0
    	∂y_∂p: 0
    	∂y_∂x: 0
    	∂y_∂u: 0
    	∂e_∂p: 0
    	∂e_∂x: 0
    	∂e_∂u: 0
    	∂xr_∂xl: 0
    Gradient-Evaluations:
    	∂ẋ_∂t: 0
    	∂y_∂t: 0
    	∂e_∂t: 0
    Callback-Evaluations:
    	Condition (event-indicators): 0
    	Time-Choice (event-instances): 0
    	Affect (event-handling): 0
    	Save values: 0
    	Steps completed: 0
    Values [2]:
    	0.0	(33.92892352785205, 0.0, 26.0)
    	1.0	(33.92892352785205, 0.0, 26.0)
    Events [0]:
    



### Unload FMU

The FMU will be unloaded and all unpacked data on disc will be removed.


```julia
fmiUnload(fmu)
```

### Summary

Based on this tutorial it can be seen that there are two different variants to set and get parameters.These examples should make it clear to the user how parameters can also be set with different data types. As a small reminder, the sequence of commands for the manual parameterization of an FMU is summarized again. 

`fmiLoad()` &#8594; `fmiInstantiate!()` &#8594; `fmiSetupExperiment()` &#8594; `fmiSetXXX()` &#8594; `fmiEnterInitializationMode()` &#8594; `fmiGetXXX()` &#8594; `fmiExitInitializationMode()` &#8594; `fmiSimualte()` &#8594; `fmiUnload()`
