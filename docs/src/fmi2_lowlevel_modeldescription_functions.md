# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

```@docs
```
fmi2LoadModelDescription

## general information about the FMU

```@docs
```
fmi2GetGenerationTool
fmi2GetGenerationDateAndTime

## technical information about the FMU

```@docs
fmi2GetVersion
fmi2GetTypesPlatform

```

## FMU capabilities

```@docs
canGetSetFMUState
isModelStructureAvailable
isModelStructureDerivativesAvailable
```
fmi2DependenciesSupported
fmi2DerivativeDependenciesSupported
fmi2CanSerializeFMUstate
fmi2ProvidesDirectionalDerivative

## value references

```@docs
getModelVariableIndices
```
fmi2GetValueReferencesAndNames
fmi2GetNames

## In-/Outputs

```@docs
```
fmi2GetOutputValueReferencesAndNames
