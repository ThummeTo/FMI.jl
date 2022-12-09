#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""

fmiInstantiate!(fmu::FMU2; pushComponents::Bool = true, visible::Bool = false, loggingOn::Bool = false, externalCallbacks::Bool = false,
                      logStatusOK::Bool=true, logStatusWarning::Bool=true, logStatusDiscard::Bool=true, logStatusError::Bool=true, logStatusFatal::Bool=true, logStatusPending::Bool=true)

Creates a new instance of the FMU, version independent.

Create a new instance of the given fmu, adds a logger if logginOn == true.

# Arguments
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.

# Keywords
- `pushComponents::Bool = true`:  `pushComponents` if the item `component` should be inserted in `fmu.components`(default = `true`).
- `visible::Bool = false`: `visible` if the FMU should be started with graphic interface, if supported (default=`false`)
- `loggingOn::Bool = false`: `loggingOn` if the FMU should log and display function calls (default=`false`)
- `externalCallbacks::Bool = false`: `externalCallbacks` if an external DLL should be used for the fmi2CallbackFunctions, this may improve readability of logging messages (default=`false`)
- `logStatusOK::Bool=true`: `logStatusOK` whether to log status of kind `fmi2OK` (default=`true`)
- `logStatusWarning::Bool=true`: `logStatusWarning` whether to log status of kind `fmi2Warning` (default=`true`)
- `logStatusDiscard::Bool=true`: `logStatusDiscard` whether to log status of kind `fmi2Discard` (default=`true`)
- `logStatusError::Bool=true`: `logStatusError` whether to log status of kind `fmi2Error` (default=`true`)
- `logStatusFatal::Bool=true`: `logStatusFatal` whether to log status of kind `fmi2Fatal` (default=`true`)
- `logStatusPending::Bool=true`: `logStatusPending` whether to log status of kind `fmi2Pending` (default=`true`)

# Returns
- `nothing`: if the instantiation failed. In addition, an error message appears.
- `component`: Returns the instance of a new FMU component.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

See also [`fmi2Instantiate!`](@ref), [`fmi2Instantiate`](@ref), [`FMU2`](@ref).
"""
function fmiInstantiate!(fmu::FMU2, args...; kwargs...)
    fmi2Instantiate!(fmu, args...; kwargs...)
end
export fmiInstantiate!

"""

   fmiFreeInstance!(str::fmi2Struct)

