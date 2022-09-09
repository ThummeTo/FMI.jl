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

## FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical

### Reading the model description
This section documents functions to inquire information about the model description of an FMU
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
fmiGetTypesPlatform
```

###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs
```@docs
fmiInstantiate!
fmiFreeInstance!
fmiSetDebugLogging
```

### Simulate an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

```@docs
fmiSimulate
fmiSimulateCS
fmiSimulateME
```
### Getting and Setting Variable Values
TODO Ref FMIImport
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi2Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different [(for example, min/max
attributes)].

```@docs
fmiGet
fmiGet!
fmiSet
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


### Getting and Setting the Complete FMU State
TODO Ref FMIImport -> unterschiedliche Funktionen in FMI2 und FMI3
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
TODO Ref FMIImport
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.

```@docs
fmiGetDirectionalDerivative
fmiGetDirectionalDerivative!
fmiSampleDirectionalDerivative
fmiSampleDirectionalDerivative!
```



## FMI for Model Exchange
TODO Ref FMIImport

This chapter contains the interface description to access the equations of a dynamic system from a C
program.

###  Providing Independent Variables and Re-initialization of Caching
TODO Ref FMIImport
```@docs
fmiSetTime
fmiSetContinuousStates
fmiSetReal
fmiSetInteger
fmiSetBoolean
fmiSetString
```

### Evaluation of Model Equations
TODO Ref FMIImport
This section contains the core functions to evaluate the model equations

```@docs
fmiEnterEventMode
fmiNewDiscreteStates
fmiEnterContinuousTimeMode
fmiCompletedIntegratorStep
fmiGetDerivatives
fmiGetEventIndicators
fmiGetContinuousStates
fmiGetNominalsOfContinuousStates
```

## FMI for CO-Simulation
TODO Ref FMIImport
This chapter defines the Functional Mock-up Interface (FMI) for the coupling of two or more simulation
models in a co-simulation environment (FMI for Co-Simulation). Co-simulation is a rather general
approach to the simulation of coupled technical systems and coupled physical phenomena in
engineering with focus on instationary (time-dependent) problems.


### Transfer of Input / Output Values and Parameters
TODO Ref FMIImport
In order to enable the slave to interpolate the continuous real inputs between communication steps, the
derivatives of the inputs with respect to time can be provided. Also, higher derivatives can be set to allow
higher order interpolation.

```@docs
fmiSetRealInputDerivatives
fmiGetRealOutputDerivatives
```

### Computation
TODO Ref FMIImport
The computation of time steps is controlled by the following function.

```@docs
fmiDoStep
fmiCancelStep
```

### Retrieving Status Information from the Slave
TODO Ref FMIImport
Status information is retrieved from the slave by the following functions:

```@docs
fmiGetStatus
fmiGetRealStatus
fmiGetIntegerStatus
fmiGetBooleanStatus
fmiGetStringStatus
```


## Visualize simulation results

```@docs
fmiPlot
```
