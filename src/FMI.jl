#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

include("FMI1.jl")
include("FMI2_comp.jl")
include("FMI3.jl")
include("assertions.jl")

# ToDo: Submodules
include("FMI2_sim.jl")
#include("FMI_neural.jl")
include("FMI_plot.jl")

### EXPORTING LISTS START ###

# FMI.jl
export fmiLoad, fmiSimulate, fmiSimulateCS, fmiSimulateME, fmiUnload
export fmiGetNumberOfStates, fmiGetTypesPlatform, fmiGetVersion, fmiInstantiate!, fmiFreeInstance!
export fmiSetDebugLogging, fmiSetupExperiment, fmiEnterInitializationMode, fmiExitInitializationMode, fmiTerminate , fmiReset
export fmiGetReal, fmiSetReal, fmiGetInteger, fmiSetInteger, fmiGetBoolean, fmiSetBoolean, fmiGetString, fmiSetString, fmiGetReal!, fmiGetInteger!, fmiGetBoolean!, fmiGetString!
export fmiGetFMUstate, fmiSetFMUstate, fmiFreeFMUstate, fmiSerializedFMUstateSize, fmiSerializeFMUstate, fmiDeSerializeFMUstate
export fmiGetDirectionalDerivative, fmiDoStep, fmiSetTime, fmiSetContinuousStates, fmi2EnterEventMode, fmiNewDiscreteStates
export fmiEnterContinuousTimeMode, fmiCompletedIntegratorStep, fmiGetDerivatives, fmiGetEventIndicators, fmiGetContinuousStates, fmiGetNominalsOfContinuousStates

# FMI2.jl
export FMU2, fmi2True, fmi2False
export fmi2SimulationResultGetValuesAtIndex, fmi2SimulationResultGetTime, fmi2SimulationResultGetValues
export fmi2String2ValueReference, fmi2ValueReference2String
export fmi2Unzip, fmi2Load, fmi2Unload
export fmi2Simulate, fmi2SimulateCS, fmi2SimulateME
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

# FMI2_comp.jl
export fmi2SetDebugLogging, fmi2SetupExperiment
export fmi2GetReal, fmi2SetReal, fmi2GetInteger, fmi2SetInteger, fmi2GetBoolean, fmi2SetBoolean, fmi2GetString, fmi2SetString
export fmi2GetFMUstate, fmi2FreeFMUstate, fmi2SerializedFMUstateSize, fmi2SerializeFMUstate, fmi2DeSerializeFMUstate
export fmi2GetDirectionalDerivative
export fmi2DoStep
export fmi2SetTime, fmi2SetContinuousStates
export fmi2NewDiscreteStates, fmi2CompletedIntegratorStep, fmi2GetDerivatives, fmi2GetEventIndicators, fmi2GetContinuousStates, fmi2GetNominalsOfContinuousStates

# FMI2_c.jl
export fmi2Instantiate, fmi2FreeInstance, fmi2SetDebugLogging
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
export fmi2SimulateME

# FMI_plot.jl
export fmiPlot

# FMI2_md.jl
# nothing to export

### EXPORTING LISTS END ###

fmi2Struct = Union{FMU2, fmi2Component}
fmi2Reference = Union{String, Array{String}, fmi2ValueReference, Array{fmi2ValueReference}}

""" Multiple Dispatch variants for FMUs with version 2.0.X """
function fmiLoad(pathToFMU::String)
    fmi2Load(pathToFMU)
end

"""Simulate an fmu according to its standard from 0.0 to t_stop"""
function fmiSimulate(fmu::fmi2Struct, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, recordValues::Union{Array{fmi2ValueReference}, Array{String}} = [])
    fmi2Simulate(fmu, dt, t_start, t_stop, recordValues)
end

"""Simulate an CoSimulation fmu according to its standard from 0.0 to t_stop"""
function fmiSimulateCS(fmu::fmi2Struct, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, recordValues::Union{Array{fmi2ValueReference}, Array{String}} = [])
    fmi2SimulateCS(fmu, dt, t_start, t_stop, recordValues)
end

