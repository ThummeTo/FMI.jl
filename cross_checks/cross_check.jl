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

getInputValues = t -> t

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--os"
            help = "The operating system for which the cross checks should be excecuted"
            arg_type = String
            default = "windows-latest"
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
        "--includefatals"
            help = "Include FMUs that have caused the cross check runner to fail and exit"
            action = :store_true
        "--skipnotcompliant"
            help = "Reject officially not compliant FMUs and don't excecute them"
            action = :store_true
        "--commitrejected"
            help = "Also commit the result file for FMUs that hasn't been excecuted (e.g. officially not compliant FMUs if they are not skipped)"
            action = :store_true
        "--commitfailed"
            help = "Also commit the result file for failed FMUs"
            action = :store_true

    end
    println("Arguments used for cross check:")
    for (arg,val) in parse_args(s)
        println("\t$(arg):\t\t\t$(val)")
    end
    return parse_args(s)
end

function runCrossCheckFmu(checkPath::String, resultPath::String, check::FmuCrossCheck, skipnotcompliant::Bool, commitrejected::Bool, commitfailed::Bool)::FmuCrossCheck
    pathToFMU = joinpath(checkPath, "$(check.fmuCheck).fmu")

    fmuToCheck = nothing
    try 
        if !(check.notCompliant && skipnotcompliant)
            fmuToCheck = fmiLoad(pathToFMU)
            fmiInfo(fmuToCheck)
            hasInputValues = false

            # Read Options
            fmuOptions = CSV.File(joinpath(checkPath, "$(check.fmuCheck)_ref.opt"), header=false) |> Dict
            tStart = fmuOptions["StartTime"]
            tStop = fmuOptions["StopTime"]
            relTol = fmuOptions["RelTol"]

            # Read Ref values
            fmuRecordValueNames = map((x) -> replace(strip(x),"\"" => "" ), (readdlm(joinpath(checkPath, "$(check.fmuCheck)_ref.csv"), ',', String)[1, 2:end]))
            fmuRefValues = CSV.File(joinpath(checkPath, "$(check.fmuCheck)_ref.csv")) |> Tables.rowtable |> Tables.columntable

            if isfile(joinpath(checkPath, "$(check.fmuCheck)_in.csv"))
                inputValues = CSV.File(joinpath(checkPath, "$(check.fmuCheck)_in.csv")) |> Tables.rowtable
                hasInputValues = true
                getInputValues = function(t)
                    for (valIndex, val) in enumerate(inputValues)
                        if val.time >= t
                            a = collect(inputValues[valIndex])[2:end] 
                            return a
                            break;
                        end
                    end
                end
            end
            
            if hasInputValues
                if check.type == CS
                    # simData = fmiSimulateCS(fmuToCheck, (tStart, tStop); tolerance=relTol, saveat=fmuRefValues[1], inputFunction=getInputValues, inputValueReferences=:inputs, recordValues=fmuRecordValueNames)
                    simData = fmiSimulateCS(fmuToCheck, (tStart, tStop); tolerance=relTol, saveat=fmuRefValues[1], inputFunction=getInputValues, inputValueReferences=:inputs, recordValues=fmuRecordValueNames)
                elseif check.type == ME
                    simData = fmiSimulateME(fmuToCheck, (tStart, tStop); reltol=relTol, saveat=fmuRefValues[1], inputFunction=getInputValues, inputValueReferences=:inputs, recordValues=fmuRecordValueNames)
                else
                    @error "Unkown FMU Type. Only 'cs' and 'me' are valid types"
                end
            else
                if check.type == CS
                    simData = fmiSimulateCS(fmuToCheck, (tStart, tStop); tolerance=relTol, saveat=fmuRefValues[1], recordValues=fmuRecordValueNames)
                elseif check.type == ME
                    simData = fmiSimulateME(fmuToCheck, (tStart, tStop); reltol=relTol, saveat=fmuRefValues[1], recordValues=fmuRecordValueNames)
                else
                    @error "Unkown FMU Type. Only 'cs' and 'me' are valid types"
                end
            end
            
            check.result = calucateNRMSE(fmuRecordValueNames, simData, fmuRefValues)
            check.skipped = false
        
            if (check.result < NRMSE_THRESHHOLD)
                check.success = true
                mkpath(resultPath)
                cd(resultPath)
                touch("passed")
                touch("README.md")
                file = open("README.md", "w")
                write(file, "test content")
                close(file)
            else
                check.success = false
                if commitfailed
                    mkpath(resultPath)
                    cd(resultPath)
                    touch("failed")
                end
            end
        else
            check.skipped = true
            if commitrejected
                mkpath(resultPath)
                cd(resultPath)
                touch("rejected")
            end
        end
        check.error = nothing
    catch e
        @warn e
        check.result = nothing
        check.skipped = false
        io = IOBuffer();
        showerror(io, e)
        check.error = String(take!(io))
        check.success = false
        if commitfailed
            mkpath(resultPath)
            cd(resultPath)
            touch("failed")
        end
    finally
        try
            fmiUnload(fmuToCheck)
        catch
        end
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
    os_version = parsed_args["os"]
    os = "win64"
    if os_version == "ubuntu-latest"
        os = "linux64"
    end
    includeFatals = parsed_args["includefatals"]
    skipnotcompliant = parsed_args["skipnotcompliant"]
    commitrejected = parsed_args["commitrejected"]
    commitfailed = parsed_args["commitfailed"]

    # checking of inputs
    # TODO: Might work better as assert
    if fmiVersion != "2.0"
        @warn "cross checks only for fmi version 2.0 validated"
    end

    # Loading all available cross checks
    fmiCrossCheckRepoPath = getFmuCrossCheckRepo(crossCheckRepo, unpackPath)

    #   Excecute FMUs
    crossChecks = getFmusToTest(fmiCrossCheckRepoPath, fmiVersion, os)
    if !includeFatals
        crossChecks = filter(c -> (c.system != "AMESim" && c.system != "Test-FMUs" && c.system != "SimulationX" && c.system != "Silver"), crossChecks)
    end
    
    for (index, check) in enumerate(crossChecks)
        checkPath = joinpath(fmiCrossCheckRepoPath, "fmus", check.fmiVersion, check.type, check.os, check.system, check.systemVersion, check.fmuCheck)
        resultPath = joinpath(fmiCrossCheckRepoPath, "results", check.fmiVersion, check.type, check.os, TOOL_ID, TOOL_VERSION, check.system, check.systemVersion, check.fmuCheck)
        cd(checkPath)
        println("Checking $check for $checkPath and expecting $resultPath")

        check = runCrossCheckFmu(checkPath, resultPath, check, skipnotcompliant, commitrejected, commitfailed)
        crossChecks[index] = check
    end
    println("#################### End FMI Cross checks Run ####################")
    
    # Write Summary of Cross Check run
    println("#################### Start FMI Cross check Summary ####################")
    println("\tTotal Cross checks:\t\t\t$(count(c -> (true), crossChecks))")
    println("\tSuccessfull Cross checks:\t\t\t$(count(c -> (c.success), crossChecks))")
    println("\tFailed Cross checks:\t\t\t$(count(c -> (!c.success && c.error === nothing && !c.skipped), crossChecks))")
    println("\tCross checks with errors:\t\t\t$(count(c -> (c.error !== nothing), crossChecks))")
    println("\tSkipped Cross checks:\t\t\t$(count(c -> (c.skipped), crossChecks))")
    println("\tList of successfull Cross checks")
    for (index, success) in enumerate(filter(c -> (c.success), crossChecks))
        println("\u001B[32m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of failed Cross checks")
    for (index, success) in enumerate(filter(c -> (!c.success && c.error === nothing && !c.skipped), crossChecks))
        println("\u001B[33m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of Cross checks with errors")
    for (index, error) in enumerate(filter(c -> (c.error !== nothing), crossChecks))
        println("\u001B[31m\t\t$(index):\t$(error)\u001B[0m")
    end
    println("#################### End FMI Cross check Summary ####################")

    # run(Cmd(`$(git()) config --global user.name 'Your Name'`, dir=fmiCrossCheckRepoPath))
    # run(Cmd(`$(git()) config --global user.email 'your-username@users.noreply.github.com'"`, dir=fmiCrossCheckRepoPath))
    # run(Cmd(`$(git()) remote set-url origin https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}`, dir=fmiCrossCheckRepoPath))
    run(Cmd(`$(git()) commit -a -m "Run FMI cross checks for FMI.JL"`, dir=fmiCrossCheckRepoPath))
    run(Cmd(`$(git()) push`, dir=fmiCrossCheckRepoPath))
end

main()