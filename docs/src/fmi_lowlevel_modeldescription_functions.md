# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

```@docs
```
fmi2LoadModelDescription

## general information about the FMU

```@docs
getGUID
getInstantiationToken
getGenerationDateAndTime
getGenerationTool
```

## technical information about the FMU

```@docs
getNumberOfEventIndicators
getModelIdentifier
getVariableNamingConvention
```
fmi2GetVersion
fmi2GetTypesPlatform

## default experiment settings

```@docs
getDefaultStartTime
getDefaultStepSize
getDefaultStopTime
getDefaultTolerance
```

## FMU capabilities

```@docs
canSerializeFMUState
providesDirectionalDerivatives
providesAdjointDerivatives
```
canGetSetFMUState
fmi2DependenciesSupported
fmi2DerivativeDependenciesSupported
fmi2ProvidesDirectionalDerivative

## value references

```@docs
getValueReferencesAndNames
getNames
dataTypeForValueReference
prepareValueReference
prepareValue
```

## In-/Outputs

```@docs
getInputNames
getInputValueReferencesAndNames
getInputNamesAndStarts
getOutputNames
getOutputValueReferencesAndNames
```

## Parameters

```@docs
getParameterValueReferencesAndNames
getParameterNames
```

## States

```@docs
getStateNames
getStateValueReferencesAndNames
```

## Derivatives

```@docs
getDerivateValueReferencesAndNames
getDerivativeNames
```

## Variables

```@docs
getNamesAndInitials
getNamesAndDescriptions
getNamesAndUnits
```