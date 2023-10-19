#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI3_comp_wraps.jl` (FMU instance wrappers)?
# - wrappers to call fmi3InstanceFunctions from FMUs (FMI-functions,        last instantiated instance is used) [exported]
# - wrappers to call fmi3InstanceFunctions from FMUs (additional functions, last instantiated instance is used) [exported]

# fmi-spec
"""
    fmi3Simulate(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3Simulate(fmu::FMU3, c::Union{FMU3Instance, Nothing}, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets passed as `nothing`)
"""
function fmi3Simulate(fmu::FMU3, args...; kwargs...)
    return fmi3Simulate(fmu, nothing, args...; kwargs...)
end

"""
    fmi3SimulateCS(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SimulateCS(fmu::FMU3, c::Union{FMU3Instance, Nothing}, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets passed as `nothing`)
"""
function fmi3SimulateCS(fmu::FMU3, args...; kwargs...)
    return fmi3SimulateCS(fmu, nothing, args...; kwargs...)
end

"""
    fmi3SimulateME(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SimulateME(fmu::FMU3, c::Union{FMU3Instance, Nothing}, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets passed as `nothing`)
"""
function fmi3SimulateME(fmu::FMU3, args...; kwargs...)
    return fmi3SimulateME(fmu, nothing, args...; kwargs...)
end

"""
    fmi3FreeInstance!(fmu::FMU3)

Wrapper for `fmi3FreeInstance!(c::FMU3Instance; popInstance::Bool = true)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3FreeInstance!(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3FreeInstance!(fmu.instances[end]) # this command also removes the instance from the array
end

"""
    fmi3SetDebugLogging(fmu::FMU3)

