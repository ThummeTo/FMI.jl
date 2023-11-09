#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

@debug "Debugging messages enabled for FMI.jl ..."

using Requires

using FMIImport

import FMIImport.FMICore: unsense, getCurrentComponent

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
# import FMIImport: fmi3DependenciesSupported
import FMIImport:fmi3GetModelIdentifier, fmi3CanGetSetState, fmi3CanSerializeFMUState, fmi3ProvidesDirectionalDerivatives, fmi3ProvidesAdjointDerivatives
import FMIImport: fmi3Get, fmi3Get!, fmi3Set 
# import FMIImport: fmi3GetSolutionTime, fmi3GetSolutionState, fmi3GetSolutionValue
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
using FMIExport: fmi2Create, fmi2CreateSimple

using FMIImport.FMICore: fmi2ValueReference, fmi3ValueReference
using FMIImport: fmi2ValueReferenceFormat, fmi3ValueReferenceFormat, fmi2StructMD, fmi3StructMD, fmi2Struct, fmi3Struct

using FMIImport.FMICore: FMU, FMU2, FMU3, FMU2Component, FMU3Instance, FMUSolution
export FMU, FMU2, FMU3, FMU2Component, FMU3Instance

using FMIImport.FMICore: FMU2ExecutionConfiguration, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_NO_FREEING
export FMU2ExecutionConfiguration, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_NO_FREEING

using FMIImport.FMICore: FMU3ExecutionConfiguration, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_NO_FREEING
export FMU3ExecutionConfiguration, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_NO_FREEING

using FMIImport: prepareValue, prepareValueReference

export fmi2Real, fmi2Integer, fmi2String, fmi2Enumeration, fmi2Boolean
export fmi2Info, fmi3Info
export fmi2VariableDependsOnVariable, fmi2GetDependencies, fmi2PrintDependencies, fmi3VariableDependsOnVariable, fmi3GetDependencies, fmi3PrintDependencies

include("check.jl")

include("FMI2/additional.jl")
include("FMI3/additional.jl")
include("assertions.jl")

include("FMI2/comp_wraps.jl")
include("FMI3/comp_wraps.jl")

include("FMI2/sim.jl")
include("FMI3/sim.jl")

include("deprecated.jl")

# from FMI2_plot.jl
function fmiPlot(solution::FMUSolution; kwargs...)
    @assert false "fmiPlot(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`."
end
function fmiPlot!(fig, solution::FMUSolution; kwargs...)
    @assert false "fmiPlot!(...) needs `Plots` package. Please install `Plots` and do `using Plots` or `import Plots`."
end
export fmiPlot, fmiPlot!

# from FMI2_JLD2.jl
function fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution")
    @assert false "fmiSave(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
end
function fmiLoadSolutionJLD2(path::AbstractString; keyword="solution")
    @assert false "fmiLoad(...) needs `JLD2` package. Please install `JLD2` and do `using JLD2` or `import JLD2`."
end
export fmiSaveSolutionJLD2, fmiLoadSolutionJLD2

# from CSV.jl
function fmiSaveSolutionCSV(solution::FMUSolution, filepath::AbstractString)
    @assert false "fmiSave(...) needs `CSV` and `DataFrames` package. Please install `CSV` and `DataFrames` and do `using CSV, DataFrames` or `import CSV, DataFrames`."
end
export fmiSaveSolutionCSV

# from MAT.jl
function fmiSaveSolutionMAT(solution::FMUSolution, filepath::AbstractString)
    @assert false "fmiSave(...) needs `MAT` package. Please install `MAT` and do `using MAT` or `import MAT`."
end
export fmiSaveSolutionMAT

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
        include("extensions/Plots.jl")
    end
    @require JLD2="033835bb-8acc-5ee8-8aae-3f567f8a3819" begin
        import .JLD2
        include("extensions/JLD2.jl")
    end
    @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
        import .DataFrames
        @require CSV="336ed68f-0bac-5ca0-87d4-7b16caf5d00b" begin
            import .CSV
            include("extensions/CSV.jl")   
        end
    end
    @require MAT="23992714-dd62-5051-b70f-ba57cb901cac" begin
        import .MAT
        include("extensions/MAT.jl")   
    end
end

### EXPORTING LISTS START ###

# FMI.jl
export fmiLoad, fmiReload, fmiSimulate, fmiSimulateCS, fmiSimulateME, fmiUnload
export fmiInfo
export fmiGetModelName, fmiGetGUID, fmiGetGenerationTool, fmiGetGenerationDateAndTime

