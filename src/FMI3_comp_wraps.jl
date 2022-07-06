#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI3_comp_wraps.jl` (FMU instance wrappers)?
# - wrappers to call fmi3InstanceFunctions from FMUs (FMI-functions,        last instantiated component is used) [exported]
# - wrappers to call fmi3InstanceFunctions from FMUs (additional functions, last instantiated component is used) [exported]


using FMIImport: FMU3, fmi3ModelDescription
using FMIImport: fmi3Float32, fmi3Float64, fmi3Int8, fmi3Int16, fmi3Int32, fmi3Int64, fmi3Boolean, fmi3String, fmi3Binary, fmi3UInt8, fmi3UInt16, fmi3UInt32, fmi3UInt64, fmi3Byte
using FMIImport: fmi3Clock, fmi3FMUState
using FMIImport: fmi3CallbackLogger, fmi3CallbackIntermediateUpdate, fmi3CallbackClockUpdate

# fmi-spec
"""
    fmi3FreeInstance!(fmu::FMU3)

Wrapper for fmi3FreeInstance!() in FMIImport/FMI3_c.jl
"""
function fmi3FreeInstance!(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2FreeInstance!(fmu.instances[end]) # this command also removes the instance from the array
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
    fmi3EnterInitializationMode(fmu::FMU3, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)

Wrapper for fmi3EnterInitializationMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterInitializationMode(fmu::FMU3, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterInitializationMode(fmu.instances[end], startTime, stopTime; tolerance = tolerance)
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

Wrapper for fmi2Reset() in FMIImport/FMI3_c.jl
"""
function fmi3Reset(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3Reset(fmu.instances[end])
end

"""
    fmi3GetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetFloat32() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat32(fmu.instances[end], vr)
end

"""
    fmi3GetFloat32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})

Wrapper for fmi3GetFloat32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat32!(fmu.instances[end], vr, values)
end

"""
fmi3SetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})

Wrapper for fmi3SetFloat32() in FMIImport/FMI3_int.jl
"""
function fmi3SetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFloat32(fmu.instances[end], vr, values)
end

"""
    fmi3GetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetFloat64() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat64(fmu.instances[end], vr)
end

"""
    fmi3GetFloat64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})

Wrapper for fmi3GetFloat64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetFloat64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFloat64!(fmu.instances[end], vr, values)
end

"""
    fmi3SetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})

Wrapper for fmi3SetFloat64() in FMIImport/FMI3_int.jl
"""
function fmi3SetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFloat64(fmu.instances[end], vr, values)
end

"""
    fmi3GetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetInt8() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt8(fmu.instances[end], vr)
end

"""
    fmi3GetInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})

Wrapper for fmi3GetInt8!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt8!(fmu.instances[end], vr, values)
end

"""
    fmi3SetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})

Wrapper for fmi3SetInt8() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt8(fmu.instances[end], vr, values)
end

"""
    fmi3GetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetUInt8() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt8(fmu.instances[end], vr)
end

"""
    fmi3GetUInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})

Wrapper for fmi3GetUInt8!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt8!(fmu.instances[end], vr, values)
end

"""
    fmi3SetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})

Wrapper for fmi3SetUInt8() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt8(fmu.instances[end], vr, values)
end

"""
    fmi3GetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetInt16() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt16(fmu.instances[end], vr)
end

"""
    fmi3GetInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})

Wrapper for fmi3GetInt16!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt16!(fmu.instances[end], vr, values)
end

"""
    fmi3SetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})

Wrapper for fmi3SetInt16() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt16(fmu.instances[end], vr, values)
end

"""
    fmi3GetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetUInt16() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt16(fmu.instances[end], vr)
end

"""
    fmi3GetUInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})

Wrapper for fmi3GetUInt16!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt16!(fmu.instances[end], vr, values)
end

"""
    fmi3SetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})

Wrapper for fmi3SetUInt16() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt16(fmu.instances[end], vr, values)
end

"""
    fmi3GetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetInt32() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt32(fmu.instances[end], vr)
end

"""
    fmi3GetInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})

Wrapper for fmi3GetInt32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt32!(fmu.instances[end], vr, values)
end

"""
    fmi3SetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})

Wrapper for fmi3SetInt32() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt32(fmu.instances[end], vr, values)
end

"""
    fmi3GetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetUInt32() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt32(fmu.instances[end], vr)
end

"""
    fmi3GetUInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})

