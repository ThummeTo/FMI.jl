#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

@debug "Debugging messages enabled for FMI.jl ..."

using Requires

using FMIImport
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
import FMIImport: fmi2GetStartValue, fmi2SampleDirectionalDerivative, fmi2CompletedIntegratorStep
import FMIImport: fmi2Unzip, fmi2Load, loadBinary, fmi2Reload, fmi2Unload, fmi2Instantiate!
import FMIImport: fmi2SampleDirectionalDerivative!
import FMIImport: fmi2GetJacobian, fmi2GetJacobian!, fmi2GetFullJacobian, fmi2GetFullJacobian!
import FMIImport: fmi2LoadModelDescription
import FMIImport: fmi2GetDefaultStartTime, fmi2GetDefaultStopTime, fmi2GetDefaultTolerance, fmi2GetDefaultStepSize
import FMIImport: fmi2GetModelName, fmi2GetGUID, fmi2GetGenerationTool, fmi2GetGenerationDateAndTime, fmi2GetVariableNamingConvention, fmi2GetNumberOfEventIndicators, fmi2GetNumberOfStates, fmi2IsCoSimulation, fmi2IsModelExchange
import FMIImport: fmi2DependenciesSupported, fmi2GetModelIdentifier, fmi2CanGetSetState, fmi2CanSerializeFMUstate, fmi2ProvidesDirectionalDerivative
import FMIImport: fmi2Get, fmi2Get!, fmi2Set 
import FMIImport: fmi2GetSolutionTime, fmi2GetSolutionState, fmi2GetSolutionValue
export fmi2GetSolutionTime, fmi2GetSolutionState, fmi2GetSolutionValue

using FMIExport
using FMIExport: fmi2Create, fmi2CreateSimple

using FMIImport.FMICore: fmi2ValueReference, fmi3ValueReference
using FMIImport: fmi2ValueReferenceFormat, fmi3ValueReferenceFormat, fmi2StructMD, fmi3StructMD, fmi2Struct, fmi3Struct

using FMIImport.FMICore: FMU2, FMU3, FMU2Component, FMU3Component
export FMU2, FMU3, FMU2Component, FMU3Component

using FMIImport.FMICore: FMU2ExecutionConfiguration, FMU_EXECUTION_CONFIGURATION_RESET, FMU_EXECUTION_CONFIGURATION_NO_RESET, FMU_EXECUTION_CONFIGURATION_NO_FREEING
export FMU2ExecutionConfiguration, FMU_EXECUTION_CONFIGURATION_RESET, FMU_EXECUTION_CONFIGURATION_NO_RESET, FMU_EXECUTION_CONFIGURATION_NO_FREEING

using FMIImport: prepareValue, prepareValueReference

include("FMI1_additional.jl")
include("FMI2_additional.jl")
include("FMI3_additional.jl")
include("assertions.jl")

include("FMI1_comp_wraps.jl")
include("FMI2_comp_wraps.jl")
include("FMI3_comp_wraps.jl")

include("FMI2_sim.jl")
include("FMI3_sim.jl")

function fmiPlot(solution::FMU2Solution; kwargs...)
    @warn "fmiPlot(...) needs `Plots` package. Please do `using Plots` or `import Plots`."
end
function fmiPlot!(fig, solution::FMU2Solution; kwargs...)
    @warn "fmiPlot!(...) needs `Plots` package. Please do `using Plots` or `import Plots`." 
end
function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        import .Plots
        include("FMI2_plot.jl")
        include("FMI3_plot.jl")
    end 
end
export fmiPlot, fmiPlot!

### EXPORTING LISTS START ###

