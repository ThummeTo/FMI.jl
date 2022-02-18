#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMU3, fmi3ModelDescription
using FMIImport: fmi3Float32, fmi3Float64, fmi3Int8, fmi3Int16, fmi3Int32, fmi3Int64, fmi3Boolean, fmi3String, fmi3Binary, fmi3UInt8, fmi3UInt16, fmi3UInt32, fmi3UInt64, fmi3Byte
using FMIImport: fmi3Clock, fmi3FMUState
using FMIImport: fmi3CallbackLogger, fmi3CallbackIntermediateUpdate, fmi3CallbackClockUpdate

# wrapper functions on the model description
function fmi3GetModelName(fmu::FMU3)
    fmi3GetModelName(fmu.modelDescription)
end
function fmi3GetInstantiationToken(fmu::FMU3)
    fmi3GetInstantiationToken(fmu.modelDescription)
end
function fmi3GetGenerationTool(fmu::FMU3)
    fmi3GetGenerationTool(fmu.modelDescription)
end
function fmi3GetGenerationDateAndTime(fmu::FMU3)
    fmi3GetGenerationDateAndTime(fmu.modelDescription)
end
function fmi3GetVariableNamingConvention(fmu::FMU3)
    fmi3GetVariableNamingConvention(fmu.modelDescription)
end

function fmi3CanGetSetState(fmu::FMU3)
    fmi3CanGetSetState(fmu.modelDescription)
end
function fmi3CanSerializeFMUstate(fmu::FMU3)
    fmi3CanSerializeFMUstate(fmu.modelDescription)
end
function fmi3ProvidesDirectionalDerivatives(fmu::FMU3)
    fmi3ProvidesDirectionalDerivatives(fmu.modelDescription)
end
function fmi3ProvidesAdjointDerivatives(fmu::FMU3)
    fmi3ProvidesAdjointDerivatives(fmu.modelDescription)
end
function fmi3IsCoSimulation(fmu::FMU3)
    fmi3IsCoSimulation(fmu.modelDescription)
end
function fmi3IsModelExchange(fmu::FMU3)
    fmi3IsModelExchange(fmu.modelDescription)
end
function fmi3IsScheduledExecution(fmu::FMU3)
    fmi3IsScheduledExecution(fmu.modelDescription)
end

"""
Returns an array of ValueReferences coresponding to the variable names.
"""
function fmi3String2ValueReference(md::fmi3ModelDescription, names::Array{String})
    vr = Array{fmi3ValueReference}(undef,0)
    for name in names
        reference = fmi3String2ValueReference(md, name)
        if reference === nothing
            @warn "Value reference for variable '$name' not found, skipping."
        else
            push!(vr, reference)
        end
    end
    vr
end

"""
Returns the ValueReference coresponding to the variable name.
"""
function fmi3String2ValueReference(md::fmi3ModelDescription, name::String)
    reference = nothing
    if haskey(md.stringValueReferences, name)
        reference = md.stringValueReferences[name]
    else
        @warn "No variable named '$name' found."
    end
    reference
end

function fmi3String2ValueReference(fmu::FMU3, name::Union{String, Array{String}})
    fmi3String2ValueReference(fmu.modelDescription, name)
end

"""
Returns an array of variable names matching a fmi3ValueReference.
"""
function fmi3ValueReference2String(md::fmi3ModelDescription, reference::fmi3ValueReference)
    [k for (k,v) in md.stringValueReferences if v == reference]
end
function fmi3ValueReference2String(md::fmi3ModelDescription, reference::Int64)
    fmi3ValueReference2String(md, fmi3ValueReference(reference))
end

