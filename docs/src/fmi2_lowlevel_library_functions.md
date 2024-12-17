# FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical.

## Opening and closing FMUs

```@docs
```
fmi2Unzip
fmi2Load
fmi2Reload
fmi2Unload

##  Creation, Destruction and Logging of FMU Instances

```@docs
fmi2Instantiate!
fmi2Instantiate
fmi2FreeInstance
fmi2SetDebugLogging
```

## Initialization, Termination, and Resetting an FMU

```@docs
fmi2SetupExperiment
fmi2EnterInitializationMode
fmi2ExitInitializationMode
fmi2Terminate
fmi2Reset
```

## Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi2Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different (for example, min/max
attributes).

```@docs
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
fmi2Get
fmi2Get!
fmi2Set

## Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functions of this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulation from it.

```@docs
fmi2GetFMUstate
fmi2GetFMUstate!
fmi2SetFMUstate
fmi2FreeFMUstate
fmi2SerializedFMUstateSize
fmi2SerializedFMUstateSize!
fmi2SerializeFMUstate
fmi2SerializeFMUstate!
fmi2DeSerializeFMUstate
fmi2DeSerializeFMUstate!
```

## Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.

```@docs
fmi2GetDirectionalDerivative
fmi2GetDirectionalDerivative!
fmi2SetRealInputDerivatives
fmi2GetRealOutputDerivatives!
```
fmi2SampleJacobian
fmi2SampleJacobian!

## External/Additional functions

```@docs
setDiscreteStates
getDiscreteStates
getDiscreteStates!
getSimpleTypeAttributeStruct
getDeclaredType
```
fmi2GetSolutionDerivative
fmi2GetSolutionState
fmi2GetSolutionValue
fmi2GetSolutionTime
fmi2GetJacobian
fmi2GetJacobian!
fmi2GetFullJacobian
fmi2GetFullJacobian!

## Export functions

```@docs
fmi2ModelDescriptionAddModelStructureOutputs
fmi2CreateEmbedded
fmi2ModelDescriptionAddModelStructureInitialUnknowns
fmi2ModelDescriptionAddModelVariable
fmi2CreateSimple
fmi2Create
fmi2ModelDescriptionAddModelStructureDerivatives
```