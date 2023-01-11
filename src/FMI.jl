#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

@debug "Debugging messages enabled for FMI.jl ..."

using Requires

using FMIImport

# TODO recheck export import list
# fmi2 imports
import FMIImport: fmi2CallbackLogger, fmi2CallbackAllocateMemory, fmi2CallbackFreeMemory, fmi2CallbackStepFinished
import FMIImport: fmi2ComponentState, fmi2ComponentStateInstantiated, fmi2ComponentStateInitializationMode, fmi2ComponentStateEventMode, fmi2ComponentStateContinuousTimeMode, fmi2ComponentStateTerminated, fmi2ComponentStateError, fmi2ComponentStateFatal
import FMIImport: fmi2Instantiate, fmi2FreeInstance!, fmi2GetTypesPlatform, fmi2GetVersion
import FMIImport: fmi2SetDebugLogging, fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
import FMIImport: fmi2GetReal!, fmi2SetReal, fmi2GetInteger!, fmi2SetInteger, fmi2GetBoolean!, fmi2SetBoolean, fmi2GetString!, fmi2SetString
import FMIImport: fmi2GetFMUstate!, fmi2SetFMUstate, fmi2FreeFMUstate!, fmi2SerializedFMUstateSize!, fmi2SerializeFMUstate!, fmi2DeSerializeFMUstate!
import FMIImport: fmi2GetDirectionalDerivative!, fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives
import FMIImport: fmi2DoStep, fmi2CancelStep, fmi2GetStatus!, fmi2GetRealStatus!, fmi2GetIntegerStatus!, fmi2GetBooleanStatus!, fmi2GetStringStatus!
import FMIImport: fmi2SetTime, fmi2SetContinuousStates, fmi2EnterEventMode, fmi2NewDiscreteStates, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep!
import FMIImport: fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates
import FMIImport: fmi2StringToValueReference, fmi2ValueReferenceToString, fmi2ModelVariablesForValueReference
import FMIImport: fmi2GetReal, fmi2GetInteger, fmi2GetString, fmi2GetBoolean
import FMIImport: fmi2GetFMUstate, fmi2SerializedFMUstateSize, fmi2SerializeFMUstate, fmi2DeSerializeFMUstate
import FMIImport: fmi2GetDirectionalDerivative
import FMIImport: fmi2GetStartValue, fmi2SampleJacobian, fmi2CompletedIntegratorStep
import FMIImport: fmi2Unzip, fmi2Load, loadBinary, fmi2Reload, fmi2Unload, fmi2Instantiate!
import FMIImport: fmi2SampleJacobian!
import FMIImport: fmi2GetJacobian, fmi2GetJacobian!, fmi2GetFullJacobian, fmi2GetFullJacobian!
import FMIImport: fmi2LoadModelDescription
import FMIImport: fmi2GetDefaultStartTime, fmi2GetDefaultStopTime, fmi2GetDefaultTolerance, fmi2GetDefaultStepSize
import FMIImport: fmi2GetModelName, fmi2GetGUID, fmi2GetGenerationTool, fmi2GetGenerationDateAndTime, fmi2GetVariableNamingConvention, fmi2GetNumberOfEventIndicators, fmi2GetNumberOfStates, fmi2IsCoSimulation, fmi2IsModelExchange
import FMIImport: fmi2DependenciesSupported, fmi2GetModelIdentifier, fmi2CanGetSetState, fmi2CanSerializeFMUstate, fmi2ProvidesDirectionalDerivative
import FMIImport: fmi2Get, fmi2Get!, fmi2Set
import FMIImport: fmi2GetSolutionTime, fmi2GetSolutionState, fmi2GetSolutionValue
export fmi2GetSolutionTime, fmi2GetSolutionState, fmi2GetSolutionValue

# fmi3 imports
import FMIImport: fmi3CallbackLogger, fmi3CallbackIntermediateUpdate, fmi3CallbackClockUpdate
import FMIImport: fmi3InstanceState, fmi3InstanceStateInstantiated, fmi3InstanceStateInitializationMode, fmi3InstanceStateEventMode, fmi3InstanceStateContinuousTimeMode, fmi3InstanceStateTerminated, fmi3InstanceStateError, fmi3InstanceStateFatal
import FMIImport: fmi3InstantiateModelExchange!, fmi3InstantiateCoSimulation!, fmi3InstantiateScheduledExecution!, fmi3FreeInstance!, fmi3GetVersion
import FMIImport: fmi3SetDebugLogging, fmi3EnterInitializationMode, fmi3ExitInitializationMode, fmi3Terminate, fmi3Reset
import FMIImport: fmi3GetFloat32!, fmi3SetFloat32, fmi3GetFloat64!, fmi3SetFloat64
import FMIImport: fmi3GetInt8!, fmi3SetInt8, fmi3GetUInt8!, fmi3SetUInt8, fmi3GetInt16!, fmi3SetInt16, fmi3GetUInt16!, fmi3SetUInt16, fmi3GetInt32!, fmi3SetInt32, fmi3GetUInt32!, fmi3SetUInt32, fmi3GetInt64!, fmi3SetInt64, fmi3GetUInt64!, fmi3SetUInt64
import FMIImport: fmi3GetBoolean!, fmi3SetBoolean, fmi3GetString!, fmi3SetString, fmi3GetBinary!, fmi3SetBinary, fmi3GetClock!, fmi3SetClock
import FMIImport: fmi3GetFMUState!, fmi3SetFMUState, fmi3FreeFMUState!, fmi3SerializedFMUStateSize!, fmi3SerializeFMUState!, fmi3DeSerializeFMUState!
import FMIImport: fmi3SetIntervalDecimal, fmi3SetIntervalFraction, fmi3GetIntervalDecimal!, fmi3GetIntervalFraction!, fmi3GetShiftDecimal!, fmi3GetShiftFraction!
import FMIImport: fmi3ActivateModelPartition
import FMIImport: fmi3GetNumberOfVariableDependencies!, fmi3GetVariableDependencies!
import FMIImport: fmi3GetDirectionalDerivative!, fmi3GetAdjointDerivative!, fmi3GetOutputDerivatives!
import FMIImport: fmi3DoStep!

