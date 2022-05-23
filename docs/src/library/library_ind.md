# Version independent library functions

## Creation, Destruction FMU

```@docs
fmiInstantiate!
fmiFreeInstance!
```

## Platform and Version number

```@docs
fmiGetTypesPlatform
fmiGetVersion
fmiSetDebugLogging
```

## Initialization, Termination and Destruction

```@docs
fmiSetupExperiment
fmiEnterInitializationMode
fmiExitInitializationMode
fmiTerminate
fmiReset
```

## Get/Set variable values
```@docs
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
```

## FMU state Functions

```@docs
fmiGetFMUstate
fmiSetFMUstate
fmiFreeFMUstate!
fmiSerializedFMUstateSize
fmiSerializeFMUstate
fmiDeSerializeFMUstate
```

## Partial Derivatives

```@docs
fmiGetDirectionalDerivative(::FMI.fmi2Struct, ::Array{Cint}, ::Array{Cint}, ::Array{Real}, ::Array{Real})
```

## CoSimulation specific Functions

```@docs
fmiDoStep(::FMI.fmi2Struct, ::Real)
```

## ModelExchange specific Functions

```@docs
fmiSetTime
fmiSetContinuousStates
fmiNewDiscreteStates
fmiEnterContinuousTimeMode
fmiCompletedIntegratorStep
fmiGetDerivatives
fmiGetEventIndicators
fmiGetContinuousStates
fmiGetNominalsOfContinuousStates
```
