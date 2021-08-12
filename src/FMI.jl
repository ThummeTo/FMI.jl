#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

"""
The mutable struct representing an abstract (version unknown) FMU.
"""
abstract type FMU end

include("FMI1.jl")
include("FMI2.jl")
include("FMI3.jl")
include("assertions.jl")

# ToDo: Submodules
include("FMI2_sim.jl")
include("FMI_plot.jl")

### EXPORTING LISTS START ###

export FMU

# FMI.jl
export fmiLoad, fmiSimulate, fmiSimulateCS, fmiSimulateME, fmiUnload
export fmiGetNumberOfStates, fmiGetTypesPlatform, fmiGetVersion, fmiInstantiate!, fmiFreeInstance!
export fmiSetDebugLogging, fmiSetupExperiment, fmiEnterInitializationMode, fmiExitInitializationMode, fmiTerminate , fmiReset
export fmiGetReal, fmiSetReal, fmiGetInteger, fmiSetInteger, fmiGetBoolean, fmiSetBoolean, fmiGetString, fmiSetString, fmiGetReal!, fmiGetInteger!, fmiGetBoolean!, fmiGetString!
export fmiGetFMUstate, fmiSetFMUstate, fmiFreeFMUstate, fmiSerializedFMUstateSize, fmiSerializeFMUstate, fmiDeSerializeFMUstate
export fmiGetDirectionalDerivative, fmiDoStep, fmiSetTime, fmiSetContinuousStates, fmi2EnterEventMode, fmiNewDiscreteStates
export fmiEnterContinuousTimeMode, fmiCompletedIntegratorStep, fmiGetDerivatives, fmiGetEventIndicators, fmiGetContinuousStates, fmiGetNominalsOfContinuousStates
export fmiInfo
export fmiGetModelName, fmiGetGUID, fmiGetGenerationTool, fmiGetGenerationDateAndTime
export fmiGetVariableNamingConvention, fmiGetNumberOfEventIndicators
export fmiCanGetSetState, fmiCanSerializeFMUstate
export fmiProvidesDirectionalDerivative
export fmiIsCoSimulation, fmiIsModelExchange
export fmiString2ValueReference

# FMI2.jl
export FMU2, fmi2True, fmi2False
export fmi2SimulationResult, fmi2SimulationResultGetValuesAtIndex, fmi2SimulationResultGetTime, fmi2SimulationResultGetValues
export fmi2ValueReference, fmi2String2ValueReference, fmi2ValueReference2String
export fmi2Unzip, fmi2Load, fmi2Unload
export fmi2GetTypesPlatform, fmi2GetVersion
export fmi2Instantiate!, fmi2FreeInstance!, fmi2SetDebugLogging
export fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
export fmi2GetReal, fmi2SetReal, fmi2GetInteger, fmi2SetInteger, fmi2GetBoolean, fmi2SetBoolean, fmi2GetString, fmi2SetString
export fmi2GetFMUstate, fmi2SetFMUstate, fmi2FreeFMUstate, fmi2SerializedFMUstateSize, fmi2SerializeFMUstate, fmi2DeSerializeFMUstate
export fmi2GetDirectionalDerivative
export fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives
export fmi2DoStep, fmi2CancelStep
export fmi2GetStatus, fmi2GetRealStatus, fmi2GetIntegerStatus, fmi2GetBooleanStatus, fmi2GetStringStatus
export fmi2SetTime, fmi2SetContinuousStates
export fmi2EnterEventMode, fmi2NewDiscreteStates, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep, fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates
export fmi2Info

# FMI2_comp.jl
export fmi2SetDebugLogging, fmi2SetupExperiment
export fmi2GetReal, fmi2SetReal, fmi2GetInteger, fmi2SetInteger, fmi2GetBoolean, fmi2SetBoolean, fmi2GetString, fmi2SetString
export fmi2GetFMUstate, fmi2FreeFMUstate, fmi2SerializedFMUstateSize, fmi2SerializeFMUstate, fmi2DeSerializeFMUstate
export fmi2GetDirectionalDerivative
export fmi2DoStep
export fmi2SetTime, fmi2SetContinuousStates
export fmi2NewDiscreteStates, fmi2CompletedIntegratorStep, fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates

