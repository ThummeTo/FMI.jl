
# [FMI Import/Core .jl Library Functions/Types for FMI3](@id library)
```@docs
FMU3
FMU3Instance
FMU3InstanceEnvironment
fmi3Struct
fmi3StructMD
fmi3Initial
FMU3Solution
fmi3Variable
fmi3VariableDependency
fmi3SimpleType
fmi3Type
fmi3Unit
fmi3Float32
fmi3Float64
fmi3Int8
fmi3Int16
fmi3Int32
fmi3Int64
fmi3True
fmi3False
fmi3IntervalQualifier
fmi3Variability
fmi3DependencyKind
FMU3Event
FMU3ExecutionConfiguration
fmi3Status
fmi3StatusOK
fmi3Annotation
```

## FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical.

### Reading the model description
This section documents functions to inquire information about the model description of an FMU.

#### Load/Parse the FMI model description
```@docs
fmi3ModelDescription
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
fmi3GetNumberOfEventIndicators!
fmi3IsCoSimulation
fmi3IsModelExchange
fmi3IsScheduledExecution
```

#### Information functions


```@docs
fmi3GetModelIdentifier
fmi3ProvidesAdjointDerivatives
fmi3CanGetSetState
fmi3CanSerializeFMUState
fmi3ProvidesDirectionalDerivatives
fmi3GetVersion
fmi3VariableNamingConvention
fmi3VariableNamingConventionFlat
fmi3VariableNamingConventionStructured
fmi3VariableNamingConventionToString
fmi3StringToVariableNamingConvention
fmi3StringToVariability
fmi3VariabilityToString
fmi3StatusToString
fmi3DependencyKindToString
fmi3StringToDependencyKind
```

###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs.

```@docs
fmi3InstantiateCoSimulation
fmi3InstantiateCoSimulation!
fmi3InstantiateModelExchange
fmi3InstantiateModelExchange!
fmi3InstantiateScheduledExecution
fmi3InstantiateScheduledExecution!
fmi3FreeInstance!
fmi3SetDebugLogging

```

### Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

```@docs
fmi3EnterInitializationMode
fmi3ExitInitializationMode
fmi3EnterConfigurationMode
fmi3ExitConfigurationMode
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
fmi3GetFloat32
fmi3GetFloat32!
fmi3GetFloat64
fmi3GetFloat64!
fmi3GetInt8
fmi3GetInt8!
fmi3GetInt16
fmi3GetInt16!
fmi3GetInt32
fmi3GetInt32!
fmi3GetInt64
fmi3GetInt64!
fmi3GetUInt8
fmi3GetUInt8!
fmi3GetUInt16
fmi3GetUInt16!
fmi3GetUInt32
fmi3GetUInt32!
fmi3GetUInt64
fmi3GetUInt64!
fmi3GetBoolean
fmi3GetBoolean!
fmi3GetString
fmi3GetString!
fmi3GetBinary
fmi3GetBinary!
fmi3Set
fmi3SetFloat32
fmi3SetFloat64
fmi3SetInt8
fmi3SetInt16
fmi3SetInt32
fmi3SetInt64
fmi3SetUInt8
fmi3SetUInt16
fmi3SetUInt32
fmi3SetUInt64
fmi3SetBoolean
fmi3SetString
fmi3SetBinary
```


### Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functions of this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulation from it.

```@docs
fmi3GetFMUState
fmi3GetFMUState!
fmi3SetFMUState
fmi3FreeFMUState!
fmi3SerializeFMUState
fmi3SerializeFMUState!
fmi3SerializedFMUStateSize
fmi3SerializedFMUStateSize!
fmi3DeSerializeFMUState
fmi3DeSerializeFMUState!
fmi3UpdateDiscreteStates
fmi3EvaluateDiscreteStates
```

TODO: Clockstuff

```@docs
fmi3GetIntervalDecimal!
fmi3GetIntervalFraction!
fmi3GetShiftDecimal!
fmi3GetShiftFraction!
fmi3GetClock
fmi3GetClock!
fmi3SetIntervalDecimal
fmi3SetIntervalFraction
fmi3SetClock
fmi3ActivateModelPartition
fmi3CallbackClockUpdate
```

### Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.


```@docs
fmi3GetDirectionalDerivative
fmi3GetDirectionalDerivative!
fmi3GetContinuousStateDerivatives
fmi3GetContinuousStateDerivatives!
fmi3GetAdjointDerivative!
fmi3GetOutputDerivatives
fmi3GetOutputDerivatives!
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
fmi3GetNumberOfContinuousStates
fmi3GetNumberOfContinuousStates!
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
fmi3CallbackIntermediateUpdate
```

### Computation
The computation of time steps is controlled by the following function.

```@docs
fmi3EnterStepMode
fmi3DoStep!
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
fmi3IntervalQualifierToString
fmi3StringToIntervalQualifier
fmi3Causality
fmi3StringToCausality
fmi3CausalityToString
fmi3InitialToString
fmi3StringToInitial
```

### External/Additional functions

```@docs
fmi3GetJacobian
fmi3GetJacobian!
fmi3GetFullJacobian
fmi3GetFullJacobian!
fmi3GetStartValue
fmi3GetNumberOfVariableDependencies!
fmi3GetVariableDependencies!
fmi3GetDependencies
fmi3SampleDirectionalDerivative
fmi3SampleDirectionalDerivative!
```

```@docs
fmi3StringToType
fmi3TypeToString
```