Frees the allocated memory of the last instance of the FMU.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [fmi2FreeInstance](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiFreeInstance!(str::fmi2Struct)
    fmi2FreeInstance!(str)
end
export fmiFreeInstance!

"""
    fmiSetDebugLogging(str::fmi2Struct)

Control the use of the logging callback function, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
 - `fmi2OK`: all well
 - `fmi2Warning`: things are not quite right, but the computation can continue
 - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
 - `fmi2Error`: the communication step could not be carried out at all
 - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
 - `fmi2Pending`: this status is returned if the slave executes the function asynchronously


# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.22]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances
See also [`fmi2SetDebugLogging`](@ref).
"""
function fmiSetDebugLogging(str::fmi2Struct)
    fmi2SetDebugLogging(str)
end
export fmiSetDebugLogging

"""

    fmiSetupExperiment(str::fmi2Struct, c::FMU2Component, startTime::Union{Real, Nothing} = nothing, stopTime::Union{Real, Nothing} = nothing; tolerance::Union{Real, Nothing} = nothing)

Initialize the Simulation boundries

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `startTime::Union{Real, Nothing} = nothing`: `startTime` is a real number which sets the value of starting time of the experiment. The default value is set automatically if doing nothing (default = `nothing`).
- `stopTime::Union{Real, Nothing} = nothing`: `stopTime` is a real number which sets the value of ending time of the experiment. The default value is set automatically if doing nothing (default = `nothing`).

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: `tolerance` is a real number which sets the value of tolerance range. The default value is set automatically if doing nothing (default = `nothing`).

# Returns
- Returns a warning if `str.state` is not called in `fmi2ComponentStateInstantiated`.
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [fmi2SetupExperiment](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetupExperiment(str::fmi2Struct, args...; kwargs...)
    fmi2SetupExperiment(str, args...; kwargs...)
end
export fmiSetupExperiment

"""

    fmiEnterInitializationMode(str::fmi2Struct)

Informs the FMU to enter initializaton mode, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
-  Returns a warning if `str.state` is not called in `fmi2ComponentStateInstantiated`.
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [fmi2EnterInitializationMode](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiEnterInitializationMode(str::fmi2Struct)
    fmi2EnterInitializationMode(str)
end
export fmiEnterInitializationMode

"""

    fmiExitInitializationMode(str::fmi2Struct)

Informs the FMU to exit initialization mode, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- Returns a warning if `str.state` is not called in `fmi2ComponentStateInitializationMode`.
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [`fmi2ExitInitializationMode`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiExitInitializationMode(str::fmi2Struct)
    fmi2ExitInitializationMode(str)
end
export fmiExitInitializationMode

"""

    fmiTerminate(str::fmi2Struct)

Informs the FMU that the simulation run is terminated, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- Returns a warning if `str.state` is not called in `fmi2ComponentStateContinuousTimeMode` or `fmi2ComponentStateEventMode`.
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [`fmi2ExitInitializationMode`](@ref), [`fmi2Status`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).


"""
function fmiTerminate(str::fmi2Struct)
    fmi2Terminate(str)
end
export fmiTerminate

"""

    fmiReset(str::fmi2Struct)

Resets the FMU after a simulation run, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- Returns a warning if `str.state` is not called in `fmi2ComponentStateTerminated` or `fmi2ComponentStateError`.
- Returns an error if the reinstantiation failed.
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [`fmi2Reset`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiReset(str::fmi2Struct)
    fmi2Reset(str)
end
export fmiReset

"""

   fmi2GetRealOutputDerivatives(c::FMU2Component, vr::fmi2ValueReferenceFormat, order::AbstractArray{fmi2Integer})


Sets the n-th time derivative of real input variables.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variables whose derivatives shall be set.
- `order::Array{fmi2Integer}`: Argument `order` is an array of fmi2Integer values witch specifys the corresponding order of derivative of the real input variable.
-

# Returns
- `value::AbstactArray{fmi2Integer}`: Return `value` is an array which represents a vector with the values of the derivatives.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

See also [`fmi2SetRealInputDerivatives!`](@ref).
"""

function fmiGetRealOutputDerivatives(str::fmi2Struct, args...; kwargs...)
    fmi2GetRealOutputDerivatives(str, args...; kwargs...)
end
export fmiGetRealOutputDerivatives

"""

    fmiGetReal!(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Real})

    fmiGetReal!(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Real})

Writes the real values of an array of variables in the given field

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Wildcards for how a user can pass a fmi[X]ValueReference
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Array{fm2Real}`: Argument `values` is an array with the actual values of these variables.
# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [`fmi2GetReal!`](@ref), [`fmi2GetReal`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetReal!(str::fmi2Struct, args...; kwargs...)
    fmi2GetReal!(str, args...; kwargs...)
end
export fmiGetReal!

"""

    fmiSetReal(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})

    fmiSetReal(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Real})

Set the values of an array of real variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Wildcards for how a user can pass a fmi[X]ValueReference
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{<:Real}, <:Real}`: Argument `values` is an array with the actual values of these variables.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [`fmi2SetReal`](@ref), [`fmi2GetReal`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ValueReference`](@ref).
"""
function fmiSetReal(str::fmi2Struct, args...; kwargs...)
    fmi2SetReal(str, args...; kwargs...)
end
export fmiSetReal

"""
#Todo: Add types according spec

    fmiSetRealInputDerivatives(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, order, values)

    fmiSetRealInputDerivatives(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, order::Array{fmi2Integer}, value::Array{fmi2Real})

Sets the n-th time derivative of real input variables.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `order::Array{fmi2Integer}`: Argument `order` is an array of fmi2Integer values witch specifys the corresponding order of derivative of the real input variable.
- `values::Array{fmi2Real}`: Argument `values` is an array with the actual values of these variables.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