# FMI2_c.jl
export fmi2Component
export fmi2Instantiate, fmi2SetDebugLogging # fmi2FreeInstance!
export fmi2GetTypesPlatform, fmi2GetVersion
export fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
export fmi2GetReal!, fmi2SetReal, fmi2GetInteger!, fmi2SetInteger, fmi2GetBoolean!, fmi2SetBoolean, fmi2GetString!, fmi2SetString
export fmi2GetFMUstate, fmi2SetFMUstate, fmi2FreeFMUstate, fmi2SerializedFMUstateSize, fmi2SerializeFMUstate, fmi2DeSerializeFMUstate
export fmi2GetDirectionalDerivative!
export fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives
export fmi2DoStep, fmi2CancelStep
export fmi2GetStatus, fmi2GetRealStatus, fmi2GetIntegerStatus, fmi2GetBooleanStatus, fmi2GetStringStatus
export fmi2SetTime, fmi2SetContinuousStates
export fmi2EnterEventMode, fmi2NewDiscreteStates, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep!, fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates

# FMI2_sim.jl
export fmi2Simulate, fmi2SimulateCS, fmi2SimulateME

# FMI_plot.jl
export fmiPlot

# FMI2_md.jl
export fmi2GetModelName, fmi2GetGUID
export fmi2GetGenerationTool, fmi2GetGenerationDateAndTime
export fmi2GetVariableNamingConvention, fmi2GetNumberOfEventIndicators
export fmi2CanGetSetState, fmi2CanSerializeFMUstate
export fmi2ProvidesDirectionalDerivative
export fmi2IsCoSimulation, fmi2IsModelExchange

### EXPORTING LISTS END ###

fmi2Struct = Union{FMU2, fmi2Component}

"""
Receives one or an array of value references in an arbitrary format (see fmi2ValueReferenceFormat) and converts it into an Array{fmi2ValueReference} (if not already).
"""
function prepareValueReference(md::fmi2ModelDescription, vr::fmi2ValueReferenceFormat)
    tvr = typeof(vr)
    if tvr == Array{fmi2ValueReference,1}
        return vr
    elseif tvr == fmi2ValueReference
        return [vr]
    elseif tvr == String
        return [fmi2String2ValueReference(md, vr)]
    elseif tvr == Array{String,1}
        return fmi2String2ValueReference(md, vr)
    elseif tvr == Int64
        return [fmi2ValueReference(vr)]
    elseif tvr == Array{Int64,1}
        return fmi2ValueReference.(vr)
    elseif tvr == Nothing
        return []
    end

    @assert false "prepareValueReference(...): Unknown value reference structure `$tvr`."
end
function prepareValueReference(fmu::FMU2, vr::fmi2ValueReferenceFormat)
    prepareValueReference(fmu.modelDescription, vr)
end
function prepareValueReference(comp::fmi2Component, vr::fmi2ValueReferenceFormat)
    prepareValueReference(comp.fmu.modelDescription, vr)
end

"""
Receives one or an array of values and converts it into an Array{typeof(value)} (if not already).
"""
function prepareValue(value)
    if isa(value, Array) && length(size(value)) == 1
        return value
    else
        return [value]
    end

    @assert false "prepareValue(...): Unknown dimension of structure `$dim`."
end

""" 
Returns the ValueReference coresponding to the variable name.
""" 
function fmiString2ValueReference(dataStruct::Union{FMU2, fmi2ModelDescription}, identifier::Union{String, Array{String}})
    fmi2String2ValueReference(dataStruct, identifier)
end

# Wrapping modelDescription Functions

function fmiGetModelName(fmu::FMU2)
    fmi2GetModelName(fmu)
end
function fmiGetGUID(fmu::FMU2)
    fmi2GetGUID(fmu)
end
function fmiGetGenerationTool(fmu::FMU2)
    fmi2GetGenerationTool(fmu)
end
function fmiGetGenerationDateAndTime(fmu::FMU2)
    fmi2GetGenerationDateAndTime(fmu)
end
function fmiGetVariableNamingConvention(fmu::FMU2)
    fmi2GetVariableNamingConvention(fmu)
end
function fmiGetNumberOfEventIndicators(fmu::FMU2)
    fmi2GetNumberOfEventIndicators(fmu)
end
function fmiCanGetSetState(fmu::FMU2)
    fmi2CanGetSetState(fmu)
end
function fmiCanSerializeFMUstate(fmu::FMU2)
    fmi2CanSerializeFMUstate(fmu)
end
function fmiProvidesDirectionalDerivative(fmu::FMU2)
    fmi2ProvidesDirectionalDerivative(fmu)
