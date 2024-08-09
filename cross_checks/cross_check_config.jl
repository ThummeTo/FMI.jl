#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Cristof Baumgartner
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

#config
const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"
const NRMSE_THRESHHOLD = 5
const EXCLUDED_SYSTEMS = ["AMESim", "Test-FMUs", "SimulationX", "Silver"]
const CROSS_CHECK_README_CONTENT = "See https://github.com/ThummeTo/FMI.jl for more information."

#static strings
const ME = "me"
const CS = "cs"
const WIN64 = "win64"

mutable struct FmuCrossCheck
    fmiVersion::String
    type::String
    os::String
    system::String
    systemVersion::String
    fmuCheck::String
    notCompliant::Bool
    result::Union{Float64,Missing,Nothing}
    success::Union{Bool,Missing}
    skipped::Union{Bool,Missing}
    error::Union{String,Missing,Nothing}
end
