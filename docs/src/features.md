
# Features
Please note, that this guide focuses also on users, that are not familiar with FMI. The following feature explanations are written in an easy-to-read-fashion, so there might be some points that are scientifically only 95% correct. For further information on FMI and FMUs, see [fmi-standard.org](http://fmi-standard.org/).

## Execution Configuration
Not all FMUs support all features they should according to the FMI-standard, so *FMI.jl* provides a so called *execution configuration*. 
This configuration is also respected by *FMIFlux.jl*.
The content of the execution configuration may change in future (together with new or deprecated features of linked libraries), but the most important core features will be kept over time.
Because not all users need the full potential of this configuration tool, there are three presets given: 
- `myFMU.executionConfig = FMU2_EXECUTION_CONFIGURATION_NO_RESET` is the default operation mode for FMUs. FMUs are not reset via `fmi2Reset`, but new instantiated for every simulation run (or training step). This is not the most efficient way, but many FMUs have problems with resetting.
- `myFMU.executionConfig = FMU2_EXECUTION_CONFIGURATION_RESET` is faster for well-implemented FMUs, but needs a fully working `fmi2Reset`-function. So if you know you have a fully working `fmi2Reset`, you may be faster with that option.
- `myFMU.executionConfig = FMU2_EXECUTION_CONFIGURATION_NO_FREEING` should only be the very last choice. If your FMU neither supports `fmi2Reset` nor a proper `fmi2FreeInstance`, you could use this configuration as a last way out. Keep in mind, that new FMU instances are allocated but not freed, as long as your Julia instance is running (memory leak). In general, the amount of leaked memory is small, but you need to know what you are doing, if you do thousands or ten-thousands of simulation runs with such a FMU.

## Debugging / Logging
### Logging FMI-calls
To log all FMI-calls that happen (including "hidden" calls e.g. if you are using `fmiSimulate`) you can enable debugging for *FMICore.jl* using `ENV["JULIA_DEBUG"] = "FMICore"`. This will log any `fmi2xxx`-call, including the given parameters and return value.
### Printing internal FMU messages
Many FMUs support for printing debugging messages. To force message printing, you can use the keyword `logginOn=true` either ...
- in the call `fmiInstantiate`, for example `fmiInstantiate(myFMU; loggingOn=true)` or
- as part of the `executionConfig`, for example `myFMU.executionConfig.loggingOn=true`
You can further control which message types - like `OK`, `Warning`, `Discard`, `Error`, `Fatal`, `Pending` - should be logged by using the keywords `logStatus{TYPE}=true` as part of `fmiInstantiate` or (soon) the execution configuration. By default, all are activated.
If the FMU uses a variadic callback function for messages (this is not supported by Julia at this time), you may need to activate external callbacks with the keyword `externalCallbacks=true` either ...
- in the call `fmiInstantiate!`, for example `fmiInstantiate!(myFMU; loggingOn=true, externalCallbacks=true)` or
- as part of the `executionConfig`, for example `myFMU.executionConfig.loggingOn=true; myFMU.executionConfig.externalCallbacks=true`
Note, that external callbacks are currently only supported on Windows.

## Model variable identification
*FMI.jl* offers multiple ways to retrieve your model variables. Any function that accepts a variable identifier can handle the following argument types:
- `UInt32` or `fmi2ValueReference` for example `1610612742` or `0x16000001`: This is the most performant way of passing a variable identifier, but you need to know the *value reference* (you can determine them by having a look in the `modelDescription.xml`).
- `Array{UInt32}` or `Array{fmi2ValueReference}` for example `[1610612742, 1610612743]` or `[0x16000001, 0x16000002]`: This is the most performant way of passing multiple variable identifiers, but you need to know the *value references*.
- `String` for example `"ball.s"`: This is the most intuitive way, because you might already know the variable name from your modelling environment or model documentation.
- `Array{String}` for example `["ball.s", "der(ball.s)"]`: This is the most intuitive way for multiple variable identifiers, because you might already know the variable names from your modelling environment or model documentation.
- `Symbol` for example `:states`: There are multiple symbol-wildcards for interesting variable groups like `:all`, `:none`, `:states`, `:derivatives`, `:inputs` and `:outputs`.
- `nothing`: If you don't want to record anything (same as `:none`)

## Event handling
In FMI2, there are basically two types of events: state and time. 
State events are triggered, as soon as one or more *event indicators* - scalar values that describe the "distance" in state space to the next state event - crossing zero. 
Time events are triggered at known time points during the simulation. 
If your model has state and/or time events is detected automatically by *FMI.jl* and the event handling happens automatically in the background.

## Model exchange (ME) and co-simulation (CS)
There are two different model types for FMUs in FMI2: Model exchange (ME) and co-simulation (CS). 
If you have a FMU and are only interested in getting it simulated, use `fmiSimulate` so *FMI.jl* will automatically pick CS if available and otherwise ME.
If you want to force a specific simulation mode, you can use `fmiSimulateME` (for ME) or `fmiSimulateCS` (for CS).

## Simulate arbitrary time intervals
You can simply simulate arbitrary time intervals by passing a `startTime` unequal zero to `fmi2SetupExperiment`. 
Because many FMUs don't support `startTime != 0.0` and will throw an error or warning, a time shifting feature inside *FMI.jl* performs all necessary steps in the background - all corresponding commands like e.g. `fmi2SetTime` or `fmi2NewDiscreteStates` act like the desired time interval is simulated.
If you don't want this feature (maybe because you are simulating time-dependent systems), you may use the execution configuration `myFMU.executionConfig.autoTimeShift=false` while providing a `startTime != 0.0`.

## Performance
**In- and Out-of-Place:** Many commands in *FMI.jl* are available in in-place and out-of-place semantics. Of course, in-place-calls are faster, because they don't need to allocate new memory at every call (for the return values).
So if you have an eye on performance (or *must* have), a good starting point is to substitute out-of-place- with in-place-calls. Typical improvements are:
- `valueArray = fmi2GetReal(args...)` -> `fmi2GetReal!(args..., valueArray)`
- `valueArray = fmi2GetDerivatives(args...)` -> `fmi2GetDerivatives!(args..., valueArray)`
- `valueArray = fmi2NewDiscreteStates(args...)` -> `fmi2NewDiscreteStates!(args..., valueArray)`
Of course, you have to use the same piece of memory (to write your return values in) for multiple calls - otherwise there will be no improvement because the number of allocations stays the same.

**Views:** You can use [array-views](https://docs.julialang.org/en/v1/base/arrays/#Views-(SubArrays-and-other-view-types)) instead of array-slices as input for in-place-functions, which further reduces memory allocations.

## Watch your progress
When simulating FMUs with *FMI.jl*, a progress meter is shown per default. You can control the appearance via the keyword argument `showProgress` for `fmiSimulate`, `fmiSimulateME` and `fmiSimulateCS`. 
Progress meters are also available for *FMIFlux.jl*, but deactivated by default (during training, this can be a bit too much). When evaluating a NeuralFMU, you can use the same keyword with `showProgress=true` to show a progress bar during training, too.
The simulation trajectory (also called the *solution* of your FMU's ODE system) can be plotted using `fmiPlot(myFMU, solution)`, all axis will be labeled automatically.

## Parallelization
A native integrated support for multi-threaded and multi-process FMU-simulation will be deployed soon. 