end
function fmiIsCoSimulation(fmu::FMU2)
    fmi2IsCoSimulation(fmu)
end
function fmiIsModelExchange(fmu::FMU2)
    fmi2IsModelExchange(fmu)
end

# Multiple Dispatch variants for FMUs with version 2.0.X

"""
Load FMUs independent of the FMI version, currently supporting version 2.0.X.
"""
function fmiLoad(pathToFMU::String; unpackPath=nothing)
    fmi2Load(pathToFMU; unpackPath=unpackPath)
end

"""
Simulate an fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulate(str::fmi2Struct, t_start::Real = 0.0, t_stop::Real = 1.0;
                     recordValues::fmi2ValueReferenceFormat = nothing, saveat = [], setup = true)
    fmi2Simulate(str, t_start, t_stop;
                 recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
Simulate an CoSimulation fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulateCS(str::fmi2Struct, t_start::Real = 0.0, t_stop::Real = 1.0;
                       recordValues::fmi2ValueReferenceFormat = nothing, saveat = [], setup = true)
    fmi2SimulateCS(str, t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
Simulate an ModelExchange fmu according to its standard from 0.0 to t_stop.
"""
function fmiSimulateME(str::fmi2Struct, t_start::Real = 0.0, t_stop::Real = 1.0;
                       recordValues::fmi2ValueReferenceFormat = nothing, saveat = [], setup = true, solver = nothing)
    fmi2SimulateME(str, t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup, solver=solver)
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

function fmiGetNumberOfStates(fmu::FMU2)
    length(fmu.modelDescription.stateValueReferences)
end

"""
Returns the header file used to compile the FMU. By default returns `default`, version independent.
"""
function fmiGetTypesPlatform(fmu::FMU2)
    fmi2GetTypesPlatform(fmu)
end

"""
Returns the version of the FMU, version independent.
"""
function fmiGetVersion(fmu::FMU2)
    fmi2GetVersion(fmu)
end

"""
Prints FMU-specific information into the REPL.
"""
function fmiInfo(fmu::FMU2)
    fmi2Info(fmu)
end

"""
Creates a new instance of the FMU, version independent.
"""
function fmiInstantiate!(fmu::FMU2; visible::Bool = false, loggingOn::Bool = false)

    version = fmiGetVersion(fmu)

    if version == "2.0"
        return fmi2Instantiate!(fmu; visible, loggingOn)
    else
        @assert false ["fmiInstantiate!(...): Unknwon FMI version $version !"]
    end

    nothing
end

"""
Frees the allocated memory of the last instance of the FMU.
"""
function fmiFreeInstance!(s::fmi2Struct)
    fmi2FreeInstance!(s)
end


"""
Control the use of the logging callback function, version independent.
"""
function fmiSetDebugLogging(s::fmi2Struct)
    fmi2SetDebugLogging(s)
end

"""
Initialize the Simulation boundries
"""
function fmiSetupExperiment(fmu::fmi2Struct, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)
    fmi2SetupExperiment(fmu, startTime, stopTime; tolerance=tolerance)
end


"""
Informs the FMU to enter initializaton mode, version independent.
"""
function fmiEnterInitializationMode(s::fmi2Struct)
    fmi2EnterInitializationMode(s)
end


"""
Informs the FMU to exit initialization mode, version independent.
"""
function fmiExitInitializationMode(s::fmi2Struct)
    fmi2ExitInitializationMode(s)
end

"""
Informs the FMU that the simulation run is terminated, version independent.
"""
function fmiTerminate(s::fmi2Struct)
    fmi2Terminate(s)
end

"""
Resets the FMU after a simulation run, version independent.
"""
function fmiReset(s::fmi2Struct)
    fmi2Reset(s)
end

"""
Returns the real values of an array of variables
"""
function fmiGetReal(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetReal(fmu, vr)
end

"""
Writes the real values of an array of variables in the given field
"""
function fmiGetReal!(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})
    fmi2GetReal!(fmu, vr, values)
end

"""
Set the values of an array of real variables
"""
function fmiSetReal(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})
    fmi2SetReal(fmu, vr, values)
end

"""
Returns the integer values of an array of variables
"""
function fmiGetInteger(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetInteger(fmu, vr)
end

"""
Writes the integer values of an array of variables in the given field
"""
function fmiGetInteger!(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})
    fmi2GetInteger!(fmu, vr, values)
