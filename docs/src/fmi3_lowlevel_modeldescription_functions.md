# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

```@docs
fmi3LoadModelDescription
```

## general information about the FMU

```@docs
fmi3GetModelName
fmi3GetInstantiationToken
fmi3IsCoSimulation
fmi3IsModelExchange
fmi3IsScheduledExecution
fmi3GetGenerationTool
fmi3GetGenerationDateAndTime
```

## technical information about the FMU

```@docs
fmi3GetModelIdentifier
fmi3GetVariableNamingConvention
fmi3GetVersion

fmi3GetNumberOfEventIndicators
fmi3GetNumberOfEventIndicators!
```

## default experiment settings

```@docs
fmi3GetDefaultStartTime
fmi3GetDefaultStopTime
fmi3GetDefaultTolerance
fmi3GetDefaultStepSize
```

## FMU capabilities

```@docs
fmi3CanGetSetState
fmi3CanSerializeFMUState
fmi3ProvidesDirectionalDerivatives
fmi3ProvidesAdjointDerivatives
```