"""Simulate an ModelExchange fmu according to its standard from 0.0 to t_stop"""
function fmiSimulateME(fmu::fmi2Struct, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0)
    fmi2SimulateME(fmu, dt, t_start, t_stop)
end

"""Unloads the FMU and all its instances and frees the allocated memory"""
function fmiUnload(fmu::FMU2)
    fmi2Unload(fmu)
end

"""Returns the number of states of the FMU"""
function fmiGetNumberOfStates(fmu::FMU2)
    length(fmu.modelDescription.stateValueReferences)
end

"""Returns the header file used to compile the FMU. By default returns "default" """
function fmiGetTypesPlatform(fmu::FMU2)
    fmi2GetTypesPlatform(fmu)
end

"""Returns the version of the FMU"""
function fmiGetVersion(fmu::FMU2)
    fmi2GetVersion(fmu)
end

"""Creates a new instance of the FMU"""
function fmiInstantiate!(fmu::FMU2; visible::Bool = false, loggingOn::Bool = false)

    version = fmiGetVersion(fmu)

    if version == "2.0"
        return fmi2Instantiate!(fmu; visible, loggingOn)
    else
        @assert false ["fmiInstantiate!(...): Unknwon FMI version $version !"]
    end

    nothing
end

"""Frees the allocated memory of the last instance of the FMU"""
function fmiFreeInstance!(fmu::FMU2)
    fmi2FreeInstance!(fmu)
end

"""Control the use of the logging callback function"""
function fmiSetDebugLogging(s::fmi2Struct)
    fmi2SetDebugLogging(s)
end

