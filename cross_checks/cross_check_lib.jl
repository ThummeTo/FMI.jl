""" 
Returns the path where the FMU cross checks are saved locally.
This will also checkout the repository from a specified URL if they are not yet present in the specified path.
Hint: This will not check the cross check repository for integrety
# Arguments
- `crossCheckRepo::String`: URL to the FMU Cross check repository that should be used. Note, if you want to push your results later, this should be a fork that you have access to
- `unpackPath::Union{String, Nothing}`:  optional path that is used to checkout the the fmu cross check repository. If no path is specified, a temporary path is created
# Returns
- `repoPath::String`: The path where the repository can be found locally (including the repository name)
"""
function getFmuCrossCheckRepo(crossCheckRepo::String, unpackPath::Union{String, Nothing} = nothing)::String
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

"""
Returns a array of all available FMI Cross Checks 
# Arguments
- `repoPath::String`:  path to the local FMI Cross Check repository
- `fmiVersion::String`: FMI Version used for running the FMUs. Note: Currently only 2.0 officially supported
- `os::String`: The operating system that is used for running the FMUs
"""
function getFmusToTest(repoPath::String, fmiVersion::String, os::String)::Vector{FmuCrossCheck}
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
                    push!(results, FmuCrossCheck(fmiVersion, type, os, system, version, check, notCompliant, missing, missing, missing, missing)) 
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
- `simData::FMU2Solution`: The solution data of the FMU (returned values of fmiSimulate())
- `referenceData::Table`: Reference data that was provided with the cross check FMU that is used as basis for the error calculation
# Returns
- `nrmse::Float64`: the mean of the nrmse of all recorded variables
"""
function calucateNRMSE(recordedVariables::Vector{String}, simData::FMU2Solution, referenceData)::Float64
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
                        minimalValues[nameIndex] = min(minimalValues[nameIndex], referenceData[nameIndex+1][valIndex])
                    end
                    if (length(maximalValues) < nameIndex + 1)
                        push!(maximalValues, referenceData[nameIndex+1][valIndex])
                    else
                        maximalValues[nameIndex] = max(maximalValues[nameIndex], referenceData[nameIndex+1][valIndex])
                    end
                    # println("Simulation time: $time, Simulation value: $(simData.values.saveval[simIndex][nameIndex]) Reference time: $(value) Reference Value: $(referenceData[nameIndex+1][valIndex])")
                    squaredErrorSums[nameIndex] += ((simData.values.saveval[simIndex][nameIndex] - referenceData[nameIndex+1][valIndex]))^2
                end
                break;
            end
        end
    end
    errors = []
    for recordValue = 1:length(recordedVariables)
        valueRange = maximalValues[recordValue] - minimalValues[recordValue]
        if (valueRange == 0)
            valueRange = 1
        end
        value = (sqrt(squaredErrorSums[recordValue]/valueCount[recordValue])/(valueRange))
        push!(errors, value)
    end
    return mean(errors)
end