# FMI.jl
export fmiLoad, fmiReload, fmiSimulate, fmiSimulateCS, fmiSimulateME, fmiUnload
export fmiGetNumberOfStates, fmiGetTypesPlatform, fmiGetVersion, fmiInstantiate!, fmiFreeInstance!
export fmiSetDebugLogging, fmiSetupExperiment, fmiEnterInitializationMode, fmiExitInitializationMode, fmiTerminate , fmiReset
export fmiGetReal, fmiSetReal, fmiGetInteger, fmiSetInteger, fmiGetBoolean, fmiSetBoolean, fmiGetString, fmiSetString, fmiGetReal!, fmiGetInteger!, fmiGetBoolean!, fmiGetString!
export fmiSetRealInputDerivatives, fmiGetRealOutputDerivatives
export fmiGetFMUstate, fmiSetFMUstate, fmiFreeFMUstate!, fmiSerializedFMUstateSize, fmiSerializeFMUstate, fmiDeSerializeFMUstate
export fmiGetDirectionalDerivative, fmiSampleDirectionalDerivative, fmiGetDirectionalDerivative!, fmiSampleDirectionalDerivative!
export fmiDoStep, fmiSetTime, fmiSetContinuousStates, fmiEnterEventMode, fmiNewDiscreteStates
export fmiEnterContinuousTimeMode, fmiCompletedIntegratorStep, fmiGetDerivatives, fmiGetEventIndicators, fmiGetContinuousStates, fmiGetNominalsOfContinuousStates
export fmiInfo
export fmiGetModelName, fmiGetGUID, fmiGetGenerationTool, fmiGetGenerationDateAndTime
export fmiGetVariableNamingConvention, fmiGetNumberOfEventIndicators
export fmiCanGetSetState, fmiCanSerializeFMUstate
export fmiProvidesDirectionalDerivative
export fmiIsCoSimulation, fmiIsModelExchange
export fmiGetDependencies
export fmiGetStartValue
export fmiSimulate, fmiSimulateCS, fmiSimulateME
export fmiGet, fmiGet!, fmiSet
export fmiGetSolutionTime, fmiGetSolutionState, fmiGetSolutionValue

export fmiSetFctGetTypesPlatform, fmiSetFctGetVersion
export fmiSetFctInstantiate, fmiSetFctFreeInstance, fmiSetFctSetDebugLogging, fmiSetFctSetupExperiment, fmiSetEnterInitializationMode, fmiSetFctExitInitializationMode
export fmiSetFctTerminate, fmiSetFctReset
export fmiSetFctGetReal, fmiSetFctGetInteger, fmiSetFctGetBoolean, fmiSetFctGetString, fmiSetFctSetReal, fmiSetFctSetInteger, fmiSetFctSetBoolean, fmiSetFctSetString
export fmiSetFctSetTime, fmiSetFctSetContinuousStates, fmiSetFctEnterEventMode, fmiSetFctNewDiscreteStates, fmiSetFctEnterContinuousTimeMode, fmiSetFctCompletedIntegratorStep
export fmiSetFctGetDerivatives, fmiSetFctGetEventIndicators, fmiSetFctGetContinuousStates, fmiSetFctGetNominalsOfContinuousStates

### EXPORTING LISTS END ###

"""

    fmiGetDependencies(fmu::FMU2)

Building dependency matrix `dim x dim` for fast look-ups on variable dependencies (`dim` is number of states).    

#Arguments
- `fmu::FMU2`: Mutable Struct representing a FMU in [FMI Standard Version 2.0.2](https://fmi-standard.org/).

See also [`fmi2GetDependencies`](@ref), [`FMU2`](@ref).  
"""
function fmiGetDependencies(fmu::FMU2)
    fmi2GetDependencies(fmu)
end

"""   

    fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription, FMU3, fmmi3ModelDescription}, identifier::Union{String, Array{String}})

Returns the ValueReference coresponding to the variable identifier.

# Arguments
- `dataStruct::Union{FMU2, fmi2ModelDescription, FMU3, fmmi3ModelDescription}`: Model of the type FMU2/FMU3 or the Model Description of fmi2/fmi3. Same for Model of type FMU3 or the Model Description of fmi3
- `identifier::Union{String, Array{String}}`: Variable identifier in type String or as a 1-dimensional Array containing elements of type String

See also [`fmi2StringToValueReference`](@ref), [`fmi3StringToValueReference`](@ref).
"""  
function fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, Array{String}})
    fmi2StringToValueReference(dataStruct, identifier)
end
function fmiStringToValueReference(dataStruct::Union{FMU3, fmi3ModelDescription}, identifier::Union{String, Array{String}})
    fmi3StringToValueReference(dataStruct, identifier)
end

