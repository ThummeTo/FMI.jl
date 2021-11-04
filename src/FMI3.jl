#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl
using ZipFile

include("FMI3_c.jl")
include("FMI3_comp.jl")
include("FMI3_md.jl")

"""
IN PROGRESS:
The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3 <: FMU
    modelName::fmi3String
    instanceName::fmi3String
    fmuResourceLocation::fmi3String

    modelDescription::fmi3ModelDescription

    type::fmi3Type
    callbackFunctions::fmi3CallbackFunctions
    components::Array{fmi3Component}

    # paths of ziped and unziped FMU folders
    path::String
    zipPath::String
    # Constructor
    fmu3() = new()

    # c-libraries
    libHandle::Ptr{Nothing}

end