export fmiProvidesDirectionalDerivative
export fmiIsCoSimulation, fmiIsModelExchange, fmiIsScheduledExecution
export fmiGetDependencies
export fmiGetStartValue, fmiStringToValueReference
export fmiGet, fmiGet!, fmiSet
export fmiGetSolutionTime, fmiGetSolutionState, fmiGetSolutionDerivative, fmiGetSolutionValue
export fmiGetNumberOfStates

export fmiGetState, fmiSetState, fmiFreeState!

### EXPORTING LISTS END ###

"""
    (str::Union{fmi2Struct, fmi3Struct})(; t::Tuple{Float64, Float64}, kwargs...)

Wrapper for dispatch to [`fmiSimulate`](@ref).
"""
function (str::Union{fmi2Struct, fmi3Struct})(; t::Tuple{Float64, Float64}, kwargs...)
    fmiSimulate(str, t; kwargs...)
end

"""
    fmiGetState(str::fmi2Struct)

Wrapper for [`fmi2GetFMUstate`](@ref).

See also [`fmiSetState`](@ref), [`fmiFreeState!`](@ref).
"""
function fmiGetState(str::fmi2Struct)
    fmi2GetFMUstate(str)
end

"""
    fmiGetState(str::fmi3Struct)

Wrapper for [`fmi3GetFMUState`](@ref).

See also [`fmiSetState`](@ref), [`fmiFreeState!`](@ref).
"""
function fmiGetState(str::fmi3Struct)
    fmi3GetFMUState(str)
end

"""
    fmiFreeState!(str::fmi2Struct, args...; kwargs...)

Wrapper for [`fmi2FreeFMUstate!`](@ref).

See also [`fmiSetState`](@ref), [`fmiGetState`](@ref).
"""
function fmiFreeState!(str::fmi2Struct, args...; kwargs...)
    fmi2FreeFMUstate!(str, args...; kwargs...)
end

"""
    fmiFreeState!(str::fmi3Struct, args...; kwargs...)

Wrapper for [`fmi3FreeFMUState!`](@ref).

See also [`fmiSetState`](@ref), [`fmiGetState`](@ref).
"""
function fmiFreeState!(str::fmi3Struct, args...; kwargs...)
    fmi3FreeFMUState!(str, args...; kwargs...)
end

"""
    fmiSetState(str::fmi2Struct, args...; kwargs...)

Wrapper for [`fmi2SetFMUstate`](@ref).

See also [`fmiGetState`](@ref), [`fmiFreeState!`](@ref).
"""
function fmiSetState(str::fmi2Struct, args...; kwargs...)
    fmi2SetFMUstate(str, args...; kwargs...)
end

"""
    fmiSetState(str::fmi3Struct, args...; kwargs...)

Wrapper for [`fmi3SetFMUState`](@ref).

See also [`fmiGetState`](@ref), [`fmiFreeState!`](@ref).
"""
function fmiSetState(str::fmi3Struct, args...; kwargs...)
    fmi3SetFMUState(str, args...; kwargs...)
end

"""
    fmiGetDependencies(fmu::FMU2)

Wrapper for [`fmi2GetDependencies`](@ref).
"""
function fmiGetDependencies(fmu::FMU2)
    fmi2GetDependencies(fmu)
end

"""
    fmiGetDependencies(fmu::FMU3)

Wrapper for [`fmi3GetDependencies`](@ref).
"""
function fmiGetDependencies(fmu::FMU3)
    fmi3GetDependencies(fmu)
end

"""
    fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, AbstractArray{String}})

Wrapper for [`fmi2StringToValueReference`](@ref).

See also [`fmi2ValueReferenceToString`](@ref).
"""
function fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, AbstractArray{String}})
    fmi2StringToValueReference(dataStruct, identifier)
end

"""
    fmiStringToValueReference(dataStruct::Union{FMU3, fmi3ModelDescription}, identifier::Union{String, AbstractArray{String}})

Wrapper for [`fmi3StringToValueReference`](@ref).
    
See also [`fmi3ValueReferenceToString`](@ref).
"""
function fmiStringToValueReference(dataStruct::Union{FMU3, fmi3ModelDescription}, identifier::Union{String, AbstractArray{String}})
    fmi3StringToValueReference(dataStruct, identifier)
end

"""
    fmiGetModelName(str::fmi2StructMD)

Return the `modelName` from `str`'s model description.

Wrapper for [`fmi2GetModelName`](@ref).
"""
function fmiGetModelName(str::fmi2StructMD)
    fmi2GetModelName(str)
end

"""
    fmiGetModelName(str::fmi3StructMD)

Return the `modelName` from `str`'s model description.

Wrapper for [`fmi3GetModelName`](@ref).
"""
function fmiGetModelName(str::fmi3StructMD)
    fmi3GetModelName(str)
end

