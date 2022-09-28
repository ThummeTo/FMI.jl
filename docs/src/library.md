# Library Functions

## FMI Common Concepts for Model Exchange and Co-Simulation
In both cases, FMI defines an input/output block of a dynamic model where the distribution of the block, the
platform dependent header file, several access functions, as well as the schema files are identical

FMI2 and FMI3 contain different functions for this paragraph, therefore reference to the specific function in the FMIImport documentation.
- [FMI2]()
- [FMI3]() TODo Link

### Reading the model description
This section documents functions to inquire information about the model description of an FMU

- [FMI2]()
- [FMI3]() TODo Link
###  Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with instantiation, destruction and logging of FMUs

- [FMI2]()
- [FMI3]() TODo Link
### Creation, Destruction and Logging of FMU Instances
This section documents functions that deal with initialization, termination, resetting of an FMU.

- [FMI2]()
- [FMI3]() TODo Link
### Initialization, Termination, and Resetting an FMU
This section documents functions that deal with initialization, termination, resetting of an FMU.

- [FMI2]()
- [FMI3]() TODo Link
### Getting and Setting Variable Values
All variable values of an FMU are identified with a variable handle called “value reference”. The handle is
defined in the modelDescription.xml file (as attribute “valueReference” in element
“ScalarVariable”). Element “valueReference” might not be unique for all variables. If two or more
variables of the same base data type (such as fmi2Real) have the same valueReference, then they
have identical values but other parts of the variable definition might be different [(for example, min/max
attributes)].

- [FMI2]()
- [FMI3]() TODo Link
### Getting and Setting the Complete FMU State
The FMU has an internal state consisting of all values that are needed to continue a simulation. This internal state consists especially of the values of the continuous-time states, iteration variables, parameter values, input values, delay buffers, file identifiers, and FMU internal status information. With the functionsof this section, the internal FMU state can be copied and the pointer to this copy is returned to the environment. The FMU state copy can be set as actual FMU state, in order to continue the simulationfrom it.

- [FMI2]()
- [FMI3]() TODo Link

### Getting Partial Dervatives
It is optionally possible to provide evaluation of partial derivatives for an FMU. For Model Exchange, this
means computing the partial derivatives at a particular time instant. For Co-Simulation, this means to
compute the partial derivatives at a particular communication point. One function is provided to compute
directional derivatives. This function can be used to construct the desired partial derivative matrices.


- [FMI2]()
- [FMI3]() TODo Link

## FMI for Model Exchange
This chapter contains the interface description to access the equations of a dynamic system from a C
program.

FMI2 and FMI3 contain different functions for this paragraph, therefore reference to the specific function in the FMIImport documentation.
- [FMI2]()
- [FMI3]() TODo Link
###  Providing Independent Variables and Re-initialization of Caching
Depending on the situation, different variables need to be computed. In order to be efficient, it is important that the interface requires only the computation of variables that are needed in the present context. The state derivatives shall be reused from the previous call. This feature is called “caching of variables” in the sequel. Caching requires that the model evaluation can detect when the input arguments, like time or states, have changed.

- [FMI2]()
- [FMI3]() TODo Link
### Evaluation of Model Equations
This section contains the core functions to evaluate the model equations


- [FMI2]()
- [FMI3]() TODo Link
## FMI for CO-Simulation
This chapter defines the Functional Mock-up Interface (FMI) for the coupling of two or more simulation
models in a co-simulation environment (FMI for Co-Simulation). Co-simulation is a rather general
approach to the simulation of coupled technical systems and coupled physical phenomena in
engineering with focus on instationary (time-dependent) problems.

FMI2 and FMI3 contain different functions for this paragraph, therefore reference to the specific function in the FMIImport documentation.
- [FMI2]()
- [FMI3]() TODo Link
### Transfer of Input / Output Values and Parameters
In order to enable the slave to interpolate the continuous real inputs between communication steps, the
derivatives of the inputs with respect to time can be provided. Also, higher derivatives can be set to allow
higher order interpolation.

- [FMI2]()
- [FMI3]() TODo Link
### Computation
The computation of time steps is controlled by the following function.

- [FMI2]()
- [FMI3]() TODo Link
### Retrieving Status Information from the Slave


- [FMI2]()
- [FMI3]() TODo Link
## Self-developed functions
These new functions, that are useful, but not part of the FMI-spec (example: `fmi2Load`, `fmi2SampleDirectionalDerivative`)


### Opening and closing FMUs
There are a few more function that are different in FMI2 and FMI3.
Therefor follow the links below:
- [FMI2]()
- [FMI3]() TODo Link

```@docs
fmiLoad
fmiUnload
fmiReload
```
### Conversion functions
There are a few more function that are different in FMI2 and FMI3.
Therefor follow the links below:
- [FMI2]()
- [FMI3]() TODo Link

```@docs
fmiStringToValueReference
```

### external/additional functions
FMI2 and FMI3 contain different functions for this paragraph, therefore reference to the specific function in the FMIImport documentation.
- [FMI2]()
- [FMI3]() TODo Link


### Visualize simulation results

```@docs
fmiPlot
```
