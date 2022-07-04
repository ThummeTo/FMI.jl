
# FAQ

This list some common - often numerical - errors, that can be fixed by better understanding the ODE-Problem inside your FMU.

## Solving non-linear system
### Description
Error message or warning, that solving of a non-linear system failed, close to the simulation start time.

### Example
- `Solving non-linear system 101 failed at time=3e-05.`

### Reason
This could be, because the first step of the integration is accepted by the solver's error estimation, but shouldn't. This is usually, if the first step is picked to large by the solver's start step size heuristics.

### Fix
- Try a small start value for the integration with keyword `dt`.