# TODO call differently in fmi3: getInstantationToken
"""  
    fmiGetGUID(str::fmi2StructMD)

Return the `guid` from `str`'s model description.

Wrapper for [`fmi2GetGUID`](@ref).
"""
function fmiGetGUID(str::fmi2StructMD)
    fmi2GetGUID(str)
end

"""  
    fmiGetGenerationTool(str::fmi2StructMD)

Returns the `generationtool` from `str`'s model description.

Wrapper for [`fmi2GetGenerationTool`](@ref).
"""
function fmiGetGenerationTool(str::fmi2StructMD)
    fmi2GetGenerationTool(str)
end

"""  
    fmiGetGenerationTool(str::fmi3StructMD)

Returns the `generationtool` from `str`'s model description.

Wrapper for [`fmi3GetGenerationTool`](@ref).
"""
function fmiGetGenerationTool(str::fmi3StructMD)
    fmi3GetGenerationTool(str)
end

"""
    fmiGetGenerationDateAndTime(str::fmi2StructMD)

Returns the `generationdateandtime` from `str`'s model description.

Wrapper for [`fmi2GetGenerationDateAndTime`](@ref).
"""
function fmiGetGenerationDateAndTime(str::fmi2StructMD)
    fmi2GetGenerationDateAndTime(str)
end

"""
    fmiGetGenerationDateAndTime(str::fmi3StructMD)

Returns the `generationdateandtime` from `str`'s model description.

Wrapper for [`fmi3GetGenerationDateAndTime`](@ref).
"""
function fmiGetGenerationDateAndTime(str::fmi3StructMD)
    fmi3GetGenerationDateAndTime(str)
end

"""
    fmiGetVariableNamingConvention(str::fmi2StructMD)

Returns the `varaiblenamingconvention` from `str`'s model description.

Wrapper for [`fmi2GetVariableNamingConvention`](@ref).
"""
function fmiGetVariableNamingConvention(str::fmi2StructMD)
    fmi2GetVariableNamingConvention(str)
end

"""
    fmiGetVariableNamingConvention(str::fmi3StructMD)

Returns the `varaiblenamingconvention` from `str`'s model description.

Wrapper for [`fmi3GetVariableNamingConvention`](@ref).
"""
function fmiGetVariableNamingConvention(str::fmi3StructMD)
    fmi3GetVariableNamingConvention(str)
end

"""
    fmiGetNumberOfEventIndicators(str::fmi2StructMD)

Returns the `numberOfEventIndicators` from `str`'s model description.

Wrapper for [`fmi2GetNumberOfEventIndicators`](@ref).
"""
function fmiGetNumberOfEventIndicators(str::fmi2StructMD)
    fmi2GetNumberOfEventIndicators(str)
end

"""
    fmiGetNumberOfEventIndicators(str::fmi3StructMD)

Returns the `numberOfEventIndicators` from `str`'s model description.

Wrapper for [`fmi3GetNumberOfEventIndicators`](@ref).
"""
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

See also [`fmi2ProvidesDirectionalDerivative`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`fmi3ProvidesDirectionalDerivatives`](@ref), [`fmi3StructMD`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref), [`fmi3ModelDescription`](@ref).
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
function fmiIsScheduledExecution(str::fmi3StructMD)
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

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
- FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions


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
    fmiSimulate(str::fmi2Struct, args...; kwargs...)

Start a simulation of the FMU instance `str` for the matching FMU version and type.

Wrapper for [`fmi2Simulate`](@ref).
"""
function fmiSimulate(str::fmi2Struct, args...; kwargs...)
    fmi2Simulate(str, args...; kwargs...)
end

"""
    fmiSimulate(str::fmi3Struct, args...; kwargs...)

Start a simulation of the FMU instance `str` for the matching FMU version and type.

Wrapper for [`fmi3Simulate`](@ref).
"""
function fmiSimulate(str::fmi3Struct, args...; kwargs...)
    fmi3Simulate(str, args...; kwargs...)
end

"""
    fmiSimulateCS(str::fmi2Struct, args...; kwargs...)

Start a simulation of the Co-Simulation FMU instance `str`.

Wrapper for [`fmi2SimulateCS`](@ref).
"""
function fmiSimulateCS(str::fmi2Struct, args...; kwargs...)
    fmi2SimulateCS(str, tspan, args...; kwargs...)
end

"""
    fmiSimulateCS(str::fmi3Struct, args...; kwargs...)

Start a simulation of the Co-Simulation FMU instance `str`.

