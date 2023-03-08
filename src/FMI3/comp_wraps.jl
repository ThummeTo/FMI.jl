#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI3_comp_wraps.jl` (FMU instance wrappers)?
# - wrappers to call fmi3InstanceFunctions from FMUs (FMI-functions,        last instantiated instance is used) [exported]
# - wrappers to call fmi3InstanceFunctions from FMUs (additional functions, last instantiated instance is used) [exported]

# TODO why is this here?
# using FMIImport: FMU3, fmi3ModelDescription
# using FMIImport: fmi3Float32, fmi3Float64, fmi3Int8, fmi3Int16, fmi3Int32, fmi3Int64, fmi3Boolean, fmi3String, fmi3Binary, fmi3UInt8, fmi3UInt16, fmi3UInt32, fmi3UInt64, fmi3Byte
# using FMIImport: fmi3Clock, fmi3FMUState
# using FMIImport: fmi3CallbackLogger, fmi3CallbackIntermediateUpdate, fmi3CallbackClockUpdate

# fmi-spec
"""
    fmi3FreeInstance!(fmu::FMU3)

Wrapper for fmi3FreeInstance!() in FMIImport/FMI3_c.jl
"""
function fmi3FreeInstance!(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3FreeInstance!(fmu.instances[end]) # this command also removes the instance from the array
end

"""
    fmi3SetDebugLogging(fmu::FMU3)

Wrapper for fmi3SetDebugLogging() in FMIImport/FMI3_int.jl
"""
function fmi3SetDebugLogging(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetDebugLogging(fmu.instances[end])
end

"""
    fmi3EnterInitializationMode(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3EnterInitializationMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterInitializationMode(fmu::FMU3, args...; kwargs...)
            @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterInitializationMode(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3ExitInitializationMode(fmu::FMU2)

Wrapper for fmi3ExitInitializationMode() in FMIImport/FMI3_c.jl
"""
function fmi3ExitInitializationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3ExitInitializationMode(fmu.instances[end])
end

"""
    fmi3Terminate(fmu::FMU3)

Wrapper for fmi3Terminate() in FMIImport/FMI3_c.jl
"""
function fmi3Terminate(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Terminate(fmu.instances[end])
end

"""
    fmi3Reset(fmu::FMU3)

Wrapper for fmi3Reset() in FMIImport/FMI3_c.jl
"""
function fmi3Reset(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Reset(fmu.instances[end])
end

"""
    fmi3GetFloat32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetFloat32() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat32!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetFloat32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat32!(fmu.instances[end], args...; kwargs...)
end

"""
fmi3SetFloat32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetFloat32() in FMIImport/FMI3_int.jl
"""
function fmi3SetFloat32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFloat32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat64(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetFloat64() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat64!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetFloat64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetFloat64(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetFloat64() in FMIImport/FMI3_int.jl
"""
function fmi3SetFloat64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFloat64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt8(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt8() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt8!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt8!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt8!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt8!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt8(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetInt8() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt8(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt8() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt8!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt8!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt8!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt8!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt8(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetUInt8() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt16(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt16() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt16!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt16!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt16!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt16!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt16(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetInt16() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt16(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt16() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt16!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt16!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt16!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt16!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt16(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetUInt16() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt32() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt32!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt32!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetInt32() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt32() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt32!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetUInt32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt32!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt32(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetUInt32() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt64(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt64() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt64!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetInt64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt64(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetInt64() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt64(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetUInt64() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt64!(fmu::FMU3, args...; kwargs...)
        
Wrapper for fmi3GetUInt64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt64(fmu::FMU3, args...; kwargs...)
        
Wrapper for fmi3SetUInt64() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBoolean(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetBoolean() in FMIImport/FMI3_int.jl
"""
function fmi3GetBoolean(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBoolean(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBoolean!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetBoolean!() in FMIImport/FMI3_int.jl
"""
function fmi3GetBoolean!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBoolean!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetBoolean(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetBoolean!() in FMIImport/FMI3_int.jl
"""
function fmi3SetBoolean(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetBoolean(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetString(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetString() in FMIImport/FMI3_int.jl
"""
function fmi3GetString(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetString(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetString!(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetString!() in FMIImport/FMI3_int.jl
"""
function fmi3GetString!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetString!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetString(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3SetString() in FMIImport/FMI3_int.jl
"""
function fmi3SetString(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetString(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBinary(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetBinary() in FMIImport/FMI3_int.jl
"""
function fmi3GetBinary(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBinary(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBinary!(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetBinary!() in FMIImport/FMI3_int.jl
"""
function fmi3GetBinary!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBinary!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetBinary(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3SetBinary() in FMIImport/FMI3_int.jl
"""
function fmi3SetBinary(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetBinary(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetClock(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetClock() in FMIImport/FMI3_int.jl
"""
function fmi3GetClock(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetClock(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetClock!(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetClock!() in FMIImport/FMI3_int.jl
"""
function fmi3GetClock!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetClock!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetClock(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3SetClock() in FMIImport/FMI3_int.jl
"""
function fmi3SetClock(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetClock(fmu.instances[end], args...; kwargs...)
end

"""
    fmiGet(fmu::FMU3, args...; kwargs...)

Wrapper for fmiGet() in FMIImport/FMI3_ext.jl
"""
function fmiGet(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Get(fmu.instances[end], args...; kwargs...)
end

"""
    fmiGet!(fmu::FMU3, args...; kwargs...)

Wrapper for fmiGet!() in FMIImport/FMI3_ext.jl
"""
function fmiGet!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Get!(fmu.instances[end], args...; kwargs...)
end

"""
    fmiSet(fmu::FMU3, args...; kwargs...)

Wrapper for fmiSet() in FMIImport/FMI3_ext.jl
"""
function fmiSet(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Set(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFMUstate(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetFMUstate() in FMIImport/FMI3_int.jl
"""
function fmi3GetFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetFMUstate(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetFMUstate() in FMIImport/FMI3_c.jl
"""
function fmi3SetFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3FreeFMUState!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3FreeFMUState!() in FMIImport/FMI3_int.jl
"""
function fmi3FreeFMUState!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3FreeFMUState!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SerializedFMUStateSize(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SerializedFMUStateSize() in FMIImport/FMI3_int.jl
"""
function fmi3SerializedFMUStateSize(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SerializedFMUStateSize(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SerializeFMUState(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SerializeFMUState() in FMIImport/FMI3_int.jl
"""
function fmi3SerializeFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SerializeFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3DeSerializeFMUState(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3DeSerializeFMUState() in FMIImport/FMI3_int.jl
"""
function fmi3DeSerializeFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3DeSerializeFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetDirectionalDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetDirectionalDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetDirectionalDerivative(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetDirectionalDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetDirectionalDerivative!(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetDirectionalDerivative!() in FMIImport/FMI3_int.jl
"""
function fmi3GetDirectionalDerivative!(fmu::FMU3, args...; kwargs...) 
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetDirectionalDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetAdjointDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetAdjointDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetAdjointDerivative(fmu::FMU3, args...; kwargs...)

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetAdjointDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetAdjointDerivative!(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetAdjointDerivative!() in FMIImport/FMI3_int.jl
"""
function fmi3GetAdjointDerivative!(fmu::FMU3, args...; kwargs...) 

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetAdjointDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SampleDirectionalDerivative!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SampleDirectionalDerivative!() in FMIImport/FMI3_ext.jl
"""
function fmi3SampleDirectionalDerivative!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SampleDirectionalDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SampleDirectionalDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SampleDirectionalDerivative() in FMIImport/FMI3_ext.jl
"""
function fmi3SampleDirectionalDerivative(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SampleDirectionalDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetJacobian!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetJacobian!() in FMIImport/FMI3_ext.jl
"""
function fmi3GetJacobian!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetJacobian!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetJacobian(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetJacobian() in FMIImport/FMI3_ext.jl
"""
function fmi3GetJacobian(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetJacobian(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetOutputDerivatives(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetOutputDerivatives() in FMIImport/FMI3_int.jl
"""
function fmi3GetOutputDerivatives(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetOutputDerivatives(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3EnterConfigurationMode(fmu::FMU3)
    
Wrapper for fmi3EnterConfigurationMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterConfigurationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterConfigurationMode(fmu.instances[end])
end

"""
    fmi3GetNumberOfContinuousStates(fmu::FMU3)
    
Wrapper for fmi3GetNumberOfContinuousStates() in FMIImport/FMI3_c.jl
"""
function fmi3GetNumberOfContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNumberOfContinuousStates(fmu.instances[end])
end

"""
    fmi3GetNumberOfVariableDependencies(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetNumberOfVariableDependencies() in FMIImport/FMI3_c.jl
"""
function fmi3GetNumberOfVariableDependencies(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNumberOfVariableDependencies(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetVariableDependencies(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3GetVariableDependencies() in FMIImport/FMI3_c.jl
"""
function fmi3GetVariableDependencies(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetVariableDependencies(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetContinuousStates(fmu::FMU3)

Wrapper for fmi3GetContinuousStates() in FMIImport/FMI3_c.jl
"""
function fmi3GetContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetContinuousStates(fmu.instances[end])
end

"""
    fmi3GetNominalsOfContinuousStates(fmu::FMU3)

Wrapper for fmi3GetNominalsOfContinuousStates() in FMIImport/FMI3_c.jl
"""
function fmi3GetNominalsOfContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNominalsOfContinuousStates(fmu.instances[end])
end

"""
fmi3EvaluateDiscreteStates(fmu::FMU3)

Wrapper for fmi3EvaluateDiscreteStates() in FMIImport/FMI3_c.jl
"""
function fmi3EvaluateDiscreteStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EvaluateDiscreteStates(fmu.instances[end])
end

"""
    fmi3UpdateDiscreteStates(fmu::FMU3)

Wrapper for fmi3UpdateDiscreteStates() in FMIImport/FMI3_c.jl
"""
function fmi3UpdateDiscreteStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3UpdateDiscreteStates(fmu.instances[end])
end

"""
    fmi3EnterContinuousTimeMode(fmu::FMU3)

Wrapper for fmi3EnterContinuousTimeMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterContinuousTimeMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterContinuousTimeMode(fmu.instances[end])
end

"""
    fmi3EnterStepMode(fmu::FMU3)

Wrapper for fmi3EnterStepMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterStepMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterStepMode(fmu.instances[end])
end

"""
    fmi3ExitConfigurationMode(fmu::FMU3)

Wrapper for fmi3ExitConfigurationMode() in FMIImport/FMI3_c.jl
"""
function fmi3ExitConfigurationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3ExitConfigurationMode(fmu.instances[end])
end

"""
    fmi3SetTime(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetTime() in FMIImport/FMI3_c.jl
"""
function fmi3SetTime(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetTime(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetContinuousStates(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SetContinuousStates() in FMIImport/FMI3_c.jl
"""
function fmi3SetContinuousStates(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetContinuousStates(fmu.instances[end], args...; kwargs...)
end

"""
fmi3GetContinuousStateDerivatives(fmu::FMU3)

Wrapper for fmi3GetContinuousStateDerivatives() in FMIImport/FMI3_c.jl
"""
function  fmi3GetContinuousStateDerivatives(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetContinuousStateDerivatives(fmu.instances[end])
end

"""
    fmi3GetEventIndicators(fmu::FMU3)

Wrapper for fmi3GetEventIndicators() in FMIImport/FMI3_c.jl
"""
function fmi3GetEventIndicators(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetEventIndicators(fmu.instances[end])
end

"""
fmi3CompletedIntegratorStep(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3CompletedIntegratorStep() in FMIImport/FMI3_c.jl
"""
function fmi3CompletedIntegratorStep(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3CompletedIntegratorStep(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3EnterEventMode(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3EnterEventMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterEventMode(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterEventMode(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3DoStep!(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3DoStep!() in FMIImport/FMI3_c.jl
"""
function fmi3DoStep!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3DoStep!(fmu.instances[end], args...; kwargs...)
end

#additional
"""
    fmi3Simulate(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3Simulate() in FMI/FMI3_sim.jl
"""
function fmi3Simulate(fmu::FMU3, args...; kwargs...)
    fmi3Simulate(fmu, nothing, args...; kwargs...)
end

"""
    fmi3SimulateCS(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SimulateCS() in FMI/FMI3_sim.jl
"""
function fmi3SimulateCS(fmu::FMU3, args...; kwargs...)
    return fmi3SimulateCS(fmu, nothing, args...; kwargs...)
end

"""
    fmi3SimulateME(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SimulateME() in FMI/FMI3_sim.jl
"""
function fmi3SimulateME(fmu::FMU3, args...; kwargs...)
    return fmi3SimulateME(fmu, nothing, args...; kwargs...)
end


"""
    fmi3GetStartValue(fmu::FMU3, args...; kwargs...)
    
Wrapper for fmi3GetStartValue() in FMIImport/FMI3_c.jl
"""
function fmi3GetStartValue(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetStartValue(fmu.instances[end], args...; kwargs...)
end