"""Initialize the Simulation boundries"""
function fmiSetupExperiment(fmu::fmi2Struct,
    toleranceDefined::Bool,
                tolerance::Real,
                startTime::Real,
                stopTimeDefined::Bool,
                stopTime::Real)

    fmi2SetupExperiment(fmu, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end
"""Initialize the Simulation boundries"""
function fmiSetupExperiment(fmu::fmi2Struct, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)

    toleranceDefined = (tolerance > 0.0)
    stopTimeDefined = (stopTime > startTime)

    fmi2SetupExperiment(fmu, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end

"""Informs the FMU to enter initializaton mode"""
function fmiEnterInitializationMode(s::fmi2Struct)
    fmi2EnterInitializationMode(s)
end

"""Informs the FMU to exit initialization mode"""
function fmiExitInitializationMode(s::fmi2Struct)
    fmi2ExitInitializationMode(s)
end

"""Informs the FMU that the simulation run is terminated"""
function fmiTerminate(s::fmi2Struct)
    fmi2Terminate(s)
end

"""Resets the FMU after a simulation run"""
function fmiReset(s::fmi2Struct)
    fmi2Reset(s)
end

"""Returns the real values of an array of variables"""
function fmiGetReal(fmu::fmi2Struct, vr::fmi2Reference)
    fmi2GetReal(fmu, vr)
end

"""Writes the real values of an array of variables in the given field"""
function fmiGetReal!(fmu::fmi2Struct, vr::Union{Array{fmi2ValueReference}, Array{String}}, values::Array{<:Real})
    fmi2GetReal!(fmu, vr, values)
end

"""Set the values of an array of real variables"""
function fmiSetReal(fmu::fmi2Struct, vr::fmi2Reference, value::Array{<:Real})
    fmi2SetReal(fmu, vr, Array{Real}(value))
end

"""Set the value of a real variable"""
function fmiSetReal(fmu::fmi2Struct, vr::fmi2Reference, value::Real)
    fmi2SetReal(fmu, vr, Real(value))
end
"""Returns the integer values of an array of variables"""
function fmiGetInteger(fmu::fmi2Struct, vr::fmi2Reference)
    fmi2GetInteger(fmu, vr)
end

"""Writes the integer values of an array of variables in the given field"""
function fmiGetInteger!(fmu::fmi2Struct, vr::Union{Array{fmi2ValueReference}, Array{String}}, values::Array{<:Integer})
    fmi2GetInteger!(fmu, vr, values)
end

"""Set the values of an array of integer variables"""
function fmiSetInteger(fmu::fmi2Struct, vr::fmi2Reference, value::Array{<:Integer})
    fmi2SetInteger(fmu, vr, Array{Integer}(value))
end

"""Set the value of a integer variable"""
function fmiSetInteger(fmu::fmi2Struct, vr::fmi2Reference, value::Integer)
    fmi2SetInteger(fmu, vr, Integer(value))
end
"""Returns the boolean values of an array of variables"""
function fmiGetBoolean(fmu::fmi2Struct, vr::fmi2Reference)
    fmi2GetBoolean(fmu, vr)
end

"""Writes the boolean values of an array of variables in the given field"""
function fmiGetBoolean!(fmu::fmi2Struct, vr::Union{Array{fmi2ValueReference}, Array{String}}, values::Array{Bool})
    fmi2GetBoolean!(fmu, vr, values)
end

"""Set the values of an array of boolean variables"""
function fmiSetBoolean(fmu::fmi2Struct, vr::fmi2Reference, value::Array{Bool})
    fmi2SetBoolean(fmu, vr, value)
end

"""Set the value of a boolean variable"""
function fmiSetBoolean(fmu::fmi2Struct, vr::fmi2Reference, value::Bool)
    fmi2SetBoolean(fmu, vr, value)
end
"""Returns the string values of an array of variables"""
function fmiGetString(fmu::fmi2Struct, vr::fmi2Reference)
    fmi2GetString(fmu, vr)
end

"""Writes the string values of an array of variables in the given field"""
function fmiGetString!(fmu::fmi2Struct, vr::Union{Array{fmi2ValueReference}, Array{String}}, values::Array{String})
    fmi2GetString!(fmu, vr, values)
end

"""Set the values of an array of string variables"""
function fmiSetString(fmu::fmi2Struct, vr::fmi2Reference, value::Array{String})
    fmi2SetString(fmu, vr, value)
end

"""Set the value of a string variable"""
function fmiSetString(fmu::fmi2Struct, vr::fmi2Reference, value::String)
    fmi2SetString(fmu, vr, value)
end
"""Returns the FMU state of the fmu"""
function fmiGetFMUstate(fmu2::fmi2Struct)
    fmi2GetFMUstate(fmu2)
end
"""Sets the FMU to the given state"""
function fmiSetFMUstate(fmu2::fmi2Struct, state::fmi2FMUstate)
    fmi2SetFMUstate(fmu2, state)
end
"""Free the memory for the allocated FMU state"""
function fmiFreeFMUstate(fmu2::fmi2Struct, state::fmi2FMUstate)
    fmi2FreeFMUstate(fmu2)
end
"""Returns the size of the byte vector the FMU can be stored in"""
function fmiSerializedFMUstateSize(c::fmi2Struct, state::fmi2FMUstate)
    fmi2SerializedFMUstateSize(c, state)
end
"""Serialize the data in the FMU state pointer"""
function fmiSerializeFMUstate(c::fmi2Struct, state::fmi2FMUstate)
    fmi2SerializeFMUstate(c, state)
end
"""Deserialize the data in the FMU state pointer"""
function fmiDeSerializeFMUstate(c::fmi2Struct, serializedState::Array{fmi2Byte})
    fmi2DeSerializeFMUstate(c, serializedState)
end
"""Returns the values of the directional derivatives"""
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

""" Wrapper for single directional derivative """
function fmiGetDirectionalDerivative(fmu::fmi2Struct, vUnknown_ref::Cint, vKnown_ref::Cint, dvKnown::Real = 1.0, dvUnknown::Real = 1.0)
    fmi2GetDirectionalDerivative(fmu, vUnknown_ref, vKnown_ref, dvKnown, dvUnknown)
end

"""Does one step in the CoSimulation FMU"""
function fmiDoStep(fmu::fmi2Struct, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
    fmi2DoStep(fmu, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint)
end
"""Does one step in the CoSimulation FMU"""
function fmiDoStep(c::fmi2Struct, communicationStepSize::Real)
    fmi2DoStep(c, communicationStepSize)
end
"""Set a time instant"""
function fmiSetTime(fmu2::fmi2Struct, time::Real)
    fmi2SetTime(fmu, time)
end
"""Set a new (continuous) state vector"""
function fmiSetContinuousStates(c::fmi2Struct, x::Union{Array{Float32}, Array{Float64}})
    fmi2SetContinuousStates(c, x)
end
"""The model enters Event Mode"""
function fmi2EnterEventMode(fmu2::fmi2Struct)
    fmi2EnterEventMode(fmu2)
end
"""Returns the next discrete states"""
function fmiNewDiscreteStates(c::fmi2Struct)
    fmi2NewDiscreteStates(c)
end
"""The model enters Continuous-Time Mode"""
function fmiEnterContinuousTimeMode(fmu2::fmi2Struct)
    fmi2EnterContinuousTimeMode(fmu2)
end
"""This function must be called by the environment after every completed step"""
function fmiCompletedIntegratorStep(fmu2::fmi2Struct,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    fmi2CompletedIntegratorStep(fmu2,noSetFMUStatePriorToCurrentPoint)
end
"""Compute state derivatives at the current time instant and for the current states"""
function  fmiGetDerivatives(c::fmi2Struct)
    fmi2GetDerivatives(c)
end
"""Returns the event indicators of the FMU"""
function fmiGetEventIndicators(fmu2::fmi2Struct)
    fmi2GetEventIndicators(fmu2)
end
"""Return the new (continuous) state vector x"""
function fmiGetContinuousStates(fmu2::fmi2Struct)
    fmi2GetContinuousStates(fmu2)
end
"""Return the new (continuous) state vector x"""
function fmiGetNominalsOfContinuousStates(fmu2::fmi2Struct)
    fmi2GetNominalsOfContinuousStates(fmu2)
end


""" Multiple Dispatch fallback for FMUs with unsupported versions """
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

function fmiGetReal(fmu::unsupportedFMUs, vr::Array{fmi2Reference})
    error(unsupportedFMU::errorType)
end

function fmiGetReal(fmu::unsupportedFMUs, vr::fmi2Reference)
    error(unsupportedFMU::errorType)
end

function fmiSetReal(fmu::unsupportedFMUs, vr::Array{fmi2Reference}, value::Array{fmi2Real})
    error(unsupportedFMU::errorType)
end

function fmiSetReal(fmu::unsupportedFMUs, vr::fmi2ValueReference, value::fmi2Real)
    error(unsupportedFMU::errorType)
end

function fmiSimulate(fmu::unsupportedFMUs, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiSimulateCS(fmu::unsupportedFMUs, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiSimulateME(fmu::unsupportedFMUs, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0)
    error(unsupportedFMU::errorType)
end

function fmiSetReal(fmu::unsupportedFMUs, vr::fmi2Reference, value::Real)
    error(unsupportedFMU::errorType)
end

function fmiGetInteger(fmu::unsupportedFMUs, vr::fmi2Reference)
    error(unsupportedFMU::errorType)
end

function fmiSetInteger(fmu::unsupportedFMUs, vr::fmi2Reference, value::Array{Int64})
    error(unsupportedFMU::errorType)
end

function fmiSetInteger(fmu::unsupportedFMUs, vr::fmi2Reference, value::Int64)
    error(unsupportedFMU::errorType)
end

function fmiGetBoolean(fmu::unsupportedFMUs, vr::fmi2Reference)
    error(unsupportedFMU::errorType)
end

function fmiSetBoolean(fmu::unsupportedFMUs, vr::fmi2Reference, value::Array{Bool})
    error(unsupportedFMU::errorType)
end

function fmiSetBoolean(fmu::unsupportedFMUs, vr::fmi2Reference, value::Bool)
    error(unsupportedFMU::errorType)
end

function fmiGetString(fmu::unsupportedFMUs, vr::fmi2Reference)
    error(unsupportedFMU::errorType)
end

function fmiSetString(fmu::unsupportedFMUs, vr::fmi2Reference, value::Array{String})
    error(unsupportedFMU::errorType)
end

function fmiSetString(fmu::unsupportedFMUs, vr::fmi2Reference, value::String)
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

end # module FMI