# Wrapping modelDescription Functions
"""  

    fmiGetModelName(str::Union{fmi2StructMD, fmi3StructMD})  

Returns the tag 'modelName' from the model description.

# Arguments
- `str::Union{fmi2StructMD, fmi3StructMD}`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/) or [FMI 3.0 Standard](https://fmi-standard.org/). Other notation:
 `Union{fmi2StructMD, fmi3StructMD} = Union{FMU2, FMU2Component, fmi2ModelDescription, FMU3, FMU3Component, fmi3ModelDescription}`
  - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
  - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
  - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.
  - `str::FMU3`: Mutable struct representing an FMU in the [FMI 3.0 Standard](https://fmi-standard.org/).
  - `str::FMU3Component`:  Mutable struct represents a pointer to an FMU specific data structure that contains the information needed. Also in [FMI 3.0 Standard](https://fmi-standard.org/).
  - `str::fmi3ModelDescription`: Struct witch provides the static information of ModelVariables.

See also [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref), [`FMU3`](@ref), [`FMU3Component`](@ref), [`fmi3ModelDescription`](@ref).
"""
function fmiGetModelName(str::fmi2StructMD)
    fmi2GetModelName(str)
end
function fmiGetModelName(str::fmi3StructMD)
    fmi3GetModelName(str)
end

"""  

    fmiGetGUID(str::fmi2StructMD)

Returns the tag 'guid' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/). More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.

See also [`fmi2GetGUID`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).  
"""
function fmiGetGUID(str::fmi2StructMD)
    fmi2GetGUID(str)
end

"""  

    fmiGetGenerationTool(str::fmi2StructMD)

Returns the tag 'generationtool' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.

# Returns
- `str.generationtool`: The function `fmi2GetGenerationTool` returns the tag 'generationtool' from the struct, representing a FMU (`str`).

See also [`fmi2GetGenerationTool`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).  

"""
function fmiGetGenerationTool(str::fmi2StructMD)
    fmi2GetGenerationTool(str)
end

"""

    fmiGetGenerationDateAndTime(str::fmi2StructMD)

Returns the tag 'generationdateandtime' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.generationDateAndTime`: The function `fmi2GetGenerationDateAndTime` returns the tag 'generationDateAndTime' from the struct, representing a FMU (`str`).

See also [`fmi2GetGenerationDateAndTime`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).  

"""
function fmiGetGenerationDateAndTime(str::fmi2StructMD)
    fmi2GetGenerationDateAndTime(str)
end

"""

    fmiGetVariableNamingConvention(str::fmi2StructMD)

Returns the tag 'varaiblenamingconvention' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 More detailed:  `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.variableNamingConvention`: The function `fmi2GetVariableNamingConvention` returns the tag 'variableNamingConvention' from the struct, representing a FMU (`str`).


See also [`fmi2GetVariableNamingConvention`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiGetVariableNamingConvention(str::fmi2StructMD)
    fmi2GetVariableNamingConvention(str)
end

"""  

    fmiGetNumberOfEventIndicators(str::fmi2StructMD)

Returns the tag 'numberOfEventIndicators' from the model description.

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `str.numberOfEventIndicators`: The function `fmi2GetNumberOfEventIndicators` returns the tag 'numberOfEventIndicators' from the struct, representing a FMU (`str`).

See also [`fmi2GetNumberOfEventIndicators`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).

"""
function fmiGetNumberOfEventIndicators(str::fmi2StructMD)
    fmi2GetNumberOfEventIndicators(str)
end

"""  

    fmiGetModelIdentifier(fmu::FMU2)

Returns the tag 'modelIdentifier' from CS or ME section.

# Arguments
 - `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).

# Returns
- `fmu.modelDescription.coSimulation.modelIdentifier`: The function `fmiGetModelIdentifier` returns the tag 'coSimulation.modelIdentifier' from the model description of the FMU2-struct (`fmu.modelDescription`), if the FMU supports co simulation.
- `fmu.modelDescription.modelExchange.modelIdentifier`: The function `fmiGetModelIdentifier` returns the tag 'modelExchange.modelIdentifier'  from the model description of the FMU2-struct (`fmu.modelDescription`), if the FMU supports model exchange

Also see [`fmi2GetModelIdentifier`](@ref), [`FMU2`](@ref).

"""
function fmiGetModelIdentifier(fmu::FMU2)
    fmi2GetModelIdentifier(fmu.modelDescription; type=fmu.type)
end

"""

    fmiCanGetSetState(str::fmi2StructMD)

Returns true, if the FMU supports the getting/setting of states

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2CanGetSetState` returns True, if the FMU supports the getting/setting of states.

