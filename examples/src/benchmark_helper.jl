#
# Copyright (c) 2023 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

@everywhere workers import Pkg
@everywhere workers using BenchmarkTools
@everywhere workers using Sundials 

using Suppressor

@everywhere function evalBenchmark(b; samples=2, seconds=600, kwargs...)
    res = nothing
    try
        res = run(b; samples=samples, seconds=seconds, kwargs...)
    catch e 
       @error "Benchmark failed:\n$(e)"
       return 0.0, 0, 0
    end

    if length(res.times) <= 1 
        @error "Only ran $(length(res.times)) benchmarks, this is not enough because of the first compilation run!"
    end

    min_time = min(res.times...)
    memory = res.memory 
    allocs = res.allocs
    return min_time, memory, allocs 
end

@everywhere workers function benchmarkSimulation(fmu, data, solver)
    return @benchmarkable fmiSimulate(fmu, (data.consumption_t[1], data.consumption_t[end]); parameters=data.params, saveat=data.consumption_t, recordValues=realVRs, showProgress=false, solver=solver, reltol=1e-4);
end

@everywhere workers using ReverseDiff

@everywhere workers function loss(p, x0, fmu, data, solver)
    fmu.optim_p = p 
    fmu.optim_p_refs = collect(fmi2StringToValueReference(fmu, vr) for vr in keys(data.params))
    sol = fmiSimulate(fmu, (data.consumption_t[1], 1.0); x0=x0, parameters=data.params, saveat=data.consumption_t, showProgress=false, solver=solver, reltol=1e-4);
    return sum(collect(u[1] for u in sol.states))
end

@everywhere workers function benchmarkGradient(p, x0, fmu, data, solver)
    return @benchmarkable grad(p, x0, fmu, data, solver)
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
        Pkg.develop(url=version[5:end])
    else
        Pkg.add(name="FMI", version=version)
    end

    Pkg.add("FMIZoo")

    # install FMISensitivity for FMI.jl >= 0.13.0
    if !ispath
        f, m, b = split(version, ".")
        f = parse(Float64, f)
        m = parse(Float64, m)
        b = parse(Float64, b)

        if f >= 1 || m >= 13 
            Pkg.add(name="FMISensitivity")
        end
    end
end 

function runBenchmark()

    min_times = zeros(numVersions)
    memories = zeros(numVersions)
    allocs = zeros(numVersions)

    @suppress begin
        # simulate one after another, so we don't have negative influences between processes
        for i in 1:numVersions
            future = @spawnat workers[i] evalBenchmark(b; samples=3)
            min_times[i], memories[i], allocs[i] = fetch(future)
        end
    end

    return min_times, memories, allocs
end

function round_or_empty(val; suffix="", digits=0)
    if val == 0.0
        return "[n.a.]"
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
    bar!(twinx(), y2s; ylabel="Allocated Memory [MB]", color=:red, xticks=:none, legend=:none)
    for i in 1:length(versions)
        annotate!(fig, 3+(i-1)*3, memories[i]/2.0, text(round_or_empty(memories[i];digits=0, suffix=" MB"); halign=:center, valign=:center, rotation=90, color=:white))
    end
    fig 
end
