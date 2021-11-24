#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# Comfort functions for fmi2 functions using fmi2Components

"""
TODO: FMI specification reference.

Set the DebugLogger for the FMU.
"""
function fmi3SetDebugLogging(c::fmi3Component)
    fmi3SetDebugLogging(c, fmi2False, Unsigned(0), C_NULL)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetFloat32(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Float32, nvr)
    fmi3GetFloat32!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetFloat32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Float32})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetFloat32!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetFloat32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Float32)
    @assert false "fmi3GetFloat32! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetFloat32(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetFloat32(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetFloat64(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Float64, nvr)
    fmi3GetFloat64!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetFloat64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Float64})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetFloat64!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetFloat64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Float64)
    @assert false "fmi3GetFloat64! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetFloat64(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetFloat64(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt8(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Int8, nvr)
    fmi3GetInt8!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt8!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Int8})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetInt8!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetInt8!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Int8)
    @assert false "fmi3GetInt8! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetInt8(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetInt8(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt8(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3UInt8, nvr)
    fmi3GetUInt8!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt8!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3UInt8})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetUInt8!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetUInt8!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3UInt8)
    @assert false "fmi3GetInt8! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetUInt8(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetUInt8(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt16(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Int16, nvr)
    fmi3GetInt16!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end
"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt16!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Int16})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetInt16!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetInt16!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Int16)
    @assert false "fmi3GetInt16! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetInt16(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetInt16(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt16(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3UInt16, nvr)
    fmi3GetUInt16!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt16!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3UInt16})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetUInt16!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetUInt16!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3UInt16)
    @assert false "fmi3GetInt16! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetUInt16(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetUInt16(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt32(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Int32, nvr)
    fmi3GetInt32!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Int32})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetInt32!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetInt32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Int32)
    @assert false "fmi3GetInt32! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetInt32(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetInt32(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt32(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3UInt32, nvr)
    fmi3GetUInt32!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3UInt32})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetUInt32!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetUInt32!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3UInt32)
    @assert false "fmi3GetInt32! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetUInt32(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetUInt32(c, vr, nvr, values, nvr)
end
"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt64(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3Int64, nvr)
    fmi3GetInt64!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end
"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetInt64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Int64})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetInt64!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetInt64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Int64)
    @assert false "fmi3GetInt64! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetInt64(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetInt64(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt64(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = zeros(fmi3UInt64, nvr)
    fmi3GetUInt64!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Real variables.

For more information call ?fmi2GetReal!
"""
function fmi3GetUInt64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3UInt64})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2GetReal!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetUInt64!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetUInt64!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3UInt64)
    @assert false "fmi3GetInt64! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Real variables.

For more information call ?fmi2SetReal
"""
function fmi3SetUInt64(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi2SetReal(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetUInt64(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Boolean variables.

For more information call ?fmi2GetBoolean!
"""
function fmi3GetBoolean(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = Array{fmi3Boolean}(undef, nvr)
    fmi3GetBoolean!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2Boolean variables.

For more information call ?fmi2GetBoolean!
"""
function fmi3GetBoolean!(c::fmi2Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Boolean})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3GetBoolean!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(values))
    fmi3GetBoolean!(c, vr, nvr, values, nvr)

    nothing
end
function fmi3GetBoolean!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Bool)
    @assert false "fmi2GetBoolean! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2Boolean variables.