import FMIImport: fmi3EnterConfigurationMode, fmi3ExitConfigurationMode, fmi3GetNumberOfContinuousStates!, fmi3GetNumberOfEventIndicators!, fmi3GetContinuousStates!, fmi3GetNominalsOfContinuousStates!
import FMIImport: fmi3EvaluateDiscreteStates, fmi3EnterStepMode
import FMIImport: fmi3SetTime, fmi3SetContinuousStates, fmi3EnterEventMode, fmi3UpdateDiscreteStates, fmi3EnterContinuousTimeMode, fmi3CompletedIntegratorStep!
import FMIImport: fmi3GetContinuousStateDerivatives, fmi3GetContinuousStateDerivatives!, fmi3GetEventIndicators, fmi3GetContinuousStates, fmi3GetNominalsOfContinuousStates
import FMIImport: fmi3StringToValueReference, fmi3ValueReferenceToString, fmi3ModelVariablesForValueReference
import FMIImport: fmi3GetFloat32, fmi3GetFloat64, fmi3GetInt8, fmi3GetUInt8, fmi3GetInt16, fmi3GetUInt16, fmi3GetInt32, fmi3GetUInt32, fmi3GetInt64, fmi3GetUInt64, fmi3GetBoolean, fmi3GetBinary, fmi3GetClock, fmi3GetString
import FMIImport: fmi3SetFloat32, fmi3SetFloat64, fmi3SetInt8, fmi3SetUInt8, fmi3SetInt16, fmi3SetUInt16, fmi3SetInt32, fmi3SetUInt32, fmi3SetInt64, fmi3SetUInt64, fmi3SetBoolean, fmi3SetBinary, fmi3SetClock, fmi3SetString
import FMIImport: fmi3GetFMUState, fmi3SerializedFMUStateSize, fmi3SerializeFMUState, fmi3DeSerializeFMUState
import FMIImport: fmi3GetDirectionalDerivative, fmi3GetAdjointDerivative
import FMIImport: fmi3GetStartValue, fmi3SampleDirectionalDerivative, fmi3CompletedIntegratorStep
import FMIImport: fmi3Unzip, fmi3Load, loadBinary, fmi3Reload, fmi3Unload
import FMIImport: fmi3SampleDirectionalDerivative!
import FMIImport: fmi3GetJacobian, fmi3GetJacobian!, fmi3GetFullJacobian, fmi3GetFullJacobian!
import FMIImport: fmi3LoadModelDescription
import FMIImport: fmi3GetDefaultStartTime, fmi3GetDefaultStopTime, fmi3GetDefaultTolerance, fmi3GetDefaultStepSize
import FMIImport: fmi3GetModelName, fmi3GetInstantiationToken, fmi3GetGenerationTool, fmi3GetGenerationDateAndTime, fmi3GetVariableNamingConvention, fmi3GetNumberOfEventIndicators, fmi3GetNumberOfContinuousStates, fmi3IsCoSimulation, fmi3IsModelExchange, fmi3IsScheduledExecution
import FMIImport: fmi3DependenciesSupported, fmi3GetModelIdentifier, fmi3CanGetSetState, fmi3CanSerializeFMUState, fmi3ProvidesDirectionalDerivatives, fmi3ProvidesAdjointDerivatives
import FMIImport: fmi3Get, fmi3Get!, fmi3Set 
import FMIImport: fmi3GetSolutionTime, fmi3GetSolutionState, fmi3GetSolutionValue
# export fmi3GetSolutionTime, fmi3GetSolutionState, fmi3GetSolutionValue
export fmi3InstantiateCoSimulation!, fmi3InstantiateModelExchange!, fmi3InstantiateScheduledExecution!
export fmi3EnterInitializationMode, fmi3ExitInitializationMode
export fmi3GetFloat32, fmi3GetFloat64, fmi3GetInt8, fmi3GetUInt8, fmi3GetInt16, fmi3GetUInt16, fmi3GetInt32, fmi3GetUInt32, fmi3GetInt64, fmi3GetUInt64, fmi3GetBoolean, fmi3GetBinary, fmi3GetClock, fmi3GetString
export fmi3SetFloat64
export fmi3UpdateDiscreteStates, fmi3GetContinuousStateDerivatives!

import FMIImport: fmi2TypeModelExchange, fmi2TypeCoSimulation, fmi2Type
export fmi2TypeModelExchange, fmi2TypeCoSimulation, fmi2Type

export fmiCanGetSetState

import FMIImport: fmi3TypeModelExchange, fmi3TypeCoSimulation, fmi3TypeScheduledExecution, fmi3Type
export fmi2TypeModelExchange, fmi2TypeCoSimulation, fmi3TypeScheduledExecution, fmi2Type

