# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following fuctions can be used to obtain all information provided by the model descripton, wich in turn can be extrated from the fmu.

## Loading/Parsing

```@docs
fmi2LoadModelDescription
```

## general information about the FMU

```@docs
fmi2GetModelName
fmi2GetGUID
fmi2IsCoSimulation
fmi2IsModelExchange
fmi2GetGenerationTool
fmi2GetGenerationDateAndTime
```

## tecnical information about the FMU

```@docs
fmi2GetModelIdentifier
fmi2GetVariableNamingConvention
fmi2GetVersion
fmi2GetTypesPlatform

fmi2GetNumberOfEventIndicators
```

## default experiment settings

```@docs
fmi2GetDefaultStartTime
fmi2GetDefaultStopTime
fmi2GetDefaultTolerance
fmi2GetDefaultStepSize
```

## FMU capabilities

```@docs
fmi2DependenciesSupported
fmi2DerivativeDependenciesSupported
fmi2CanGetSetState
fmi2CanSerializeFMUstate
fmi2ProvidesDirectionalDerivative
```

## value references

```@docs
fmi2GetValueReferencesAndNames
fmi2GetNames
fmi2GetModelVariableIndices
fmi2DataTypeForValueReference
```

## In-/Outputs

```@docs
fmi2GetInputValueReferencesAndNames
fmi2GetInputNames
fmi2GetOutputValueReferencesAndNames
fmi2GetOutputNames
```

## Parameters

```@docs
fmi2GetParameterValueReferencesAndNames
fmi2GetParameterNames
```

## States

```@docs
fmi2GetNumberOfStates
fmi2GetStateValueReferencesAndNames
fmi2GetStateNames
```

## Derivatives

```@docs
fmi2GetDerivateValueReferencesAndNames
fmi2GetDerivativeNames
```

## Variables

```@docs
fmi2GetNamesAndDescriptions
fmi2GetNamesAndUnits
fmi2GetNamesAndInitials
fmi2GetInputNamesAndStarts
```
