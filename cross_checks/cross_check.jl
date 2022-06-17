using FMI
using FMIZoo
using FMICore
using Plots
using ArgParse
using Git
using CSV
using DelimitedFiles
using Tables

const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"

errorList = []
successList = []

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

function getCrossChecks(unpackPath::String, crossCheckRepo::String)
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

function runCrossCheck(path::String, type::String, name::String)
    if isfile(joinpath(path, "notCompliantWithLatestRules"))
        @warn "$path not excecuted because it is not compliant with latest rules"
        return FMUnotCompliant, ""
    end
    
    pathToFMU = joinpath(path, "$(name).fmu")
    
    try
        myFMU = fmiLoad(pathToFMU)
        fmiInfo(myFMU)
        if isfile(joinpath(path, "$(name)_in.csv"))
            @warn "$path not excecuted because inputs are not supported yet"
            return FMUskipped, ""
        end
        
        # Read Options
        fmuOptions = CSV.File(joinpath(path, "$(name)_ref.opt"), header=false) |> Dict
        display(fmuOptions)
        tStart = fmuOptions["StartTime"]
        tStop = fmuOptions["StopTime"]
        relTol = fmuOptions["RelTol"]

        # Read Ref values
        fmuVarNames = readdlm(joinpath(path, "$(name)_ref.csv"), ',', String)[1, 2:end]

        fmuRefValues = CSV.File(joinpath(path, "$(name)_ref.csv")) |> Tables.rowtable |> Tables.columntable
        
        simData = fmiSimulate(myFMU, tStart, tStop; reltol=relTol, recordValues=fmuVarNames)
        for (simIndex, time) in enumerate(simData.values.t)
            errorcount = 0
            # println("$time: $(simData.values.saveval[index][2])")
            for (index, value) in enumerate(fmuRefValues[1]) # ToDo: Start later than last loop
                
                if value >= time
                    # $(value[fmuVarNames[1]])
                    for nameIndex = 1:length(fmuVarNames)
                        @debug "Simulation time: $time, Simulation value: $(simData.values.saveval[simIndex][nameIndex]) Reference time: $(value) Reference Value: $(fmuRefValues[nameIndex+1][index]) "
                        if abs(simData.values.saveval[simIndex][nameIndex] - fmuRefValues[nameIndex+1][index]) > 1 #ToDo: Find better check method
                            errorcount += 1
                        end
                        if errorcount >= 10
                            @error "Not Matching values of $path at Simulation time: $time, Simulation value: $(simData.values.saveval[simIndex][nameIndex]) Reference time: $(value) Reference Value: $(fmuRefValues[nameIndex+1][index])"
                            return FMUfailed, "Not Matching values of $path at Simulation time: $time, Simulation value: $(simData.values.saveval[simIndex][nameIndex]) Reference time: $(value) Reference Value: $(fmuRefValues[nameIndex+1][index])"
                        end
                    end
                    break;
                end
            end
        end

        fmiUnload(myFMU)
        return FMUsucceeded, ""
    catch e
        @warn e
        return FMUfailed, "$e"
    end
    
end

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
    crossChecksSucceeded = 0
    fmiTypes = ["me", "cs"]
    for (index, type) in enumerate(fmiTypes)
        meCheckPath = joinpath(fmiCrossCheckRepoPath, "fmus", fmiVersion, type, os)
        meResultsPath = joinpath(fmiCrossCheckRepoPath, "results", fmiVersion, type, os, TOOL_ID, TOOL_VERSION)
        cd(meCheckPath)
        meCheckSystems = readdir()
        @info "Found following systems to cross check: $meCheckSystems"
        if type != "cs"
            continue
        end

        for (index, system) in enumerate(meCheckSystems)
            cd(joinpath(meCheckPath, system))
            meCheckVersions = readdir()
            @info "Found following versions for $system to cross check: $meCheckVersions"
            if system != "CATIA"
                #continue
            end

            for (index, version) in enumerate(meCheckVersions)
                cd(joinpath(meCheckPath, system, version))
                meChecks = readdir()
                @info "Found following checks for $system - $version to cross check: $meChecks"
                if version != "R2016x"
                    #continue
                end

                for (index, check) in enumerate(meChecks)
                    checkPath = joinpath(meCheckPath, system, version, check)
                    cd(checkPath)
                    if check != "ControlledTemperature"
                        #continue
                    end
                    println("Checking $check")
                    (status, errorDescription) = runCrossCheck(checkPath, type, check)
                    crossChecksExcecuted = crossChecksExcecuted + 1
                    if status == FMUsucceeded #TODO revert
                        push!(successList, "$type - $os - $system - $version - $(check).fmu")
                        crossChecksSucceeded += 1
                    end
                    if status == FMUfailed #TODO revert
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
    println("\tSuccessfull Cross checks:\t\t\t$(crossChecksSucceeded)")
    println("\tFailed Cross checks:\t\t\t$(crossChecksFailed)")
    println("\tNot compliant Cross checks:\t\t\t$(crossChecksNotCompliant)")
    println("\tSkipped Cross checks:\t\t\t$(crossChecksSkipped)")
    println("\tList of successfull Cross checks")
    for (index, success) in enumerate(successList)
        println("\u001B[32m\t\t$(index):\t$(success)")
    end
    println("\u001B[0m\tList of failed Cross checks")
    for (index, error) in enumerate(errorList)
        println("\u001B[31m\t\t$(index):\t$(error)")
    end
    println("\u001B[0m#################### End FMI Cross check Summary ####################")
end

main()