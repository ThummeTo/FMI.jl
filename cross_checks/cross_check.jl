using FMI
using FMIZoo
using FMICore
using Plots
using ArgParse
using Git

const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--os"
            help = "The operating system for which the cross checks should be excecuted"
            arg_type = String
            default = "win64"
        "--ccrepo"
            help = "The Url to the git repository that contains the cross checks. Not setting this will prevent saving the results"
            arg_type = String
            default = "https://github.com/modelica/fmi-cross-check"
        "--tempdir"
            help = "temporary directive that is used for cross checks and results"
            arg_type = String
            default = "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem"
        "--fmiversion"
            help = "FMI version that should be used for the cross checks"
            arg_type = String
            default = "2.0"
    end

    return parse_args(s)
end

function getCrossChecks(unpackPath, crossCheckRepo)
    @info "Create temporary working directory"
    if unpackPath === nothing
        if Sys.iswindows()
            unpackPath = mktempdir(; prefix="fmicrosschecks_", cleanup=false) #ToDo: Change to true
        else
            # cleanup=true leads to issues with automatic testing on linux server.
            unpackPath = mktempdir(; prefix="fmicrosschecks_", cleanup=false)
        end
        @info "temporary working directory created at $(unpackPath)"
    end

    @info "Retrieving cross-checks"
    fmiCrossCheckRepoPath = joinpath(unpackPath, FMI_CROSS_CHECK_REPO_NAME)
    if !isdir(fmiCrossCheckRepoPath)
        println("Checking out cross-checks from $(crossCheckRepo)...")
        run(Cmd(`$(git()) clone $(crossCheckRepo)`, dir=unpackPath))
    else
        println("Using existing cross-checks at $(fmiCrossCheckRepoPath)")
    end
    return fmiCrossCheckRepoPath
end

function main()
    # parsing of cli arguments and setting of configuration
    parsed_args = parse_commandline()
    println("#################### Start FMI Cross checks ####################")
    println("Arguments used for cross check:")
    for (arg,val) in parsed_args
        println("\t$(arg):\t\t\t$(val)")
    end
    unpackPath = parsed_args["tempdir"]
    fmiVersion = parsed_args["fmiversion"]
    crossCheckRepo = parsed_args["ccrepo"]
    os = parsed_args["os"]
    
    if fmiVersion != "2.0"
        @warn "cross checks only for fmi version 2.0 validated"
    end

    fmiCrossCheckRepoPath = getCrossChecks(unpackPath, crossCheckRepo)

    @info "Running model exchange check"
    crossChecksExcecuted = 0
    crossChecksFailed = 0
    fmiTypes = ["me", "cs"]
    for (index, type) in enumerate(fmiTypes)
        meCheckPath = joinpath(fmiCrossCheckRepoPath, "fmus", fmiVersion, type, os)
        meResultsPath = joinpath(fmiCrossCheckRepoPath, "results", fmiVersion, type, os, TOOL_ID, TOOL_VERSION)
        cd(meCheckPath)
        meCheckSystems = readdir()
        @info "Found following systems to cross check: $meCheckSystems"

        for (index, system) in enumerate(meCheckSystems)
            cd(joinpath(meCheckPath, system))
            meCheckVersions = readdir()
            @info "Found following versions for $system to cross check: $meCheckVersions"

            for (index, version) in enumerate(meCheckVersions)
                cd(joinpath(meCheckPath, system, version))
                meChecks = readdir()
                @info "Found following checks for $system - $version to cross check: $meChecks"

                for (index, check) in enumerate(meChecks)
                    cd(joinpath(meCheckPath, system, version, check))
                    println("Checking $check")
                    crossChecksExcecuted = crossChecksExcecuted + 1
                end
            end
        end
    end
    println("$crossChecksFailed of $crossChecksExcecuted Failed")

end

main()

# tStart = 0.0
# tStop = 8.0

# # we use an FMU from the FMIZoo.jl
# #println("I want: ", (@__DIR__));
# #pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")
# pathToFMU = "$(@__DIR__)\\ControlledTemperature.fmu"
# myFMU = fmiLoad(pathToFMU)

# fmiInfo(myFMU,345)

# vrs = ["TRes", "heatCapacitor_T"]

# simData = fmiSimulateME(myFMU, tStart, tStop; recordValues=vrs)

# fig = fmiPlot(simData, states=false)

# # save, where the original `fmi2GetReal` function was stored, so we can access it in our new function
# originalGetReal = myFMU.cGetReal

# function myGetReal!(c::fmi2Component, vr::Union{Array{fmi2ValueReference}, Ptr{fmi2ValueReference}}, 
#                     nvr::Csize_t, value::Union{Array{fmi2Real}, Ptr{fmi2Real}})
#     # first, we do what the original function does
#     status = fmi2GetReal!(originalGetReal, c, vr, nvr, value)

#     # if we have a pointer to an array, we must interprete it as array to access elements
#     if isa(value, Ptr{fmi2Real})
#         value = unsafe_wrap(Array{fmi2Real}, value, nvr, own=false)
#     end

#     # now, we multiply every value by two (just for fun!)
#     for i in 1:nvr 
#         value[i] *= 2.0 
#     end 

#     # return the original status
#     return status
# end

# # no we overwrite the original function
# fmiSetFctGetReal(myFMU, myGetReal!)

# simData = fmiSimulateME(myFMU, tStart, tStop; recordValues=vrs)
# fmiPlot!(fig, simData; states=false, style=:dash)

