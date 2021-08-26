# Simulate a FMU

## Instantiation

After you loaded your FMU (see more [here](@ref loading)), you need to create an instance of it to work with. An instance has the type ```fmiXComponent```. You can assign your instance to a variable and work with it.
```
julia> fmucomponent = fmiInstantiate!(myFMU)
```

Additionally it is stored in the Julia struct representing the FMU. All functions in the FMI.jl library support function calls using a ```fmiXComponent``` or a ```fmiXStruct```. Please note that if you instantiate a FMU multiple times, the function calls using the ```fmiXStruct``` will always use the lastly created instance of the FMU.

```@repl
using FMI # hide

pathToFMU = joinpath(dirname(@__FILE__), "../../model/Dymola/2020x/SpringFrictionPendulum1D.fmu") # hide

myFMU = fmiLoad(pathToFMU) # hide

fmucomponent = fmiInstantiate!(myFMU)
fmiInstantiate!(myFMU; loggingOn = true)
myFMU.components
```
Optionally you can activate the logging of the replies of the FMU by ```logginOn = true```. By default this feature is deactivated.

## Initialization

To be able to simulate a FMU, you first have to initialize it. With ```fmiSetupExperiment``` you are able to set the start and stop time for which the simulation should be valid. If no stop time is provided, the start time is used.
```
julia> fmiSetupExperiment(myFMU, 0.0, 10.0)
```

After the setup of the simulation, the following function calls are mandatory:

```
julia> fmiEnterInitializationMode(myFMU)
julia> fmiExitInitializationMode(myFMU)
```

If you want to change the values of parameters before a simulation, you have to use the respective ```fmiSetXXX``` command in between those two function calls above.

```
julia> fmiEnterInitializationMode(myFMU)
julia> fmiSetReal(myFMU, "realVariable", realValue)
julia> fmiSetInteger(myFMU, "integerVariable", integerValue)
julia> fmiExitInitializationMode(myFMU)
```

## Simulation

FMI.jl supports multiple ways to simulate a FMU. You can either use a one line command to simulate a model exchange or co simulation FMU and record the variables you want to track during the simulation or use the native commands of the FMI standard. But before you actually simulate something, you first have to define a start and stop time for the current simulation. An easy example for that is here provided.

```
t_start = 0.0
t_stop = 8.0
```

### Easy Simulation

FMI.jl can identify what type of FMU you want to simulate and adjust the simulation accordingly. If the FMU supports both model exchange and co simulation, the FMU is always as a co simulation FMU simulated. If you want to simulate it as a model exchange FMU, you have to use the specific ```fmiSimulateME``` function call. Additionally to the needed start and stop time, you can also provide an array of variable names that you want keep track of. The function returns the values of those variables for the whole simulation time. Those can be plotted using the ```fmiPlot``` function.

```
data = fmiSimulate(myFMU, t_start, t_stop, ["mass.s", "mass.v"])

fmiPlot(data)
```

### Simulation close to FMI Standard




fmiUnload(myFMU)
```