using FMIExport

using FMIImport.FMICore: fmi2ValueReference, fmi3ValueReference
using FMIImport: fmi2ValueReferenceFormat, fmi3ValueReferenceFormat, fmi2StructMD, fmi3StructMD, fmi2Struct, fmi3Struct

using FMIImport.FMICore: FMU, FMU2, FMU3, FMU2Component, FMU3Instance
export FMU, FMU2, FMU3, FMU2Component, FMU3Instance

using FMIImport.FMICore: FMU2ExecutionConfiguration, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_NO_FREEING
export FMU2ExecutionConfiguration, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_NO_FREEING

using FMIImport.FMICore: FMU3ExecutionConfiguration, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_NO_FREEING
export FMU3ExecutionConfiguration, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_NO_FREEING

using FMIImport: prepareValue, prepareValueReference

export fmi2Real, fmi2Integer, fmi2String, fmi2Enumeration, fmi2Boolean

include("FMI2/additional.jl")
include("FMI3/additional.jl")
include("assertions.jl")

include("FMI2/comp_wraps.jl")
include("FMI3/comp_wraps.jl")

include("FMI2/sim.jl")
include("FMI3/sim.jl")

include("deprecated.jl")

# from FMI2_plot.jl
function fmiPlot(solution::FMU2Solution; kwargs...)
    @assert false "fmiPlot(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`."
end
function fmiPlot!(fig, solution::FMU2Solution; kwargs...)
    @assert false "fmiPlot!(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`."
end
export fmiPlot, fmiPlot!

# from FMI2_JLD2.jl
function fmiSaveSolution(solution::FMU2Solution, filepath::AbstractString; keyword="solution")
    @assert false "fmiSave(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
end
function fmiLoadSolution(path::AbstractString; keyword="solution")
    @assert false "fmiLoad(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
end
export fmiSaveSolution, fmiLoadSolution

# from FMI3_plot.jl
# function fmiPlot(solution::FMU3Solution; kwargs...)
#     @warn "fmiPlot(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`."
# end
# function fmiPlot!(fig, solution::FMU3Solution; kwargs...)
#     @warn "fmiPlot!(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`." 
# end
# export fmiPlot, fmiPlot!

# from FMI3_JLD2.jl
# function fmiSaveSolution(solution::FMU3Solution, filepath::AbstractString; keyword="solution") 
#     @warn "fmiSave(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
# end
# function fmiLoadSolution(path::AbstractString; keyword="solution")
#     @warn "fmiLoad(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
# end

# Requires init
function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        import .Plots
        include("FMI2/extensions/Plots.jl")
        include("FMI3/extensions/Plots.jl")
    end
    @require JLD2="033835bb-8acc-5ee8-8aae-3f567f8a3819" begin
        import .JLD2
        include("FMI2/extensions/JLD2.jl")
        include("FMI3/extensions/JLD2.jl")
    end 
end

### EXPORTING LISTS START ###

# FMI.jl
export fmiLoad, fmiReload, fmiSimulate, fmiSimulateCS, fmiSimulateME, fmiUnload
export fmiInfo
export fmiGetModelName, fmiGetGUID, fmiGetGenerationTool, fmiGetGenerationDateAndTime

export fmiProvidesDirectionalDerivative
export fmiIsCoSimulation, fmiIsModelExchange
export fmiGetDependencies
export fmiGetStartValue, fmiStringToValueReference
export fmiGet, fmiGet!, fmiSet
export fmiGetSolutionTime, fmiGetSolutionState, fmiGetSolutionDerivative, fmiGetSolutionValue
export fmiGetNumberOfStates

export fmiGetState, fmiSetState, fmiFreeState!

### EXPORTING LISTS END ###

# Dispatch to call FMUs for a simulation
function (str::Union{fmi2Struct, fmi3Struct})(; t::Tuple{Float64, Float64}, kwargs...)
    fmiSimulate(str, t; kwargs...)
end

"""
#ToDo fmi3Docs for all functions

    fmiGetState(str::fmi2Struct)

Makes a copy of the internal FMU state and returns a pointer to this copy.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- Return `state` is a pointer to a copy of the internal FMU state.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2GetFMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetState(str::fmi2Struct)
    fmi2GetFMUstate(str)
end

function fmiGetState(str::fmi3Struct)
    fmi3GetFMUState(str)
end

"""

    fmiFreeState!(str::fmi2Struct, c::FMU2Component, state::fmi2FMUstate)

    fmiFreeState!(str::fmi2Struct, c::FMU2Component, FMUstate::Ref{fmi2FMUstate})

Free the memory for the allocated FMU state

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `state::fmi2FMUstate`: Argument `state` is a pointer to a data structure in the FMU that saves the internal FMU state of the actual or a previous time instant.
- `FMUstate::Ref{fmi2FMUstate}`: Argument `FMUstate` is an object that safely references data of type `fmi3FMUstate` wich is a pointer to a data structure in the FMU that saves the internal FMU state of the actual or a previous time instant.


# Returns
- Return singleton instance of type `Nothing`, if there is no value to return (as in a C void function) or when a variable or field holds no value.
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
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2FreeFMUstate!`](@ref),[`fmi2FMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
    """
function fmiFreeState!(str::fmi2Struct, args...; kwargs...)
    fmi2FreeFMUstate!(str, args...; kwargs...)
end
function fmiFreeState!(str::fmi3Struct, args...; kwargs...)
    fmi3FreeFMUState!(str, args...; kwargs...)
end

"""

    fmiSetState(str::fmi2Struct, c::FMU2Component, FMUstate::fmi2FMUstate)

