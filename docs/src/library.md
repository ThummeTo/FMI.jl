# FMI.jl Library Functions

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
fmiGetNumberOfStates
fmiGetDependencies
fmiInfo
fmiGetGUID
fmiIsCoSimulation
fmiIsModelExchange
fmiIsScheduledExecution
```

# Visualize simulation results

```@docs
fmiPlot
```

# Save/load simulation results

```@docs
fmiSaveSolution
fmiSaveSolutionJLD2
fmiSaveSolutionMAT
fmiSaveSolutionCSV
fmiLoadSolution
fmiLoadSolutionJLD2
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