Wrapper for `fmi3SetDebugLogging(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetDebugLogging(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetDebugLogging(fmu.instances[end])
end

"""
    fmi3EnterInitializationMode(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3EnterInitializationMode(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EnterInitializationMode(fmu::FMU3, args...; kwargs...)
            @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterInitializationMode(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3ExitInitializationMode(fmu::FMU3)

Wrapper for `fmi3ExitInitializationMode(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3ExitInitializationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3ExitInitializationMode(fmu.instances[end])
end

"""
    fmi3Terminate(fmu::FMU3)

Wrapper for `fmi3Terminate(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3Terminate(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Terminate(fmu.instances[end])
end

"""
    fmi3Reset(fmu::FMU3)

Wrapper for `fmi3Reset(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3Reset(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Reset(fmu.instances[end])
end

"""
    fmi3GetFloat32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetFloat32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetFloat32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat32!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetFloat32!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetFloat32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat32!(fmu.instances[end], args...; kwargs...)
end

"""
fmi3SetFloat32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetFloat32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetFloat32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFloat32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat64(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetFloat64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetFloat64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFloat64!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetFloat64!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetFloat64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFloat64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetFloat64(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetFloat64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetFloat64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFloat64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt8(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt8(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt8!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt8!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt8!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt8!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt8(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetInt8(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt8(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt8(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt8!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt8!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt8!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt8!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt8(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetUInt8(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetUInt8(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt8(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt16(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt16(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt16!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt16!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt16!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt16!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt16(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetInt16(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt16(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt16(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt16!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt16!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt16!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt16!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt16(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetUInt16(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetUInt16(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt16(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt32!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt32!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt32!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetInt32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt32!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetUInt32!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt32!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt32!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt32(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetUInt32(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetUInt32(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt32(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt64(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetInt64!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetInt64!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetInt64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetInt64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetInt64(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetInt64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt64(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetUInt64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetUInt64!(fmu::FMU3, args...; kwargs...)
        
Wrapper for `fmi3GetUInt64!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetUInt64!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetUInt64!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetUInt64(fmu::FMU3, args...; kwargs...)
        
Wrapper for `fmi3SetUInt64(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetUInt64(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetUInt64(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBoolean(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetBoolean(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetBoolean(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBoolean(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBoolean!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetBoolean!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetBoolean!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBoolean!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetBoolean(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetBoolean!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetBoolean(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetBoolean(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetString(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetString(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetString(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetString(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetString!(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetString!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetString!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetString!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetString(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3SetString(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetString(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetString(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBinary(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetBinary(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetBinary(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBinary(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetBinary!(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetBinary!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetBinary!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetBinary!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetBinary(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3SetBinary(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetBinary(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetBinary(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetClock(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetClock(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetClock(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetClock(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetClock!(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetClock!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetClock!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetClock!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetClock(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3SetClock(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetClock(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetClock(fmu.instances[end], args...; kwargs...)
end

"""
    fmiGet(fmu::FMU3, args...; kwargs...)

Wrapper for `fmiGet(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmiGet(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Get(fmu.instances[end], args...; kwargs...)
end

"""
    fmiGet!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmiGet!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmiGet!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Get!(fmu.instances[end], args...; kwargs...)
end

"""
    fmiSet(fmu::FMU3, args...; kwargs...)

Wrapper for `fmiSet(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmiSet(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3Set(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetFMUstate(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetFMUstate(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetFMUstate(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetFMUstate(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3FreeFMUState!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3FreeFMUState!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3FreeFMUState!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3FreeFMUState!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SerializedFMUStateSize(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SerializedFMUStateSize(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SerializedFMUStateSize(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SerializedFMUStateSize(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SerializeFMUState(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SerializeFMUState(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SerializeFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SerializeFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3DeSerializeFMUState(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3DeSerializeFMUState(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3DeSerializeFMUState(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3DeSerializeFMUState(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetDirectionalDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetDirectionalDerivative(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetDirectionalDerivative(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetDirectionalDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetDirectionalDerivative!(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetDirectionalDerivative!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetDirectionalDerivative!(fmu::FMU3, args...; kwargs...) 
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetDirectionalDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetAdjointDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetAdjointDerivative(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetAdjointDerivative(fmu::FMU3, args...; kwargs...)

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetAdjointDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetAdjointDerivative!(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetAdjointDerivative!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetAdjointDerivative!(fmu::FMU3, args...; kwargs...) 

    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetAdjointDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SampleDirectionalDerivative!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SampleDirectionalDerivative!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SampleDirectionalDerivative!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SampleDirectionalDerivative!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SampleDirectionalDerivative(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SampleDirectionalDerivative(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SampleDirectionalDerivative(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SampleDirectionalDerivative(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetJacobian!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetJacobian!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetJacobian!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetJacobian!(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetJacobian(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetJacobian(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetJacobian(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetJacobian(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetOutputDerivatives(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetOutputDerivatives(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetOutputDerivatives(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetOutputDerivatives(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3EnterConfigurationMode(fmu::FMU3)
    
Wrapper for `fmi3EnterConfigurationMode(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EnterConfigurationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterConfigurationMode(fmu.instances[end])
end

"""
    fmi3GetNumberOfContinuousStates(fmu::FMU3)
    
Wrapper for `fmi3GetNumberOfContinuousStates(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetNumberOfContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNumberOfContinuousStates(fmu.instances[end])
end

"""
    fmi3GetNumberOfVariableDependencies(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetNumberOfVariableDependencies(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetNumberOfVariableDependencies(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNumberOfVariableDependencies(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetVariableDependencies(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3GetVariableDependencies(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetVariableDependencies(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetVariableDependencies(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3GetContinuousStates(fmu::FMU3)

Wrapper for `fmi3GetContinuousStates(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetContinuousStates(fmu.instances[end])
end

"""
    fmi3GetNominalsOfContinuousStates(fmu::FMU3)

Wrapper for `fmi3GetNominalsOfContinuousStates(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetNominalsOfContinuousStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetNominalsOfContinuousStates(fmu.instances[end])
end

"""
fmi3EvaluateDiscreteStates(fmu::FMU3)

Wrapper for `fmi3EvaluateDiscreteStates(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EvaluateDiscreteStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EvaluateDiscreteStates(fmu.instances[end])
end

"""
    fmi3UpdateDiscreteStates(fmu::FMU3)

Wrapper for `fmi3UpdateDiscreteStates(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3UpdateDiscreteStates(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3UpdateDiscreteStates(fmu.instances[end])
end

"""
    fmi3EnterContinuousTimeMode(fmu::FMU3)

Wrapper for `fmi3EnterContinuousTimeMode(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EnterContinuousTimeMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterContinuousTimeMode(fmu.instances[end])
end

"""
    fmi3EnterStepMode(fmu::FMU3)

Wrapper for `fmi3EnterStepMode(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EnterStepMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterStepMode(fmu.instances[end])
end

"""
    fmi3ExitConfigurationMode(fmu::FMU3)

Wrapper for `fmi3ExitConfigurationMode(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3ExitConfigurationMode(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3ExitConfigurationMode(fmu.instances[end])
end

"""
    fmi3SetTime(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetTime(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetTime(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetTime(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3SetContinuousStates(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3SetContinuousStates(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3SetContinuousStates(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3SetContinuousStates(fmu.instances[end], args...; kwargs...)
end

"""
fmi3GetContinuousStateDerivatives(fmu::FMU3)

Wrapper for `fmi3GetContinuousStateDerivatives(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function  fmi3GetContinuousStateDerivatives(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetContinuousStateDerivatives(fmu.instances[end])
end

"""
    fmi3GetEventIndicators(fmu::FMU3)

Wrapper for `fmi3GetEventIndicators(c::FMU3Instance)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetEventIndicators(fmu::FMU3)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetEventIndicators(fmu.instances[end])
end

"""
fmi3CompletedIntegratorStep(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3CompletedIntegratorStep(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3CompletedIntegratorStep(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3CompletedIntegratorStep(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3EnterEventMode(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3EnterEventMode(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3EnterEventMode(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3EnterEventMode(fmu.instances[end], args...; kwargs...)
end

"""
    fmi3DoStep!(fmu::FMU3, args...; kwargs...)

Wrapper for `fmi3DoStep!(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3DoStep!(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3DoStep!(fmu.instances[end], args...; kwargs...)
end


"""
    fmi3GetStartValue(fmu::FMU3, args...; kwargs...)
    
Wrapper for `fmi3GetStartValue(c::FMU3Instance, args...; kwargs...)` without a provided FMU3Instance.
(Instance `c` gets selected from `fmu`)
"""
function fmi3GetStartValue(fmu::FMU3, args...; kwargs...)
    @assert length(fmu.instances) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi3GetStartValue(fmu.instances[end], args...; kwargs...)
end