function fmi3ValueReference2String(fmu::FMU3, reference::Union{fmi3ValueReference, Int64})
    fmi3ValueReference2String(fmu.modelDescription, reference)
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateModelExchange
"""
function fmi3InstantiateModelExchange!(fmu::FMU3; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(fmi3CallbackLogger, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))

    compAddr = fmi3InstantiateModelExchange(fmu.cInstantiateModelExchange, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), fmu.instanceEnvironment, ptrLogger)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateModelExchange!(...): Instantiation failed!"
        return nothing
    end
    previous_z  = zeros(fmi3Float64, fmi3GetEventIndicators(fmu.modelDescription))
    rootsFound  = zeros(fmi3Int32, fmi3GetEventIndicators(fmu.modelDescription))
    stateEvent  = fmi3False
    timeEvent   = fmi3False
    stepEvent   = fmi3False
    component = fmi3Component(compAddr, fmu, previous_z, rootsFound, stateEvent, timeEvent, stepEvent)
    push!(fmu.components, component)
    component
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateCoSimulation
"""
function fmi3InstantiateCoSimulation!(fmu::FMU3; visible::Bool = false, loggingOn::Bool = false, eventModeUsed::Bool = false, ptrIntermediateUpdate=nothing)

    ptrLogger = @cfunction(fmi3CallbackLogger, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))
    if ptrIntermediateUpdate === nothing
        ptrIntermediateUpdate = @cfunction(fmi3CallbackIntermediateUpdate, Cvoid, (Ptr{Cvoid}, fmi3Float64, fmi3Boolean, fmi3Boolean, fmi3Boolean, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Float64}))
    end
    if fmu.modelDescription.CShasEventMode 
        mode = eventModeUsed
    else
        mode = false
    end

    compAddr = fmi3InstantiateCoSimulation(fmu.cInstantiateCoSimulation, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), 
                                            fmi3Boolean(mode), fmi3Boolean(fmu.modelDescription.CScanReturnEarlyAfterIntermediateUpdate), fmu.modelDescription.intermediateUpdateValueReferences, Csize_t(length(fmu.modelDescription.intermediateUpdateValueReferences)), fmu.instanceEnvironment, ptrLogger, ptrIntermediateUpdate)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateCoSimulation!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateScheduledExecution
"""
function fmi3InstantiateScheduledExecution!(fmu::FMU3, ptrlockPreemption::Ptr{Cvoid}, ptrunlockPreemption::Ptr{Cvoid}; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(fmi3CallbackLogger, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))
    ptrClockUpdate = @cfunction(fmi3CallbackClockUpdate, Cvoid, (Ptr{Cvoid}, ))

    compAddr = fmi3InstantiateScheduledExecution(fmu.cInstantiateScheduledExecution, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), fmu.instanceEnvironment, ptrLogger, ptrClockUpdate, ptrlockPreemption, ptrunlockPreemption)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateScheduledExecution!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end


"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.4. Inquire Version Number of Header Files

Returns the version of the FMI Standard used in this FMU.

For more information call ?fmi3GetVersion
"""
function fmi3GetVersion(fmu::FMU3)
    fmi3GetVersion(fmu.cGetVersion)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Sets debug logging for the FMU.