Sets the FMU to the given state

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `FMUstate::fmi2FMUstate`: Argument `FMUstate` is a pointer to a data structure in the FMU that saves the internal FMU state of the actual or a previous time instant.

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
- FMISpec2.0.2[p.25]: 2.1.8 Getting and Setting the Complete FMU State

See also [`fmi2GetFMUstate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetState(str::fmi2Struct, args...; kwargs...)
    fmi2SetFMUstate(str, args...; kwargs...)
end
function fmiSetState(str::fmi3Struct, args...; kwargs...)
    fmi3SetFMUState(str, args...; kwargs...)
end

"""

    fmiGetDependencies(fmu::FMU2)

Building dependency matrix `dim x dim` for fast look-ups on variable dependencies (`dim` is number of states).

# Arguments
- `fmu::FMU2`: Mutable Struct representing a FMU.

# Retruns
- `fmu.dependencies::Matrix{Union{fmi2DependencyKind, Nothing}}`: Returns the FMU's dependency-matrix for fast look-ups on dependencies between value references. Entries are from type fmi2DependencyKind.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetDependencies`](@ref).
"""
function fmiGetDependencies(fmu::FMU2)
    fmi2GetDependencies(fmu)
end
function fmiGetDependencies(fmu::FMU3)
    fmi3GetDependencies(fmu)
end

"""

    fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription, FMU3, fmmi3ModelDescription}, identifier::Union{String, AbstractArray{String}})

Returns the ValueReference coresponding to the variable identifier.

# Arguments
- `dataStruct::Union{FMU2, fmi2ModelDescription, FMU3, fmmi3ModelDescription}`: Model of the type FMU2/FMU3 or the Model Description of fmi2/fmi3. Same for Model of type FMU3 or the Model Description of fmi3
- `identifier::Union{String, AbstractArray{String}}`: Variable identifier in type String or as a 1-dimensional AbstractArray containing elements of type String

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2StringToValueReference`](@ref), [`fmi3StringToValueReference`](@ref).
"""
function fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, AbstractArray{String}})
    fmi2StringToValueReference(dataStruct, identifier)
end
function fmiStringToValueReference(dataStruct::Union{FMU3, fmi3ModelDescription}, identifier::Union{String, AbstractArray{String}})
    fmi3StringToValueReference(dataStruct, identifier)
end

# Wrapping modelDescription Functions
"""

    fmiGetModelName(str::Union{fmi2StructMD, fmi3StructMD})

Returns the tag 'modelName' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
 `Union{fmi2StructMD, fmi3StructMD} = Union{FMU2, FMU2Component, fmi2ModelDescription, FMU3, FMU3Instance, fmi3ModelDescription}`
  - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
  - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
  - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.
  - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
  - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
  - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiGetModelName(str::fmi2StructMD)
    fmi2GetModelName(str)
end
function fmiGetModelName(str::fmi3StructMD)
    fmi3GetModelName(str)
end

# TODO call differently in fmi3: getInstantationToken
"""  

    fmiGetGUID(str::fmi2StructMD)

Returns the tag 'guid' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/). More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetGUID`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiGetGUID(str::fmi2StructMD)
    fmi2GetGUID(str)
end

# TODO how wo work with docstring
"""  

    fmiGetGenerationTool(str::Union{fmi2StructMD, fmi3StructMD})

Returns the tag 'generationtool' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
`fmi2StructMD= Union{FMU2, FMU2Component, fmi2ModelDescription}`
`fmi3StructMD= Union{FMU3, FMU3Instance, fmi3ModelDescription}`
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.generationtool`: The function `fmi2GetGenerationTool` returns the tag 'generationtool' from the struct, representing a FMU (`str`).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetGenerationTool`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiGetGenerationTool(str::fmi2StructMD)
    fmi2GetGenerationTool(str)
end
function fmiGetGenerationTool(str::fmi3StructMD)
    fmi3GetGenerationTool(str)
end
"""

    fmiGetGenerationDateAndTime(str::Union{fmi2StructMD, fmi3StructMD})

Returns the tag 'generationdateandtime' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
 More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 More detailed:  `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.generationDateAndTime`: The function `fmi2GetGenerationDateAndTime` returns the tag 'generationDateAndTime' from the struct, representing a FMU (`str`).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetGenerationDateAndTime`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiGetGenerationDateAndTime(str::fmi2StructMD)
    fmi2GetGenerationDateAndTime(str)
end
function fmiGetGenerationDateAndTime(str::fmi3StructMD)
    fmi3GetGenerationDateAndTime(str)
end

"""

    fmiGetVariableNamingConvention(str::Union{fmi2StructMD, fmi3StructMD})

Returns the tag 'varaiblenamingconvention' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
 More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 More detailed:  `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.variableNamingConvention`: The function `fmi2GetVariableNamingConvention` returns the tag 'variableNamingConvention' from the struct, representing a FMU (`str`).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetVariableNamingConvention`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3GetVariableNamingConvention`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiGetVariableNamingConvention(str::fmi2StructMD)
    fmi2GetVariableNamingConvention(str)
end
function fmiGetVariableNamingConvention(str::fmi3StructMD)
    fmi3GetVariableNamingConvention(str)
end

"""

    fmiGetNumberOfEventIndicators(str::str::Union{fmi2StructMD, fmi3StructMD})

Returns the tag 'numberOfEventIndicators' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.numberOfEventIndicators`: The function `fmi2GetNumberOfEventIndicators` returns the tag 'numberOfEventIndicators' from the struct, representing a FMU (`str`).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetNumberOfEventIndicators`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3GetNumberOfEventIndicators`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiGetNumberOfEventIndicators(str::fmi2StructMD)
    fmi2GetNumberOfEventIndicators(str)
