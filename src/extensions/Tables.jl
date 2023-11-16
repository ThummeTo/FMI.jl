#
# Copyright (c) 2023 Andreas Heuermann
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

# Declare that FMUSolution is a table
Tables.istable(::Type{<:FMUSolution}) = true

# TODO: Define [optional] schema

# Column interface
Tables.columnaccess(table) = true

function Tables.columns(solution::FMUSolution)
    return solution
end

"""
Retrieve a column by index.
"""
function Tables.getcolumn(solution::FMUSolution, i::Int)::Vector{Float64}
    if i == 1 # Time
        return solution.values.t
    end
    # Variables
    return [val[i-1] for val in solution.values.saveval]
end

"""
Retrieve a column by name.
"""
function Tables.getcolumn(solution::FMUSolution, nm::Symbol)
    if nm == :time # Time
        return solution.values.t
    end
    # Variables
    vr = first(fmi2StringToValueReference(solution.component.fmu, string(nm)))
    idx = findfirst(idx -> idx == vr, solution.valueReferences)
    return [val[idx] for val in solution.values.saveval]
end

"""
Return column names for a table as an indexable collection.
"""
function Tables.columnnames(solution::FMUSolution)
    names = Symbol[]
    push!(names, Symbol("time"))
    for i in 1:length(solution.values.saveval[1])
        var = fmi2ValueReferenceToString(solution.component.fmu, solution.valueReferences[i])
        append!(names, Symbol.(var))
    end
    return unique(names)
end
