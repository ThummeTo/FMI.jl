using FMI
using FMIZoo
using FMICore
using Plots
using ArgParse
using Git
using CSV
using DelimitedFiles
using Tables
using Statistics

include("cross_check_types.jl")
include("cross_check_lib.jl")

#config
const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"
const NRMSE_THRESHHOLD = 5

# Main Array that holds all information about the excecuted cross checks and results
crossChecks = []

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--os"
            help = "The operating system for which the cross checks should be excecuted"
            arg_type = String
            default = WIN64
        "--ccrepo"
            help = "The Url to the git repository that contains the cross checks. Not setting this will prevent saving the results"
            arg_type = String
            default = "https://github.com/modelica/fmi-cross-check"
        "--tempdir"
            help = "temporary directive that is used for cross checks and results"
            arg_type = String
        "--fmiversion"
            help = "FMI version that should be used for the cross checks"
            arg_type = String
            default = "2.0"
    end
    println("Arguments used for cross check:")
    for (arg,val) in parse_args(s)
        println("\t$(arg):\t\t\t$(val)")
    end
    return parse_args(s)
end

function runCrossCheckFmu(checkPath::String, check::FmuCrossCheck)::FmuCrossCheck
    pathToFMU = joinpath(checkPath, "$(check.fmuCheck).fmu")
    
    try
        fmuToCheck = fmiLoad(pathToFMU)
        fmiInfo(fmuToCheck)

        ########TODO Implement input data##########
        if isfile(joinpath(checkPath, "$(check.fmuCheck)_in.csv"))
            @warn "$pathToFMU not excecuted because inputs are not supported yet"
            check.result = nothing
            check.skipped = true
            check.success = false
            check.error = nothing
            return check
        end
        
        # Read Options
        fmuOptions = CSV.File(joinpath(checkPath, "$(check.fmuCheck)_ref.opt"), header=false) |> Dict
        tStart = fmuOptions["StartTime"]
        tStop = fmuOptions["StopTime"]
        relTol = fmuOptions["RelTol"]

        # Read Ref values
        fmuRecordValueNames = readdlm(joinpath(checkPath, "$(check.fmuCheck)_ref.csv"), ',', String)[1, 2:end]
        fmuRefValues = CSV.File(joinpath(checkPath, "$(check.fmuCheck)_ref.csv")) |> Tables.rowtable |> Tables.columntable
        
        if check.type == CS
            ######## TODO Fix CS excecution issues ##########
            # simData = fmiSimulate(fmuToCheck, tStart, tStop; recordValues=fmuVarNames)
        elseif check.type == ME
            simData = fmiSimulateME(fmuToCheck, tStart, tStop; reltol=relTol, saveat=fmuRefValues.time, recordValues=fmuRecordValueNames)
        else
            @error "Unkown FMU Type. Only 'cs' and 'me' are valid types"
        end
        
        check.result = calucateNRMSE(fmuRecordValueNames, simData, fmuRefValues)
        check.skipped = false
        if (check.result < NRMSE_THRESHHOLD)
            check.success = true
        else
            check.success = false
        end
        check.error = nothing
        fmiUnload(fmuToCheck)

    catch e
        check.result = nothing
        check.skipped = false
        io = IOBuffer();
        showerror(io, e)
        check.error = String(take!(io))
        check.success = false
    end

    return check
    
end

function main()
    println("#################### Start FMI Cross checks Run ####################")
    # parsing of cli arguments and setting of configuration
    parsed_args = parse_commandline()
    unpackPath = parsed_args["tempdir"]
    fmiVersion = parsed_args["fmiversion"]
    crossCheckRepo = parsed_args["ccrepo"]
    os = parsed_args["os"]

    # checking of inputs
    # TODO: Might work better as assert
    if fmiVersion != "2.0"
        @warn "cross checks only for fmi version 2.0 validated"
    end

    # Loading all available cross checks
    fmiCrossCheckRepoPath = getFmuCrossCheckRepo(crossCheckRepo, unpackPath)

    #   Excecute FMUs
    crossChecks = getFmusToTest(fmiCrossCheckRepoPath, fmiVersion, os)
    # crossChecks = filter(c -> (c.type != CS && c.system == "CATIA"), crossChecks)
    for (index, check) in enumerate(crossChecks)
        checkPath = joinpath(fmiCrossCheckRepoPath, "fmus", check.fmiVersion, check.type, check.os, check.system, check.systemVersion, check.fmuCheck)
        cd(checkPath)
        println("Checking $check")

        check = runCrossCheckFmu(checkPath, check)
        crossChecks[index] = check
    end
    println("#################### End FMI Cross checks Run ####################")
    
    # Write Summary of Cross Check run
    println("#################### Start FMI Cross check Summary ####################")
    println("\tTotal Cross checks:\t\t\t$(count(c -> (true), crossChecks))")
    println("\tSuccessfull Cross checks:\t\t\t$(count(c -> (c.success), crossChecks))")
    println("\tFailed Cross checks:\t\t\t$(count(c -> (!c.success && c.error === nothing), crossChecks))")
    println("\tCross checks with errors:\t\t\t$(count(c -> (c.error !== nothing), crossChecks))")
    println("\tSkipped Cross checks:\t\t\t$(count(c -> (c.skipped), crossChecks))")
    println("\tList of successfull Cross checks")
    for (index, success) in enumerate(filter(c -> (c.success), crossChecks))
        println("\u001B[32m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of failed Cross checks")
    for (index, success) in enumerate(filter(c -> (!c.success && c.error === nothing && !c.skipped), crossChecks))
        println("\u001B[31m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of Cross checks with errors")
    for (index, error) in enumerate(filter(c -> (c.error !== nothing), crossChecks))
        println("\u001B[31m\t\t$(index):\t$(error)\u001B[0m")
    end
    println("#################### End FMI Cross check Summary ####################")
end

main()