# Library Functions

## Parsing variable names to ValueReferences

```@docs
fmiStringToValueReference
```

## Opening and closing FMUs

```@docs
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

## Get/Set variable values

```@docs
fmiGet
fmiGet!
fmiSet
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