For more information call ?fmi2SetBoolean
"""
function fmi3SetBoolean(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3SetBoolean(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetBoolean(c, vr, nvr, Array{fmi3Boolean}(values), nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetString(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    vars = Vector{Ptr{Cchar}}(undef, nvr)
    values = string.(zeros(nvr))
    fmi3GetString!(c, vr, nvr, vars, nvr)
    values[:] = unsafe_string.(vars)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetString!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3String})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3GetString!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    # values = Vector{Ptr{Cchar}}.(values)
    vars = Vector{Ptr{Cchar}}(undef, nvr)
    fmi3GetString!(c, vr, nvr, vars, nvr)
    values[:] = unsafe_string.(vars)
    nothing
end
function fmi3GetString!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::String)
    @assert false "fmi3GetString! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2String variables.

For more information call ?fmi2SetString
"""
function fmi3SetString(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3SetString(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    ptrs = pointer.(values)
    fmi3SetString(c, vr, nvr, ptrs, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetBinary(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = Array{fmi3Binary}(undef, nvr)
    fmi3GetBinary!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetBinary!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Binary})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3GetString!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3GetBinary!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetBinary!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Binary)
    @assert false "fmi3GetBinary! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2String variables.

For more information call ?fmi2SetString
"""
function fmi3SetBinary(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3SetBinary(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetBinary(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetClock(c::fmi3Component, vr::fmi3ValueReferenceFormat)

    vr = prepareValueReference(c, vr)

    nvr = Csize_t(length(vr))
    values = Array{fmi3Clock}(undef, nvr)
    fmi3GetClock!(c, vr, nvr, values, nvr)

    if length(values) == 1
        return values[1]
    else
        return values
    end
end

"""
TODO: FMI specification reference.

Get the values of an array of fmi2String variables.

For more information call ?fmi2GetString!
"""
function fmi3GetClock!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Array{fmi3Clock})

    vr = prepareValueReference(c, vr)
    # values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3GetClock!(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3GetClock!(c, vr, nvr, values, nvr)
    nothing
end
function fmi3GetClock!(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::fmi3Clock)
    @assert false "fmi3GetClock! is only possible for arrays of values, please use an array instead of a scalar."
end

"""
TODO: FMI specification reference.

Set the values of an array of fmi2String variables.

For more information call ?fmi2SetString
"""
function fmi3SetClock(c::fmi3Component, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})

    vr = prepareValueReference(c, vr)
    values = prepareValue(values)
    @assert length(vr) == length(values) "fmi3SetBinary(...): `vr` and `values` need to be the same length."

    nvr = Csize_t(length(vr))
    fmi3SetClock(c, vr, nvr, values, nvr)
end

"""
TODO: FMI specification reference.

Get the pointer to the current FMU state.

For more information call ?fmi2GetFMUstate
"""
function fmi3GetFMUState(c::fmi3Component)
    state = fmi3FMUState()
    stateRef = Ref(state)
    fmi3GetFMUState(c, stateRef)
    state = stateRef[]
    state
end

"""
TODO: FMI specification reference.

Free the allocated memory for the FMU state.

For more information call ?fmi2FreeFMUstate
"""
function fmi3FreeFMUState(c::fmi3Component, state::fmi3FMUState)
    stateRef = Ref(state)
    fmi3FreeFMUState(c, stateRef)
    state = stateRef[]
end

"""
TODO: FMI specification reference.

Returns the size of a byte vector the FMU can be stored in.

For more information call ?fmi2SerzializedFMUstateSize
"""
function fmi3SerializedFMUStateSize(c::fmi3Component, state::fmi3FMUState)
    size = 0
    sizeRef = Ref(Csize_t(size))
    fmi3SerializedFMUStateSize(c, state, sizeRef)
    size = sizeRef[]
end

"""
TODO: FMI specification reference.

Serialize the data in the FMU state pointer.

For more information call ?fmi2SerzializeFMUstate
"""
function fmi3SerializeFMUstate(c::fmi3Component, state::fmi3FMUState)
    size = fmi3SerializedFMUStateSize(c, state)
    serializedState = Array{fmi3Byte}(undef, size)
    fmi3SerializeFMUState(c, state, serializedState, size)
    serializedState
end

"""
TODO: FMI specification reference.

Deserialize the data in the serializedState fmi2Byte field.

For more information call ?fmi2DeSerzializeFMUstate
"""
function fmi3DeSerializeFMUState(c::fmi3Component, serializedState::Array{fmi3Byte})
    size = length(serializedState)
    state = fmi3FMUState()
    stateRef = Ref(state)
    fmi23DeSerializeFMUState(c, serializedState, Csize_t(size), stateRef)
    state = stateRef[]
end

"""
TODO: FMI specification reference.

Computes directional derivatives.

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi3GetDirectionalDerivative(c::fmi3Component,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))
    sensitivity = zeros(fmi3Float64, length(unknowns))

    fmi3GetDirectionalDerivative!(c, unknowns, knowns, seed, sensitivity)

    sensitivity