Wrapper for fmi3GetUInt32!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt32!(fmu.instances[end], vr, values)
end

"""
    fmi3SetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})

Wrapper for fmi3SetUInt32() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt32(fmu.instances[end], vr, values)
end

"""
    fmi3GetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetInt64() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt64(fmu.instances[end], vr)
end

"""
    fmi3GetInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})

Wrapper for fmi3GetInt64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetInt64!(fmu.instances[end], vr, values)
end

"""
    fmi3SetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})

Wrapper for fmi3SetInt64() in FMIImport/FMI3_int.jl
"""
function fmi3SetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetInt64(fmu.instances[end], vr, values)
end

"""
    fmi3GetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    
Wrapper for fmi3GetUInt64() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt64(fmu.instances[end], vr)
end

"""
    fmi3GetUInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
        
Wrapper for fmi3GetUInt64!() in FMIImport/FMI3_int.jl
"""
function fmi3GetUInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetUInt64!(fmu.instances[end], vr, values)
end

"""
    fmi3SetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
        
Wrapper for fmi3SetUInt64() in FMIImport/FMI3_int.jl
"""
function fmi3SetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetUInt64(fmu.instances[end], vr, values)
end

"""
    fmi3GetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat)

Wrapper for fmi3GetBoolean() in FMIImport/FMI3_int.jl
"""
function fmi3GetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBoolean(fmu.instances[end], vr)
end

"""
    fmi3GetBoolean!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool, Array{fmi3Boolean}})

Wrapper for fmi3GetBoolean!() in FMIImport/FMI3_int.jl
"""
function fmi3GetBoolean!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool, Array{fmi3Boolean}})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBoolean!(fmu.instances[end], vr, values)
end

"""
    fmi3SetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool, Array{fmi3Boolean}})

Wrapper for fmi3SetBoolean!() in FMIImport/FMI3_int.jl
"""
function fmi3SetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetBoolean(fmu.instances[end], vr, values)
end

