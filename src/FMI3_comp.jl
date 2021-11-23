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