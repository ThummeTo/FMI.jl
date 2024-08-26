# FMI for Model Exchange

This chapter contains the interface description to access the equations of a dynamic system from a C
program.

##  Providing Independent Variables and Re-initialization of Caching
Depending on the situation, different variables need to be computed. In order to be efficient, it is important that the interface requires only the computation of variables that are needed in the present context. The state derivatives shall be reused from the previous call. This feature is called “caching of variables” in the sequel. Caching requires that the model evaluation can detect when the input arguments, like time or states, have changed.

```@docs
fmi3SetTime
fmi3SetContinuousStates
fmi3GetEventIndicators
fmi3GetEventIndicators!
```

## Evaluation of Model Equations

```@docs
fmi3EnterEventMode
fmi3EnterContinuousTimeMode
fmi3CompletedIntegratorStep!
fmi3GetContinuousStates
fmi3GetContinuousStates!
fmi3GetNominalsOfContinuousStates!
fmi3GetNumberOfContinuousStates
fmi3GetNumberOfContinuousStates!
```
fmi3CompletedIntegratorStep
