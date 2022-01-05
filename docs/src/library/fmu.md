# [Version independent FMU functions] (@id FMU2_ind)

## Parsing variable names to ValueReferences

```@docs
fmiString2ValueReference
```

## Opening and closing FMUs

```@docs
fmiUnzip
fmiLoad
fmiUnload
```

## Reading the model description
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
```

## Simulate FMU

```@docs
fmiSimulate
fmiSimulateCS
fmiSimulateME

```

## Visualize simulation results

```@docs
fmiPlot
```