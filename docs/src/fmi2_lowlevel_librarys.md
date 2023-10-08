
# [FMI Import/Export/Core/Build .jl Library Functions for FMI2](@id fmi2importlibrary)
```@docs
FMU2
FMU2Component
FMU2ComponentEnvironment
fmi2Struct
fmi2Initial
FMU2Solution
fmi2ScalarVariable
fmi2SimpleType
fmi2Type
fmi2Unit
fmi2Char
fmi2True
fmi2False
fmi2Variability
fmi2VariableDependency
fmi2DependencyKind
fmi2EventInfo
FMU2Event
FMU2ExecutionConfiguration
fmi2Status
fmi2StatusOK
fmi2Annotation
```

## FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical.

### [Reading the model description](@id fmi2importlibraryreadingthemodeldescription)
This section documents functions to inquire information about the model description of an FMU.

#### Load/Parse the FMI model description
```@docs
fmi2ModelDescription
fmi2LoadModelDescription
```

#### Get value functions
```@docs
fmi2GetDefaultStartTime
fmi2GetDefaultStopTime
fmi2GetDefaultTolerance
fmi2GetDefaultStepSize
fmi2GetModelName
fmi2GetGUID
fmi2GetGenerationTool
fmi2GetGenerationDateAndTime
fmi2GetVariableNamingConvention
fmi2GetNumberOfEventIndicators
fmi2GetNumberOfStates
fmi2IsCoSimulation
fmi2IsModelExchange
```

#### Information functions

```@docs
fmi2DependenciesSupported
fmi2DerivativeDependenciesSupported
fmi2GetModelIdentifier
fmi2CanGetSetState
fmi2CanSerializeFMUstate
fmi2ProvidesDirectionalDerivative
fmi2GetValueReferencesAndNames
fmi2GetNames
fmi2GetModelVariableIndices
fmi2GetInputValueReferencesAndNames
fmi2GetInputNames
fmi2GetOutputValueReferencesAndNames
fmi2GetOutputNames
fmi2GetParameterValueReferencesAndNames
fmi2GetParameterNames
fmi2GetStateValueReferencesAndNames
fmi2GetStateNames
fmi2GetDerivateValueReferencesAndNames
fmi2GetDerivativeNames
fmi2GetNamesAndDescriptions
fmi2GetNamesAndUnits
fmi2GetNamesAndInitials
fmi2GetInputNamesAndStarts
fmi2GetVersion
fmi2GetTypesPlatform
fmi2GetSolutionDerivative
fmi2StringToVariability
fmi2VariabilityToString
fmi2StatusToString
fmi2DataTypeForValueReference
fmi2DependencyKindToString
fmi2StringToDependencyKind
```

###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs.

```@docs
fmi2Instantiate!
fmi2Instantiate
fmi2FreeInstance!
fmi2SetDebugLogging
```

### Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

```@docs
fmi2SetupExperiment
fmi2EnterInitializationMode
fmi2ExitInitializationMode
fmi2Terminate
fmi2Reset
```
### Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi2Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different [(for example, min/max
attributes)].

```@docs
fmi2Get
fmi2Get!
fmi2Set
fmi2GetReal
fmi2GetReal!
fmi2GetInteger
fmi2GetInteger!
fmi2GetBoolean
fmi2GetBoolean!
fmi2GetString
fmi2GetString!
fmi2SetReal
fmi2SetInteger
fmi2SetBoolean
fmi2SetString
```


### Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functions of this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulation from it.

```@docs
fmi2GetFMUstate
fmi2GetFMUstate!
fmi2SetFMUstate
fmi2FreeFMUstate!
fmi2SerializedFMUstateSize
fmi2SerializedFMUstateSize!
fmi2SerializeFMUstate
fmi2SerializeFMUstate!
fmi2DeSerializeFMUstate
fmi2DeSerializeFMUstate!
```

### Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.


```@docs
fmi2GetDirectionalDerivative
fmi2GetDirectionalDerivative!
fmi2SetRealInputDerivatives
fmi2GetRealOutputDerivatives!
fmi2SampleJacobian
fmi2SampleJacobian!
```

## FMI for Model Exchange

This chapter contains the interface description to access the equations of a dynamic system from a C
program.

###  Providing Independent Variables and Re-initialization of Caching
Depending on the situation, different variables need to be computed. In order to be efficient, it is important that the interface requires only the computation of variables that are needed in the present context. The state derivatives shall be reused from the previous call. This feature is called “caching of variables” in the sequel. Caching requires that the model evaluation can detect when the input arguments, like time or states, have changed.

```@docs
fmi2SetTime
fmi2SetContinuousStates
```

### Evaluation of Model Equations
This section contains the core functions to evaluate the model equations.


```@docs
fmi2EnterEventMode
fmi2NewDiscreteStates
fmi2NewDiscreteStates!
fmi2EnterContinuousTimeMode
fmi2CompletedIntegratorStep
fmi2CompletedIntegratorStep!
fmi2GetDerivatives
fmi2GetDerivatives!
fmi2GetEventIndicators
fmi2GetEventIndicators!
fmi2GetContinuousStates
fmi2GetContinuousStates!
fmi2GetNominalsOfContinuousStates
fmi2GetNominalsOfContinuousStates!
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
fmi2GetRealOutputDerivatives
```

### Computation
The computation of time steps is controlled by the following function.

```@docs
fmi2StatusKind
fmi2DoStep
fmi2CancelStep
```

### Retrieving Status Information from the Slave
Status information is retrieved from the slave by the following functions:

```@docs
fmi2GetStatus!
fmi2GetRealStatus!
fmi2GetIntegerStatus!
fmi2GetBooleanStatus!
fmi2GetStringStatus!
```

## non FMI-spec functions
These new functions, that are useful, but not part of the FMI-spec. (example: `fmi2Load`, `fmi2SampleJacobian`)

### Opening and closing FMUs
```@docs
fmi2Unzip
fmi2Unload
fmi2Load
fmi2Reload
```

### Conversion functions

```@docs
fmi2StringToValueReference
fmi2ModelVariablesForValueReference
fmi2ValueReferenceToString
fmi2Causality
fmi2StringToCausality
fmi2CausalityToString
fmi2InitialToString
fmi2StringToInitial
fmi2GetSolutionState
fmi2GetSolutionValue
fmi2GetSolutionTime
```

### External/Additional functions

```@docs
fmi2GetJacobian
fmi2GetJacobian!
fmi2GetFullJacobian
fmi2GetFullJacobian!
fmi2GetStartValue
fmi2GetUnit
fmi2GetDeclaredType
fmi2GetInitial
fmi2GetSimpleTypeAttributeStruct
fmi2GetDependencies
```

