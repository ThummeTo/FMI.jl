# Functions in FMI Import/Core .jl 

```@docs
logInfo
logWarning
logError
```

## Solver backend

```@docs
solveFMUProblem!
```

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
FMIBase.snapshot_if_needed!
FMIBase.getSnapshot
```
