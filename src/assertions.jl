#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@enum errorType begin
    unsupportedFMU
    unknownFMUType
    unknown
end

# Format the fmi2Status into a String
function errorTypeString(type::errorType)
    fname = StackTraces.stacktrace()[3].func    # index 3 to step into calling function!

    if type == unsupportedFMU
        return "$fname() doesn't support FMUs with this version."
    elseif type == unknownFMUType
        return "Unknown FMU type in $fname(), is neigther CS nor ME."
    end

    "Unknwon Assertion in $fname()."
end

function assert(cond::Bool, type::errorType = unknwon)
    @assert cond [errorTypeString(type)]
end

function error(type::errorType = unknwon)
    @assert false [errorTypeString(type)]
end