See also [`fmi2SetRealInputDerivatives`](@ref), [`fmi2GetReal`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ValueReference`](@ref).
"""
function fmiSetRealInputDerivatives(str::fmi2Struct, args...; kwargs...)
    fmi2SetRealInputDerivatives(str, args...; kwargs...)
end
export fmiSetRealInputDerivatives

"""

    fmiGetInteger(str::fmi2Struct,c::FMU2Component, vr::fmi2ValueReferenceFormat)

Returns the integer values of an array of variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `values::Array{fmi2Integer}`: Return `values` is an array with the actual values of these variables.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [`fmi2GetInteger`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiGetInteger(str::fmi2Struct,args...; kwargs...)
    fmi2GetInteger(str, args...; kwargs...)
end
export fmiGetInteger

"""

    function fmiGetInteger!(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Integer})

    function fmiGetInteger!(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Integer})

Writes the integer values of an array of variables in the given field

fmi2GetInteger! is only possible for arrays of values, please use an array instead of a scalar.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Array{fmi2Integer}`: Argument `values` is an array with the actual values of these variables.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [`fmi2GetInteger!`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiGetInteger!(str::fmi2Struct, args...; kwargs...)
    fmi2GetInteger!(str, args...; kwargs...)
end
export fmiGetInteger!

"""

    fmiSetInteger(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})

    fmiSetInteger(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Integer})

Set the values of an array of integer variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{<:Integer}, <:Integer}`: Argument `values` is an array or a single value with type Integer or any subtyp
- `value::Array{fmi2Integer}`: Argument `values` is an array with the actual values of these variables.
# Returns
- `status::fmi2Status`: Return `status` indicates the success of the function call.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [`fmi2SetInteger`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetInteger(str::fmi2Struct, args...; kwargs...)
    fmi2SetInteger(str, args...; kwargs...)
end
export fmiSetInteger

"""

    fmiGetBoolean(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat)

Returns the boolean values of an array of variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `values::Array{fmi2Boolean}`: Return `values` is an array with the actual values of these variables.
See also [`fmi2GetBoolean`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetBoolean(str::fmi2Struct, args...; kwargs...)
    fmi2GetBoolean(str, args...; kwargs...)
end
export fmiGetBoolean

"""

    fmiGetBoolean!(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Boolean})

Writes the boolean values of an array of variables in the given field

fmi2GetBoolean! is only possible for arrays of values, please use an array instead of a scalar.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Argument `vr` is an array of `nvr` value handels called "ValueReference" that define the variable that shall be inquired.
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{<:Integer}, <:Integer}`: Argument `values` is an array or a single value with type Integer or any subtyp
- `value::Array{fmi2Integer}`: Argument `values` is an array with the actual values of these variables.
# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
See also [`fmi2GetBoolean!`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetBoolean!(str::fmi2Struct, args...; kwargs...)
    fmi2GetBoolean!(str, args...; kwargs...)
end
export fmiGetBoolean!

"""

    fmiSetBoolean(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Boolean})

    fmiSetBoolean(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})

Set the values of an array of boolean variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Array of the FMI2 Data Typ `fmi2ValueReference`
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{Bool}, Bool}`: Argument `values` is an array or a single value with type Boolean or any subtyp
- `value::Array{fmi2Boolean}`: Argument `values` is an array with the actual values of these variables.
# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
See also [`fmi2GetBoolean`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetBoolean(str::fmi2Struct, args...; kwargs...)
    fmi2SetBoolean(str, args...; kwargs...)
end
export fmiSetBoolean

"""

    fmiGetString(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat)

Returns the string values of an array of variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `values::Array{fmi2String}`:  Return `values` is an array with the actual values of these variables.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
See also [`fmi2GetBoolean!`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiGetString(str::fmi2Struct, args...; kwargs...)
    fmi2GetString(str, args...; kwargs...)
end
export fmiGetString

"""

    fmiGetString!(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2String})

    fmiGetString!(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Vector{Ptr{Cchar}})

Writes the string values of an array of variables in the given field

These functions are especially used to get the actual values of output variables if a model is connected with other
models.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Array of the FMI2 Data Typ `fmi2ValueReference`
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{Bool}, Bool}`: Argument `values` is an array or a single value with type Boolean or any subtyp.
- `value::Vector{Ptr{Cchar}}`: Argument `values` is an vector with the actual values of these variables.
# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
See also [`fmi2GetString!`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetString!(str::fmi2Struct, args...; kwargs...)
    fmi2GetString!(str, args...; kwargs...)
end
export fmiGetString!

"""

    fmiSetString(str::fmi2Struct, c::FMU2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})

    fmiSetString(str::fmi2Struct, c::FMU2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Union{Array{Ptr{Cchar}}, Array{Ptr{UInt8}}})

Set the values of an array of string variables

For the exact rules on which type of variables fmi2SetXXX
can be called see FMISpec2.0.2 section 2.2.7 , as well as FMISpec2.0.2 section 3.2.3 in case of ModelExchange and FMISpec2.0.2 section 4.2.4 in case of
CoSimulation.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: Argument `vr` defines the value references of the variables.
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`
- `vr::Array{fmi2ValueReference}`: Array of the FMI2 Data Typ `fmi2ValueReference`
- `nvr::Csize_t`: Argument `nvr` defines the size of `vr`.
- `values::Union{Array{String}, String}`: Argument `values` is an array or a single value with type String.
- `value::Vector{Ptr{Cchar}}`: Argument `values` is an vector with the actual values of these variables.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.46]: 2.2.7 Definition of Model Variables
- FMISpec2.0.2[p.46]: 3.2.3 State Machine of Calling Sequence
- FMISpec2.0.2[p.108]: 4.2.4 State Machine of Calling Sequence from Master to Slave
See also [`fmi2SetString`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetString(str::fmi2Struct, args...; kwargs...)
    fmi2SetString(str, args...; kwargs...)
end
export fmiSetString

"""

    fmiSerializedFMUstateSize(str::fmi2Struct, c::FMU2Component, state::fmi2FMUstate)


Returns the size of the byte vector in which the FMUstate can be stored.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `state::fmi2FMUstate`: Argument `state` is a pointer to a data structure in the FMU that saves the internal FMU state of the actual or a previous time instant.

# Returns
- Return `size` is an object that safely references a value of type `Csize_t`.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2SerializedFMUstateSize`](@ref),[`fmi2FMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiSerializedFMUstateSize(str::fmi2Struct, args...; kwargs...)
    fmi2SerializedFMUstateSize(str, args...; kwargs...)
end
export fmiSerializedFMUstateSize

"""

    fmiSerializeFMUstate(str::fmi2Struct, c::FMU2Component, state::fmi2FMUstate)

Serializes the data referenced by the pointer FMUstate and copies this data into the byte vector serializedState of length size to be provided by the environment.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `state::fmi2FMUstate`: Argument `state` is a pointer to a data structure in the FMU that saves the internal FMU state of the actual or a previous time instant.

# Returns
- `serialized:: Array{fmi2Byte}`: Return `serializedState` contains the copy of the serialized data referenced by the pointer FMUstate

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2SerializeFMUstate`](@ref),[`fmi2FMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSerializeFMUstate(str::fmi2Struct, args...; kwargs...)
    fmi2SerializeFMUstate(str, args...; kwargs...)
end
export fmiSerializeFMUstate

"""
TODO
    fmiDeSerializeFMUstate(str::fmi2Struct, c::FMU2Component, serializedState::Array{fmi2Byte})

Deserialize the data in the serializedState fmi2Byte field

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `serializedState::Array{fmi2Byte}`: Argument `serializedState` contains the fmi2Byte field to be deserialized.

# Returns
- Return `state` is a pointer to a copy of the internal FMU state.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2DeSerializeFMUstate`](@ref),[`fmi2FMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiDeSerializeFMUstate(str::fmi2Struct, args...; kwargs...)
    fmi2DeSerializeFMUstate(str, args...; kwargs...)
end
export fmiDeSerializeFMUstate

"""

    fmiGetDirectionalDerivative(str::fmi2Struct, c::FMU2Component,
                                      vUnknown_ref::AbstractArray{fmi2ValueReference},
                                      vKnown_ref::AbstractArray{fmi2ValueReference},
                                      dvKnown::Union{AbstractArray{fmi2Real}, Nothing} = nothing)

    fmi2GetDirectionalDerivative(str::fmi2Struct, c::FMU2Component,
                                        vUnknown_ref::fmi2ValueReference,
                                        vKnown_ref::fmi2ValueReference,
                                        dvKnown::fmi2Real = 1.0)

The Wrapper Function and the Direct function call to compute the partial derivative with respect to `vKnown_ref`.

Computes the directional derivatives of an FMU. An FMU has different Modes and in every Mode an FMU might be described by different equations and different unknowns.The precise definitions are given in the mathematical descriptions of Model Exchange (section 3.1) and Co-Simulation (section 4.1). In every Mode, the general form of the FMU equations are:
𝐯_unknown = 𝐡(𝐯_known, 𝐯_rest)

- `v_unknown`: vector of unknown Real variables computed in the actual Mode:
    - Initialization Mode: unkowns kisted under `<ModelStructure><InitialUnknowns>` that have type Real.
    - Continuous-Time Mode (ModelExchange): The continuous-time outputs and state derivatives. (= the variables listed under `<ModelStructure><Outputs>` with type Real and variability = `continuous` and the variables listed as state derivatives under `<ModelStructure><Derivatives>)`.
    - Event Mode (ModelExchange): The same variables as in the Continuous-Time Mode and additionally variables under `<ModelStructure><Outputs>` with type Real and variability = `discrete`.
    - Step Mode (CoSimulation):  The variables listed under `<ModelStructure><Outputs>` with type Real and variability = `continuous` or `discrete`. If `<ModelStructure><Derivatives>` is present, also the variables listed here as state derivatives.
- `v_known`: Real input variables of function h that changes its value in the actual Mode.
- `v_rest`:Set of input variables of function h that either changes its value in the actual Mode but are non-Real variables, or do not change their values in this Mode, but change their values in other Modes

Computes a linear combination of the partial derivatives of h with respect to the selected input variables 𝐯_known:

    Δv_unknown = (δh / δv_known) Δv_known

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vUnknown_ref::AbstractArray{fmi2ValueReference}`: Argument `vUnknown_ref` contains values of type`fmi2ValueReference` which are identifiers of a variable value of the model. `vUnknown_ref` can be equated with `v_unknown`(variable described above).
 - `vUnknown_ref::fmi2ValueReference`: Argument `vUnknown_ref` contains a value of type`fmi2ValueReference` which is an identifier of a variable value of the model. `vUnknown_ref` can be equated with `v_unknown`(variable described above).
- `vKnown_ref::AbstractArray{fmi2ValueReference}`: Argument `vKnown_ref` contains values of type `fmi2ValueReference` which are identifiers of a variable value of the model.`vKnown_ref` can be equated with `v_known`(variable described above).
- `vKnown_ref::fmi2ValueReference`: Argument `vKnown_ref` contains a value of type`fmi2ValueReference` which is an identifier of a variable value of the model. `vKnown_ref` can be equated with `v_known`(variable described above).
- `dvKnown::Union{AbstractArray{fmi2Real}, Nothing} = nothing`: If no seed vector is passed the value `nothing` is used. The vector values Compute the partial derivative with respect to the given entries in vector `vKnown_ref` with the matching evaluate of `dvKnown`.
- `dvKnown::Fmi2Real = 1.0`: If no seed value is passed the value `dvKnown = 1.0` is used. Compute the partial derivative with respect to `vKnown_ref` with the value `dvKnown = 1.0`.  # gehört das zu den v_rest values

# Returns
- `dvUnknown::Array{fmi2Real}`: Return `dvUnknown` contains the directional derivative vector values.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.25]: 2.1.9 Getting Partial Derivatives
See also [`fmi2GetDirectionalDerivative`](@ref),[`fmi2FMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetDirectionalDerivative(str::fmi2Struct, args...; kwargs...)
    fmi2GetDirectionalDerivative(str, args...; kwargs...)
end
export fmiGetDirectionalDerivative

"""
TODO -> Arguments
    fmiGetDirectionalDerivative!(str::fmi2Struct, c::FMU2Component,
                                      vUnknown_ref::AbstractArray{fmi2ValueReference},
                                      vKnown_ref::AbstractArray{fmi2ValueReference},
                                      dvUnknown::AbstractArray,
                                      dvKnown::Union{Array{fmi2Real}, Nothing} = nothing)

    fmiGetDirectionalDerivative!(str::fmi2Struct, c::FMU2Component,
                                       vUnknown_ref::AbstractArray{fmi2ValueReference},
                                       nUnknown::Csize_t,
                                       vKnown_ref::AbstractArray{fmi2ValueReference},
                                       nKnown::Csize_t,
                                       dvKnown::AbstractArray{fmi2Real},
                                       dvUnknown::AbstractArray)


Wrapper Function call to compute the partial derivative with respect to the variables `vKnown_ref`.

Computes the directional derivatives of an FMU. An FMU has different Modes and in every Mode an FMU might be described by different equations and different unknowns.The precise definitions are given in the mathematical descriptions of Model Exchange (section 3.1) and Co-Simulation (section 4.1). In every Mode, the general form of the FMU equations are:
𝐯_unknown = 𝐡(𝐯_known, 𝐯_rest)

- `v_unknown`: vector of unknown Real variables computed in the actual Mode:
   - Initialization Mode: unkowns kisted under `<ModelStructure><InitialUnknowns>` that have type Real.
   - Continuous-Time Mode (ModelExchange): The continuous-time outputs and state derivatives. (= the variables listed under `<ModelStructure><Outputs>` with type Real and variability = `continuous` and the variables listed as state derivatives under `<ModelStructure><Derivatives>)`.
   - Event Mode (ModelExchange): The same variables as in the Continuous-Time Mode and additionally variables under `<ModelStructure><Outputs>` with type Real and variability = `discrete`.
   - Step Mode (CoSimulation):  The variables listed under `<ModelStructure><Outputs>` with type Real and variability = `continuous` or `discrete`. If `<ModelStructure><Derivatives>` is present, also the variables listed here as state derivatives.
- `v_known`: Real input variables of function h that changes its value in the actual Mode.
- `v_rest`:Set of input variables of function h that either changes its value in the actual Mode but are non-Real variables, or do not change their values in this Mode, but change their values in other Modes

Computes a linear combination of the partial derivatives of h with respect to the selected input variables 𝐯_known:

   Δv_unknown = (δh / δv_known) Δv_known

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vUnknown_ref::AbstracArray{fmi2ValueReference}`: Argument `vUnknown_ref` contains values of type`fmi2ValueReference` which are identifiers of a variable value of the model. `vUnknown_ref` can be equated with `v_unknown`(variable described above).
- `vKnown_ref::AbstractArray{fmi2ValueReference}`: Argument `vKnown_ref` contains values of type `fmi2ValueReference` which are identifiers of a variable value of the model.`vKnown_ref` can be equated with `v_known`(variable described above).
- `dvUnknown::AbstractArray`: Stores the directional derivative vector values.
- `dvKnown::Union{Array{fmi2Real}, Nothing} = nothing`: If no seed vector is passed the value `nothing` is used. The vector values Compute the partial derivative with respect to the given entries in vector `vKnown_ref` with the matching evaluate of `dvKnown`.
- `dvKnown::AbstractArray{fmi2Real}`:The vector values Compute the partial derivative with respect to the given entries in vector `vKnown_ref` with the matching evaluate of `dvKnown`.
- `nUnknown::Csize_t`:
- `nKnown::Csize_t`:

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.25]: 2.1.9 Getting Partial Derivatives
See also [`fmi2GetDirectionalDerivative`](@ref).
"""
function fmiGetDirectionalDerivative!(str::fmi2Struct, args...; kwargs...)
    fmi2GetDirectionalDerivative!(str, args...; kwargs...)
end
export fmiGetDirectionalDerivative!

"""

    fmiDoStep(str::fmi2Struct, c::FMU2Component, communicationStepSize::Union{Real, Nothing} = nothing; currentCommunicationPoint::Union{Real, Nothing} = nothing, noSetFMUStatePriorToCurrentPoint::Bool = true)

    fmiDoStep(str::fmi2Struct, c::FMU2Component, currentCommunicationPoint::fmi2Real, communicationStepSize::fmi2Real, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)

Does one step in the CoSimulation FMU

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `communicationStepSize::Union{Real, Nothing} = nothing`: Argument `communicationStepSize` contains a value of type `Real` or `Nothing` , if no argument is passed the default value `nothing` is used. `communicationStepSize` defines the communiction step size.
- `currentCommunicationPoint::fmi2Real`: Argument `currentCommunicationPoint` contains a value of type `fmi2Real` which is a identifier for a variable value . `currentCommunicationPoint` defines the current communication point of the master.
- `communicationStepSize::fmi2Real`: Argument `communicationStepSize` contains a value of type `fmi2Real` which is a identifier for a variable value. `communicationStepSize` defines the communiction step size.
- `noSetFMUStatePriorToCurrentPoint::fmi2Boolean`: Argument `noSetFMUStatePriorToCurrentPoint` contains a value of type `fmi2Boolean` which is a identifier for a variable value. `noSetFMUStatePriorToCurrentPoint` indicates whether `fmi2SetFMUState`will no longer be called for time instants prior to `currentCommunicationPoint` in this simulation run.

# Keywords
- `currentCommunicationPoint::Union{Real, Nothing} = nothing`: Argument `currentCommunicationPoint` contains a value of type `Real` or type `Nothing`. If no argument is passed the default value `nothing` is used. `currentCommunicationPoint` defines the current communication point of the master.
- `noSetFMUStatePriorToCurrentPoint::Bool = true`: Argument `noSetFMUStatePriorToCurrentPoint` contains a value of type `Boolean`. If no argument is passed the default value `true` is used. `noSetFMUStatePriorToCurrentPoint` indicates whether `fmi2SetFMUState` is no longer called for times before the `currentCommunicationPoint` in this simulation run Simulation run.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.104]: 4.2.2 Computation
See also [`fmi2DoStep`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiDoStep(str::fmi2Struct, args...; kwargs...)
    fmi2DoStep(str, args...; kwargs...)
end
export fmiDoStep

"""

    fmiSetTime(c::fmi2Struct, c::FMU2Component, time::fmi2Real)

    fmiSetTime(c::fmi2Struct, c::FMU2Component, t::Real)

Set a new time instant and re-initialize caching of variables that depend on time.

# Arguments
- `c::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `c::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `c::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `time::fmi2Real`: Argument `time` contains a value of type `fmi2Real` which is a alias type for `Real` data type. `time` sets the independent variable time t.
- `t::Real`: Argument `t` contains a value of type `Real`. `t` sets the independent variable time t.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching
See also [`fmi2SetTime`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ValueReference`](@ref).
"""
function fmiSetTime(c::fmi2Struct, args...; kwargs...)
    fmi2SetTime(c, args...; kwargs...)
end
export fmiSetTime

"""

    fmiSetContinuousStates(str::fmi2Struct, c::FMU2Component,
                                 x::AbstractArray{fmi2Real},
                                 nx::Csize_t)

    fmiSetContinuousStates(str::fmi2Struct, c::FMU2Component,
                                 x::Union{AbstractArray{Float32},AbstractArray{Float64}})

Set a new (continuous) state vector

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `x::AbstractArray{fmi2Real}`: Argument `x` contains values of type `fmi2Real` which is a alias type for `Real` data type.`x` is the `AbstractArray` of the vector values of `Real` input variables of function h that changes its value in the actual Mode.
- `x::Union{AbstractArray{Float32},AbstractArray{Float64}}`:
- `nx::Csize_t`: Argument `nx` defines the length of vector `x` and is provided for checking purposes

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching
See also [`fmi2SetContinuousStates`](@ref).
"""
function fmiSetContinuousStates(str::fmi2Struct, args...; kwargs...)
    fmi2SetContinuousStates(str, args...; kwargs...)
end
export fmiSetContinuousStates

"""

    fmi2EnterEventMode(str::fmi2Struct)

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2EnterEventMode`](@ref).
"""
function fmi2EnterEventMode(str::fmi2Struct)
    fmi2EnterEventMode(str)
end
export fmi2EnterEventMode

"""

    fmiNewDiscreteStates(str::fmi2Struct)

Returns the next discrete states

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `eventInfo::fmi2EventInfo*`: Strut with `fmi2Boolean` Variables
More detailed:
  - `newDiscreteStatesNeeded::fmi2Boolean`: If `newDiscreteStatesNeeded = fmi2True` the FMU should stay in Event Mode, and the FMU requires to set new inputs to the FMU to compute and get the outputs and to call
fmi2NewDiscreteStates again. If all FMUs return `newDiscreteStatesNeeded = fmi2False` call fmi2EnterContinuousTimeMode.
  - `terminateSimulation::fmi2Boolean`: If `terminateSimulation = fmi2True` call `fmi2Terminate`
  - `nominalsOfContinuousStatesChanged::fmi2Boolean`: If `nominalsOfContinuousStatesChanged = fmi2True` then the nominal values of the states have changed due to the function call and can be inquired with `fmi2GetNominalsOfContinuousStates`.
  - `valuesOfContinuousStatesChanged::fmi2Boolean`: If `valuesOfContinuousStatesChanged = fmi2True`, then at least one element of the continuous state vector has changed its value due to the function call. The new values of the states can be retrieved with `fmi2GetContinuousStates`. If no element of the continuous state vector has changed its value, `valuesOfContinuousStatesChanged` must return fmi2False.
  - `nextEventTimeDefined::fmi2Boolean`: If `nextEventTimeDefined = fmi2True`, then the simulation shall integrate at most until `time = nextEventTime`, and shall call `fmi2EnterEventMode` at this time instant. If integration is stopped before nextEventTime, the definition of `nextEventTime` becomes obsolete.
  - `nextEventTime::fmi2Real`: next event if `nextEventTimeDefined=fmi2True`
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2NewDiscreteStates`](@ref).
"""
function fmiNewDiscreteStates(str::fmi2Struct)
    fmi2NewDiscreteStates(str)
end
export fmiNewDiscreteStates

"""

    fmiEnterContinuousTimeMode(str::fmi2Struct)

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode  into Continuous-Time Mode.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2EnterContinuousTimeMode`](@ref).
"""
function fmiEnterContinuousTimeMode(str::fmi2Struct)
    fmi2EnterContinuousTimeMode(str)
end
export fmiEnterContinuousTimeMode

"""

    fmiCompletedIntegratorStep(str::fmi2Struct, c::FMU2Component, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)

This function must be called by the environment after every completed step

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `noSetFMUStatePriorToCurrentPoint::fmi2Boolean`: Argument `noSetFMUStatePriorToCurrentPoint = fmi2True` if `fmi2SetFMUState`  will no longer be called for time instants prior to current time in this simulation run.

# Returns
- `status::fmi2Status`: Return `status` is an enumeration of type `fmi2Status` and indicates the success of the function call.
More detailed:
  - `fmi2OK`: all well
  - `fmi2Warning`: things are not quite right, but the computation can continue
  - `fmi2Discard`: if the slave computed successfully only a subinterval of the communication step
  - `fmi2Error`: the communication step could not be carried out at all
  - `fmi2Fatal`: if an error occurred which corrupted the FMU irreparably
  - `fmi2Pending`: this status is returned if the slave executes the function asynchronously
- `enterEventMode::Array{fmi2Boolean, 1}`: Returns `enterEventMode[1]` to signal to the environment if the FMU shall call `fmi2EnterEventMode`
- `terminateSimulation::Array{fmi2Boolean, 1}`: Returns `terminateSimulation[1]` to signal if the simulation shall be terminated.
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2CompletedIntegratorStep`](@ref), [`fmi2SetFMUState`](@ref).
"""
function fmiCompletedIntegratorStep(str::fmi2Struct, args...; kwargs...)
    fmi2CompletedIntegratorStep(str, args...; kwargs...)
end
export fmiCompletedIntegratorStep

"""

    fmiGetDerivatives(str::fmi2Struct)

Compute state derivatives at the current time instant and for the current states.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `derivatives::Array{fmi2Real}`: Returns an array of `fmi2Real` values representing the `derivatives` for the current states. The ordering of the elements of the derivatives vector is identical to the ordering of the state
vector.
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2GetDerivatives`](@ref).
"""

function fmiGetDerivatives(str::fmi2Struct)
    fmi2GetDerivatives(str)
end
export fmiGetDerivatives

"""

    fmiGetEventIndicators(str::fmi2Struct)

