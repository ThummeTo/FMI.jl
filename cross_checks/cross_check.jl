#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Cristof Baumgartner
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using FMI.FMIImport.FMIBase.FMICore
using FMIZoo
using Plots
using ArgParse
using Git
using CSV
using DelimitedFiles
using Tables
using Statistics
using DifferentialEquations
using Plots, Colors

import Base64

include("cross_check_config.jl")
include("cross_check_lib.jl")

# Main Array that holds all information about the executed cross checks and results
crossChecks = []

getInputValues = function (t, u)
    return nothing
end

getSolver = function ()
    return Tsit5() # CVODE_BDF() # Rosenbrock23(autodiff=false)
end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--os"
        help = "The operating system for which the cross checks should be executed"
        arg_type = String
        default = "windows-latest"
        "--ccrepo"
        help = "The Url to the git repository that contains the cross checks."
        arg_type = String
        default = "https://github.com/modelica/fmi-cross-check"
        "--ccbranch"
        help = "The name of the branch in which the results will be pushed"
        arg_type = String
        default = "master"
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
        help = "Reject officially not compliant FMUs and don't execute them"
        action = :store_true
        "--commitrejected"
        help = "Also commit the result file for FMUs that hasn't been executed (e.g. officially not compliant FMUs if they are not skipped)"
        action = :store_true
        "--commitfailed"
        help = "Also commit the result file for failed FMUs"
        action = :store_true
        "--plotfailed"
        help = "Plot result for failed FMUs"
        action = :store_true

    end
    println("Arguments used for cross check:")
    for (arg, val) in parse_args(s)
        println("\t$(arg):\t\t\t$(val)")
    end
    return parse_args(s)
end

function runCrossCheckFMU(
    checkPath::String,
    resultPath::String,
    check::FmuCrossCheck,
    skipnotcompliant::Bool,
    commitrejected::Bool,
    commitfailed::Bool,
    plotfailed::Bool,
)::FmuCrossCheck
    pathToFMU = joinpath(checkPath, "$(check.fmuCheck).fmu")

    fmuToCheck = nothing
    try
        if !(check.notCompliant && skipnotcompliant)
            fmuToCheck = loadFMU(pathToFMU)
            info(fmuToCheck)
            hasInputValues = false

            # Read Options
            fmuOptions =
                CSV.File(
                    joinpath(checkPath, "$(check.fmuCheck)_ref.opt"),
                    header = false,
                ) |> Dict
            tStart = fmuOptions["StartTime"]
            tStop = fmuOptions["StopTime"]
            relTol = fmuOptions["RelTol"]

            # Read Ref values
            fmuRecordValueNames = map(
                (x) -> replace(strip(x), "\"" => ""),
                (readdlm(joinpath(checkPath, "$(check.fmuCheck)_ref.csv"), ',', String)[
                    1,
                    2:end,
                ]),
            )
            fmuRefValues =
                CSV.File(joinpath(checkPath, "$(check.fmuCheck)_ref.csv")) |>
                Tables.rowtable |>
                Tables.columntable

            if isfile(joinpath(checkPath, "$(check.fmuCheck)_in.csv"))
                inputValues =
                    CSV.File(joinpath(checkPath, "$(check.fmuCheck)_in.csv")) |>
                    Tables.rowtable
                hasInputValues = true
                getInputValues = function (t, u)
                    for (valIndex, val) in enumerate(inputValues)
                        if val.time >= t
                            u[:] = collect(inputValues[valIndex])[2:end]
                            # a = collect(inputValues[valIndex])[2:end] 
                            # return a
                            break
                        end
                    end
                end
            end

            if hasInputValues
                if check.type == CS
                    simData = simulateCS(
                        fmuToCheck,
                        (tStart, tStop);
                        tolerance = relTol,
                        saveat = fmuRefValues[1],
                        inputFunction = getInputValues,
                        inputValueReferences = :inputs,
                        recordValues = fmuRecordValueNames,
                    )
                elseif check.type == ME
                    simData = simulateME(
                        fmuToCheck,
                        (tStart, tStop);
                        solver = getSolver(),
                        reltol = relTol,
                        saveat = fmuRefValues[1],
                        inputFunction = getInputValues,
                        inputValueReferences = :inputs,
                        recordValues = fmuRecordValueNames,
                    )
                else
                    @error "Unkown FMU Type. Only 'cs' and 'me' are valid types"
                end
            else
                if check.type == CS
                    simData = simulateCS(
                        fmuToCheck,
                        (tStart, tStop);
                        tolerance = relTol,
                        saveat = fmuRefValues[1],
                        recordValues = fmuRecordValueNames,
                    )
                elseif check.type == ME
                    simData = simulateME(
                        fmuToCheck,
                        (tStart, tStop);
                        solver = getSolver(),
                        reltol = relTol,
                        saveat = fmuRefValues[1],
                        recordValues = fmuRecordValueNames,
                    )
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
                rm("failed", force = true)
                rm("rejected", force = true)
                rm("README.md", force = true)
                touch("passed")
                touch("README.md")
                file = open("README.md", "w")
                write(file, CROSS_CHECK_README_CONTENT)
                close(file)
            else
                check.success = false
                if commitfailed
                    mkpath(resultPath)
                    cd(resultPath)

                    rm("passed", force = true)
                    rm("rejected", force = true)
                    rm("README.md", force = true)
                    touch("failed")
                end
                if plotfailed
                    mkpath(resultPath)
                    cd(resultPath)

                    names = keys(fmuRefValues)
                    num = length(names) - 1
                    colors = distinguishable_colors(num)

                    fig = plot()
                    for j = 1:num
                        ts = fmuRefValues[1]
                        vals = fmuRefValues[1+j]
                        plot!(
                            fig,
                            ts,
                            vals;
                            style = :solid,
                            color = colors[j],
                            label = "$(names[j+1])",
                        )

                        ts = simData.values.t
                        vals = collect(u[j] for u in simData.values.saveval)
                        plot!(
                            fig,
                            ts,
                            vals;
                            style = :dash,
                            color = colors[j],
                            label = :none,
                        )
                    end
                    display(fig)
                end

            end
        else
            check.skipped = true
            if commitrejected
                mkpath(resultPath)
                cd(resultPath)
                rm("failed", force = true)
                rm("passed", force = true)
                rm("README.md", force = true)
                touch("rejected")
            end
        end
        check.error = nothing
    catch e
        @warn e
        check.result = nothing
        check.skipped = false
        io = IOBuffer()
        showerror(io, e)
        check.error = String(take!(io))
        check.success = false
        mkpath(resultPath)
        cd(resultPath)
        rm("rejected", force = true)
        rm("passed", force = true)
        rm("README.md", force = true)
        if commitfailed
            touch("failed")
        end
    finally
        try
            unloadFMU(fmuToCheck)
        catch
        end
    end
    return check