"""
    fmi3GetString(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    
Wrapper for fmi3GetString() in FMIImport/FMI3_int.jl
"""
function fmi3GetString(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetString(fmu.instances[end], vr)
end

"""
    fmi3GetString!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    
Wrapper for fmi3GetString!() in FMIImport/FMI3_int.jl
"""
function fmi3GetString!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetString!(fmu.instances[end], vr, values)
end

"""
    fmi3SetString(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    
Wrapper for fmi3SetString() in FMIImport/FMI3_int.jl
"""
function fmi3SetString(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetString(fmu.instances[end], vr, values)
end

"""
    fmi3GetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    
Wrapper for fmi3GetBinary() in FMIImport/FMI3_int.jl
"""
function fmi3GetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBinary(fmu.instances[end], vr)
end

"""
    fmi3GetBinary!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})
    
Wrapper for fmi3GetBinary!() in FMIImport/FMI3_int.jl
"""
function fmi3GetBinary!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetBinary!(fmu.instances[end], vr, values)
end

"""
    fmi3SetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})
    
Wrapper for fmi3SetBinary() in FMIImport/FMI3_int.jl
"""
function fmi3SetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat, valueSizes::Union{Array{Csize_t}, Csize_t}, values::Union{Array{fmi3Binary}, fmi3Binary})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetBinary(fmu.instances[end], vr, valueSizes, values)
end

"""
    fmi3GetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    
Wrapper for fmi3GetClock() in FMIImport/FMI3_int.jl
"""
function fmi3GetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetClock(fmu.instances[end], vr)
end

"""
    fmi3GetClock!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    
Wrapper for fmi3GetClock!() in FMIImport/FMI3_int.jl
"""
function fmi3GetClock!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetClock!(fmu.instances[end], vr, values)
end

"""
    fmi3SetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    
Wrapper for fmi3SetClock() in FMIImport/FMI3_int.jl
"""
function fmi3SetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetClock(fmu.instances[end], vr, values)
end

"""
    fmi3GetFMUstate(fmu::FMU3)

Wrapper for fmi3GetFMUstate() in FMIImport/FMI3_int.jl
"""
function fmi3GetFMUState(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetFMUState(fmu.instances[end])
end

"""
    fmi3SetFMUstate(fmu::FMU3,state::fmi3FMUState)

Wrapper for fmi3SetFMUstate() in FMIImport/FMI3_c.jl
"""
function fmi3SetFMUState(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SetFMUState(fmu.instances[end], state)
end

"""
    fmi3FreeFMUState!(fmu::FMU3, state::fmi3FMUState)

Wrapper for fmi3FreeFMUState!() in FMIImport/FMI3_int.jl
"""
function fmi3FreeFMUState!(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3FreeFMUState!(fmu.instances[end], state)
end

"""
    fmi3SerializedFMUStateSize(fmu::FMU3, state::fmi3FMUState)

Wrapper for fmi3SerializedFMUStateSize() in FMIImport/FMI3_int.jl
"""
function fmi3SerializedFMUStateSize(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SerializedFMUStateSize(fmu.instances[end], state)
end

"""
    fmi3SerializeFMUState(fmu::FMU3, state::fmi3FMUState)

Wrapper for fmi3SerializeFMUState() in FMIImport/FMI3_int.jl
"""
function fmi3SerializeFMUState(fmu::FMU3, state::fmi3FMUState)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3SerializeFMUState(fmu.instances[end], state)
end

"""
    fmi3DeSerializeFMUState(fmu::FMU3, serializedState::Array{fmi3Byte})

Wrapper for fmi3DeSerializeFMUState() in FMIImport/FMI3_int.jl
"""
function fmi3DeSerializeFMUState(fmu::FMU3, serializedState::Array{fmi3Byte})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3DeSerializeFMUState(fmu.instances[end], serializedState)
end

"""
    fmi3GetDirectionalDerivative(fmu::FMU3, unknowns::fmi3ValueReference, knowns::fmi3ValueReference, seed::fmi3Float64 = 1.0))

Wrapper for fmi3GetDirectionalDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative(fmu.instances[end], unknowns, knowns, seed)
end

"""
    fmi3GetDirectionalDerivative(fmu::FMU3, unknowns::fmi3ValueReference, knowns::fmi3ValueReference,  seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

Wrapper for fmi3GetDirectionalDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative(fmu.instances[end], unknowns, knowns, seed)
end

"""
    fmi3GetDirectionalDerivative!(fmu::FMU3, unknowns::Array{fmi3ValueReference}, knowns::Array{fmi3ValueReference}, sensitivity::Array{fmi3Float64}, seed::Array{fmi3Float64} = Array{fmi3Float64}([]))
    
Wrapper for fmi3GetDirectionalDerivative!() in FMIImport/FMI3_int.jl
"""
function fmi3GetDirectionalDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetDirectionalDerivative!(fmu.instances[end], unknowns, knowns, sensitivity, seed)
end

"""
    fmi3GetAdjointDerivative(fmu::FMU3, unknowns::fmi3ValueReference, knowns::fmi3ValueReference, seed::fmi3Float64 = 1.0))

Wrapper for fmi3GetAdjointDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative(fmu.instances[end], unknowns, knowns, seed)
end

"""
    fmi3GetAdjointDerivative(fmu::FMU3, unknowns::fmi3ValueReference, knowns::fmi3ValueReference,  seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

Wrapper for fmi3GetAdjointDerivative() in FMIImport/FMI3_int.jl
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative(fmu.instances[end], unknowns, knowns, seed)
end

"""
    fmi3GetAdjointDerivative!(fmu::FMU3, unknowns::Array{fmi3ValueReference}, knowns::Array{fmi3ValueReference}, sensitivity::Array{fmi3Float64}, seed::Array{fmi3Float64} = Array{fmi3Float64}([]))
    
Wrapper for fmi3GetAdjointDerivative!() in FMIImport/FMI3_int.jl
"""
function fmi3GetAdjointDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetAdjointDerivative!(fmu.instances[end], unknowns, knowns, sensitivity, seed)
end
"""
    fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReferenceFormat, order::Array{Integer})
    
Wrapper for fmi3GetOutputDerivatives() in FMIImport/FMI3_int.jl
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReferenceFormat, order::Array{Integer})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetOutputDerivatives(fmu.instances[end], vr, order)
end

"""
    fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReferenceFormat, order::Integer)
    
Wrapper for fmi3GetOutputDerivatives() in FMIImport/FMI3_int.jl
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReference, order::Integer)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetOutputDerivatives(fmu.instances[end], vr, order)
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
    fmi3GetNumberOfEventIndicators(fmu::FMU3)

Wrapper for fmi3GetNumberOfEventIndicators() in FMIImport/FMI3_c.jl
"""
function fmi3GetNumberOfEventIndicators(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNumberOfEventIndicators(fmu.instances[end])
end

"""
    fmi3GetNumberOfVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    
Wrapper for fmi3GetNumberOfVariableDependencies() in FMIImport/FMI3_c.jl
"""
function fmi3GetNumberOfVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetNumberOfVariableDependencies(fmu.instances[end], vr)
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
    fmi3GetVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})

Wrapper for fmi3GetVariableDependencies() in FMIImport/FMI3_c.jl
"""
function fmi3GetVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3GetVariableDependencies(fmu.instances[end], vr)
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
    fmi3SetTime(fmu::FMU3, time::Real)

Wrapper for fmi3SetTime() in FMIImport/FMI3_c.jl
"""
function fmi3SetTime(fmu::FMU3, time::Real)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmu.t = time
    fmi3SetTime(fmu.instances[end], fmi3Float64(time))
end

"""
    fmi3SetContinuousStates(fmu::FMU3, x::Union{Array{Float32}, Array{Float64}})

Wrapper for fmi3SetContinuousStates() in FMIImport/FMI3_c.jl
"""
function fmi3SetContinuousStates(fmu::FMU3, x::Union{Array{Float32}, Array{Float64}})
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    nx = Csize_t(length(x))
    fmu.x = x
    fmi3SetContinuousStates(fmu.instances[end], Array{fmi3Float64}(x), nx)
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
fmi3CompletedIntegratorStep(fmu::FMU3, noSetFMUStatePriorToCurrentPoint::fmi3Boolean)

Wrapper for fmi3CompletedIntegratorStep() in FMIImport/FMI3_c.jl
"""
function fmi3CompletedIntegratorStep(fmu::FMU3,
                                     noSetFMUStatePriorToCurrentPoint::fmi3Boolean)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3CompletedIntegratorStep(fmu.instances[end], noSetFMUStatePriorToCurrentPoint)
end

"""
    fmi3EnterEventMode(fmu::FMU3, stepEvent::Bool, stateEvent::Bool, rootsFound::Array{fmi3Int32}, nEventIndicators::Integer, timeEvent::Bool)

Wrapper for fmi3EnterEventMode() in FMIImport/FMI3_c.jl
"""
function fmi3EnterEventMode(fmu::FMU3, stepEvent::Bool, stateEvent::Bool, rootsFound::Array{fmi3Int32}, nEventIndicators::Integer, timeEvent::Bool)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3EnterEventMode(fmu.instances[end], stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
end

"""
    fmi3DoStep(fmu::FMU3, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool, eventEncountered::fmi3Boolean, terminateSimulation::fmi3Boolean, earlyReturn::fmi3Boolean, lastSuccessfulTime::fmi3Float64)

Wrapper for fmi3DoStep() in FMIImport/FMI3_c.jl
"""
function fmi3DoStep(fmu::FMU3, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool, eventEncountered::fmi3Boolean, terminateSimulation::fmi3Boolean, earlyReturn::fmi3Boolean, lastSuccessfulTime::fmi3Float64)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    refeventEncountered = Ref(eventEncountered)
    refterminateSimulation = Ref(terminateSimulation)
    refearlyReturn = Ref(earlyReturn)
    reflastSuccessfulTime = Ref(lastSuccessfulTime)
    fmi3DoStep(fmu.instances[end], fmi3Float64(currentCommunicationPoint), fmi3Float64(communicationStepSize), fmi3Boolean(noSetFMUStatePriorToCurrentPoint), refeventEncountered, refterminateSimulation, refearlyReturn, reflastSuccessfulTime)
    eventEncountered = refeventEncountered[]
    terminateSimulation = refterminateSimulation[]
    earlyReturn = refearlyReturn[]
    lastSuccessfulTime = reflastSuccessfulTime[]
end

#additional
"""
    fmi3Simulate(fmu::FMU3, t_start::Real = 0.0, t_stop::Real = 1.0;
    recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)

Wrapper for fmi3Simulate() in FMI/FMI3_sim.jl
"""
function fmi3Simulate(fmu::FMU3, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]

    fmi3Simulate(fmu.instances[end], t_start, t_stop;
                 recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
    fmi3SimulateCS(fmu::FMU3, args...; kwargs...)

Wrapper for fmi3SimulateCS() in FMI/FMI2_sim.jl
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
    fmi3GetStartValue(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    
Wrapper for fmi3GetStartValue() in FMIImport/FMI3_c.jl
"""
function fmi3GetStartValue(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    
    fmi3GetStartValue(fmu.instances[end], vr)
end