Wrapper for [`fmi3SimulateCS`](@ref).
"""
function fmiSimulateCS(str::fmi3Struct, args...; kwargs...)
    fmi3SimulateCS(str, args...; kwargs...)
end

"""
    fmiSimulateME(str::Union{fmi2Struct,fmi3Struct}, tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing;
                    tolerance::Union{Real, Nothing} = nothing,
                    dt::Union{Real, Nothing} = nothing,
                    solver = nothing,
                    customFx = nothing,
                    recordValues::fmi2ValueReferenceFormat = nothing,
                    saveat = nothing,
                    x0::Union{AbstractArray{<:Real}, Nothing} = nothing,
                    setup::Union{Bool, Nothing} = nothing,
                    reset::Union{Bool, Nothing} = nothing,
                    instantiate::Union{Bool, Nothing} = nothing,
                    freeInstance::Union{Bool, Nothing} = nothing,
                    terminate::Union{Bool, Nothing} = nothing,
                    inputValueReferences::fmi2ValueReferenceFormat = nothing,
                    inputFunction = nothing,
                    parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing,
                    dtmax::Union{Real, Nothing} = nothing,
                    callbacks = [],
                    showProgress::Bool = true,
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
 - `tspan::Union{Tuple{Float64, Float64}, Nothing}=nothing`: Sets the time span as a tuple or the default value from the model description is used. 

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: AbstractArray of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = nothing`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `x0::Union{AbstractArray{<:Real}, Nothing} = nothing`: Stores the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference to the input variable vr (vr = vrs[i]). And is therefore passed within prepareSolveFMU to fmi2Set , to set the start state.
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `instantiate::Union{Bool, Nothing} = nothing`: Boolean value that decides whether to create a new instance of the specified fmu.
- `freeInstance::Union{Bool, Nothing} = nothing`: Boolean value that determines whether to dispose of the given instance, unload the loaded model, and free the allocated memory and other resources allocated by the FMU interface functions.
- `terminate::Union{Bool, Nothing} = nothing`: Boolean value that tells the FMU that the simulation run will be aborted.
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: AbstractArray of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `callbacks = []`: custom callbacks to add.
- `showProgress::Bool = true`: Boolean value that determines whether a progress bar is generated for a task
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

#to add to docstring: see also [`fmi3GetNumberOfStates`](@ref)
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

See also [`fmi2GetNumberOfStates`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), , [`fmi3Struct`](@ref), [`FMU3`](@ref), [`FMU3Instance`](@ref).
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

Stors the specific value of `fmi2ScalarVariable` containing the modelVariables with the identical fmi2ValueReference in an array.

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

export fmiGetReal


"""
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
- `steps::Array{fmi2Real} = ones(fmi2Real, length(vKnown_ref)).*1e-5`: Predefined step size vector `steps`, where all entries have the value 1e-5.
- `steps::Union{AbstractArray{fmi2Real}, Nothing} = nothing`:  Step size to be used for numerical differentiation. If nothing, a default value will be chosen automatically.

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
"""
function fmiSampleJacobian!(str::fmi3Struct, args...; kwargs...)
    fmi3SampleJacobian!(str, args...; kwargs...)
end
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

"""
    fmiSaveSolution(solution::FMUSolution, filepath::AbstractString [; keyword="solution"])

Save a `solution` of an FMU simulation at `filepath`.

Currently .mat, .jld2 and .csv are supported for saving and selected by the ending of `filepath`.
For JLD2 the `keyword` is used as key.
Loading a FMUSolution into FMI.jl is currently only possible for .jld2 files.

See also [`fmiSaveSolutionCSV`](@ref), [`fmiSaveSolutionMAT`](@ref), [`fmiSaveSolutionJLD2`](@ref), [`fmiLoadSolutionJLD2`](@ref).
"""
function fmiSaveSolution(solution::FMUSolution, filepath::AbstractString; keyword="solution")
    ending = split(filepath, ".")[2]
    if ending == "mat"
        fmiSaveSolutionMAT(solution, filepath)
    elseif ending == "jld2"
        fmiSaveSolutionJLD2(solution, filepath; keyword="solution")
    elseif ending == "csv"
        fmiSaveSolutionCSV(solution, filepath)
    else
        @assert false "This file format is currently not supported, please use *.mat, *.csv, *.JLD2"
    end
end

"""
    fmiLoadSolution(filepath::AbstractString; keyword="solution")

Wrapper for [`fmiLoadSolutionJLD2`](@ref).
"""
function fmiLoadSolution(filepath::AbstractString; keyword="solution")
    ending = split(filepath, ".")[2]
    if ending == "jld2"
        fmiLoadSolutionJLD2(filepath; keyword="solution")
    else
        @warn "This file format is currently not supported, please use *.jld2"
    end
end
export fmiSaveSolution, fmiLoadSolution

end # module FMI
