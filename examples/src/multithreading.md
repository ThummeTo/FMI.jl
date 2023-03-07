# Multithreading
Tutorial by Jonas Wilfert, Tobias Thummerer

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](http://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Units*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how to parallelize the computation of an FMU in FMI.jl. We can compute a batch of FMU-evaluations in parallel with different initial settings.
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multithreading**, check `multiprocessing.ipynb` for multiprocessing.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multithreading.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multithreading.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multithreading.md) corresponding to the notebook.  


## Getting started

### Installation prerequisites
|     | Description                       | Command                   | Alternative                                    |   
|:----|:----------------------------------|:--------------------------|:-----------------------------------------------|
| 1.  | Enter Package Manager via         | ]                         |                                                |
| 2.  | Install FMI via                   | add FMI                   | add " https://github.com/ThummeTo/FMI.jl "     |
| 3.  | Install FMIZoo via                | add FMIZoo                | add " https://github.com/ThummeTo/FMIZoo.jl "  |
| 4.  | Install FMICore via               | add FMICore               | add " https://github.com/ThummeTo/FMICore.jl " |
| 5.  | Install Folds via                 | add Folds                 |                                                |
| 6.  | Install BenchmarkTools via        | add BenchmarkTools        |                                                |

## Code section

To run the example, the previously installed packages must be included. 


```julia
# imports
using FMI
using FMIZoo
using Folds
using BenchmarkTools
```

First, check the amount of available threads:


```julia
Threads.nthreads()
```




    1



If the number of available threads doesn't match your expections, you can increase the number of threads available to the Julia process like described [here](https://docs.julialang.org/en/v1/manual/multi-threading/#Starting-Julia-with-multiple-threads).

### Simulation setup

Next, the start time and end time of the simulation are set. Here we also decide the size of the batch.


```julia
t_start = 0.0
t_step = 0.1
t_stop = 10.0
tspan = (t_start, t_stop)
tData = collect(t_start:t_step:t_stop)

# Best if batchSize is a multiple of the threads/cores
batchSize = Threads.nthreads()

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))

```




    1-element Vector{Vector{Float64}}:
     [0.10858636566695234, 0.43338441792327553]



We need to instantiate one FMU for each parallel execution, as they cannot be easily shared among different threads.


```julia
# a single FMU to compare the performance
realFMU = fmiLoad("SpringPendulum1D", "Dymola", "2022x")

# the FMU batch
realFMUBatch = [fmiLoad("SpringPendulum1D", "Dymola", "2022x") for _ in 1:batchSize]
```

    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmiUnzipVersion(...): Successfully unzipped modelDescription.xml at `/tmp/fmijl_dOAIP6/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmiUnzipVersion(...): Successfully unzipped modelDescription.xml at `/tmp/fmijl_veXR6c/SpringPendulum1D`.





    1-element Vector{FMU2}:
     Model name:        SpringPendulum1D
    Type:              1



We define a helper function to calculate the FMU solution and combine it into an Matrix.


```julia
function runCalcFormatted(fmu::FMU2, x0::Vector{Float64}, recordValues::Vector{String}=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, tspan; recordValues=recordValues, saveat=tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```




    runCalcFormatted (generic function with 2 methods)



Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(realFMU, rand(2))
```

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m





    BenchmarkTools.Trial: 7 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m787.257 ms[22m[39m … [35m813.474 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m1.36% … 1.31%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m803.842 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m2.68%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m800.782 ms[22m[39m ± [32m  9.117 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m2.12% ± 0.72%
    
      [39m█[39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m█[34m [39m[39m [39m [39m█[39m█[39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m█[34m▁[39m[39m▁[39m▁[39m█[39m█[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      787 ms[90m           Histogram: frequency by time[39m          813 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m152.72 MiB[39m, allocs estimate[90m: [39m[33m6802164[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(realFMU, i) for i in input_values)
```

    Single Threaded


    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m





    BenchmarkTools.Trial: 8 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m672.615 ms[22m[39m … [35m699.459 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m1.75% … 1.68%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m692.648 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m2.54%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m686.930 ms[22m[39m ± [32m 10.855 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m2.56% ± 0.88%
    
      [39m█[39m [39m█[39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [34m█[39m[39m [39m█[39m█[39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [39m█[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[34m█[39m[39m▁[39m█[39m█[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      673 ms[90m           Histogram: frequency by time[39m          699 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m152.72 MiB[39m, allocs estimate[90m: [39m[33m6802161[39m.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread it's own fmu, as they are not thread safe.
To spread the execution of a function to multiple threads, the library `Folds` can be used.


```julia
println("Multi Threaded")
@benchmark Folds.collect(runCalcFormatted(fmu, i) for (fmu, i) in zip(realFMUBatch, input_values))
```

    Multi Threaded


    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m
    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mFMU simulation failed with solver return code `Success`, please check log for hints.
    [33m[1m└ [22m[39m[90m@ FMI ~/work/FMI.jl/FMI.jl/src/FMI2/sim.jl:407[39m





    BenchmarkTools.Trial: 8 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m637.220 ms[22m[39m … [35m663.861 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m1.90% … 1.81%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m654.129 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m2.75%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m652.353 ms[22m[39m ± [32m 10.044 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m2.76% ± 0.95%
    
      [39m█[39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [34m█[39m[39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m█[39m█[39m [39m [39m [39m [39m█[39m [39m 
      [39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[34m█[39m[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m█[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      637 ms[90m           Histogram: frequency by time[39m          664 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m152.72 MiB[39m, allocs estimate[90m: [39m[33m6802165[39m.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `Threads.nthreads()`, this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` threads for the Julia process.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
fmiUnload(realFMU)
fmiUnload.(realFMUBatch)
```




    1-element Vector{Nothing}:
     nothing



### Summary

In this tutorial it is shown how multi threading with `Folds.jl` can be used to improve the performance for calculating a Batch of FMUs.
