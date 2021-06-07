#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

include("FMI2.jl")

# Comfort functions for fmi2 functions using fmi2Components

"""
Set the DebugLogger for the FMU

For more information call ?fmi2SetDebugLogging
"""
function fmi2SetDebugLogging(c::fmi2Component)
    fmi2SetDebugLogging(c, fmi2False, Unsigned(0), C_NULL)
end

"""
Set the start and end time for a simulation, can only be called after fmi2Instantiate and before fmi2EnterInitializationMode

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(c::fmi2Component,
    toleranceDefined::Bool,
                tolerance::Real,
                startTime::Real,
                stopTimeDefined::Bool,
                stopTime::Real)
    c.fmu.t = startTime
    fmi2SetupExperiment(c, fmi2Boolean(toleranceDefined), fmi2Real(tolerance),
                            fmi2Real(startTime), fmi2Boolean(stopTimeDefined), fmi2Real(stopTime))
end

"""
Setup the simulation but without defining all of the parameters

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(c::fmi2Component, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)

    toleranceDefined = (tolerance > 0.0)
    stopTimeDefined = (stopTime > startTime)

    fmi2SetupExperiment(c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end
"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal(c::fmi2Component, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    values = zeros(fmi2Real, nvr)
    fmi2GetReal!(c, vr, nvr, values)
    values
end

"""
Get the value of a fmi2Real variable

For more information call ?fmi2GetReal
"""
function fmi2GetReal(c::fmi2Component, vr::fmi2ValueReference)
    values = fmi2GetReal(c, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Real variables by variable name

For more information call ?fmi2GetReal
"""
function fmi2GetReal(c::fmi2Component, vr_string::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetReal(c, vr)
    end
end
"""
Get the value of a fmi2Real variable by variable name

For more information call ?fmi2GetReal
"""
function fmi2GetReal(c::fmi2Component, vr_string::String)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetReal(c, vr)
    end
end
"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal!(c::fmi2Component, vr::Array{fmi2ValueReference}, values::Array{<:Real})
    vars = zeros(fmi2Real, length(values))
    if length(values) != length(vr)
        display("[ERROR]: Number of value references and in place array doesn't match")
    else
        fmi2GetReal!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Get the values of an array of fmi2Real variables by variable name

For more information call ?fmi2GetReal
"""
function fmi2GetReal!(c::fmi2Component, vr_string::Array{String}, values::Array{<:Real})
    vars = zeros(fmi2Real, length(values))
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    elseif length(values) != length(vr)
            display("[ERROR]: Number of value references and in place array doesn't match")
    else
            fmi2GetReal!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Set the values of an array of fmi2Real variables

For more information call ?fmi2SetReal
"""
function fmi2SetReal(c::fmi2Component, vr::Array{fmi2ValueReference}, value::Array{<:Real})
    nvr = Csize_t(length(vr))
    fmi2SetReal(c, vr, nvr, Array{fmi2Real}(value))
end

"""
Set the value of a fmi2Real variable

For more information call ?fmi2SetReal
"""
function fmi2SetReal(c::fmi2Component, vr::fmi2ValueReference, value::Real)
    fmi2SetReal(c, [vr], [value])
end
"""
Set the values of an array of fmi2Real variables by variable name

For more information call ?fmi2SetReal
"""
function fmi2SetReal(c::fmi2Component, vr_string::Array{String}, value::Array{<:Real})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetReal(c, vr, value)
    end
end
"""
Set the value of a fmi2Real variable by variable name

For more information call ?fmi2SetReal
"""
function fmi2SetReal(c::fmi2Component, vr_string::String, value::Real)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetReal(c, vr, value)
    end
end
"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(c::fmi2Component, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    values = zeros(fmi2Integer, nvr)

    fmi2GetInteger!(c, vr, nvr, values)
    values
end

"""
Get the value of a fmi2Integer variable

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(c::fmi2Component, vr::fmi2ValueReference)
    values = fmi2GetInteger(c, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Integer variables by variable name

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(c::fmi2Component, vr_string::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetInteger(c, vr)
    end
end
"""
Get the value of a fmi2Integer variable by variable name

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(c::fmi2Component, vr_string::String)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetInteger(c, vr)
    end
end
"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger!(c::fmi2Component, vr::Array{fmi2ValueReference}, values::Array{<:Integer})
    vars = zeros(fmi2Integer, length(values))
    if length(values) != length(vr)
        display("[ERROR]: Number of value references and in place array doesn't match")
    else
        fmi2GetInteger!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Get the values of an array of fmi2Integer variables by variable name

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger!(c::fmi2Component, vr_string::Array{String}, values::Array{<:Integer})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    vars = zeros(fmi2Integer, length(values))
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    elseif length(values) != length(vr)
            display("[ERROR]: Number of value references and in place array doesn't match")
    else
            fmi2GetInteger!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Set the values of an array of fmi2Integer variables

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(c::fmi2Component, vr::Array{fmi2ValueReference},value::Array{<:Integer})
    nvr = Csize_t(length(vr))
    fmi2SetInteger(c, vr, nvr, Array{fmi2Integer}(value))
end
"""
Get the value of a fmi2Integer variable

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(c::fmi2Component, vr::fmi2ValueReference, value::Integer)
    fmi2SetInteger(c,[vr], [value])
end
"""
Set the values of an array of fmi2Integer variables by variable name

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(c::fmi2Component, vr_string::Array{String}, value::Array{<:Integer})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetInteger(c, vr, value)
    end
end
"""
Set the value of a fmi2Integer variable by variable name

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(c::fmi2Component, vr_string::String, value::Integer)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetInteger(c, vr, value)
    end
end
"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(c::fmi2Component, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    value = zeros(fmi2Boolean, nvr)
    fmi2GetBoolean!(c, vr, nvr, value)
end
"""
Get the value of a fmi2Boolean variable

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(c::fmi2Component, vr::fmi2ValueReference)
    values = fmi2GetBoolean(c, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Boolean variables by variable name

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(c::fmi2Component, vr_string::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetBoolean(c, vr)
    end
end
"""
Get the value of a fmi2Boolean variable by variable name

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(c::fmi2Component, vr_string::String)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetBoolean(c, vr)
    end
end
"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean!(c::fmi2Component, vr::Array{fmi2ValueReference}, values::Array{Bool})
    vars = zeros(fmi2Boolean, length(values))
    if length(values) != length(vr)
        display("[ERROR]: Number of value references and in place array doesn't match")
    else
        fmi2GetBoolean!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Get the values of an array of fmi2Boolean variables by variable name

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean!(c::fmi2Component, vr_string::Array{String}, values::Array{Bool})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    vars = zeros(fmi2Real, length(values))
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    elseif length(values) != length(vr)
            display("[ERROR]: Number of value references and in place array doesn't match")
    else
            fmi2GetBoolean!(c, vr, Csize_t(length(values)), vars)
    end
    values[:] = vars
end
"""
Set the values of an array of fmi2Boolean variables

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(c::fmi2Component, vr::Array{fmi2ValueReference}, value::Array{Bool})
    nvr = Csize_t(length(vr))
    fmi2SetBoolean(c, vr, nvr, Array{fmi2Boolean}(value))
end
"""
Set the value of a fmi2Boolean variable

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(c::fmi2Component, vr::fmi2ValueReference, value::Bool)
    fmi2SetBoolean(c, [vr], [value])
end
"""
Set the values of an array of fmi2Boolean variables by variable name

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(c::fmi2Component, vr_string::Array{String}, value::Array{Bool})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetBoolean(c, vr, value)
    end
end
"""
Set the value of a fmi2Boolean variable by variable name

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(c::fmi2Component, vr_string::String, value::Bool)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetBoolean(c, vr, value)
    end
end
"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString(c::fmi2Component, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    value = Array{fmi2String}(undef, nvr)
    fmi2GetString!(c, vr, nvr, value)
end
"""
Get the value of a fmi2String variable

For more information call ?fmi2GetString
"""
function fmi2GetString(c::fmi2Component, vr::fmi2ValueReference)
    values = fmi2GetString(c, [vr])
    values[1]
end
"""
Get the values of an array of fmi2String variables by variable name

For more information call ?fmi2GetString
"""
function fmi2GetString(c::fmi2Component, vr_string::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetString(c, vr)
    end
end
"""
Get the value of a fmi2String variable by variable name

For more information call ?fmi2GetString
"""
function fmi2GetString(c::fmi2Component, vr_string::String)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetString(c, vr)
    end
end
"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString!(c::fmi2Component, vr::Array{fmi2ValueReference}, values::Array{String})
    vars = Vector{Ptr{Cchar}}(undef, length(vr))
    if length(values) != length(vr)
        display("[ERROR]: Number of value references and in place array doesn't match")
    else
        fmi2GetString!(c, vr, Csize_t(length(values)), vars)
        values[:] = vars
    end
end
"""
Get the values of an array of fmi2String variables by variable name

For more information call ?fmi2GetString
"""
function fmi2GetString!(c::fmi2Component, vr_string::Array{String}, values::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    vars = Vector{Ptr{Cchar}}(undef, length(vr))
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    elseif length(values) != length(vr)
            display("[ERROR]: Number of value references and in place array doesn't match")
    else
            fmi2GetString!(c, vr, Csize_t(length(values)), vars)
            values[:] = unsafe_string.(vars)
    end
end
"""
Set the values of an array of fmi2String variables

For more information call ?fmi2SetString
"""
function fmi2SetString(c::fmi2Component, vr::Array{fmi2ValueReference}, value::Array{String})
    nvr = Csize_t(length(vr))
    fmi2SetString(c, vr, nvr, Array{fmi2String}(value))
end
"""
Set the values of a fmi2String variable

For more information call ?fmi2SetString
"""
function fmi2SetString(c::fmi2Component, vr::fmi2ValueReference, value::String)
    fmi2SetString(c, [vr], [value])
end
"""
Set the values of an array of fmi2String variables by variable name

For more information call ?fmi2SetString
"""
function fmi2SetString(c::fmi2Component, vr_string::Array{String}, value::Array{String})
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetString(c, vr, value)
    end
end
"""
Set the value of a fmi2String variable by variable name

For more information call ?fmi2SetString
"""
function fmi2SetString(c::fmi2Component, vr_string::String, value::String)
    vr = fmi2String2ValueReference(c.fmu, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetString(c, vr, value)
    end
end
"""
Get the pointer to the current FMU state

For more information call ?fmi2GetFMUstate
"""
function fmi2GetFMUstate(c::fmi2Component)
    state = fmi2FMUstate()
    stateRef = Ref(state)
    fmi2GetFMUstate(c, stateRef)
    state = stateRef[]
    state
end
"""
Free the allocated memory for the FMU state

For more information call ?fmi2FreeFMUstate
"""
function fmi2FreeFMUstate(c::fmi2Component)
    stateRef = Ref(state)
    fmi2FreeFMUstate(c, stateRef)
    state = stateRef[]
end

"""
Returns the size of a byte vector the FMU can be stored in

For more information call ?fmi2SerzializedFMUstateSize
"""
function fmi2SerializedFMUstateSize(c::fmi2Component, state::fmi2FMUstate)
    size = 0
    sizeRef = Ref(Csize_t(size))
    fmi2SerializedFMUstateSize(c, state, sizeRef)
    size = sizeRef[]
end

"""
Serialize the data in the FMU state pointer

For more information call ?fmi2SerzializeFMUstate
"""
function fmi2SerializeFMUstate(c::fmi2Component, state::fmi2FMUstate)
    size = fmi2SerializedFMUstateSize(c, state)
    serializedState = Array{fmi2Byte}(undef, size)
    fmi2SerializeFMUstate(c, state, serializedState, size)
    serializedState
end

"""
Deserialize the data in the serializedState fmi2Byte field

For more information call ?fmi2DeSerzializeFMUstate
"""
function fmi2DeSerializeFMUstate(c::fmi2Component, serializedState::Array{fmi2Byte})
    size = length(serializedState)
    state = fmi2FMUstate()
    stateRef = Ref(state)
    fmi2DeSerializeFMUstate(c, serializedState, Csize_t(size), stateRef)
    state = stateRef[]
end

"""
Computes directional derivatives

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi2GetDirectionalDerivative(c::fmi2Component,
                                      vUnknown_ref::Array{fmi2ValueReference},
                                      vKnown_ref::Array{fmi2ValueReference},
                                      dvKnown::Array{fmi2Real} = Array{fmi2Real}([]))

    nKnown = Csize_t(length(vKnown_ref))
    nUnknown = Csize_t(length(vUnknown_ref))

    if length(dvKnown) < nKnown
        dvKnown = ones(fmi2Real, nKnown)
    end

    dvUnknown = zeros(fmi2Real, nUnknown)

    fmi2GetDirectionalDerivative!(c, vUnknown_ref, nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown)

    dvUnknown
end
"""
Computes directional derivatives

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi2GetDirectionalDerivative(c::fmi2Component,
                                      vUnknown_ref::fmi2ValueReference,
                                      vKnown_ref::fmi2ValueReference,
                                      dvKnown::fmi2Real = 1.0,
                                      dvUnknown::fmi2Real = 1.0)

    fmi2GetDirectionalDerivative(c, [vUnknown_ref], [vKnown_ref], [dvKnown])[1]
end

# CoSimulation specific functions

"""
The computation of a time step is started.

For more information call ?fmi2DoStep
"""
function fmi2DoStep(c::fmi2Component, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
    fmi2DoStep(c, fmi2Real(currentCommunicationPoint), fmi2Real(communicationStepSize), fmi2Boolean(noSetFMUStatePriorToCurrentPoint))
end
"""
The computation of a time step is started.

For more information call ?fmi2DoStep
"""
function fmi2DoStep(c::fmi2Component, communicationStepSize::Real)
    fmi2DoStep(c, fmi2Real(c.fmu.t), fmi2Real(communicationStepSize), fmi2True)
    fmu2.t += communicationStepSize
end

# Model Exchange specific functions
"""
Set a new time instant

For more information call ?fmi2SetTime
"""
function fmi2SetTime(c::fmi2Component, time::Real)
    fmi2SetTime(c, fmi2Real(time))
end

"""
Set a new (continuous) state vector

For more information call ?fmi2SetContinuousStates
"""
function fmi2SetContinuousStates(c::fmi2Component, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    fmi2SetContinuousStates(c, Array{fmi2Real}(x), nx)
end
"""
Returns the next discrete states

For more information call ?fmi2NewDiscretestates
"""
function fmi2NewDiscreteStates(c::fmi2Component)
    eventInfo = fmi2EventInfo()
    fmi2NewDiscreteStates(c, eventInfo)
    eventInfo
end
"""
This function must be called by the environment after every completed step

For more information call ?fmi2CompletedIntegratorStep
"""
function fmi2CompletedIntegratorStep(c::fmi2Component,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    enterEventMode = fmi2Boolean(false)
    terminateSimulation = fmi2Boolean(false)
    status = fmi2CompletedIntegratorStep!(c,
                                         noSetFMUStatePriorToCurrentPoint,
                                         enterEventMode,
                                         terminateSimulation)
    (status, enterEventMode, terminateSimulation)
end

"""
Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi2GetDerivatives
"""
function  fmi2GetDerivatives(c::fmi2Component)
    nx = Csize_t(c.fmu.modelDescription.numberOfContinuousStates)
    derivatives = zeros(fmi2Real, nx)
    fmi2GetDerivatives(c, derivatives, nx)
    derivatives
end
"""
Returns the event indicators of the FMU

For more information call ?fmi2GetEventIndicators
"""
function fmi2GetEventIndicators(c::fmi2Component)
    ni = Csize_t(c.fmu.modelDescription.numberOfEventIndicators)
    eventIndicators = zeros(fmi2Real, ni)
    fmi2GetEventIndicators(c, eventIndicators, ni)
    eventIndicators
end
"""
Return the new (continuous) state vector x

For more information call ?fmi2GetContinuousStates
"""
function fmi2GetContinuousStates(c::fmi2Component)
    nx = Csize_t(c.fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetContinuousStates(c, x, nx)
    x
end

"""
Return the new (continuous) state vector x

For more information call ?fmi2GetNominalsOfContinuousStates
"""
function fmi2GetNominalsOfContinuousStates(c::fmi2Component)
    nx = Csize_t(c.fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetNominalsOfContinuousStates(c, x, nx)
    x
end



"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available the CoSimulation Simulation is started
"""
function fmi2Simulate(c::fmi2Component, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, recordValues::Union{Array{fmi2ValueReference}, Array{String}} = [])

    if c.fmu.fmuType == fmi2CoSimulation::fmi2Type
        fmi2SimulateCS(c, dt, t_start, t_stop, recordValues)
    elseif c.fmu.fmuType == fmi2ModelExchange::fmi2Type
        fmi2SimulateME(c, dt, t_start, t_stop)
    else
        error(unknownFMUType)
    end
end
"""
Starts a simulation of the CoSimulation FMU instance
"""
function fmi2SimulateCS(c::fmi2Component, dt::Real, t_start::Real, t_stop::Real, recordValues::Array{fmi2ValueReference} = [])

    fmi2SetupExperiment(c, t_start, t_stop)
    fmiEnterInitializationMode(c)
    fmiExitInitializationMode(c)

    t = t_start

    sd = nothing
    record = length(recordValues) > 0

    numDigits = length(string(round(Integer, 1/dt)))

    if record
        sd = fmi2SimulationResult()
        sd.valueReferences = recordValues
        sd.dataPoints = []
        sd.fmu = c.fmu

        values = fmi2GetReal(c, sd.valueReferences)
        push!(sd.dataPoints, (t, values...))

        while t < t_stop
            fmiDoStep(c, t, dt)
            t = round(t + dt, digits=numDigits)

            values = fmi2GetReal(c, sd.valueReferences)
            push!(sd.dataPoints, (t, values...))
        end
    else
        while t < t_stop
            fmiDoStep(c, t, dt)
            t = round(t + dt, digits=numDigits)
        end
    end

    sd
end
"""
Starts a simulation of the CoSimulation FMU instance
"""
function fmi2SimulateCS(c::fmi2Component, dt::Real, t_start::Real, t_stop::Real, recordValues::Array{String})
    vr = fmi2String2ValueReference(c.fmu, recordValues)
    fmi2SimulateCS(c, dt, t_start, t_stop, vr)
end
