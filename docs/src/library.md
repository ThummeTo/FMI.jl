# Library Functions

Many of the functions in this library are based on already defined functions of the [FMIImport.jl](https://github.com/ThummeTo/FMIImport.jl) library. 

# Simulate FMUs

```@docs
fmiSimulate
fmiSimulateCS
fmiSimulateME
fmiLoad
fmiUnload
fmiReload
```
# Conversion functions

```@docs
fmiStringToValueReference
```

# External/additional functions

```@docs
fmiGetDependencies
fmiInfo
```

# Visualize simulation results

```@docs
fmiPlot
```

# FMI2 specific

```@docs
fmi2Info
fmi2Simulate
fmi2SimulateME
fmi2SimulateCS
```

# FMI3 specific

```@docs
fmi3Info
fmi3Simulate
fmi3SimulateME
fmi3SimulateSE
fmi3SimulateCS
```