See also [`fmi2CanGetSetState`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiCanGetSetState(str::fmi2StructMD)
    fmi2CanGetSetState(str)
end

"""

    fmiCanSerializeFMUstate(str::fmi2StructMD)

Returns true, if the FMU state can be serialized

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct wich provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2CanSerializeFMUstate` returns True, if the FMU state can be serialized.

See also [`fmi2CanSerializeFMUstate`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiCanSerializeFMUstate(str::fmi2StructMD)
    fmi2CanSerializeFMUstate(str)
end

"""

    fmiProvidesDirectionalDerivative(str::fmi2StructMD)

Returns true, if the FMU provides directional derivatives

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
- `::Bool`: The function `fmi2ProvidesDirectionalDerivative` returns True, if the FMU provides directional derivatives.

See also [`fmi2ProvidesDirectionalDerivative`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiProvidesDirectionalDerivative(str::fmi2StructMD)
    fmi2ProvidesDirectionalDerivative(str)
end

"""

    fmiIsCoSimulation(str::fmi2StructMD)

Returns true, if the FMU supports co simulation

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2IsCoSimulation` returns True, if the FMU supports co simulation

See also [`fmi2IsCoSimulation`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiIsCoSimulation(str::fmi2StructMD)
    fmi2IsCoSimulation(str)
end

"""

    fmiIsModelExchange(str::fmi2StructMD)

Returns true, if the FMU supports model exchange

# Arguments
- `str::fmi2StructMD`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2StructMD =  Union{FMU2, FMU2Component, fmi2ModelDescription}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::fmi2ModelDescription`: Struct witch provides the static information of ModelVariables.

# Returns
 - `::Bool`: The function `fmi2IsCoSimulation` returns True, if the FMU supports model exchange.

See also [`fmi2IsModelExchange`](@ref), [`fmi2StructMD`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref), [`fmi2ModelDescription`](@ref).
"""
function fmiIsModelExchange(str::fmi2StructMD)
    fmi2IsModelExchange(str)
end

# Multiple Dispatch variants for FMUs with version 2.0.X

"""

   fmiLoad(pathToFMU::String; unpackPath=nothing, type=nothing)

Load FMUs independent of the FMI version, currently supporting version 2.0.X.

# Arguments
- `pathToFMU::String`: String that contains the paths of ziped and unziped FMU folders.

# Keywords
- `unpackPath=nothing`: Via optional argument ```unpackPath```, a path to unpack the FMU can be specified (default: system temporary directory).
- `type::Union{CS, ME} = nothing`:  Via ```type```, a FMU type can be selected. If none of the unified type set is used, the default value `type = nothing` will be used.

# Returns
- Returns the instance of the FMU struct.

See also [`fmi2Load`](@ref).
"""
function fmiLoad(args...; kwargs...)
    fmi2Load(args...; kwargs...)
end

"""

    fmiReload(fmu::FMU2)

Reloads the FMU-binary. This is useful, if the FMU does not support a clean reset implementation.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).


See also [`fmi2Reload`](@ref).
"""
function fmiReload(fmu::FMU2, args...; kwargs...)
    fmi2Reload(fmu, args...; kwargs...)
end

"""

    fmiSimulate(str::fmi2Struct, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
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
- - `str::fmi2Struct`: Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
- `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
- `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Array of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns   
- `success::Bool` for CS-FMUs  
- `ODESolution` for ME-FMUs  
- if keyword `recordValues` is set, a tuple of type (success::Bool, DiffEqCallbacks.SavedValues) for CS-FMUs  
- if keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues) for ME-FMUs  

See also [`fmi2Simulate`](@ref), [`fmi2SimulateME`](@ref), [`fmi2SimulateCS`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).   

"""
function fmiSimulate(str::fmi2Struct, args...; kwargs...)
    fmi2Simulate(str, args...; kwargs...)
end

"""

    fmiSimulateCS(str::fmi2Struct, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
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
- `str::fmi2Struct`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
- `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
- `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Array of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns   
- If keyword `recordValues` is not set, a boolean `success` is returned (simulation success).
- If keyword `recordValues` is set, a tuple of type (true, DiffEqCallbacks.SavedValues) or (false, nothing).  

See also [`fmi2SimulateCS`](@ref), [`fmi2Simulate`](@ref), [`fmi2SimulateME`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).

"""  
function fmiSimulateCS(str::fmi2Struct, args...; kwargs...)
    fmi2SimulateCS(str, args...; kwargs...)
end

"""

    fmiSimulateME(str::fmi2Struct, t_start::Union{Real, Nothing} = nothing, t_stop::Union{Real, Nothing} = nothing;
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
- `str::fmi2Struct`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
- `t_start::Union{Real, Nothing} = nothing`: Set the start time to a value of type Real or the default value from the model description is used.
- `t_stop::Union{Real, Nothing} = nothing`: Set the end time to a value of type Real or the default value from the model description is used.

# Keywords
- `tolerance::Union{Real, Nothing} = nothing`: Real number to set the tolerance for any OED-solver
- `dt::Union{Real, Nothing} = nothing`: Real number to set the step size of the OED-solver. Defaults to an automatic choice if the method is adaptive. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `solver = nothing`: Any Julia-supported OED-solver  (default is Tsit5). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/solvers/ode_solve/#ode_solve)
- `customFx = nothing`: [deperecated] Ability to give a custom state derivative function ẋ=f(x,t)
- `recordValues::fmi2ValueReferenceFormat = nothing`: Array of variables (strings or variableIdentifiers) to record. Results are returned as `DiffEqCallbacks.SavedValues`
- `saveat = []`: Time points to save values at (interpolated). More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Output-Control)
- `setup::Bool = true`: Boolean, if FMU should be setup (default: setup=true)
- `reset::Union{Bool, Nothing} = nothing`: Boolean, if FMU should be reset before simulation (default: reset:=auto)
- `inputValueReferences::fmi2ValueReferenceFormat = nothing`: Array of input variables (strings or variableIdentifiers) to set at every simulation step
- `inputFunction = nothing`: Function to retrieve the values to set the inputs to
- `parameters::Union{Dict{<:Any, <:Any}, Nothing} = nothing`: Dictionary of parameter variables (strings or variableIdentifiers) and values (Real, Integer, Boolean, String) to set parameters during initialization
- `dtmax::Union{Real, Nothing} = nothing`: Real number for setting maximum dt for adaptive timestepping for the ODE solver. The default values are package dependent. More Info: [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai/stable/basics/common_solver_opts/#Stepsize-Control)
- `kwargs...`: Further parameters of already defined functions `solve(args..., kwargs...)` from the library [DifferentialEquations.jl](https://diffeq.sciml.ai/stable/#DifferentialEquations.jl:-Scientific-Machine-Learning-(SciML)-Enabled-Simulation-and-Estimation)

# Returns   
- If keyword `recordValues` is not set, a struct of type `ODESolution`.
- If keyword `recordValues` is set, a tuple of type (ODESolution, DiffEqCallbacks.SavedValues).

See also [`fmi2SimulateME`](@ref) [`fmi2SimulateCS`](@ref), [`fmi2Simulate`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).  

"""
function fmiSimulateME(str::fmi2Struct, args...; kwargs...)
    fmi2SimulateME(str, args...; kwargs...)
end

"""

    fmiUnload(fmu::FMU2)

Unloads the FMU and all its instances and frees the allocated memory.

# Arguments
- `fmu::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).

See also [`fmi2Unload`](@ref).
"""
function fmiUnload(fmu::FMU2)
    fmi2Unload(fmu)
end

"""

    fmiGetNumberOfStates(str::fmi2Struct)

Returns the number of states of the FMU.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).

