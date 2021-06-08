# Library functions

## Creation, Destruction FMU

```@docs
fmi2Instantiate
fmi2FreeInstance
```

## Platform and Version number

```@docs
fmi2GetVersion
fmi2GetTypesPlatform
fmi2SetDebugLogging
```

## Initialization, Termination and Destruction

```@docs
fmi2SetupExperiment
fmi2EnterInitializationMode
fmi2ExitInitializationMode
fmi2Terminate
fmi2Reset(c::FMI.fmi2Component)
```

## Get/Set variable values
```@docs
fmi2GetReal
fmi2GetReal!
fmi2SetReal
fmi2GetInteger
fmi2GetInteger!
fmi2SetInteger
fmi2GetBoolean
fmi2GetBoolean!
fmi2SetBoolean
fmi2GetString
fmi2GetString!
fmi2SetString
```

## FMU state Functions

```@docs
fmi2GetFMUstate
fmi2SetFMUstate
fmi2FreeFMUstate
fmi2SerializedFMUstateSize
fmi2SerializeFMUstate
fmi2DeSerializeFMUstate
```

## Partial Derivatives

```@docs
fmi2GetDirectionalDerivative!
fmi2GetDirectionalDerivative
```

## CoSimulation specific Functions

```@docs
fmi2SetRealInputDerivatives
fmi2GetRealOutputDerivatives
fmi2DoStep
fmi2CancelStep
fmi2GetStatus
fmi2GetRealStatus
fmi2GetIntegerStatus
fmi2GetBooleanStatus
fmi2GetStringStatus
```

## ModelExchange specific Functions

```@docs
fmi2SetTime
fmi2SetContinuousStates
fmi2EnterEventMode
fmi2NewDiscreteStates
fmi2EnterContinuousTimeMode
fmi2CompletedIntegratorStep!
fmi2GetDerivatives
fmi2GetEventIndicators
fmi2GetContinuousStates
fmi2GetNominalsOfContinuousStates
```
