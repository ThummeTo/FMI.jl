#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# Comfort functions for fmi2 functions using fmi2Components

"""
Set the DebugLogger for the FMU

For more information call ?fmi2SetDebugLogging
"""
function fmi2SetDebugLogging(c::fmi2Component)
    fmi2SetDebugLogging(c, fmi2False, Unsigned(0), C_NULL)
end

"""
Setup the simulation but without defining all of the parameters

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(c::fmi2Component, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)

    toleranceDefined = (tolerance > 0.0)
    stopTimeDefined = (stopTime > startTime)

    fmi2SetupExperiment(c, fmi2Boolean(toleranceDefined), fmi2Real(tolerance), fmi2Real(startTime), fmi2Boolean(stopTimeDefined), fmi2Real(stopTime))
end

"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal(c::fmi2Component, vr::fmi2ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi2Real, nvr)
    fmi2GetReal!(c, vr, nvr, values)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Real})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    # values[:] = fmi2Real.(values)
    fmi2GetReal!(c, vr, nvr, values)
    nothing
end
function fmi2GetReal!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Real)
    @assert false "fmi2GetReal! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
Set the values of an array of fmi2Real variables

For more information call ?fmi2SetReal
"""
function fmi2SetReal(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi2SetReal(c, vr, nvr, Array{fmi2Real}(values))
end

"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(c::fmi2Component, vr::fmi2ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi2Integer, nvr)
    fmi2GetInteger!(c, vr, nvr, values)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Integer})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetInteger!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    # values[:] = Cint.(values)
    # display(typeof(values))
    fmi2GetInteger!(c, vr, nvr, values)
    nothing
end
function fmi2GetInteger!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Integer)
    @assert false "fmi2GetInteger! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
Set the values of an array of fmi2Integer variables

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetInteger(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi2SetInteger(c, vr, nvr, Array{fmi2Integer}(values))
end

"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(c::fmi2Component, vr::fmi2ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = Array{fmi2Boolean}(undef, nvr)
    fmi2GetBoolean!(c, vr, nvr, values)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2Boolean})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetBoolean!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    #values = fmi2Boolean.(values)
    fmi2GetBoolean!(c, vr, nvr, values)

    nothing
end
function fmi2GetBoolean!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Bool)
    @assert false "fmi2GetBoolean! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
Set the values of an array of fmi2Boolean variables

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetBoolean(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi2SetBoolean(c, vr, nvr, Array{fmi2Boolean}(values))
end

"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString(c::fmi2Component, vr::fmi2ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    vars = Vector{Ptr{Cchar}}(undef, nvr)
    values = string.(zeros(nvr))
    fmi2GetString!(c, vr, nvr, vars)
    values[:] = unsafe_string.(vars)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Array{fmi2String})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetString!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    # values = Vector{Ptr{Cchar}}.(values)
    fmi2GetString!(c, vr, nvr, values)

    nothing
end
function fmi2GetString!(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::String)
    @assert false "fmi2GetString! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
Set the values of an array of fmi2String variables

For more information call ?fmi2SetString
"""
function fmi2SetString(c::fmi2Component, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    ptrs = pointer.(values)
    fmi2SetString(c, vr, nvr, ptrs)
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
function fmi2FreeFMUstate(c::fmi2Component, state::fmi2FMUstate)
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
    c.fmu.t += communicationStepSize
end

# Model Exchange specific functions
"""
Set independent variable time and reinitialize chaching of variables that depend on time

For more information call ?fmi2SetTime
"""
function fmi2SetTime(c::fmi2Component, time::Real)
    fmi2SetTime(c, fmi2Real(time))
end

"""
Set a new (continuous) state vector and reinitialize chaching of variables that depend on states

For more information call ?fmi2SetContinuousStates
"""
function fmi2SetContinuousStates(c::fmi2Component, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    fmi2SetContinuousStates(c, Array{fmi2Real}(x), nx)
end

"""
Increment the super dense time in event mode

For more information call ?fmi2NewDiscretestates
"""
function fmi2NewDiscreteStates(c::fmi2Component)
    eventInfo = fmi2EventInfo()
    fmi2NewDiscreteStates(c, eventInfo)
    eventInfo
end

"""
This function must be called by the environment after every completed step
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated

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
