# Multiprocessing
Tutorial by Jonas Wilfert, Tobias Thummerer

## License
Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert

Licensed under the MIT license. See [LICENSE](https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

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
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/multiprocessing.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/multiprocessing.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/multiprocessing.md) corresponding to the notebook.  


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
n_procs = 4
addprocs(n_procs; exeflags=`--project=$(Base.active_project()) --threads=auto`, restrict=false)
```




    4-element Vector{Int64}:
     2
     3
     4
     5



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
          From worker 4:	Hello World!
          From worker 2:	Hello World!
    Hello World!
          From worker 5:	Hello World!


### Simulation setup

Next, the batch size and input values are defined.


```julia

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))
```




    16-element Vector{Vector{Float64}}:
     [0.449426307055, 0.6015316140087363]
     [0.21420344825208315, 0.03385044755363409]
     [0.559098004261138, 0.23942894184074626]
     [0.8201753724228067, 0.880564709218326]
     [0.556490981815603, 0.7728199392532447]
     [0.5169995603177666, 0.7369379362103503]
     [0.5466491475114241, 0.25398778142752776]
     [0.3120372622002092, 0.7478277895990828]
     [0.3123560150719227, 0.3034881677157013]
     [0.09989648412942675, 0.7504004750795883]
     [0.09995270421463731, 0.34181583071174737]
     [0.9893732885581712, 0.9121174015208486]
     [0.0202193295958637, 0.023539343823322012]
     [0.1833034113919878, 0.2004329227451611]
     [0.8259293984169942, 0.5925637206223466]
     [0.6155730482002788, 0.11209405645419324]



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

    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_u0paCY/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/oQYco/src/FMI2_ext.jl:76
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_inRm6h/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_xhykBd/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_aw62yb/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_inRm6h/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_xhykBd/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_aw62yb/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_u0paCY/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/oQYco/src/FMI2_ext.jl:192
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/oQYco/src/FMI2_ext.jl:195
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_hLK1K1/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_hLK1K1/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.


We define a helper function to calculate the FMU and combine it into an Matrix.


```julia
@everywhere function runCalcFormatted(fmu, x0, recordValues=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, SharedModule.t_start, SharedModule.t_stop; recordValues=recordValues, saveat=SharedModule.tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```

Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(SharedModule.model_fmu, rand(2))
```




    BenchmarkTools.Trial: 7 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m701.971 ms[22m[39m … [35m745.005 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m3.02% … 4.44%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m715.542 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m3.21%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m723.409 ms[22m[39m ± [32m 17.659 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m3.59% ± 0.82%
    
      [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [34m█[39m[39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m█[39m [39m [39m [39m [39m█[39m [39m 
      [39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[34m█[39m[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      702 ms[90m           Histogram: frequency by time[39m          745 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m155.95 MiB[39m, allocs estimate[90m: [39m[33m3602373[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)
```

    Single Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m11.305 s[39m (4.00% GC) to evaluate,
     with a memory estimate of [33m2.44 GiB[39m, over [33m57637956[39m allocations.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread it's own fmu, as they are not thread safe.
To spread the execution of a function to multiple processes, the function `pmap` can be used.


```julia
println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)
```

    Multi Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m6.658 s[39m (0.00% GC) to evaluate,
     with a memory estimate of [33m84.52 KiB[39m, over [33m1302[39m allocations.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `n_procs` (or the number of physical cores of your CPU), this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` Julia processes.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
@everywhere fmiUnload(SharedModule.model_fmu)
```

### Summary

In this tutorial it is shown how multi processing with `Distributed.jl` can be used to improve the performance for calculating a Batch of FMUs.
