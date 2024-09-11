# FMI.jl Library Functions

Many of the functions in this library are based on already defined functions of the [FMIImport.jl](https://github.com/ThummeTo/FMIImport.jl) library. 

# Simulate FMUs

```@docs
loadFMU
simulate
simulateCS
simulateSE
simulateME
unloadFMU
reload
```

# Handling Value References

```@docs
stringToValueReference
```

# External/additional functions

```@docs
info
getModelName
getNumberOfStates
isModelExchange
isScheduledExecution
isCoSimulation
getState
getTime
getStateDerivative
```
fmiSet
fmiGet
fmiGet!
fmiCanGetSetState
fmiSetState
fmiFreeState!
fmiGetDependencies
fmiProvidesDirectionalDerivative

# Visualize simulation results

```@docs
```
fmiPlot
fmiPlot!
Plots.plot

# Save/load simulation results

```@docs
```
fmiSaveSolution
fmiSaveSolutionJLD2
fmiSaveSolutionMAT
fmiSaveSolutionCSV
fmiLoadSolution
fmiLoadSolutionJLD2

# FMI2 specific

```@docs
```
fmi2Info
fmi2Simulate
fmi2VariableDependsOnVariable
fmi2GetDependencies
fmi2PrintDependencies

# FMI3 specific

```@docs
```
fmi3Info
fmi3Simulate
fmi3VariableDependsOnVariable
fmi3GetDependencies
fmi3PrintDependencies