#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

@debug "Debugging messages enabled for FMI.jl ..."

using Requires

using FMIImport
import FMIImport: fmi2CallbackLogger, fmi2CallbackAllocateMemory, fmi2CallbackFreeMemory, fmi2CallbackStepFinished
import FMIImport: fmi2ComponentState, fmi2ComponentStateModelSetableFMUstate, fmi2ComponentStateModelUnderEvaluation, fmi2ComponentStateModelInitialized
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

using FMIExport 
using FMIExport: fmi2Create, fmi2CreateSimple 

using FMIImport.FMICore: fmi2ValueReference, fmi3ValueReference
using FMIImport: fmi2ValueReferenceFormat, fmi3ValueReferenceFormat, fmi2StructMD, fmi3StructMD, fmi2Struct, fmi3Struct
using FMIImport.FMICore: FMU2, FMU3, FMU2Component, FMU3Component
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

function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin 
        import .Plots
        include("FMI2_plot.jl")
        include("FMI3_plot.jl")
        export fmiPlot, fmiPlot!
    end 
end

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

export fmiSetFctGetTypesPlatform, fmiSetFctGetVersion
export fmiSetFctInstantiate, fmiSetFctFreeInstance, fmiSetFctSetDebugLogging, fmiSetFctSetupExperiment, fmiSetEnterInitializationMode, fmiSetFctExitInitializationMode
export fmiSetFctTerminate, fmiSetFctReset
export fmiSetFctGetReal, fmiSetFctGetInteger, fmiSetFctGetBoolean, fmiSetFctGetString, fmiSetFctSetReal, fmiSetFctSetInteger, fmiSetFctSetBoolean, fmiSetFctSetString
export fmiSetFctSetTime, fmiSetFctSetContinuousStates, fmiSetFctEnterEventMode, fmiSetFctNewDiscreteStates, fmiSetFctEnterContinuousTimeMode, fmiSetFctCompletedIntegratorStep
export fmiSetFctGetDerivatives, fmiSetFctGetEventIndicators, fmiSetFctGetContinuousStates, fmiSetFctGetNominalsOfContinuousStates

### EXPORTING LISTS END ###

"""
Returns the FMU's depndency-matrix for fast look-ups on variable dependencies.

Enter ```fmi2GetDependencies``` for more information.
"""
function fmiGetDependencies(fmu::FMU2)
    fmi2GetDependencies(fmu)
end

"""
Returns the ValueReference coresponding to the variable name.

Enter ```fmi2String2ValueReference``` for more information.
"""
function fmiStringToValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, Array{String}})
    fmi2StringToValueReference(dataStruct, identifier)
end
function fmiStringToValueReference(dataStruct::Union{FMU3, fmi3ModelDescription}, identifier::Union{String, Array{String}})
    fmi3StringToValueReference(dataStruct, identifier)
end

# Wrapping modelDescription Functions
"""
Returns the tag 'modelName' from the model description.
"""
function fmiGetModelName(str::fmi2StructMD)
    fmi2GetModelName(str)
end
function fmiGetModelName(str::fmi3StructMD)
    fmi3GetModelName(str)
end

"""
Returns the tag 'guid' from the model description.
"""
function fmiGetGUID(str::fmi2StructMD)
    fmi2GetGUID(str)
end

"""
Returns the tag 'generationtool' from the model description.
"""
function fmiGetGenerationTool(str::fmi2StructMD)
    fmi2GetGenerationTool(str)
end

"""
Returns the tag 'generationdateandtime' from the model description.
"""
function fmiGetGenerationDateAndTime(str::fmi2StructMD)
    fmi2GetGenerationDateAndTime(str)
end

"""
Returns the tag 'varaiblenamingconvention' from the model description.
"""
function fmiGetVariableNamingConvention(str::fmi2StructMD)
    fmi2GetVariableNamingConvention(str)
end

"""
Returns the tag 'numberOfEventIndicators' from the model description.
"""
function fmiGetNumberOfEventIndicators(str::fmi2StructMD)
    fmi2GetNumberOfEventIndicators(str)
