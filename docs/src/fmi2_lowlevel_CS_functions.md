# FMI for Co-Simulation
This chapter defines the Functional Mock-up Interface (FMI) for the coupling of two or more simulation
models in a Co-Simulation environment (FMI for Co-Simulation). Co-Simulation is a rather general
approach to the simulation of coupled technical systems and coupled physical phenomena in
engineering with focus on instationary (time-dependent) problems.


## Transfer of Input / Output Values and Parameters
In order to enable the slave to interpolate the continuous real inputs between communication steps, the
derivatives of the inputs with respect to time can be provided. Also, higher derivatives can be set to allow
higher order interpolation.

```@docs
fmi2GetRealOutputDerivatives
```

## Computation
The computation of time steps is controlled by the following function.

```@docs
fmi2DoStep
fmi2CancelStep
```

## Retrieving Status Information from the Slave
Status information is retrieved from the slave by the following functions:

```@docs
fmi2GetStatus
fmi2GetStatus!
fmi2GetRealStatus!
fmi2GetIntegerStatus!
fmi2GetBooleanStatus!
fmi2GetStringStatus!
```
