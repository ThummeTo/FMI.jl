# Working with the FMI model description

The FMI model description provides all human readable information on the model. The following functions can be used to obtain all information provided by the model description, which in turn can be extracted from the fmu.

## Loading/Parsing

```@docs
```
fmi3LoadModelDescription

## general information about the FMU

```@docs
```
fmi3GetGenerationTool
fmi3GetGenerationDateAndTime

## technical information about the FMU

```@docs
fmi3GetVersion

fmi3GetNumberOfEventIndicators
fmi3GetNumberOfEventIndicators!
```

## FMU capabilities

```@docs
```
fmi3CanGetSetState
fmi3CanSerializeFMUState