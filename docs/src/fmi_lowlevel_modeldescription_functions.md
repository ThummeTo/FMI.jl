# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

Model descriptions are loaded through `loadFMU` as part of FMU setup.

## general information about the FMU

```@docs
FMIBase.FMIModelDescriptionLSSA
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

## default experiment settings

```@docs
getDefaultStartTime
getDefaultStepSize
getDefaultStopTime
getDefaultTolerance
```

## FMU capabilities

```@docs
canGetSetFMUState
canSerializeFMUState
providesDirectionalDerivatives
providesAdjointDerivatives
```

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
