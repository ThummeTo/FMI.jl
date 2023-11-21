# FMI.jl Library Functions

Many of the functions in this library are based on already defined functions of the [FMIImport.jl](https://github.com/ThummeTo/FMIImport.jl) library. 

# Simulate FMUs

```@docs
fmiLoad
fmiSimulate
fmiSimulateCS
fmiSimulateME
fmiUnload
fmiReload
```
# Handling Value References

```@docs
fmiStringToValueReference
fmiGetStartValue
```

# External/additional functions

```@docs
fmiInfo
fmiSet
fmiGet
fmiGet!
fmiGetNumberOfStates
fmiCanGetSetState
fmiGetState
fmiSetState
fmiFreeState!
fmiGetDependencies
fmiProvidesDirectionalDerivative
fmiGetModelName
fmiGetGUID
fmiIsCoSimulation
fmiIsModelExchange
fmiIsScheduledExecution
```

# Visualize simulation results

```@docs
fmiPlot
fmiPlot!
Plots.plot
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
fmi2VariableDependsOnVariable
fmi2GetDependencies
fmi2PrintDependencies
```

# FMI3 specific

```@docs
fmi3Info
fmi3Simulate
fmi3SimulateME
fmi3SimulateSE
fmi3SimulateCS
fmi3VariableDependsOnVariable
fmi3GetDependencies
fmi3PrintDependencies
```