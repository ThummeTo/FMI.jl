#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Cristof Baumgartner
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

""" 
Returns the path where the FMU cross checks are saved locally.
This will also checkout the repository from a specified URL if they are not yet present in the specified path.
Hint: This will not check the cross check repository for integrity
# Arguments
- `crossCheckRepo::String`: URL to the FMU Cross check repository that should be used. Note, if you want to push your results later, this should be a fork that you have access to
- `unpackPath::Union{String, Nothing}`:  optional path that is used to checkout the the fmu cross check repository. If no path is specified, a temporary path is created
# Returns
- `repoPath::String`: The path where the repository can be found locally (including the repository name)
"""
function getFMICrossCheckRepo(
    crossCheckRepo::String,
    unpackPath::Union{String,Nothing} = nothing,
)::String
    @info "Create temporary working directory"
    if unpackPath === nothing
        # cleanup=true leads to issues with automatic testing on linux server.
        unpackPath = mktempdir(; prefix = "fmicrosschecks_", cleanup = false)
        @info "temporary working directory created at $(unpackPath)"
    end

    @info "Retrieving cross-checks"
    fmiCrossCheckRepoPath = joinpath(unpackPath, FMI_CROSS_CHECK_REPO_NAME)
    if !isdir(fmiCrossCheckRepoPath)
        println("Checking out cross-checks from $(crossCheckRepo)...")
        run(Cmd(`$(git()) clone $(crossCheckRepo)`, dir = unpackPath))
    else
        println("Using existing cross-checks at $(fmiCrossCheckRepoPath)")
    end
    return fmiCrossCheckRepoPath
end

"""
Returns a array of all available FMI Cross Checks 
# Arguments
- `repoPath::String`:  path to the local FMI Cross Check repository
- `fmiVersion::String`: FMI Version used for running the FMUs. Note: Currently only 2.0 officially supported
- `os::String`: The operating system that is used for running the FMUs
"""
function getFMUsToTest(
    repoPath::String,
    fmiVersion::String,
    os::String,
)::Vector{FmuCrossCheck}
    results = []
    fmiTypes = [ME, CS]
    for type in fmiTypes
        fmiCheckPath = joinpath(repoPath, "fmus", fmiVersion, type, os)
        cd(fmiCheckPath)
        checkSystems = readdir()
        @info "Found following systems to cross check: $checkSystems"

        for system in checkSystems
            cd(joinpath(fmiCheckPath, system))
            checkVersions = readdir()
            @info "Found following versions for $system to cross check: $checkVersions"

            for version in checkVersions
                cd(joinpath(fmiCheckPath, system, version))
                cChecks = readdir()
                @info "Found following checks for $system - $version to cross check: $cChecks"

                for check in cChecks
                    checkPath = joinpath(fmiCheckPath, system, version, check)
                    notCompliant::Bool = false
                    if isfile(joinpath(checkPath, "notCompliantWithLatestRules"))
                        @info "$checkPath is not compliant with latest rules"
                        notCompliant = true
                    end
                    push!(
                        results,
                        FmuCrossCheck(
                            fmiVersion,
                            type,
                            os,
                            system,
                            version,
                            check,
                            notCompliant,
                            missing,
                            missing,
                            missing,
                            missing,
                        ),
                    )
                end
            end
        end
    end
    return results
end

"""
Calculate the mean of all normalized root mean square errors for the different variables.
It is normalized to the difference between the smallest and largest values of the respective variable
# Arguments
- `recordedVariables::Vector{String}`: List of all variable names that were recorded within the FMU simulation
- `simData::FMUSolution`: The solution data of the FMU (returned values of fmiSimulate())
- `referenceData::Table`: Reference data that was provided with the cross check FMU that is used as basis for the error calculation
# Returns
- `nrmse::Float64`: the mean of the nrmse of all recorded variables
"""
function calucateNRMSE(
    recordedVariables::Vector{String},
    simData::FMUSolution,
    referenceData,
)::Float64
    squaredErrorSums = zeros(length(recordedVariables))
    valueCount = zeros(length(recordedVariables))
    minimalValues = []
    maximalValues = []
    for (simIndex, time) in enumerate(simData.values.t)
        for (valIndex, value) in enumerate(referenceData[1])
            if value >= time
                for nameIndex = 1:length(recordedVariables)
                    valueCount[nameIndex] += 1
                    if (length(minimalValues) < nameIndex + 1)
                        push!(minimalValues, referenceData[nameIndex+1][valIndex])
                    else
                        minimalValues[nameIndex] = min(
                            minimalValues[nameIndex],
                            referenceData[nameIndex+1][valIndex],
                        )
                    end
                    if (length(maximalValues) < nameIndex + 1)
                        push!(maximalValues, referenceData[nameIndex+1][valIndex])
                    else
                        maximalValues[nameIndex] = max(
                            maximalValues[nameIndex],
                            referenceData[nameIndex+1][valIndex],
                        )
                    end
                    squaredErrorSums[nameIndex] +=
                        ((
                            simData.values.saveval[simIndex][nameIndex] -
                            referenceData[nameIndex+1][valIndex]
                        ))^2
                end
                break
            end
        end
    end
    errors = []
    for recordValue = 1:length(recordedVariables)
        valueRange = maximalValues[recordValue] - minimalValues[recordValue]
        if (valueRange == 0)
            valueRange = 1
        end
        value =
            (sqrt(squaredErrorSums[recordValue] / valueCount[recordValue]) / (valueRange))
        push!(errors, value)
    end
    return mean(errors)
end

function create_ssh_private_key(
    dir::AbstractString,
    ssh_pkey::AbstractString,
    os::AbstractString,
)::String
    is_linux = occursin("linux", os)
    if is_linux
        run(`chmod 700 $dir`)
    else
        chmod(dir, 0o700)
    end
    pkey_filename = joinpath(dir, "privatekey")

    decoded_ssh_pkey = decode_ssh_private_key(ssh_pkey)
    open(pkey_filename, "w+") do io
        println(io, decoded_ssh_pkey)
    end
    if is_linux
        run(`chmod 600 $pkey_filename`)
    else
        chmod(pkey_filename, 0o600)
    end
    return pkey_filename
end

function is_raw_ssh_private_key(content::AbstractString)::Bool
    x1 = occursin("-", content)
    x2 = occursin(" ", content)
    x3 = occursin("BEGIN ", content)
    x4 = occursin("END ", content)
    x5 = occursin(" PRIVATE KEY", content)

    return x1 && x2 && x3 && x4 && x5
end

function decode_ssh_private_key(content::AbstractString)::String
    if is_raw_ssh_private_key(content)
        @info("This is a raw SSH private key.")
        return content
    end

    @info("This doesn't look like a raw SSH private key. 
          I will assume that it is a Base64-encoded SSH private key.")
    decoded_content = String(Base64.base64decode(content))
    return decoded_content
end
