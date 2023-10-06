
# [FMI Import/Export/Core/Build .jl Library Functions for FMI3](@id library)
```@docs
FMU3
FMU3Instance
fmi3Struct
```

## FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical.

### Reading the model description
This section documents functions to inquire information about the model description of an FMU.

#### Load/Parse the FMI model description
```@docs
fmi3LoadModelDescription
```
#### Get value functions
```@docs
fmi3GetDefaultStartTime
fmi3GetDefaultStopTime
fmi3GetDefaultTolerance
fmi3GetDefaultStepSize
fmi3GetModelName
fmi3GetInstantiationToken
fmi3GetGenerationTool
fmi3GetGenerationDateAndTime
fmi3GetVariableNamingConvention
fmi3GetNumberOfEventIndicators
fmi3IsCoSimulation
fmi3IsModelExchange
fmi3IsScheduledExecution
```

#### Information functions


```@docs
fmi3GetModelIdentifier
fmi3CanGetSetState
fmi3GetVersion
```

###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs.

```@docs
fmi3FreeInstance!
fmi3SetDebugLogging

```

### Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

```@docs
fmi3EnterInitializationMode
fmi3ExitInitializationMode
fmi3Terminate
fmi3Reset
```
### Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi3Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different [(for example, min/max
attributes)].

```@docs
fmi3Get
fmi3Get!
fmi3Set
fmi3GetBoolean
fmi3GetBoolean!
fmi3GetString
fmi3GetString!
fmi3SetBoolean
fmi3SetString
```


### Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functions of this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulation from it.

```@docs
```

### Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.


```@docs
fmi3GetDirectionalDerivative
fmi3GetDirectionalDerivative!
```

## FMI for Model Exchange

This chapter contains the interface description to access the equations of a dynamic system from a C
program.

###  Providing Independent Variables and Re-initialization of Caching
Depending on the situation, different variables need to be computed. In order to be efficient, it is important that the interface requires only the computation of variables that are needed in the present context. The state derivatives shall be reused from the previous call. This feature is called “caching of variables” in the sequel. Caching requires that the model evaluation can detect when the input arguments, like time or states, have changed.

```@docs
fmi3SetTime
fmi3SetContinuousStates
```

### Evaluation of Model Equations
This section contains the core functions to evaluate the model equations.


```@docs
fmi3EnterEventMode
fmi3EnterContinuousTimeMode
fmi3CompletedIntegratorStep
fmi3CompletedIntegratorStep!
fmi3GetEventIndicators!
fmi3GetContinuousStates!
fmi3GetNominalsOfContinuousStates!
```

## FMI for Co-Simulation
This chapter defines the Functional Mock-up Interface (FMI) for the coupling of two or more simulation
models in a Co-Simulation environment (FMI for Co-Simulation). Co-Simulation is a rather general
approach to the simulation of coupled technical systems and coupled physical phenomena in
engineering with focus on instationary (time-dependent) problems.


### Transfer of Input / Output Values and Parameters
In order to enable the slave to interpolate the continuous real inputs between communication steps, the
derivatives of the inputs with respect to time can be provided. Also, higher derivatives can be set to allow
higher order interpolation.

```@docs
```

### Computation
The computation of time steps is controlled by the following function.

```@docs
```

### Retrieving Status Information from the Slave
Status information is retrieved from the slave by the following functions:

```@docs
```

## non FMI-spec functions
These new functions, that are useful, but not part of the FMI-spec. (example: `fmi3Load`, `fmi3SampleJacobian`)

### Opening and closing FMUs
```@docs
fmi3Unzip
fmi3Unload
fmi3Load
fmi3Reload
```
### Conversion functions

```@docs
fmi3StringToValueReference
fmi3ModelVariablesForValueReference
fmi3ValueReferenceToString
```

### External/Additional functions

```@docs
fmi3GetJacobian
fmi3GetJacobian!
fmi3GetFullJacobian
fmi3GetFullJacobian!
fmi3GetStartValue
```


## All functions

```@index
```