end
function fmiGetNumberOfEventIndicators(str::fmi3StructMD)
    fmi3GetNumberOfEventIndicators(str)
end

"""

    fmiGetModelIdentifier(fmu::Union{FMU2, FMU3})

Returns the tag 'modelIdentifier' from CS or ME section.

# Arguments
 - `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `fmu::FMU3`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 3.0 Standard](https://fmi-standard.org/).
# Returns
- `fmu.modelDescription.coSimulation.modelIdentifier`: The function `fmiGetModelIdentifier` returns the tag 'coSimulation.modelIdentifier' from the model description of the FMU2 or FMU3-struct (`fmu.modelDescription`), if the FMU supports co simulation.
- `fmu.modelDescription.modelExchange.modelIdentifier`: The function `fmiGetModelIdentifier` returns the tag 'modelExchange.modelIdentifier'  from the model description of the FMU2 or FMU3-struct (`fmu.modelDescription`), if the FMU supports model exchange
- `fmu.modelDescription.modelExchange.modelIdentifier`: The function `fmiGetModelIdentifier` returns the tag 'scheduledExecution.modelIdentifier'  from the model description of the FMU3-struct (`fmu.modelDescription`), if the FMU supports scheduled execution

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

Also see [`fmi2GetModelIdentifier`](@ref), [`FMU2`](@ref), [`fmi3GetModelIdentifier`](@ref), [`FMU3`](@ref).
"""
function fmiGetModelIdentifier(fmu::FMU2)
    fmi2GetModelIdentifier(fmu.modelDescription; type=fmu.type)
end
function fmiGetModelIdentifier(fmu::FMU3)
    fmi3GetModelIdentifier(fmu.modelDescription; type=fmu.type)
end
"""

    fmiCanGetSetState(str::Union{fmi2StructMD, fmi3StructMD})

Returns true, if the FMU supports the getting/setting of states

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2CanGetSetState` returns True, if the FMU supports the getting/setting of states.

# Source
 - FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
 - FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
 - FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

 See also [`fmi2CanGetSetState`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3CanGetSetState`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
 """
function fmiCanGetSetState(str::fmi2StructMD)
    fmi2CanGetSetState(str)
end
function fmiCanGetSetState(str::fmi3StructMD)
    fmi3CanGetSetState(str)
end

"""

    fmiCanSerializeFMUstate(str::Union{fmi2StructMD, fmi3StructMD})

Returns true, if the FMU state can be serialized

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2CanSerializeFMUstate` returns True, if the FMU state can be serialized.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2CanSerializeFMUstate`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3CanSerializeFMUstate`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiCanSerializeFMUstate(str::fmi2StructMD)
    fmi2CanSerializeFMUstate(str)
end
function fmiCanSerializeFMUstate(str::fmi3StructMD)
    fmi3CanSerializeFMUState(str)
end

# TODO fmi3Call fmiProvidesDirectionalDerivatives
"""

    fmiProvidesDirectionalDerivative(str::Union{fmi2StructMD, fmi3StructMD})

Returns true, if the FMU provides directional derivatives

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `::Bool`: The function `fmi2ProvidesDirectionalDerivative` returns True, if the FMU provides directional derivatives.

