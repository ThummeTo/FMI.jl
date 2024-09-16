# FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical.

##  Creation, Destruction and Logging of FMU Instances

```@docs
fmi3InstantiateCoSimulation
fmi3InstantiateCoSimulation!
fmi3InstantiateModelExchange
fmi3InstantiateModelExchange!
fmi3InstantiateScheduledExecution
fmi3InstantiateScheduledExecution!
fmi3FreeInstance
fmi3FreeInstance!
fmi3SetDebugLogging
```

## Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

```@docs
fmi3EnterInitializationMode
fmi3ExitInitializationMode
fmi3EnterConfigurationMode
fmi3ExitConfigurationMode
fmi3Terminate
fmi3Reset
```

## Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi3Float64) have the same valueReference, then they
have identical values but other parts of the variable definition might be different (for example, min/max
attributes).

```@docs
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
fmi3Get
fmi3Get!
fmi3Set

## Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functions of this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulation from it.

```@docs
fmi3GetFMUState
fmi3GetFMUState!
fmi3SetFMUState
fmi3FreeFMUState
fmi3SerializeFMUState
fmi3SerializeFMUState!
fmi3SerializedFMUStateSize
fmi3SerializedFMUStateSize!
fmi3DeSerializeFMUState
fmi3DeSerializeFMUState!
fmi3UpdateDiscreteStates
fmi3EvaluateDiscreteStates
fmi3GetNominalsOfContinuousStates
```

## Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.

```@docs
fmi3GetDirectionalDerivative
fmi3GetDirectionalDerivative!
fmi3GetContinuousStateDerivatives
fmi3GetContinuousStateDerivatives!
fmi3GetAdjointDerivative
fmi3GetAdjointDerivative!
fmi3GetOutputDerivatives
fmi3GetOutputDerivatives!
```
fmi3SampleDirectionalDerivative
fmi3SampleDirectionalDerivative!
fmi3GetJacobian
fmi3GetJacobian!
fmi3GetFullJacobian
fmi3GetFullJacobian!

## TODO: Clockstuff

```@docs
fmi3GetIntervalDecimal!
fmi3SetIntervalDecimal
fmi3GetIntervalFraction!
fmi3SetIntervalFraction
fmi3GetShiftDecimal!
fmi3GetShiftFraction!
fmi3GetClock
fmi3GetClock!
fmi3SetClock
fmi3ActivateModelPartition
```
fmi3CallbackClockUpdate

## Conversion functions

```@docs
stringToType
typeToString
stringToVariableNamingConvention
variableNamingConventionToString
intervalQualifierToString
```
fmi3StringToCausality
fmi3StatusToString
fmi3StringToInitial

## External/Additional functions

```@docs
fmi3GetNumberOfVariableDependencies
fmi3GetNumberOfVariableDependencies!
fmi3GetVariableDependencies
fmi3GetVariableDependencies!
```