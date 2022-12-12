# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

using Distributed
n_procs = 2
addprocs(n_procs; exeflags=`--project=$(Base.active_project()) --threads=auto`, restrict=false)

# imports
@everywhere using FMI
@everywhere using FMIZoo
@everywhere using BenchmarkTools

workers()

@everywhere println("Hello World!")

# The following lines can be uncommented for more advanced informations about the subprocesses
# @everywhere println(pwd())
# @everywhere println(Base.active_project())
# @everywhere println(gethostname())
# @everywhere println(VERSION)
# @everywhere println(Threads.nthreads())


# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))

@everywhere module SharedModule
    using FMIZoo
    using FMI

    t_start = 0.0
    t_step = 0.1
    t_stop = 10.0
    tspan = (t_start, t_stop)
    tData = collect(t_start:t_step:t_stop)

    model_fmu = FMIZoo.fmiLoad("SpringPendulum1D", "Dymola", "2022x")
end

@everywhere function runCalcFormatted(fmu, x0, recordValues=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, SharedModule.tspan; recordValues=recordValues, saveat=SharedModule.tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end

@benchmark data = runCalcFormatted(SharedModule.model_fmu, rand(2))

println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)

println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)

@everywhere fmiUnload(SharedModule.model_fmu)
