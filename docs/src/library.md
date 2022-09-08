# Library Functions

## Parsing variable names to ValueReferences

```@docs
fmiStringToValueReference
```

## Opening and closing FMUs

```@docs
fmiLoad
fmiUnload
fmiReload
```

## Reading the model description

```@docs
fmiGetModelName
fmiGetGUID
fmiGetGenerationTool
fmiGetGenerationDateAndTime
fmiGetVariableNamingConvention
fmiGetNumberOfEventIndicators
fmiCanGetSetState
fmiCanSerializeFMUstate
fmiProvidesDirectionalDerivative
fmiIsCoSimulation
fmiIsModelExchange
fmiInfo
fmiGetVersion
```



## Get/Set variable values

```@docs
fmiGet
fmiGet!
fmiSet
fmiGetReal
fmiGetReal!
fmiSetReal
fmiGetInteger
fmiGetInteger!
fmiSetInteger
fmiGetBoolean
fmiGetBoolean!
fmiSetBoolean
fmiGetString
fmiGetString!
fmiSetString
fmiSetString
```


## internal FMUstate
```@docs
fmiGetFMUstate
fmiSetFMUstate
fmiFreeFMUstate!
fmiSerializedFMUstateSize
fmiSerializeFMUstate
fmiDeSerializeFMUstate
```
### Inquire Platform and Version Number of Header Files
This section documents functions to inquire information about the header files used to compile its
functions.
```@docs
fmiGetTypesPlatform
fmiGetVersion
```

###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs
```@docs
fmiInstantiate!
fmiFreeInstance!
fmiSetDebugLogging
```

### Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, and resetting of an FMU.

```@docs
fmiSetupExperiment
fmiSetEnterInitializationMode
fmiExitInitializationMode
fmiTerminate
fmiReset
```
### Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi2Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different [(for example, min/max
attributes)].

```@docs
fmiGetReal
fmiGetReal!
fmiGetInteger
fmiGetInteger!
fmiGetBoolean
fmiGetBoolean!
fmiGetString
fmiGetString!
fmiSetReal
fmiSetInteger
fmiSetBoolean
fmiSetString
```

## FMI Application Programming Interface
This section contains the common interface definitions to execute functions of an FMU from a C
program.

### Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functionsof this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulationfrom it.

```@docs
fmiGetFMUstat
fmiSetFMUstate
fmiFreeFMUstate!
fmiSerializedFMUstateSize
fmiSerializeFMUstate
fmiDeSerializeFMUstate
```

### Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.

```@docs
fmiGetDirectionalDerivative
```



## FMI Application Programming Interface
This section contains the interface description to access the in/output data and status information of a co-simulation slave from a C Program.
### Transfer of Input / Output Values and Parameters
```@docs
fmiSetRealInputDerivatives
fmiEnterInitializationMode
fmiEnterInitializationMode

```

## Derivative
```@docs
fmi2GetRealOutputDerivatives
fmiSetRealInputDerivatives
fmiGetDirectionalDerivative
fmiGetDirectionalDerivative!
fmiSampleDirectionalDerivative
fmiSampleDirectionalDerivative!
```
## Simulate FMU

```@docs
fmiSimulate
fmiSimulateCS
fmiSimulateME
fmiSetupExperiment
fmiTerminate
fmiReset
fmiDoStep
```

## Visualize simulation results

```@docs
fmiPlot
```