end

"""
Returns the tag 'modelIdentifier' from CS or ME section.
"""
function fmiGetModelIdentifier(fmu::FMU2)
    fmi2GetModelIdentifier(fmu.modelDescription; type=fmu.type)
end

"""
Returns true, if the FMU supports the getting/setting of states
"""
function fmiCanGetSetState(str::fmi2StructMD)
    fmi2CanGetSetState(str)
end

"""
Returns true, if the FMU state can be serialized
"""
function fmiCanSerializeFMUstate(str::fmi2StructMD)
    fmi2CanSerializeFMUstate(str)
end

"""
Returns true, if the FMU provides directional derivatives
"""
function fmiProvidesDirectionalDerivative(str::fmi2StructMD)
    fmi2ProvidesDirectionalDerivative(str)
end

"""
Returns true, if the FMU supports co simulation
"""
function fmiIsCoSimulation(str::fmi2StructMD)
    fmi2IsCoSimulation(str)
end

"""
Returns true, if the FMU supports model exchange
"""
function fmiIsModelExchange(str::fmi2StructMD)
    fmi2IsModelExchange(str)
end

# Multiple Dispatch variants for FMUs with version 2.0.X

"""
Load FMUs independent of the FMI version, currently supporting version 2.0.X.
"""
function fmiLoad(args...; kwargs...)
    fmi2Load(args...; kwargs...)
end

"""
Reloads the FMU-binary. This is useful, if the FMU does not support a clean reset implementation.
"""
function fmiReload(fmu::FMU2, args...; kwargs...)
    fmi2Reload(fmu, args...; kwargs...)
end

"""
Simulate an fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulate(str::fmi2Struct, args...; kwargs...)
    fmi2Simulate(str, args...; kwargs...)
end

"""
Simulate an CoSimulation fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulateCS(str::fmi2Struct, args...; kwargs...)
    fmi2SimulateCS(str, args...; kwargs...)
end

"""
Simulate an ModelExchange fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulateME(str::fmi2Struct, args...; kwargs...)
    fmi2SimulateME(str, args...; kwargs...)
end

"""
Unloads the FMU and all its instances and frees the allocated memory.
"""
function fmiUnload(fmu::FMU2)
    fmi2Unload(fmu)
end

"""
Returns the number of states of the FMU.
"""
function fmiGetNumberOfStates(str::fmi2Struct)
    fmi2GetNumberOfStates(str)
end

"""
Returns the header file used to compile the FMU. By default returns `default`, version independent.
"""
function fmiGetTypesPlatform(str::fmi2Struct)
    fmi2GetTypesPlatform(str)
end

"""
Returns the version of the FMU, version independent.
"""
function fmiGetVersion(str::fmi2Struct)
    fmi2GetVersion(str)
end

"""
Prints FMU-specific information into the REPL.
"""
function fmiInfo(str::fmi2Struct)
    fmi2Info(str)
end

"""
Creates a new instance of the FMU, version independent.
"""
function fmiInstantiate!(fmu::FMU2, args...; kwargs...)
    fmi2Instantiate!(fmu, args...; kwargs...)
end

"""
Frees the allocated memory of the last instance of the FMU.
"""
function fmiFreeInstance!(str::fmi2Struct)
    fmi2FreeInstance!(str)
end

"""
Control the use of the logging callback function, version independent.
"""
function fmiSetDebugLogging(str::fmi2Struct)
    fmi2SetDebugLogging(str)
end

"""
Initialize the Simulation boundries
"""
function fmiSetupExperiment(str::fmi2Struct, args...; kwargs...)
    fmi2SetupExperiment(str, args...; kwargs...)
end

"""
Informs the FMU to enter initializaton mode, version independent.
"""
function fmiEnterInitializationMode(str::fmi2Struct)
    fmi2EnterInitializationMode(str)
end

"""
Informs the FMU to exit initialization mode, version independent.
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