end

"""
Set the values of an array of integer variables
"""
function fmiSetInteger(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})
    fmi2SetInteger(fmu, vr, values)
end

"""
Returns the boolean values of an array of variables
"""
function fmiGetBoolean(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetBoolean(fmu, vr)
end

"""
Writes the boolean values of an array of variables in the given field
"""
function fmiGetBoolean!(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    fmi2GetBoolean!(fmu, vr, values)
end

"""
Set the values of an array of boolean variables
"""
function fmiSetBoolean(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    fmi2SetBoolean(fmu, vr, values)
end

"""
Returns the string values of an array of variables
"""
function fmiGetString(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat)
    fmi2GetString(fmu, vr)
end

"""
Writes the string values of an array of variables in the given field
"""
function fmiGetString!(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})
    fmi2GetString!(fmu, vr, values)
end

"""
Set the values of an array of string variables
"""
function fmiSetString(fmu::fmi2Struct, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})
    fmi2SetString(fmu, vr, values)
end

"""
Returns the FMU state of the fmu
"""
function fmiGetFMUstate(fmu2::fmi2Struct)
    fmi2GetFMUstate(fmu2)
end

"""
Sets the FMU to the given state
"""
function fmiSetFMUstate(fmu2::fmi2Struct, state::fmi2FMUstate)
    fmi2SetFMUstate(fmu2, state)
end

"""
Free the memory for the allocated FMU state
    """
function fmiFreeFMUstate(fmu2::fmi2Struct, state::fmi2FMUstate)
    fmi2FreeFMUstate(fmu2, state)
end

"""
Returns the size of the byte vector the FMU can be stored in
"""
function fmiSerializedFMUstateSize(c::fmi2Struct, state::fmi2FMUstate)
    fmi2SerializedFMUstateSize(c, state)
end

"""
Serialize the data in the FMU state pointer
"""
function fmiSerializeFMUstate(c::fmi2Struct, state::fmi2FMUstate)
    fmi2SerializeFMUstate(c, state)
end

"""
Deserialize the data in the FMU state pointer
"""
function fmiDeSerializeFMUstate(c::fmi2Struct, serializedState::Array{fmi2Byte})
    fmi2DeSerializeFMUstate(c, serializedState)
end

"""
Returns the values of the directional derivatives
"""
function fmiGetDirectionalDerivative(fmu::fmi2Struct,
                                     vUnknown_ref::Array{Cint},
                                     vKnown_ref::Array{Cint},
                                     dvKnown::Array{Real} = nothing,
                                     dvUnknown::Array{Real} = nothing)
    fmi2GetDirectionalDerivative(fmu,
                                 Array{fmi2ValueReference}(vUnknown_ref),
                                 Array{fmi2ValueReference}(vKnown_ref),
                                 Array{Real}(dvKnown),
                                 Array{Real}(dvUnknown))
end

"""
Wrapper for single directional derivative, version independent.
"""
function fmiGetDirectionalDerivative(fmu::fmi2Struct, vUnknown_ref::Cint, vKnown_ref::Cint, dvKnown::Real = 1.0, dvUnknown::Real = 1.0)
    fmi2GetDirectionalDerivative(fmu, vUnknown_ref, vKnown_ref, dvKnown, dvUnknown)
end

"""
Does one step in the CoSimulation FMU
"""
function fmiDoStep(fmu::fmi2Struct, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
    fmi2DoStep(fmu, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint)
end

"""
Does one step in the CoSimulation FMU
"""
function fmiDoStep(c::fmi2Struct, communicationStepSize::Real)
    fmi2DoStep(c, communicationStepSize)
end

"""
Set a time instant
"""
function fmiSetTime(fmu2::fmi2Struct, time::Real)
    fmi2SetTime(fmu, time)
end

"""
Set a new (continuous) state vector
"""
function fmiSetContinuousStates(c::fmi2Struct, x::Union{Array{Float32}, Array{Float64}})
    fmi2SetContinuousStates(c, x)
end

"""
The model enters Event Mode
"""
function fmi2EnterEventMode(fmu2::fmi2Struct)
    fmi2EnterEventMode(fmu2)
end

"""
Returns the next discrete states
"""
function fmiNewDiscreteStates(c::fmi2Struct)
    fmi2NewDiscreteStates(c)
end

"""
The model enters Continuous-Time Mode
"""
function fmiEnterContinuousTimeMode(fmu2::fmi2Struct)
    fmi2EnterContinuousTimeMode(fmu2)
end

"""
This function must be called by the environment after every completed step
"""

function fmiCompletedIntegratorStep(fmu2::fmi2Struct,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    fmi2CompletedIntegratorStep(fmu2,noSetFMUStatePriorToCurrentPoint)
end

"""
Compute state derivatives at the current time instant and for the current states
"""
function  fmiGetDerivatives(c::fmi2Struct)
    fmi2GetDerivatives(c)
end

"""
Returns the event indicators of the FMU
"""
function fmiGetEventIndicators(fmu2::fmi2Struct)
    fmi2GetEventIndicators(fmu2)
end

"""
Return the new (continuous) state vector x
"""
function fmiGetContinuousStates(fmu2::fmi2Struct)
    fmi2GetContinuousStates(fmu2)
end

"""
Return the new (continuous) state vector x
"""
function fmiGetNominalsOfContinuousStates(fmu2::fmi2Struct)
    fmi2GetNominalsOfContinuousStates(fmu2)
end

##### Multiple Dispatch fallback for FMUs with unsupported versions #####

unsupportedFMUs = Union{FMU1,FMU3}
function fmiDoStep(fmu::unsupportedFMUs, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
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

function fmiInstantiate!(fmu::unsupportedFMUs; visible::Bool = false, loggingOn::Bool = false)
    error(unsupportedFMU::errorType)
end

function fmiFreeInstance!(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetDebugLogging(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetupExperiment(fmu::unsupportedFMUs,
    toleranceDefined::Bool,
                tolerance::Real,
                startTime::Real,
                stopTimeDefined::Bool,
                stopTime::Real)
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

function fmiSimulate(fmu::unsupportedFMUs, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiSimulateCS(fmu::unsupportedFMUs, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiSimulateME(fmu::unsupportedFMUs, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function (fmu::unsupportedFMUs, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiGetReal(fmu::unsupportedFMUs, vr)
    error(unsupportedFMU::errorType)
end

function fmiGetReal!(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiSetReal(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiGetInteger(fmu::unsupportedFMUs, vr)
    error(unsupportedFMU::errorType)
end

function fmiGetInteger!(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiSetInteger(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiGetBoolean(fmu::unsupportedFMUs, vr)
    error(unsupportedFMU::errorType)
end

function fmiGetBoolean!(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiSetBoolean(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiGetString(fmu::unsupportedFMUs, vr)
    error(unsupportedFMU::errorType)
end

function fmiGetString!(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiSetString(fmu::unsupportedFMUs, vr, values)
    error(unsupportedFMU::errorType)
end

function fmiGetFMUstate(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSetFMUstate(fmu::unsupportedFMUs, state::fmi2FMUstate)
    error(unsupportedFMU::errorType)
end

function fmiFreeFMUstate(fmu::unsupportedFMUs)
    error(unsupportedFMU::errorType)
end

function fmiSerializedFMUstateSize(c::unsupportedFMUs, size::Int64)
    error(unsupportedFMU::errorType)
end

function fmiSerializeFMUstate(c::unsupportedFMUs, serializedState::fmi2Byte, size::Int64)
    error(unsupportedFMU::errorType)
end

function fmiDeSerializeFMUstate(c::unsupportedFMUs, serializedState::fmi2Byte, size::Int64)
    error(unsupportedFMU::errorType)
end

function fmiGetDirectionalDerivative(fmu::unsupportedFMUs,
                                     vUnknown_ref::Array{Cint},
                                     vKnown_ref::Array{Cint},
                                     dvKnown::Array{Real} = nothing,
                                     dvUnknown::Array{Real} = nothing)
    error(unsupportedFMU::errorType)
end

function fmiGetDirectionalDerivative(fmu::unsupportedFMUs, vUnknown_ref::Cint, vKnown_ref::Cint, dvKnown::Real = 1.0, dvUnknown::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiDoStep(c::unsupportedFMUs, communicationStepSize::Real)
    error(unsupportedFMU::errorType)
end

function fmiSetTime(fmu::unsupportedFMUs, time::Real)
    error(unsupportedFMU::errorType)
end

function fmiSetContinuousStates(c::unsupportedFMUs, x::Union{Array{Float32}, Array{Float64}})
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

function fmiCompletedIntegratorStep(fmu::unsupportedFMUs,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
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
