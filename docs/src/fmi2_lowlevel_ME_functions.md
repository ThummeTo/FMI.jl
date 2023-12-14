# FMI for Model Exchange
This chapter contains the interface description to access the equations of a dynamic system from a C
program.

##  Providing Independent Variables and Re-initialization of Caching
Depending on the situation, different variables need to be computed. In order to be efficient, it is important that the interface requires only the computation of variables that are needed in the present context. The state derivatives shall be reused from the previous call. This feature is called “caching of variables” in the sequel. Caching requires that the model evaluation can detect when the input arguments, like time or states, have changed.

```@docs
fmi2SetTime
fmi2SetContinuousStates
```

## Evaluation of Model Equations

```@docs
fmi2EnterEventMode
fmi2NewDiscreteStates
fmi2NewDiscreteStates!
fmi2EnterContinuousTimeMode
fmi2CompletedIntegratorStep
fmi2CompletedIntegratorStep!
fmi2GetDerivatives
fmi2GetDerivatives!
fmi2GetEventIndicators
fmi2GetEventIndicators!
fmi2GetContinuousStates
fmi2GetContinuousStates!
fmi2GetNominalsOfContinuousStates
fmi2GetNominalsOfContinuousStates!
```