See also [`fmi2ProvidesDirectionalDerivative`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3ProvidesDirectionalDerivative`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiProvidesDirectionalDerivative(str::fmi2StructMD)
    fmi2ProvidesDirectionalDerivative(str)
end
function fmiProvidesDirectionalDerivative(str::fmi3StructMD)
    fmi3ProvidesDirectionalDerivatives(str)
end

"""

    fmiProvidesAdjointDerivative(str::fmi3StructMD)

Returns true, if the FMU provides adjoint derivatives

# Arguments
- `str::fmi3StructMD`:  Representative for an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi3StructMD = Union{FMU3, FMU3Component, fmi3ModelDescription}`
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `::Bool`: The function `fmi3ProvidesAdjointDerivatives` returns True, if the FMU provides adjoint derivatives.

See also [`fmi3ProvidesAdjointDerivatves`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiProvidesAdjointDerivative(str::fmi3StructMD)
    fmi3ProvidesAdjointDerivatives(str)
end

"""

    fmiIsCoSimulation(str::Union{fmi2StructMD, fmi3StructMD})

Returns true, if the FMU supports co simulation

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD = Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2IsCoSimulation` returns True, if the FMU supports co simulation

See also [`fmi2IsCoSimulation`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3IsCoSimulation`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiIsCoSimulation(str::fmi2StructMD)
    fmi2IsCoSimulation(str)
end
function fmiIsCoSimulation(str::fmi3StructMD)
    fmi3IsCoSimulation(str)
end

"""

    fmiIsModelExchange(str::Union{fmi2StructMD, fmi3StructMD})

Returns true, if the FMU supports model exchange

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2StructMD = Union{FMU2, FMU2Component, fmi2ModelDescription}`
More detailed: `fmi3StructMD = Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2IsModelExchange` returns True, if the FMU supports model exchange.

 # Source
 - FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
 - FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
 - FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2IsModelExchange`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3IsModelExchange`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiIsModelExchange(str::fmi2StructMD)
    fmi2IsModelExchange(str)
end
function fmiIsModelExchange(str::fmi3StructMD)
    fmi3IsModelExchange(str)
end

"""

    fmiIsScheduledExecution(str::fmi3StructMD)

Returns true, if the FMU supports scheduled execution

# Arguments
- `str::fmi3StructMD`:  Representative for an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi3StructMD =  Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi3IsScheduledExecution` returns True, if the FMU supports scheduled execution.

See also [`fmi3IsScheduledExecution`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiIsScheduledExecution(str::fmi2StructMD)
    fmi3IsScheduledExecution(str)
end

# Multiple Dispatch variants for FMUs with version 2.0.X

"""

   fmiLoad(pathToFMU::String; unpackPath=nothing, type=nothing)

Load FMUs independent of the FMI version, currently supporting version 2.0.X and 3.0.

# Arguments
- `pathToFMU::String`: String that contains the paths of ziped and unziped FMU folders.

# Keywords
- `unpackPath=nothing`: Via optional argument ```unpackPath```, a path to unpack the FMU can be specified (default: system temporary directory).
- `type::Union{CS, ME, SE} = nothing`:  Via ```type```, a FMU type can be selected. If none of the unified type set is used, the default value `type = nothing` will be used.

# Returns
- Returns the instance of the FMU struct.

See also [`fmi2Load`](@ref), [`fmi3Load`](@ref).
"""
function fmiLoad(pathToFMU::AbstractString, args...; kwargs...)
    version = fmiCheckVersion(pathToFMU)
    if version == "2.0"
        fmi2Load(pathToFMU, args...; kwargs...)
    elseif version == "3.0"
        fmi3Load(pathToFMU, args...; kwargs...)
    else
        @warn "fmiLoad(...): Unknown FMU version"
    end
end

"""

    fmiReload(fmu::Union{FMU2, FMU3})

Reloads the FMU-binary. This is useful, if the FMU does not support a clean reset implementation.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
- `fmu::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
See also [`fmi2Reload`](@ref), [`fmi3Reload`](@ref).
"""
function fmiReload(fmu::FMU2, args...; kwargs...)
    fmi2Reload(fmu, args...; kwargs...)
end
function fmiReload(fmu::FMU3, args...; kwargs...)
    fmi3Reload(fmu, args...; kwargs...)
end

"""

    fmiSimulate(str::Union{fmi2Struct, fmi3Struct}, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
                tolerance::Union{Real, Nothing} = nothing,
                dt::Union{Real, Nothing} = nothing,
                solver = nothing,
                customFx = nothing,
                recordValues::fmi2ValueReferenceFormat = nothing,
                saveat = [],
                setup::Bool = true,
                reset::Union{Bool, Nothing} = nothing, # nothing = auto
                inputValueReferences::fmi2ValueReferenceFormat = nothing,
                inputFunction = nothing,
                parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
                dtmax::Union{Real, Nothing} = nothing,
                kwargs...)

Starts a simulation of the FMU instance for the matching FMU type, if both types are available, CS is preferred.


# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3Struct = Union{FMU3, FMU3Instance}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
 - `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
 - `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: AbstractArray of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: AbstractArray of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns
- `success::Bool` for CS-FMUs
- `ODESolution` for ME-FMUs
- if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs
- if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2Simulate`](@ref), [`fmi2SimulateME`](@ref), [`fmi2SimulateCS`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiSimulate(str::fmi2Struct, args...; kwargs...)
    fmi2Simulate(str, args...; kwargs...)
end
function fmiSimulate(str::fmi3Struct, args...; kwargs...)
    fmi3Simulate(str, args...; kwargs...)
end
"""

    fmiSimulateCS(str::Union{fmi2Struct,fmi3Struct}, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
                tolerance::Union{Real, Nothing} = nothing,
                dt::Union{Real, Nothing} = nothing,
                solver = nothing,
                customFx = nothing,
                recordValues::fmi2ValueReferenceFormat = nothing,
                saveat = [],
                setup::Bool = true,
                reset::Union{Bool, Nothing} = nothing, # nothing = auto
                inputValueReferences::fmi2ValueReferenceFormat = nothing,
                inputFunction = nothing,
                parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
                dtmax::Union{Real, Nothing} = nothing,
                kwargs...)

Starts a simulation of the Co-Simulation FMU instance.


# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3Struct = Union{FMU3, FMU3Instance}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
- `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
- `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: AbstractArray of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: AbstractArray of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns
- If keyword `recordValues` is not set, a boolean `success` is returned (simulation success).
- If keyword `recordValues` is set, a tuple of type (true, DiffEqCallbacks.SavedValues) or (false, nothing).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2SimulateCS`](@ref), [`fmi2Simulate`](@ref), [`fmi2SimulateME`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi3SimulateCS`](@ref), [`fmi3Simulate`](@ref), [`fmi3SimulateME`](@ref), [`fmi3Struct`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref).

"""
function fmiSimulateCS(str::fmi2Struct, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing, args...; kwargs...)
    fmi2SimulateCS(str, tspan, args...; kwargs...)
end  
function fmiSimulateCS(str::fmi3Struct, args...; kwargs...)
    fmi3SimulateCS(str, args...; kwargs...)
end

"""

    fmiSimulateME(str::Union{fmi2Struct,fmi3Struct}, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
                tolerance::Union{Real, Nothing} = nothing,
                dt::Union{Real, Nothing} = nothing,
                solver = nothing,
                customFx = nothing,
                recordValues::fmi2ValueReferenceFormat = nothing,
                saveat = [],
                setup::Bool = true,
                reset::Union{Bool, Nothing} = nothing, # nothing = auto
                inputValueReferences::fmi2ValueReferenceFormat = nothing,
                inputFunction = nothing,
                parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
                dtmax::Union{Real, Nothing} = nothing,
                kwargs...)

Simulates a FMU instance for the given simulation time interval.


# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3Struct = Union{FMU3, FMU3Instance}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
- `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
- `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: AbstractArray of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: AbstractArray of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns
- If keyword `recordValues` is not set, a struct of type `ODESolution`.
- If keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2SimulateME`](@ref) [`fmi2SimulateCS`](@ref), [`fmi2Simulate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""

function fmiSimulateME(str::fmi2Struct, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing, args...; kwargs...)
    fmi2SimulateME(str, tspan, args...; kwargs...)
end
function fmiSimulateME(str::fmi3Struct, args...; kwargs...)
    fmi3SimulateME(str, args...; kwargs...)
end
"""

    fmiUnload(fmu::Union{FMU2, FMU3})

Unloads the FMU and all its instances and frees the allocated memory.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
- `fmu::FMU3`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 3.0 Standard](https://fmi-standard.org/).

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
See also [`fmi2Unload`](@ref), [`fmi3Unload`](@ref).
"""
function fmiUnload(fmu::FMU2)
    fmi2Unload(fmu)
end
function fmiUnload(fmu::FMU3)
    fmi3Unload(fmu)
end

"""

    fmiGetNumberOfStates(str::Union{fmi2Struct, fmi3Struct})

Returns the number of states of the FMU.

# Arguments
- `str::Union{fmi2Struct, fmi3Struct}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3StructMD = Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).

# Returns
- Returns the length of the `md.valueReferences::Array{fmi2ValueReference}` corresponding to the number of states of the FMU.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetNumberOfStates`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi3GetNumberOfStates`](@ref), [`fmi3Struct`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref).
"""
function fmiGetNumberOfStates(str::fmi2Struct)
    fmi2GetNumberOfStates(str)
end
function fmiGetNumberOfStates(str::fmi3Struct)
    fmi3GetNumberOfStates(str)
end

# TODO not in FMI3
"""

    fmiGetTypesPlatform(str::fmi2Struct)

Returns the header file used to compile the FMU. By default returns `default`, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).

# Returns
- Returns the string to uniquely identify the “fmi2TypesPlatform.h” header file used for compilation of the functions of the FMU.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetVersion`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetTypesPlatform(str::fmi2Struct)
    fmi2GetTypesPlatform(str)
end

"""

    fmiGetVersion(str::Union{fmi2Struct, fmi3Struct})

Returns the version of the FMU, version independent.

# Arguments
- `str::Union{fmi2Struct, fmi3Struct}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3StructMD = Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).

# Returns
- Returns a string from the address of a C-style (NUL-terminated) string. The string represents the version of the “fmiXFunctions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0” or "3.0"

# Source
 - FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
 - FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
 - FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions
 - FMISpec3.0[p. ]: 2.2.5. Inquire Version Number of Header Files

See also [`fmi2GetVersion`](@ref), [`unsafe_string`](https://docs.julialang.org/en/v1/base/strings/#Base.unsafe_string), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi3GetVersion`](@ref), [`fmi3Struct`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref).
"""
function fmiGetVersion(str::fmi2Struct)
    fmi2GetVersion(str)
end
function fmiGetVersion(str::fmi3Struct)
    fmi3GetVersion(str)
end

"""
    fmiInfo(str::fmi2Struct)

Prints FMU-specific information into the REPL.

# Arguments
- `str::Union{fmi2Struct, fmi3Struct}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
More detailed: `fmi3StructMD = Union{FMU3, FMU3Instance, fmi3ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
 - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
 - `str::FMU3Instance`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).

# Returns
- Prints FMU related information.


# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec3.0 Link: [https://fmi-standard.org/](https://fmi-standard.org/)

See also [`fmi2Info`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi3Info`](@ref), [`fmi3Struct`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref).
"""
function fmiInfo(str::fmi2Struct)
    fmi2Info(str)
end
function fmiInfo(str::fmi3Struct)
    fmi3Info(str)
end

"""

    fmiGet(str::fmi2Struct, comp::FMU2Component, vrs::fmi2ValueReferenceFormat)

Returns the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference in an array.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
 - `vrs::fmi2ValueReferenceFormat`: wildcards for how a user can pass a fmi[X]ValueReference
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `dstArray::Array{Any,1}(undef, length(vrs))`: Stores the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference to the input variable vr (vr = vrs[i]). `dstArray` is a 1-Dimensional Array that has the same length as `vrs`.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

"""
function fmiGet(str::fmi2Struct, args...; kwargs...)
    fmi2Get(str, args...; kwargs...)
end
function fmiGet(str::fmi3Struct, args...; kwargs...)
    fmi3Get(str, args...; kwargs...)
end
"""
   fmiGet!(str::fmi2Struct, comp::FMU2Component, vrs::fmi2ValueReferenceFormat, dstArray::AbstractArray)

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
- `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `dstArray::AbstractArray`: Stores the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference to the input variable vr (vr = vrs[i]). `dstArray` has the same length as `vrs`.

# Returns
- `retcodes::Array{fmi2Status}`: Returns an array of length length(vrs) with Type `fmi2Status`. Type `fmi2Status` is an enumeration and indicates the success of the function call.
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

"""
function fmiGet!(str::fmi2Struct, args...; kwargs...)
    fmi2Get!(str, args...; kwargs...)
end
function fmiGet!(str::fmi3Struct, args...; kwargs...)
    fmi3Get!(str, args...; kwargs...)
end
"""

   fmiSet(str::fmi2Struct, comp::FMU2Component, vrs::fmi2ValueReferenceFormat, srcArray::AbstractArray; filter=nothing)

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
- `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
- `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `srcArray::AbstractArray`: Stores the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference to the input variable vr (vr = vrs[i]). `srcArray` has the same length as `vrs`.

# Keywords
- `filter=nothing`: whether the individual values of "fmi2ScalarVariable" are to be stored

# Returns
- `retcodes::Array{fmi2Status}`: Returns an array of length length(vrs) with Type `fmi2Status`. Type `fmi2Status` is an enumeration and indicates the success of the function call.
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
"""
function fmiSet(str::fmi2Struct, args...; kwargs...)
    fmi2Set(str, args...; kwargs...)
end
function fmiSet(str::fmi3Struct, args...; kwargs...)
    fmi3Set(str, args...; kwargs...)
end

"""

    fmiGetReal(str::fmi2Struct, vr::fmi2ValueReferenceFormat)

Returns the real values of an array of variables

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vr::fmi2ValueReferenceFormat`: wildcards for how a user can pass a fmi[X]ValueReference
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `values::Array{fm2Real}`: returns values of an array of fmi2Real variables with the dimension of fmi2ValueReferenceFormat length.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [`fmi2GetReal`](@ref),[`fmi2ValueReferenceFormat`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""
function fmiGetReal(str::fmi2Struct, args...; kwargs...)
    fmi2GetReal(str, args...; kwargs...)
end
function fmiGetReal(str::fmi3Struct, args...; kwargs...)
    fmi3GetReal(str, args...; kwargs...)
end


"""
#TODO
    fmiSampleJacobian(str::fmi2Struct, c::FMU2Component,
                                       vUnknown_ref::Array{fmi2ValueReference},
                                       vKnown_ref::Array{fmi2ValueReference},
                                       steps::Array{fmi2Real} = ones(fmi2Real, length(vKnown_ref)).*1e-5)
    fmiSampleJacobian(str::fmi2Struct, c::FMU2Component,
                                       vUnknown_ref::AbstractArray{fmi2ValueReference},
                                       vKnown_ref::AbstractArray{fmi2ValueReference},
                                       steps::Union{AbstractArray{fmi2Real}, Nothing} = nothing)
This function samples the jacobian by manipulating corresponding values (central differences).
# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
- `vUnknown_ref::Array{fmi2ValueReference}`:  Argument `vUnKnown_ref` contains values of type `fmi2ValueReference` which are identifiers of a variable value of the model.`vKnown_ref` is the Array of the vector values of Real input variables of function h that changes its value in the actual Mode.
- `vKnown_ref::Array{fmi2ValueReference}`: Argument `vKnown_ref` contains values of type `fmi2ValueReference` which are identifiers of a variable value of the model.`vKnown_ref` is the Array of the vector values of Real input variables of function h that changes its value in the actual Mode.
- `steps::Array{fmi2Real} = ones(fmi2Real, length(vKnown_ref)).*1e-5`:
- `steps::Union{AbstractArray{fmi2Real}, Nothing} = nothing`:
# Returns
- `dvUnknown::Arrya{fmi2Real}`:
# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions (fmi2TypesPlatform.h)
See also [`fmi2SampleJacobian`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ValueReference`](@ref).
"""
function fmiSampleJacobian(str::fmi2Struct, args...; kwargs...)
    fmi2SampleJacobian(str, args...; kwargs...)
end
function fmiSampleJacobian(str::fmi3Struct, args...; kwargs...)
    fmi3SampleJacobian(str, args...; kwargs...)
end

"""
#TODO
Samples the values of the jacobian (in-place).
Samples the values of the jacobian (in-place).
"""
function fmiSampleJacobian!(str::fmi3Struct, args...; kwargs...)
    fmi3SampleJacobian!(str, args...; kwargs...)
function fmiSampleJacobian!(str::fmi2Struct, args...; kwargs...)
    fmi2SampleJacobian!(str, args...; kwargs...)
end

"""

   fmiGetStartValue(s::fmi2Struct, vr::fmi2ValueReferenceFormat)

Returns the start/default value for a given value reference.


# Arguments
- `md::fmi2ModelDescription`: Struct which provides the static information of ModelVariables.
- `vrs::fmi2ValueReferenceFormat = md.valueReferences`: wildcards for how a user can pass a fmi[X]ValueReference (default = md.valueReferences)
More detailed: `fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}, Symbol}`

# Returns
- `starts::Array{fmi2ValueReferenceFormat}`: start/default value for a given value reference

"""
function fmiGetStartValue(s::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetStartValue(s, vr)
end
function fmiGetStartValue(s::fmi3Struct, vr::fmi3ValueReferenceFormat)
    fmi3GetStartValue(s, vr)
end

end # module FMI