# Returns
- Returns the length of the `str.stateValueReferences` array, which consists of `fmi2ValueReference` constants.

See also [`fmi2GetNumberOfStates`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetNumberOfStates(str::fmi2Struct)
    fmi2GetNumberOfStates(str)
end

"""

    fmiGetTypesPlatform(str::fmi2Struct)

Returns the header file used to compile the FMU. By default returns `default`, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the [FMI 2.0.2 Standard](https://fmi-standard.org/).
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the [FMI 2.0.2 Standard](https://fmi-standard.org/).

# Returns
-

See also [`fmi2GetVersion`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetTypesPlatform(str::fmi2Struct)
    fmi2GetTypesPlatform(str)
end

"""

    fmiGetVersion(str::fmi2Struct)

Returns the version of the FMU, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- Returns a string from the address of a C-style (NUL-terminated) string. The string represents the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”

# Source
 - FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
 - FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files
 - FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

See also [`fmi2GetVersion`](@ref), [`unsafe_string`](https://docs.julialang.org/en/v1/base/strings/#Base.unsafe_string), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiGetVersion(str::fmi2Struct)
    fmi2GetVersion(str)
end

"""

    fmiInfo(str::fmi2Struct)

Prints FMU-specific information into the REPL.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Source
 - FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)

See also [`fmi2Info`](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiInfo(str::fmi2Struct)
    fmi2Info(str)
end

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

"""

   fmiFreeInstance!(str::fmi2Struct)

Frees the allocated memory of the last instance of the FMU.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
- `status::fmi2Status`: returned by all functions to indicate the success of the function call

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [fmi2FreeInstance](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiFreeInstance!(str::fmi2Struct)
    fmi2FreeInstance!(str)
end

"""

    fmiSetDebugLogging(str::fmi2Struct)

Control the use of the logging callback function, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances
"""
function fmiSetDebugLogging(str::fmi2Struct)
    fmi2SetDebugLogging(str)
end

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
- `status::fmi2Status`: returned by all functions to indicate the success of the function call

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

See also [fmi2SetupExperiment](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiSetupExperiment(str::fmi2Struct, args...; kwargs...)
    fmi2SetupExperiment(str, args...; kwargs...)
end

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
-  `status::fmi2Status`: returned by all functions to indicate the success of the function call

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [fmi2EnterInitializationMode](@ref), [`fmi2Struct`](@ref), [`FMU2`](@ref), [`FMU2Component`](@ref).
"""
function fmiEnterInitializationMode(str::fmi2Struct)
    fmi2EnterInitializationMode(str)
end

"""

    fmiExitInitializationMode(str::fmi2Struct)

Informs the FMU to exit initialization mode, version independent.

# Arguments
- `str::fmi2Struct`:  Representative for an FMU in the FMI 2.0.2 Standard.
More detailed: `fmi2Struct = Union{FMU2, FMU2Component}`
 - `str::FMU2`: Mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
 - `str::FMU2Component`: Mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.

# Returns
-  Returns a warning if `str.state` is not called in `fmi2ComponentStateInitializationMode`.
-  `status::fmi2Status`: returned by all functions to indicate the success of the function call

# Source
- FMISpec2.0.2 Link: [https://fmi-standard.org/](https://fmi-standard.org/)
- FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU
- FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

 See also [fmi2ExitInitializationMode](@ref)
"""
function fmiExitInitializationMode(str::fmi2Struct)
    fmi2ExitInitializationMode(str)
end

"""
Informs the FMU that the simulation run is terminated, version independent.
"""
function fmiTerminate(str::fmi2Struct)
    fmi2Terminate(str)
end

"""
Resets the FMU after a simulation run, version independent.
"""
function fmiReset(str::fmi2Struct)
    fmi2Reset(str)
end

"""
ToDo
"""
function fmiGet(str::fmi2Struct, args...; kwargs...)
    fmi2Get(str, args...; kwargs...)
end

"""
ToDo
"""
function fmiGet!(str::fmi2Struct, args...; kwargs...)
    fmi2Get!(str, args...; kwargs...)
end

"""
ToDo
"""
function fmiSet(str::fmi2Struct, args...; kwargs...)
    fmi2Set(str, args...; kwargs...)
end

"""
Returns the real values of an array of variables
"""
function fmiGetReal(str::fmi2Struct, args...; kwargs...)
    fmi2GetReal(str, args...; kwargs...)
end

function fmiGetRealOutputDerivatives(str::fmi2Struct, args...; kwargs...)
    fmi2GetRealOutputDerivatives(str, args...; kwargs...)
end

"""
Writes the real values of an array of variables in the given field
"""
function fmiGetReal!(str::fmi2Struct, args...; kwargs...)
    fmi2GetReal!(str, args...; kwargs...)
end

"""
Set the values of an array of real variables
"""
function fmiSetReal(str::fmi2Struct, args...; kwargs...)
    fmi2SetReal(str, args...; kwargs...)
end

"""
ToDo
"""
function fmiSetRealInputDerivatives(str::fmi2Struct, args...; kwargs...)
    fmi2SetRealInputDerivatives(str, args...; kwargs...)
end

"""
Returns the integer values of an array of variables
"""
function fmiGetInteger(str::fmi2Struct,args...; kwargs...)
    fmi2GetInteger(str, args...; kwargs...)
end

"""
Writes the integer values of an array of variables in the given field
"""
function fmiGetInteger!(str::fmi2Struct, args...; kwargs...)
    fmi2GetInteger!(str, args...; kwargs...)
end

"""
Set the values of an array of integer variables
"""
function fmiSetInteger(str::fmi2Struct, args...; kwargs...)
    fmi2SetInteger(str, args...; kwargs...)
end

"""
Returns the boolean values of an array of variables
"""
function fmiGetBoolean(str::fmi2Struct, args...; kwargs...)
    fmi2GetBoolean(str, args...; kwargs...)
end

"""
Writes the boolean values of an array of variables in the given field
"""
function fmiGetBoolean!(str::fmi2Struct, args...; kwargs...)
    fmi2GetBoolean!(str, args...; kwargs...)
end

"""
Set the values of an array of boolean variables
"""
function fmiSetBoolean(str::fmi2Struct, args...; kwargs...)
    fmi2SetBoolean(str, args...; kwargs...)
end

"""
Returns the string values of an array of variables
"""
function fmiGetString(str::fmi2Struct, args...; kwargs...)
    fmi2GetString(str, args...; kwargs...)
end

"""
Writes the string values of an array of variables in the given field
"""
function fmiGetString!(str::fmi2Struct, args...; kwargs...)
    fmi2GetString!(str, args...; kwargs...)
end

"""
Set the values of an array of string variables
"""
function fmiSetString(str::fmi2Struct, args...; kwargs...)
    fmi2SetString(str, args...; kwargs...)
end

"""
Returns the FMU state of the fmu
"""
function fmiGetFMUstate(str::fmi2Struct)
    fmi2GetFMUstate(str)
end

"""
Sets the FMU to the given state
"""
function fmiSetFMUstate(str::fmi2Struct, args...; kwargs...)
    fmi2SetFMUstate(str, args...; kwargs...)
end

"""
Free the memory for the allocated FMU state
    """
function fmiFreeFMUstate!(str::fmi2Struct, args...; kwargs...)
    fmi2FreeFMUstate!(str, args...; kwargs...)
end

"""
Returns the size of the byte vector the FMU can be stored in
"""
function fmiSerializedFMUstateSize(str::fmi2Struct, args...; kwargs...)
    fmi2SerializedFMUstateSize(str, args...; kwargs...)
end

"""
Serialize the data in the FMU state pointer
"""
function fmiSerializeFMUstate(str::fmi2Struct, args...; kwargs...)
    fmi2SerializeFMUstate(str, args...; kwargs...)
end

"""
Deserialize the data in the FMU state pointer
"""
function fmiDeSerializeFMUstate(str::fmi2Struct, args...; kwargs...)
    fmi2DeSerializeFMUstate(str, args...; kwargs...)
end

"""
Returns the values of the directional derivatives.
"""
function fmiGetDirectionalDerivative(str::fmi2Struct, args...; kwargs...)
    fmi2GetDirectionalDerivative(str, args...; kwargs...)
end

"""
Returns the values of the directional derivatives (in-place).
"""
function fmiGetDirectionalDerivative!(str::fmi2Struct, args...; kwargs...)
    fmi2GetDirectionalDerivative!(str, args...; kwargs...)
end

"""
Does one step in the CoSimulation FMU
"""
function fmiDoStep(str::fmi2Struct, args...; kwargs...)
    fmi2DoStep(str, args...; kwargs...)
end

"""
Samples the values of the directional derivatives.
"""
function fmiSampleDirectionalDerivative(str::fmi2Struct, args...; kwargs...)
    fmi2SampleDirectionalDerivative(str, args...; kwargs...)
end

"""
Samples the values of the directional derivatives (in-place).
"""
function fmiSampleDirectionalDerivative!(str::fmi2Struct, args...; kwargs...)
    fmi2SampleDirectionalDerivative!(str, args...; kwargs...)
end

"""
Set a time instant
"""
function fmiSetTime(c::fmi2Struct, args...; kwargs...)
    fmi2SetTime(c, args...; kwargs...)
end

"""
Set a new (continuous) state vector
"""
function fmiSetContinuousStates(str::fmi2Struct, args...; kwargs...)
    fmi2SetContinuousStates(str, args...; kwargs...)
end

"""
The model enters Event Mode
"""
function fmi2EnterEventMode(str::fmi2Struct)
    fmi2EnterEventMode(str)
end

"""
Returns the next discrete states
"""
function fmiNewDiscreteStates(str::fmi2Struct)
    fmi2NewDiscreteStates(str)
end

"""
The model enters Continuous-Time Mode
"""
function fmiEnterContinuousTimeMode(str::fmi2Struct)
    fmi2EnterContinuousTimeMode(str)
end

"""
This function must be called by the environment after every completed step
"""
function fmiCompletedIntegratorStep(str::fmi2Struct, args...; kwargs...)
    fmi2CompletedIntegratorStep(str, args...; kwargs...)
end

"""
Compute state derivatives at the current time instant and for the current states
"""
function  fmiGetDerivatives(str::fmi2Struct)
    fmi2GetDerivatives(str)
end

"""
Returns the event indicators of the FMU
"""
function fmiGetEventIndicators(str::fmi2Struct)
    fmi2GetEventIndicators(str)
end

"""
Return the new (continuous) state vector x
"""
function fmiGetContinuousStates(s::fmi2Struct)
    fmi2GetContinuousStates(s)
end

"""
Return the new (continuous) state vector x
"""
function fmiGetNominalsOfContinuousStates(s::fmi2Struct)
    fmi2GetNominalsOfContinuousStates(s)
end

"""
Returns the start/default value for a given value reference.

TODO: Add this command in the documentation.
"""
function fmiGetStartValue(s::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetStartValue(s, vr)
end

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

function fmiGetSolutionValue(solution::FMU2Solution, args...; kwargs...)
    fmi2GetSolutionValue(solution, args...; kwargs...)
end

##### Multiple Dispatch fallback for FMUs with unsupported versions #####

unsupportedFMUs = Union{FMU1,FMU3}
function fmiDoStep(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiUnload(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiGetTypesPlatform(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiGetVersion(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiInfo(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiInstantiate!(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiFreeInstance!(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetDebugLogging(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetupExperiment(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiEnterInitializationMode(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiExitInitializationMode(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiTerminate(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiReset(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSimulate(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSimulateCS(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSimulateME(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function (fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetReal(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetReal!(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetReal(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetInteger(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetInteger!(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetInteger(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetBoolean(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetBoolean!(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetBoolean(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetString(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetString!(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetString(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetFMUstate(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetFMUstate(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiFreeFMUstate!(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSerializedFMUstateSize(c::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSerializeFMUstate(c::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiDeSerializeFMUstate(c::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiGetDirectionalDerivative(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetTime(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmiSetContinuousStates(c::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function fmi2EnterEventMode(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiNewDiscreteStates(c::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiEnterContinuousTimeMode(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiCompletedIntegratorStep(fmu::unsupportedFMUs, args...; kwargs...)
    error(unsupportedFMU::errorType)
end

function  fmiGetDerivatives(c::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiGetEventIndicators(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiGetContinuousStates(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiGetNominalsOfContinuousStates(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

# model description specific

function fmiGetModelName(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiGetGUID(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiGetGenerationTool(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiGetGenerationDateAndTime(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiGetVariableNamingConvention(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiGetNumberOfEventIndicators(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiCanGetSetState(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiCanSerializeFMUstate(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiProvidesDirectionalDerivative(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiIsCoSimulation(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end
function fmiIsModelExchange(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

end # module FMI
