#
# Copyright (c) 2023 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@everywhere workers import Pkg
@everywhere workers using BenchmarkTools
@everywhere workers using Sundials 

@everywhere function evalBenchmark(b; kwargs...)
    res = run(b; kwargs...)
    min_time = min(res.times...)
    memory = res.memory 
    allocs = res.allocs
    return min_time, memory, allocs 
end

@everywhere function benchmark1(fmu, data, cvode)
    return @benchmarkable fmiSimulate(fmu, (data.consumption_t[1], data.consumption_t[end]); parameters=data.params, saveat=data.consumption_t, recordValues=realVRs, showProgress=false, solver=cvode, reltol=1e-4);
end

@everywhere function versionName(version)
    if startswith(version, "PATH")
        return Pkg.TOML.parsefile(joinpath(version[5:end], "Project.toml"))["version"]
    end
    return version 
end

@everywhere function setupVersion(version::String)
    name = versionName(version)
    ispath = startswith(version, "PATH")

    try 
        Pkg.generate("FMI_" * name * "_Benchmark")
    catch
    end
    Pkg.activate("FMI_" * name * "_Benchmark")

    if ispath
        Pkg.add(url=version[5:end])
    else
        Pkg.add(name="FMI", version=version)
    end

    Pkg.add("FMIZoo")
end 

futures = Vector{Any}(undef, numVersions)
for i in 1:numVersions
    futures[i] = @spawnat workers[i] setupVersion(versions[i]);
end

fetch.(futures)

@everywhere workers using FMI, FMIZoo
@everywhere workers data = FMIZoo.VLDM(:train)
@everywhere workers fmu = fmiLoad("VLDM", "Dymola", "2020x"; type=:ME)
@everywhere workers using FMI.DifferentialEquations: Tsit5
@everywhere workers cvode = CVODE_BDF()

@everywhere workers realBuffer = zeros(fmi2Real, 2)
@everywhere workers realVRs = vcat(fmu.modelDescription.stateValueReferences, fmu.modelDescription.derivativeValueReferences)

@everywhere workers c=FMI.fmi2Instantiate!(fmu)
@everywhere workers FMI.fmi2EnterInitializationMode(fmu)

function runBenchmark(b)

    min_times = zeros(numVersions)
    memories = zeros(numVersions)
    allocs = zeros(numVersions)

    # simulate one after another, so we don't have negative influences between processes
    for i in 1:numVersions
        future = @spawnat workers[i] evalBenchmark(b; samples=3, seconds=60)
        min_times[i], memories[i], allocs[i] = fetch(future)
    end

    return min_times, memories, allocs
end

function round_or_empty(val; suffix="", digits=0)
    if val == 0.0
        return ""
    elseif digits > 0
        return "" * "$(round(val; digits=digits))" * suffix
    else
        return "" * "$(Int(round(val; digits=digits)))" * suffix
    end
end

function resultPlot(versions, min_times, memories)

    versions = [versionName.(versions)...]
    min_times = min_times ./ 1e9
    memories = memories ./ (1024*1024)

    ticks = [""]
    xs = 1:length(versions)*3+1
    y1s = [0.0]
    y2s = [0.0]
    for i in 1:length(versions)
        push!(ticks, versions[i])
        push!(ticks, "")
        push!(ticks, "")

        push!(y1s, min_times[i])
        push!(y1s, 0.0)
        push!(y1s, 0.0)

        push!(y2s, 0.0)
        push!(y2s, memories[i])
        push!(y2s, 0.0)
    end

    fig = bar(xs, y1s; xlabel="Tool / Version", ylabel="Execution Time [s]", legend=:none, xticks=(xs .+ 0.5, ticks))
    for i in 1:length(versions)
        annotate!(fig, 2+(i-1)*3, min_times[i]/2.0, text(round_or_empty(min_times[i]; digits=1, suffix=" s"); halign=:center, valign=:center, rotation=90, color=:white))
    end
    bar!(twinx(), y2s; ylabel="Memory Allocations [MB]", color=:red, xticks=:none, legend=:none)
    for i in 1:length(versions)
        annotate!(fig, 3+(i-1)*3, memories[i]/2.0, text(round_or_empty(memories[i];digits=0, suffix=" MB"); halign=:center, valign=:center, rotation=90, color=:white))
    end
    fig 
end
