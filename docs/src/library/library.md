# [Library functions](@id library)

## Creation, Destruction FMU

```@docs
fmi2Instantiate
fmi2FreeInstance!(::FMI.fmi2Component)
```

## Platform and Version number

```@docs
fmi2GetTypesPlatform(::Ptr{Nothing})
fmi2GetVersion(::Ptr{Nothing})
fmi2SetDebugLogging(::FMI.fmi2Component, ::FMI.fmi2Boolean, ::Unsigned, ::Ptr{Nothing})
```

## Initialization, Termination and Destruction

```@docs
fmi2SetupExperiment(::FMI.fmi2Component, ::FMI.fmi2Boolean, ::FMI.fmi2Real, ::FMI.fmi2Real, ::FMI.fmi2Boolean, ::FMI.fmi2Real)
fmi2EnterInitializationMode(::FMI.fmi2Component)
fmi2ExitInitializationMode(::FMI.fmi2Component)
fmi2Terminate(::FMI.fmi2Component)
fmi2Reset(::FMI.fmi2Component)
```

## Get/Set variable values
```@docs
fmi2GetReal(::FMI.fmi2Component, ::FMI.fmi2ValueReferenceFormat)
fmi2GetReal!(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Real})
fmi2SetReal(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Real})
fmi2GetInteger(::FMI.fmi2Component, ::FMI.fmi2ValueReferenceFormat)
fmi2GetInteger!(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Integer})
fmi2SetInteger(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Integer})
fmi2GetBoolean(::FMI.fmi2Component, ::FMI.fmi2ValueReferenceFormat)
fmi2GetBoolean!(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Boolean})
fmi2SetBoolean(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Boolean})
fmi2GetString(::FMI.fmi2Component, ::FMI.fmi2ValueReferenceFormat)
fmi2GetString!(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Vector{Ptr{Cchar}})
fmi2SetString(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Union{Array{Ptr{Cchar}}, Array{Ptr{UInt8}}})
```

## FMU state Functions

```@docs
fmi2GetFMUstate(::FMI.fmi2Component, ::Ref{FMI.fmi2FMUstate})
fmi2SetFMUstate(::FMI.fmi2Component, ::FMI.fmi2FMUstate)
fmi2FreeFMUstate(::FMI.fmi2Component, ::Ref{FMI.fmi2FMUstate})
fmi2SerializedFMUstateSize(::FMI.fmi2Component, ::FMI.fmi2FMUstate, ::Ref{Csize_t})
fmi2SerializeFMUstate(::FMI.fmi2Component, ::FMI.fmi2FMUstate, ::Array{FMI.fmi2Byte}, ::Csize_t)
fmi2DeSerializeFMUstate(::FMI.fmi2Component, ::Array{FMI.fmi2Byte}, ::Csize_t, ::Ref{FMI.fmi2FMUstate})
```

## Partial Derivatives

```@docs
fmi2GetDirectionalDerivative!(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2ValueReference}, ::Csize_t, ::Array{FMI.fmi2Real}, ::Array{FMI.fmi2Real})
fmi2GetDirectionalDerivative(::FMI.fmi2Component, ::Array{FMI.fmi2ValueReference}, ::Array{FMI.fmi2ValueReference}, ::Array{FMI.fmi2Real} = Array{FMI.fmi2Real}([]))
```

## CoSimulation specific Functions

```@docs
fmi2SetRealInputDerivatives(::FMI.fmi2Component, ::FMI.fmi2ValueReference, ::Unsigned, ::FMI.fmi2Integer, ::FMI.fmi2Real)
fmi2GetRealOutputDerivatives(::FMI.fmi2Component, ::FMI.fmi2ValueReference, ::Unsigned, ::FMI.fmi2Integer, ::FMI.fmi2Real)
fmi2DoStep(::FMI.fmi2Component, ::FMI.fmi2Real, ::FMI.fmi2Real, ::FMI.fmi2Boolean)
fmi2CancelStep(::FMI.fmi2Component)
fmi2GetStatus(::FMI.fmi2Component, ::FMI.fmi2StatusKind, ::FMI.fmi2Status)
fmi2GetRealStatus(::FMI.fmi2Component, ::FMI.fmi2StatusKind, ::FMI.fmi2Real)
fmi2GetIntegerStatus(::FMI.fmi2Component, ::FMI.fmi2StatusKind, ::FMI.fmi2Integer)
fmi2GetBooleanStatus(::FMI.fmi2Component, ::FMI.fmi2StatusKind, ::FMI.fmi2Boolean)
fmi2GetStringStatus(::FMI.fmi2Component, ::FMI.fmi2StatusKind, ::FMI.fmi2String)
```

## ModelExchange specific Functions

```@docs
fmi2SetTime(::FMI.fmi2Component, ::FMI.fmi2Real)
fmi2SetContinuousStates(::FMI.fmi2Component, ::Array{FMI.fmi2Real}, ::Csize_t)
fmi2EnterEventMode(::FMI.fmi2Component)
fmi2NewDiscreteStates(::FMI.fmi2Component, ::FMI.fmi2EventInfo)
fmi2EnterContinuousTimeMode(::FMI.fmi2Component)
fmi2CompletedIntegratorStep!(::FMI.fmi2Component, ::FMI.fmi2Boolean, ::FMI.fmi2Boolean, ::FMI.fmi2Boolean)
fmi2GetDerivatives(::FMI.fmi2Component, ::Array{FMI.fmi2Real}, ::Csize_t)
fmi2GetEventIndicators(::FMI.fmi2Component, ::Array{FMI.fmi2Real}, ::Csize_t)
fmi2GetContinuousStates(::FMI.fmi2Component, ::Array{FMI.fmi2Real}, ::Csize_t)
fmi2GetNominalsOfContinuousStates(::FMI.fmi2Component, ::Array{FMI.fmi2Real}, ::Csize_t)
```
