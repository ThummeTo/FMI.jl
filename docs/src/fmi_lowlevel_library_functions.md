# Functions in FMI Import/Core .jl 

```@docs
logInfo
logWarning
logError
```
loadBinary
eval!

## Conversion functions

```@docs
stringToStatus
statusToString
stringToDependencyKind
dependencyKindToString
valueReferenceToString
stringToInitial
initialToString
stringToIntervalQualifier
stringToDataType
stringToCausality
causalityToString
stringToVariability
variabilityToString
```

fmi2StringToInitial

## External/Additional functions

```@docs
getInitial
getStartValue
hasCurrentInstance
getCurrentInstance
modelVariablesForValueReference
setValue
getValue
getValue!
getUnit
```
fmi2GetSolutionDerivative
fmi2GetSolutionState
fmi2GetSolutionValue
fmi2GetSolutionTime
fmi2GetJacobian
fmi2GetJacobian!
fmi2GetFullJacobian
fmi2GetFullJacobian!