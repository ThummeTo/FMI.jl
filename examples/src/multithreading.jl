# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo
using Folds
using BenchmarkTools

Threads.nthreads()

t_start = 0.0
t_step = 0.1
t_stop = 10.0
tspan = (t_start, t_stop)
tData = collect(t_start:t_step:t_stop)

# Best if batchSize is a multiple of the threads/cores
batchSize = Threads.nthreads()

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))


# a single FMU to compare the performance
realFMU = fmiLoad("SpringPendulum1D", "Dymola", "2022x")

# the FMU batch
realFMUBatch = [fmiLoad("SpringPendulum1D", "Dymola", "2022x") for _ in 1:batchSize]

function runCalcFormatted(fmu::FMU2, x0::Vector{Float64}, recordValues::Vector{String}=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, tspan; recordValues=recordValues, saveat=tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end

@benchmark data = runCalcFormatted(realFMU, rand(2))

println("Single Threaded")
@benchmark collect(runCalcFormatted(realFMU, i) for i in input_values)

println("Multi Threaded")
@benchmark Folds.collect(runCalcFormatted(fmu, i) for (fmu, i) in zip(realFMUBatch, input_values))

fmiUnload(realFMU)
fmiUnload.(realFMUBatch)