end

"""
TODO: FMI specification reference.

Computes directional derivatives.

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi3GetDirectionalDerivative!(c::fmi3Component,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64}, 
                                      sensitivity::Array{fmi3Float64} = Array{fmi3Float64}([]))

    nKnowns = Csize_t(length(knowns))
    nUnknowns = Csize_t(length(unknowns))

    if length(seed) == 0
        seed = ones(fmi3Float64, nKnowns)
    end

    nSeed = Csize_t(length(seed))
    nSensitivity = Csize_t(length(sensitivity))

    fmi3GetDirectionalDerivative!(c, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)

    nothing
end

"""
TODO: FMI specification reference.

Computes directional derivatives.

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi3GetDirectionalDerivative(c::fmi3Component,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)

    fmi3GetDirectionalDerivative(c, [unknowns], [knowns], [seed])[1]
end

"""
TODO: FMI specification reference.

Return the new (continuous) state vector x.

For more information call ?fmi2GetContinuousStates
"""
function fmi3GetContinuousStates(c::fmi3Component)
    nx = Csize_t(fmi3GetNumberOfContinuousStates(c))
    x = zeros(fmi3Float64, nx)
    fmi3GetContinuousStates(c, x, nx)
    x
end

"""
TODO: FMI specification reference.

Set independent variable time and reinitialize chaching of variables that depend on time.

For more information call ?fmi2SetTime
"""
function fmi3SetTime(c::fmi3Component, time::Real)
    fmi3SetTime(c, fmi3Float64(time))
end

"""
TODO: FMI specification reference.

Set a new (continuous) state vector and reinitialize chaching of variables that depend on states.

For more information call ?fmi2SetContinuousStates
"""
function fmi3SetContinuousStates(c::fmi3Component, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    fmi3SetContinuousStates(c, Array{fmi3Real}(x), nx)
end

"""
TODO: FMI specification reference.

Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi2GetDerivatives
"""
function  fmi3GetContinuousStateDerivatives(c::fmi3Component)
    nx = Csize_t(fmi3GetNumberOfContinuousStates(fmu))
    derivatives = zeros(fmi3Float64, nx)
    fmi3GetContinuousStateDerivatives(c, derivatives, nx)
    derivatives
end

"""
TODO: FMI specification reference.

Returns the event indicators of the FMU.

For more information call ?fmi2GetEventIndicators
"""
function fmi3GetEventIndicators(c::fmi3Component)
    ni = Csize_t(fmi3GetNumberOfEventIndicators(fmu))
    eventIndicators = zeros(fmi3Float64, ni)
    fmi3GetEventIndicators(c, eventIndicators, ni)
    eventIndicators
end

"""
TODO: FMI specification reference.

This function must be called by the environment after every completed step
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated

For more information call ?fmi2CompletedIntegratorStep
"""
function fmi3CompletedIntegratorStep(c::fmi3Component,
                                     noSetFMUStatePriorToCurrentPoint::fmi3Boolean)
    enterEventMode = fmi3Boolean(false)
    terminateSimulation = fmi3Boolean(false)
    status = fmi3CompletedIntegratorStep!(c,
                                         noSetFMUStatePriorToCurrentPoint,
                                         enterEventMode,
                                         terminateSimulation)
    (status, enterEventMode, terminateSimulation)
end