Returns the event indicators of the FMU
# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `eventIndicators::Array{fmi2Real}`:The event indicators are returned as a vector represented by an array of "fmi2Real" values.
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2GetEventIndicators`](@ref).
"""
function fmiGetEventIndicators(str::fmi2Struct)
    fmi2GetEventIndicators(str)
end
export fmiGetEventIndicators

"""

    fmiGetContinuousStates(s::fmi2Struct)

Return the new (continuous) state vector x
# Arguments
- `s::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `s::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `s::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
# Returns
- `x::Array{fmi2Real}`: Returns an array of `fmi2Real` values representing the new continuous state vector `x`.
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2GetEventIndicators`](@ref).

"""
function fmiGetContinuousStates(s::fmi2Struct)
    fmi2GetContinuousStates(s)
end
export fmiGetContinuousStates

"""

    fmiGetNominalsOfContinuousStates(s::fmi2Struct)

Return the new (continuous) state vector x

# Arguments
- `s::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `s::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `s::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
# Returns
- `x::Array{fmi2Real}`: Returns an array of `fmi2Real` values representing the new continuous state vector `x`.
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.16]: 2.1.3 Status Returned by Functions
- FMISpec2.0.2[p.83]: 3.2.2 Evaluation of Model Equations
See also [`fmi2GetNominalsOfContinuousStates`](@ref).
"""
function fmiGetNominalsOfContinuousStates(s::fmi2Struct)
    fmi2GetNominalsOfContinuousStates(s)
end
export fmiGetNominalsOfContinuousStates

##### function setters

function fmiSetFctGetTypesPlatform(fmu::FMU2, fun)
    fmi2SetFctGetTypesPlatform(fmu, fun)
end

function fmiSetFctGetVersion(fmu::FMU2, fun)
    fmi2SetFctGetVersion(fmu, fun)
end

function fmiSetFctInstantiate(fmu::FMU2, fun)
    fmi2SetFctInstantiate(fmu, fun)
end

function fmiSetFctFreeInstance(fmu::FMU2, fun)
    fmi2SetFctFreeInstance(fmu, fun)
end

function fmiSetFctSetDebugLogging(fmu::FMU2, fun)
    fmi2SetFctSetDebugLogging(fmu, fun)
end

function fmiSetFctSetupExperiment(fmu::FMU2, fun)
    fmi2SetFctSetupExperiment(fmu, fun)
end

function fmiSetEnterInitializationMode(fmu::FMU2, fun)
    fmi2SetEnterInitializationMode(fmu, fun)
end

function fmiSetFctExitInitializationMode(fmu::FMU2, fun)
    fmi2SetFctExitInitializationMode(fmu, fun)
end

function fmiSetFctTerminate(fmu::FMU2, fun)
    fmi2SetFctTerminate(fmu, fun)
end

function fmiSetFctReset(fmu::FMU2, fun)
    fmi2SetFctReset(fmu, fun)
end

function fmiSetFctGetReal(fmu::FMU2, fun)
    fmi2SetFctGetReal(fmu, fun)
end

function fmiSetFctGetInteger(fmu::FMU2, fun)
    fmi2SetFctGetInteger(fmu, fun)
end

function fmiSetFctGetBoolean(fmu::FMU2, fun)
    fmi2SetFctGetBoolean(fmu, fun)
end

function fmiSetFctGetString(fmu::FMU2, fun)
    fmi2SetFctGetString(fmu, fun)
end

function fmiSetFctSetReal(fmu::FMU2, fun)
    fmi2SetFctSetReal(fmu, fun)
end

function fmiSetFctSetInteger(fmu::FMU2, fun)
    fmi2SetFctSetInteger(fmu, fun)
end

function fmiSetFctSetBoolean(fmu::FMU2, fun)
    fmi2SetFctSetBoolean(fmu, fun)
end

function fmiSetFctSetString(fmu::FMU2, fun)
    fmi2SetFctSetString(fmu, fun)
end

function fmiSetFctSetTime(fmu::FMU2, fun)
    fmi2SetFctSetTime(fmu, fun)
end

function fmiSetFctSetContinuousStates(fmu::FMU2, fun)
    fmi2SetFctSetContinuousStates(fmu, fun)
end

function fmiSetFctEnterEventMode(fmu::FMU2, fun)
    fmi2SetFctEnterEventMode(fmu, fun)
end

function fmiSetFctNewDiscreteStates(fmu::FMU2, fun)
    fmi2SetFctNewDiscreteStates(fmu, fun)
end

function fmiSetFctEnterContinuousTimeMode(fmu::FMU2, fun)
    fmi2SetFctEnterContinuousTimeMode(fmu, fun)
end

function fmiSetFctCompletedIntegratorStep(fmu::FMU2, fun)
    fmi2SetFctCompletedIntegratorStep(fmu, fun)
end

function fmiSetFctGetDerivatives(fmu::FMU2, fun)
    fmi2SetFctGetDerivatives(fmu, fun)
end

function fmiSetFctGetEventIndicators(fmu::FMU2, fun)
    fmi2SetFctGetEventIndicators(fmu, fun)
end

function fmiSetFctGetContinuousStates(fmu::FMU2, fun)
    fmi2SetFctGetContinuousStates(fmu, fun)
end

function fmiSetFctGetNominalsOfContinuousStates(fmu::FMU2, fun)
    fmi2SetFctGetNominalsOfContinuousStates(fmu, fun)
end

function fmiGetSolutionTime(solution::FMU2Solution, args...; kwargs...)
    fmi2GetSolutionTime(solution, args...; kwargs...)
end

function fmiGetSolutionState(solution::FMU2Solution, args...; kwargs...)
    fmi2GetSolutionState(solution, args...; kwargs...)
end

function fmiGetSolutionDerivative(solution::FMU2Solution, args...; kwargs...)
    fmi2GetSolutionDerivative(solution, args...; kwargs...)
end

function fmiGetSolutionValue(solution::FMU2Solution, args...; kwargs...)
    fmi2GetSolutionValue(solution, args...; kwargs...)
end

# renames 

function fmiSampleDirectionalDerivative(args...; kwargs...)
    fmi2SampleJacobian(args...; kwargs...)
end

function fmiSampleDirectionalDerivative!(args...; kwargs...)
    fmi2SampleJacobian!(args...; kwargs...)
end