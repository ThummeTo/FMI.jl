# Library Functions

Many of the functions in this library are based on already defined functions of the FMIImport.jl library. Within this library, a distinction is made between the FMI-standards (FMI2 and FMI3), which is why the links to both function collections are provided in the following.
- FMI2Standard: []
- FMI3Standard: []

In this collection only the essential and not in the standard defined functions are listed.


# Simulate FMUs

```@docs
fmiSimulate
fmiSimulateCS
fmiSimulateME
fmiLoad
fmiUnload
fmiReload
```
### Conversion functions

```@docs
fmiStringToValueReference
```

### External/additional functions

```@docs
fmiGetDependencies
fmiInfo
```

### Visualize simulation results

```@docs
fmiPlot
```
