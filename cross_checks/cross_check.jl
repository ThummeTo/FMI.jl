using FMI
using FMIZoo
using FMICore
using Plots
using ArgParse
using Git

const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"

errorList = []

@enum crossCheckState begin
    FMUsucceeded = 0
    FMUfailed = 1
    FMUnotCompliant = 2
    FMUskipped = 3
end

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
        "--includeNonCompliant"
            help = "Setting this flag will also try to run non compliant FMU cross checks"
            action = :store_true
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

function runCrossCheck(path, name )
    tStart = 0.0
    tStop = 8.0
    if isfile(joinpath(path, "notCompliantWithLatestRules"))
        @warn "$path not excecuted because it is not compliant with latest rules"
        return FMUnotCompliant, ""
    end
    
    pathToFMU = joinpath(path, "$(name).fmu")
    
    try
        myFMU = fmiLoad(pathToFMU)
        fmiInfo(myFMU)
        fmiUnload(myFMU)
        return FMUsucceeded, ""
    catch e
        @warn e
        return FMUfailed, "$e"
    end
    
end
    # vrs = ["mass.s"]
    
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

function main()
    # parsing of cli arguments and setting of configuration
    parsed_args = parse_commandline()
    println("#################### Start FMI Cross checks Run ####################")
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
    crossChecksNotCompliant = 0
    crossChecksSkipped = 0
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
                    checkPath = joinpath(meCheckPath, system, version, check)
                    cd(checkPath)
                    println("Checking $check")
                    errorDescription = ""
                    (status, errorDescription) = runCrossCheck(checkPath, check)
                    crossChecksExcecuted = crossChecksExcecuted + 1
                    if status == FMUfailed
                        push!(errorList, "$type - $os - $system - $version - $(check).fmu: $errorDescription")
                        crossChecksFailed += 1
                    end
                    if status == FMUnotCompliant
                        crossChecksNotCompliant += 1
                    end
                    if status == FMUskipped
                        crossChecksSkipped += 1
                    end
                end
            end
        end
    end
    println("#################### End FMI Cross checks Run ####################")
    println("#################### Start FMI Cross check Summary ####################")
    println("\tTotal Cross checks:\t\t\t$(crossChecksExcecuted)")
    println("\tFailed Cross checks:\t\t\t$(crossChecksFailed)")
    println("\tNot compliant Cross checks:\t\t\t$(crossChecksNotCompliant)")
    println("\tSkipped Cross checks:\t\t\t$(crossChecksSkipped)")
    println("List of failed Cross checks")
    for (index, error) in enumerate(errorList)
        println("\t$(index):\t$(error)")
    end
    println("#################### End FMI Cross check Summary ####################")
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

