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