end

function main()
    println("#################### Start FMI Cross checks Run ####################")
    # parsing of cli arguments and setting of configuration
    parsed_args = parse_commandline()
    unpackPath =
        haskey(ENV, "crosscheck_tempdir") ? ENV["crosscheck_tempdir"] :
        parsed_args["tempdir"]
    fmiVersion = parsed_args["fmiversion"]
    crossCheckRepo = parsed_args["ccrepo"]
    crossCheckBranch = parsed_args["ccbranch"]
    os_version = parsed_args["os"]
    os = "win64"
    if os_version == "ubuntu-latest"
        os = "linux64"
    end
    includeFatals = parsed_args["includefatals"]
    skipnotcompliant =
        haskey(ENV, "crosscheck_skipnotcompliant") ? true : parsed_args["skipnotcompliant"]
    commitrejected = parsed_args["commitrejected"]
    commitfailed = parsed_args["commitfailed"]
    plotfailed = haskey(ENV, "crosscheck_plotfailed") ? true : parsed_args["plotfailed"]

    # checking of inputs
    if fmiVersion != "2.0"
        @warn "cross checks only for fmi version 2.0 validated"
    end

    # Loading all available cross checks
    fmiCrossCheckRepoPath = getFMICrossCheckRepo(crossCheckRepo, unpackPath)

    # set up the github access for the fmi-cross-checks repo and checkout the respective branch
    github_token = get(ENV, "GITHUB_TOKEN", "")
    tmp_dir = mktempdir(; cleanup = true)
    pkey_filename = create_ssh_private_key(tmp_dir, github_token, os)
    if os == "win64"
        pkey_filename = replace(pkey_filename, "\\" => "/")
    end

    cross_check_repo_name = get(ENV, "CROSS_CHECK_REPO_NAME", "")
    cross_check_repo_user = get(ENV, "CROSS_CHECK_REPO_USER", "")
    if github_token != "" && cross_check_repo_name != "" && cross_check_repo_user != ""
        withenv(
            "GIT_SSH_COMMAND" =>
                isnothing(github_token) ? "ssh" :
                "ssh -i $pkey_filename -o StrictHostKeyChecking=no",
        ) do
            run(
                Cmd(
                    `$(git()) remote set-url origin git@github.com:$cross_check_repo_user/$cross_check_repo_name`,
                    dir = fmiCrossCheckRepoPath,
                ),
            )
        end

        try
            run(Cmd(`$(git()) checkout $(crossCheckBranch)`, dir = fmiCrossCheckRepoPath))
        catch
            run(
                Cmd(
                    `$(git()) checkout -b $(crossCheckBranch)`,
                    dir = fmiCrossCheckRepoPath,
                ),
            )
        end
    end

    #   Excecute FMUs
    crossChecks = getFMUsToTest(fmiCrossCheckRepoPath, fmiVersion, os)
    if !includeFatals
        crossChecks = filter(c -> (!(c.system in EXCLUDED_SYSTEMS)), crossChecks)
    end

    for (index, check) in enumerate(crossChecks)
        checkPath = joinpath(
            fmiCrossCheckRepoPath,
            "fmus",
            check.fmiVersion,
            check.type,
            check.os,
            check.system,
            check.systemVersion,
            check.fmuCheck,
        )
        resultPath = joinpath(
            fmiCrossCheckRepoPath,
            "results",
            check.fmiVersion,
            check.type,
            check.os,
            TOOL_ID,
            TOOL_VERSION,
            check.system,
            check.systemVersion,
            check.fmuCheck,
        )
        cd(checkPath)
        println("Checking $check for $checkPath and expecting $resultPath")

        check = runCrossCheckFMU(
            checkPath,
            resultPath,
            check,
            skipnotcompliant,
            commitrejected,
            commitfailed,
            plotfailed,
        )
        crossChecks[index] = check
    end
    println("#################### End FMI Cross checks Run ####################")

    # Write Summary of Cross Check run
    println("#################### Start FMI Cross check Summary ####################")
    println("\tTotal Cross checks:\t\t\t$(count(c -> (true), crossChecks))")
    println(
        "\tSuccessful Cross checks:\t\t$(count(c -> (c.success === true), crossChecks))",
    )
    println(
        "\tFailed Cross checks:\t\t\t$(count(c -> (c.success === false && c.error === nothing && c.skipped === false), crossChecks))",
    )
    println(
        "\tCross checks with errors:\t\t$(count(c -> (c.error !== nothing), crossChecks))",
    )
    println("\tSkipped Cross checks:\t\t\t$(count(c -> (c.skipped === true), crossChecks))")
    println("\tList of successful Cross checks")
    for (index, success) in enumerate(filter(c -> (c.success === true), crossChecks))
        println("\u001B[32m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of failed Cross checks")
    for (index, success) in enumerate(
        filter(
            c -> (c.success === false && c.error === nothing && c.skipped === false),
            crossChecks,
        ),
    )
        println("\u001B[33m\t\t$(index):\t$(success)\u001B[0m")
    end
    println("\tList of Cross checks with errors")
    for (index, error) in enumerate(filter(c -> (c.error !== nothing), crossChecks))
        println("\u001B[31m\t\t$(index):\t$(error)\u001B[0m")
    end
    println("#################### End FMI Cross check Summary ####################")

    if github_token != "" && cross_check_repo_name != "" && cross_check_repo_user != ""
        run(Cmd(`$(git()) add -A`, dir = fmiCrossCheckRepoPath))
        run(
            Cmd(
                `$(git()) commit -a --allow-empty -m "Run FMI cross checks for FMI.JL"`,
                dir = fmiCrossCheckRepoPath,
            ),
        )

        withenv(
            "GIT_SSH_COMMAND" =>
                isnothing(github_token) ? "ssh" :
                "ssh -i $pkey_filename -o StrictHostKeyChecking=no",
        ) do
            try
                run(Cmd(`$(git()) push`, dir = fmiCrossCheckRepoPath))
            catch
                run(
                    Cmd(
                        `$(git()) push --set-upstream origin $(crossCheckBranch)`,
                        dir = fmiCrossCheckRepoPath,
                    ),
                )
            end
        end
        rm(tmp_dir; force = true, recursive = true)
    end
end

main()
