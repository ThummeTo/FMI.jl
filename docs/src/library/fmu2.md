## [Simulation results](@id fmu2)

```@docs
fmi2SimulationResultGetValuesAtIndex
fmi2SimulationResultGetTime
fmi2SimulationResultGetValues
```

## Parsing variable names to ValueReferences

```@docs
fmi2String2ValueReference
fmi2ValueReference2String
```

## Opening and closing FMUs

```@docs
fmi2Unzip
fmi2Load
fmi2Unload
```

## Reading the model description
```@docs
fmi2GetModelName
fmi2GetGUID
fmi2GetGenerationTool
fmi2GetGenerationDateAndTime
fmi2GetVariableNamingConvention
fmi2GetNumberOfEventIndicators
fmi2CanGetSetState
fmi2CanSerializeFMUstate
fmi2ProvidesDirectionalDerivative
fmi2IsCoSimulation
fmi2IsModelExchange
```
## Simulate FMU

```@docs
fmi2Simulate(::FMU2, ::Real = 0.0, ::Real = 1.0; ::FMI.fmi2ValueReferenceFormat = nothing, saveat=[], setup=true)
fmi2SimulateCS(::FMI.fmi2Component, ::Real, ::Real; ::FMI.fmi2ValueReferenceFormat = nothing, saveat=[], setup=true)
fmi2SimulateME(::FMI.fmi2Component, ::Real = 0.0, ::Real = 1.0; solver = nothing, customFx = nothing, ::FMI.fmi2ValueReferenceFormat = nothing, saveat = [], setup = true)

```
