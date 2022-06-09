# Manipulate a function
Tutorial by Jonas Wilfert, Tobias Thummerer

## License
Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert

Licensed under the MIT license. See [LICENSE](https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](http://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Units*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how to parallelize the computation of an FMU in FMI.jl. We can compute a batch of FMU-evaluations in parallel with different initial settings.
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multi processing**, check `parallel.ipynb` for multithreading.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/main/example/distributed.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/main/example/distributed.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/distributed.md) corresponding to the notebook.  


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



Adding the desired amount of processes


```julia
using Distributed
n_procs = 8
addprocs(n_procs; exeflags=`--project=$(Base.active_project()) --threads=auto`, restrict=false)
```




    8-element Vector{Int64}:
     2
     3
     4
     5
     6
     7
     8
     9



To run the example, the previously installed packages must be included. 


```julia
# imports
@everywhere using FMI
@everywhere using FMIZoo
@everywhere using BenchmarkTools
```

Checking that we workers have been correctly initialized


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

          From worker 6:	Hello World!
          From worker 7:	Hello World!
          From worker 4:	Hello World!
          From worker 8:	Hello World!
          From worker 3:	Hello World!
          From worker 5:	Hello World!
          From worker 2:	Hello World!
    Hello World!
          From worker 9:	Hello World!


### Simulation setup

Next, the batch size and input values are defined.


```julia

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))
```




    16-element Vector{Vector{Float64}}:
     [0.39056976541477884, 0.5897075906274076]
     [0.4134256103176259, 0.052901077522343076]
     [0.33681991461588257, 0.8082956146209443]
     [0.8087411006415204, 0.6148289147294093]
     [0.6373581180078172, 0.0616351611411321]
     [0.48130224079764106, 0.7093186284436659]
     [0.5219561139696487, 0.40789540594026086]
     [0.42354137134708303, 0.9675793996676059]
     [0.4436152555285058, 0.45370153752431697]
     [0.8108388189350699, 0.4870140304657091]
     [0.5124178994673991, 0.8354261348523733]
     [0.47802800763035, 0.35607035467714665]
     [0.6868294317416757, 0.07890332427188729]
     [0.9978045367698911, 0.860672641236724]
     [0.6497836184334596, 0.8184660729156839]
     [0.5773264121530415, 0.7287854827027764]



### Shared Module
For Distributed we need to split of the FMU into a different `module`. This prevents Distributed from trying to serialize and send the FMU over the Network, as this can cause issues. It needs to be made available on all processes using `@everywhere`.


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
    FMI.fmiInstantiate!(model_fmu)
end
```

    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_jIMXUB/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_R7Q5OE/SpringPendulum1D`.
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_jIMXUB/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_V26yXU/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_rIZpvZ/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_MtIdPc/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_KhYO9O/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_R7Q5OE/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_m3g8YK/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_fN6Wam/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_V26yXU/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_rIZpvZ/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_MtIdPc/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_KhYO9O/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_m3g8YK/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_fN6Wam/SpringPendulum1D/resources`
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_xbf3L3/SpringPendulum1D`.
    [36m[1m[ [22m[39m[36m[1mInfo: [22m[39mfmi2Load(...): FMU resources location is `file:////tmp/fmijl_xbf3L3/SpringPendulum1D/resources`
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




    BenchmarkTools.Trial: 17 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m300.737 ms[22m[39m … [35m324.003 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m6.16% … 5.71%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m303.967 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m6.14%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m306.105 ms[22m[39m ± [32m  5.866 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m6.62% ± 1.12%
    
      [39m▁[39m▁[39m▁[39m█[39m [39m [39m█[39m▁[34m▁[39m[39m▁[39m [39m [39m▁[39m▁[32m▁[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m [39m 
      [39m█[39m█[39m█[39m█[39m▁[39m▁[39m█[39m█[34m█[39m[39m█[39m▁[39m▁[39m█[39m█[32m█[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      301 ms[90m           Histogram: frequency by time[39m          324 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m146.80 MiB[39m, allocs estimate[90m: [39m[33m3002434[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)
```

    Single Threaded





    BenchmarkTools.Trial: 2 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m4.917 s[22m[39m … [35m  4.934 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m7.22% … 6.83%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m4.925 s              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m7.03%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m4.925 s[22m[39m ± [32m11.940 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m7.03% ± 0.28%
    
      [34m█[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      4.92 s[90m         Histogram: frequency by time[39m        4.93 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m2.29 GiB[39m, allocs estimate[90m: [39m[33m48038932[39m.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread it's own fmu, as they are not thread safe.
To spread the execution of a function to multiple processes, the function `pmap` can be used.


```julia
println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)
```

    Multi Threaded





    BenchmarkTools.Trial: 2 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m3.069 s[22m[39m … [35m  3.092 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 0.00%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m3.080 s              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m3.080 s[22m[39m ± [32m16.552 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.00% ± 0.00%
    
      [34m█[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      3.07 s[90m         Histogram: frequency by time[39m        3.09 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m84.69 KiB[39m, allocs estimate[90m: [39m[33m1219[39m.



### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
@everywhere fmiUnload(SharedModule.model_fmu)
```

### Summary

In this tutorial it is shown how multi processing with `Distributed.jl` can be used to improve the performance for calculating a Batch of FMUs.
