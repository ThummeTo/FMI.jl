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
Use `setValue`, `getValue`, and `getValue!` for generic value access on FMU instances.

# Visualize simulation results

Use `Plots.plot(solution)` to visualize `FMUSolution` objects when `Plots.jl` is loaded.

# Save/load simulation results

```@docs
saveSolution
loadSolution
```

# FMI2 specific

Deprecated `fmi2...` wrappers have been removed from the user-level API. Use the version-independent functions above.

# FMI3 specific

Deprecated `fmi3...` wrappers have been removed from the user-level API. Use the version-independent functions above.