For more information call ?fmi3SetDebugLogging
"""
function fmi3SetDebugLogging(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetDebugLogging(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

FMU enters Initialization mode.

For more information call ?fmi3EnterInitializationMode
"""
function fmi3EnterInitializationMode(fmu::FMU3, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterInitializationMode(fmu.components[end], startTime, stopTime; tolerance = tolerance)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

FMU exits Initialization mode.

For more information call ?fmi3ExitInitializationMode
"""
function fmi3ExitInitializationMode(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3ExitInitializationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.4. Super State: Initialized

Informs FMU that simulation run is terminated.

For more information call ?fmi3Terminate
"""
function fmi3Terminate(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3Terminate(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Resets FMU.

For more information call ?fmi3Reset
"""
function fmi3Reset(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3Reset(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float32 variables.

For more information call ?fmi3GetFloat32
"""
function fmi3GetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float32 variables.

For more information call ?fmi3GetFloat32!
"""
function fmi3GetFloat32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Float32 variables.

For more information call ?fmi3SetFloat32
"""
function fmi3SetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFloat32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float64 variables.

For more information call ?fmi3GetFloat64
"""
function fmi3GetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float64 variables.

For more information call ?fmi3GetFloat64!
"""
function fmi3GetFloat64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Float64 variables.

For more information call ?fmi3SetFloat64
"""
function fmi3SetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFloat64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int8 variables.

For more information call ?fmi3GetInt8
"""
function fmi3GetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt8(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int8 variables.

For more information call ?fmi3GetInt8!
"""
function fmi3GetInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt8!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int8 variables.

For more information call ?fmi3SetInt8
"""
function fmi3SetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt8(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt8 variables.

For more information call ?fmi3GetUInt8
"""
function fmi3GetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt8(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt8 variables.

For more information call ?fmi3GetUInt8!
"""
function fmi3GetUInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt8!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt8 variables.

For more information call ?fmi3SetUInt8
"""
function fmi3SetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt8(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int16 variables.

For more information call ?fmi3GetInt16
"""
function fmi3GetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt16(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int16 variables.

For more information call ?fmi3GetInt16!
"""
function fmi3GetInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt16!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int16 variables.

For more information call ?fmi3SetInt16
"""
function fmi3SetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt16(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt16 variables.

For more information call ?fmi3GetUInt16
"""
function fmi3GetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt16(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt16 variables.

For more information call ?fmi3GetUInt16!
"""
function fmi3GetUInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt16!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt16 variables.

For more information call ?fmi3SetUInt16
"""
function fmi3SetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt16(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int32 variables.

For more information call ?fmi3GetInt32
"""
function fmi3GetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int32 variables.

For more information call ?fmi3GetInt32!
"""
function fmi3GetInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int32 variables.

For more information call ?fmi3SetInt32
"""
function fmi3SetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt32 variables.

For more information call ?fmi3GetUInt32
"""
function fmi3GetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt32 variables.

For more information call ?fmi3GetUInt32!
"""
function fmi3GetUInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt32 variables.

For more information call ?fmi3SetUInt32
"""
function fmi3SetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int64 variables.

For more information call ?fmi3GetInt64
"""
function fmi3GetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int64 variables.

For more information call ?fmi3GetInt64!
"""
function fmi3GetInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int64 variables.

For more information call ?fmi3SetInt64
"""
function fmi3SetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt64 variables.

For more information call ?fmi3GetUInt64
"""
function fmi3GetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt64 variables.

For more information call ?fmi3GetUInt64!
"""
function fmi3GetUInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt64 variables.

For more information call ?fmi3SetUInt64
"""
function fmi3SetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Boolean variables.

For more information call ?fmi3GetBoolean
"""
function fmi3GetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBoolean(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Boolean variables.

For more information call ?fmi3GetBoolean!
"""
function fmi3GetBoolean!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool, Array{fmi3Boolean}})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBoolean!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Boolean variables.

For more information call ?fmi3SetBoolean
"""
function fmi3SetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetBoolean(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3String variables.

For more information call ?fmi3GetString
"""
function fmi3GetString(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetString(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3String variables.

For more information call ?fmi3GetString!
"""
function fmi3GetString!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetString!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3String variables.

For more information call ?fmi3SetString
"""
function fmi3SetString(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetString(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Binary variables.

For more information call ?fmi3GetBinary
"""
function fmi3GetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBinary(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Binary variables.

For more information call ?fmi3GetBinary!
"""
function fmi3GetBinary!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBinary!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Binary variables.

For more information call ?fmi3SetBinary
"""
function fmi3SetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat, valueSizes::Union{Array{Csize_t}, Csize_t}, values::Union{Array{fmi3Binary}, fmi3Binary})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetBinary(fmu.components[end], vr, valueSizes, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Clock variables.

For more information call ?fmi3GetClock
"""
function fmi3GetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetClock(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Clock variables.

For more information call ?fmi3GetClock!
"""
function fmi3GetClock!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetClock!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Clock variables.

For more information call ?fmi3SetClock
"""
function fmi3SetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetClock(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Get the pointer to the current FMU state.

For more information call ?fmi3GetFMUState
"""
function fmi3GetFMUState(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFMUState(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Set the FMU to the given fmi3FMUstate.

For more information call ?fmi3SetFMUState
"""
function fmi3SetFMUState(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFMUState(fmu.components[end], state)
end

"""
function fmi3FreeFMUState(c::fmi3Component, FMUstate::Ref{fmi3FMUState})

Free the allocated memory for the FMU state.

For more information call ?fmi3FreeFMUState
"""
function fmi3FreeFMUState(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    stateRef = Ref(state)
    fmi3FreeFMUState(fmu.components[end], stateRef)
    state = stateRef[]
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Returns the size of a byte vector the FMU can be stored in.

For more information call ?fmi3SerzializedFMUStateSize
"""
function fmi3SerializedFMUStateSize(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SerializedFMUStateSize(fmu.components[end], state)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Serialize the data in the FMU state pointer.

For more information call ?fmi3SerializeFMUState
"""
function fmi3SerializeFMUState(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SerializeFMUState(fmu.components[end], state)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Deserialize the data in the serializedState fmi3Byte field.

For more information call ?fmi3DeSerializeFMUState
"""
function fmi3DeSerializeFMUState(fmu::FMU3, serializedState::Array{fmi3Byte})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3DeSerializeFMUState(fmu.components[end], serializedState)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives in-place.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative!(fmu.components[end], unknowns, knowns, sensitivity, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)

    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 

    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative!(fmu.components[end], unknowns, knowns, sensitivity, seed)
end
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi3GetOutputDerivatives
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReferenceFormat, order::Array{Integer})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetOutputDerivatives(fmu.components[end], vr, order)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi3GetOutputDerivatives
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReference, order::Integer)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetOutputDerivatives(fmu.components[end], vr, order)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

If the importer needs to change structural parameters, it must move the FMU into Configuration Mode using fmi3EnterConfigurationMode.
For more information call ?fmi3EnterConfigurationMode
"""
function fmi3EnterConfigurationMode(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterConfigurationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of continuous states.
This function can only be called in Model Exchange. 
For more information call ?fmi3GetNumberOfContinuousStates
"""
function fmi3GetNumberOfContinuousStates(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNumberOfContinuousStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of event indicators.
This function can only be called in Model Exchange.
For more information call ?fmi3GetNumberOfEventIndicators
"""
function fmi3GetNumberOfEventIndicators(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNumberOfEventIndicators(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The number of dependencies of a given variable, which may change if structural parameters are changed, can be retrieved by calling the following function:
For more information call ?fmi3GetNumberOfVariableDependencies
"""
function fmi3GetNumberOfVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNumberOfVariableDependencies(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the states at the current time instant.
For more information call ?fmi3GetContinuousStates
"""
function fmi3GetContinuousStates(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetContinuousStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The dependencies (of type dependenciesKind) can be retrieved by calling the function fmi3GetVariableDependencies.
For more information call ?fmi3GetVariableDependencies
"""
function fmi3GetVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetVariableDependencies(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the nominal values of the continuous states.

For more information call ?fmi3GetNominalsOfContinuousStates
"""
function fmi3GetNominalsOfContinuousStates(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNominalsOfContinuousStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

This function is called to trigger the evaluation of fdisc to compute the current values of discrete states from previous values. 
The FMU signals the support of fmi3EvaluateDiscreteStates via the capability flag providesEvaluateDiscreteStates.
    
For more information call ?fmi3EvaluateDiscreteStates
"""
function fmi3EvaluateDiscreteStates(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EvaluateDiscreteStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function is called to signal a converged solution at the current super-dense time instant. fmi3UpdateDiscreteStates must be called at least once per super-dense time instant.

For more information call ?fmi3UpdateDiscreteStates
"""
function fmi3UpdateDiscreteStates(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3UpdateDiscreteStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

The model enters Continuous-Time Mode.

For more information call ?fmi3EnterContinuousTimeMode
"""
function fmi3EnterContinuousTimeMode(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterContinuousTimeMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function must be called to change from Event Mode into Step Mode in Co-Simulation.

For more information call ?fmi3EnterStepMode
"""
function fmi3EnterStepMode(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterStepMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.6. State: Configuration Mode

Exits the Configuration Mode and returns to state Instantiated.

For more information call ?fmi3ExitConfigurationMode
"""
function fmi3ExitConfigurationMode(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3ExitConfigurationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set independent variable time and reinitialize chaching of variables that depend on time.

For more information call ?fmi3SetTime
"""
function fmi3SetTime(fmu::FMU3, time::Real)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmu.t = time
    fmi3SetTime(fmu.components[end], fmi3Float64(time))
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new (continuous) state vector and reinitialize chaching of variables that depend on states.

For more information call ?fmi3SetContinuousStates
"""
function fmi3SetContinuousStates(fmu::FMU3, x::Union{Array{Float32}, Array{Float64}})
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    nx = Csize_t(length(x))
    fmu.x = x
    fmi3SetContinuousStates(fmu.components[end], Array{fmi3Float64}(x), nx)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi3GetContinuousStateDerivatives
"""
function  fmi3GetContinuousStateDerivatives(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetContinuousStateDerivatives(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Returns the event indicators of the FMU.

For more information call ?fmi3GetEventIndicators
"""
function fmi3GetEventIndicators(fmu::FMU3)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetEventIndicators(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

This function must be called by the environment after every completed step
If enterEventMode == fmi3True, the event mode must be entered
If terminateSimulation == fmi3True, the simulation shall be terminated

For more information call ?fmi3CompletedIntegratorStep
"""
function fmi3CompletedIntegratorStep(fmu::FMU3,
                                     noSetFMUStatePriorToCurrentPoint::fmi3Boolean)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3CompletedIntegratorStep(fmu.components[end], noSetFMUStatePriorToCurrentPoint)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

The model enters Event Mode.

For more information call ?fmi3EnterEventMode
"""
function fmi3EnterEventMode(fmu::FMU3, stepEvent::Bool, stateEvent::Bool, rootsFound::Array{fmi3Int32}, nEventIndicators::Integer, timeEvent::Bool)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterEventMode(fmu.components[end], stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 4.2.1. State: Step Mode

The computation of a time step is started.

For more information call ?fmi3DoStep
"""
function fmi3DoStep(fmu::FMU3, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool, eventEncountered::fmi3Boolean, terminateSimulation::fmi3Boolean, earlyReturn::fmi3Boolean, lastSuccessfulTime::fmi3Float64)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    refeventEncountered = Ref(eventEncountered)
    refterminateSimulation = Ref(terminateSimulation)
    refearlyReturn = Ref(earlyReturn)
    reflastSuccessfulTime = Ref(lastSuccessfulTime)
    fmi3DoStep(fmu.components[end], fmi3Float64(currentCommunicationPoint), fmi3Float64(communicationStepSize), fmi3Boolean(noSetFMUStatePriorToCurrentPoint), refeventEncountered, refterminateSimulation, refearlyReturn, reflastSuccessfulTime)
    eventEncountered = refeventEncountered[]
    terminateSimulation = refterminateSimulation[]
    earlyReturn = refearlyReturn[]
    lastSuccessfulTime = reflastSuccessfulTime[]
end

"""
Starts a simulation of the fmu instance for the matching fmu type. If both types are available, CS is preferred over ME.
"""
function fmi3Simulate(fmu::FMU3, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3Simulate(fmu.components[end], t_start, t_stop;
                 recordValues=recordValues, saveat=saveat, setup=setup)
end
"""
Starts a simulation of a FMU in CS-mode.
"""
function fmi3SimulateCS(fmu::FMU3, t_start::Real, t_stop::Real;
                        recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SimulateCS(fmu.components[end], t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
Starts a simulation of a FMU in ME-mode.
"""
function fmi3SimulateME(fmu::FMU3, t_start::Real, t_stop::Real; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SimulateME(fmu.components[end], t_start, t_stop; kwargs...)
end

"""
Returns the start/default value for a given value reference.

TODO: Add this command in the documentation.
"""
function fmi3GetStartValue(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    
    fmi3GetStartValue(fmu.components[end], vr)
end