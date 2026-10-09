# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

Model descriptions are loaded through `loadFMU` as part of FMU setup.

## general information about the FMU

Use the version-independent model-description helpers for generation metadata.

## technical information about the FMU

```@docs
fmi2GetVersion
fmi2GetTypesPlatform

```

## FMU capabilities

```@docs
isModelStructureAvailable
isModelStructureDerivativesAvailable
```

## value references

```@docs
getModelVariableIndices
```

## In-/Outputs

Use the version-independent input and output helper functions for FMI2 model variables.
