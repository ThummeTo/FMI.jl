# Multiprocessing
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
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multiprocessing**, check `multithreading.ipynb` for multithreading.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multiprocessing.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multiprocessing.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/multiprocessing.md) corresponding to the notebook.  


## Getting started

### Installation prerequisites
|     | Description                       | Command                   | Alternative                                    |   
|:----|:----------------------------------|:--------------------------|:-----------------------------------------------|
| 1.  | Enter Package Manager via         | ]                         |                                                |
| 2.  | Install FMI via                   | add FMI                   | add " https://github.com/ThummeTo/FMI.jl "     |
| 3.  | Install FMIZoo via                | add FMIZoo                | add " https://github.com/ThummeTo/FMIZoo.jl "  |
| 4.  | Install FMICore via               | add FMICore               | add " https://github.com/ThummeTo/FMICore.jl " |
| 5.  | Install BenchmarkTools via        | add BenchmarkTools        |                                                |

## Code section



Adding your desired amount of processes:


```julia
using Distributed
n_procs = 2
addprocs(n_procs; exeflags=`--project=$(Base.active_project()) --threads=auto`, restrict=false)
```




    2-element Vector{Int64}:
     2
     3



To run the example, the previously installed packages must be included. 


```julia
# imports
@everywhere using FMI
@everywhere using FMIZoo
@everywhere using BenchmarkTools
```

Checking that we workers have been correctly initialized:


```julia
workers()

@everywhere println("Hello World!")

# The following lines can be uncommented for more advanced informations about the subprocesses
# @everywhere println(pwd())
# @everywhere println(Base.active_project())
# @everywhere println(gethostname())
# @everywhere println(VERSION)
# @everywhere println(Threads.nthreads())
```

          From worker 3:	Hello World!
          From worker 2:	Hello World!
    Hello World!


### Simulation setup

Next, the batch size and input values are defined.


```julia

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))
```




    16-element Vector{Vector{Float64}}:
     [0.05144421810913624, 0.6911026953063167]
     [0.1430427175505794, 0.1802391878263634]
     [0.7050947021667354, 0.043482559020907585]
     [0.045868595528536726, 0.16906046161244137]
     [0.079733971058362, 0.9175824228655146]
     [0.5455567934231366, 0.04727322573484716]
     [0.6658310747881929, 0.2794025430704411]
     [0.5710335726262262, 0.8731978666784531]
     [0.9629205464076773, 0.8517832981529573]
     [0.9189978284696283, 0.6474584895122929]
     [0.053433358040333, 0.8366592127681703]
     [0.6521248382176893, 0.26139226958274564]
     [0.5326026861873806, 0.7711361614973313]
     [0.8829416876614338, 0.5398629429721399]
     [0.4126450823089647, 0.020013164492589275]
     [0.4686894387412398, 0.4665376710026016]



### Shared Module
For Distributed we need to embed the FMU into its own `module`. This prevents Distributed from trying to serialize and send the FMU over the network, as this can cause issues. This module needs to be made available on all processes using `@everywhere`.


```julia
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
```

We define a helper function to calculate the FMU and combine it into an Matrix.


```julia
@everywhere function runCalcFormatted(fmu, x0, recordValues=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, SharedModule.tspan; recordValues=recordValues, saveat=SharedModule.tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```

Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(SharedModule.model_fmu, rand(2))
```




    BenchmarkTools.Trial: 8 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m639.784 ms[22m[39m … [35m670.556 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m1.87% … 1.75%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m658.726 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m3.62%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m658.144 ms[22m[39m ± [32m  8.476 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m3.17% ± 0.84%
    
      [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[34m█[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m 
      [39m▅[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[34m█[39m[39m▁[39m▁[39m▁[39m▁[39m▅[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▅[39m [39m▁
      640 ms[90m           Histogram: frequency by time[39m          671 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m152.88 MiB[39m, allocs estimate[90m: [39m[33m6801979[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)
```

    Single Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m10.516 s[39m (3.18% GC) to evaluate,
     with a memory estimate of [33m2.39 GiB[39m, over [33m108831666[39m allocations.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread it's own fmu, as they are not thread safe.
To spread the execution of a function to multiple processes, the function `pmap` can be used.


```julia
println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)
```

    Multi Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m5.964 s[39m (0.00% GC) to evaluate,
     with a memory estimate of [33m79.03 KiB[39m, over [33m1208[39m allocations.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `n_procs` (or the number of physical cores of your CPU), this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` Julia processes.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
@everywhere fmiUnload(SharedModule.model_fmu)
```

### Summary

In this tutorial it is shown how multi processing with `Distributed.jl` can be used to improve the performance for calculating a Batch of FMUs.
