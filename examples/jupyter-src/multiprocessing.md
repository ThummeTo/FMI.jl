# Multiprocessing
Tutorial by Jonas Wilfert, Tobias Thummerer

🚧 This tutorial is under revision and will be replaced by an up-to-date version soon 🚧

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert
# Licensed under the MIT license. 
# See LICENSE (https://github.com/JuliaFMI/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](https://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Unit*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how to parallelize the computation of an FMU in FMI.jl. We can compute a batch of FMU-evaluations in parallel with different initial settings.
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multiprocessing**, check `multithreading.ipynb` for multithreading.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/JuliaFMI/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/JuliaFMI/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.ipynb) there is also a [Julia file](https://github.com/JuliaFMI/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/JuliaFMI/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.md) corresponding to the notebook.  


## Getting started

### Installation prerequisites
|     | Description                       | Command                   | Alternative                                    |   
|:----|:----------------------------------|:--------------------------|:-----------------------------------------------|
| 1.  | Enter Package Manager via         | ]                         |                                                |
| 2.  | Install FMI via                   | add FMI                   | add " https://github.com/JuliaFMI/FMI.jl "     |
| 3.  | Install FMIZoo via                | add FMIZoo                | add " https://github.com/JuliaFMI/FMIZoo.jl "  |
| 4.  | Install FMICore via               | add FMICore               | add " https://github.com/JuliaFMI/FMICore.jl " |
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
@everywhere using DifferentialEquations
@everywhere using BenchmarkTools
```

Checking that we workers have been correctly initialized:


```julia
workers()

@everywhere println("Hello World!")

# The following lines can be uncommented for more advanced information about the subprocesses
# @everywhere println(pwd())
# @everywhere println(Base.active_project())
# @everywhere println(gethostname())
# @everywhere println(VERSION)
# @everywhere println(Threads.nthreads())
```

    Hello World!
          From worker 3:	Hello World!
    

          From worker 2:	Hello World!
    

### Simulation setup

Next, the batch size and input values are defined.


```julia

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))
```




    16-element Vector{Vector{Float64}}:
     [0.9293457920921313, 0.402576116372966]
     [0.12259134734034649, 0.7179386581182066]
     [0.0943252136813455, 0.5899702018324732]
     [0.8663069822825797, 0.746084003852257]
     [0.356068251604996, 0.23273698706839285]
     [0.5862786539205335, 0.2690817433781445]
     [0.9157317876486707, 0.8088371088506633]
     [0.1474287777108576, 0.6200899872997935]
     [0.3827716762542702, 0.5092584410668642]
     [0.3991691214391897, 0.5471853281812993]
     [0.6228151638578469, 0.7174572971417849]
     [0.2276767909173708, 0.650923059680724]
     [0.2407006466766225, 0.7062158918043433]
     [0.08067005382484049, 0.38487092625255936]
     [0.7293256191148918, 0.6150534212347081]
     [0.6484325935206493, 0.1667546653845573]



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

    model_fmu = loadFMU("SpringPendulum1D", "Dymola", "2022x"; type=:ME)
end
```

We define a helper function to calculate the FMU and combine it into a matrix.


```julia
@everywhere function runCalcFormatted(fmu, x0, recordValues=["mass.s", "mass.v"])
    data = simulateME(fmu, SharedModule.tspan; recordValues=recordValues, saveat=SharedModule.tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```

Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(SharedModule.model_fmu, rand(2))
```




    BenchmarkTools.Trial: 4 samples with 1 evaluation per sample.
     Range (min … max):  1.437 s …   1.459 s  ┊ GC (min … max): 0.09% … 0.16%
     Time  (median):     1.448 s              ┊ GC (median):    0.12%
     Time  (mean ± σ):   1.448 s ± 12.329 ms  ┊ GC (mean ± σ):  0.31% ± 0.40%
    
      █                                                      ▁▁  
      █▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁██ ▁
      1.44 s         Histogram: frequency by time        1.46 s <
    
     Memory estimate: 64.21 MiB, allocs estimate: 4201025.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)
```

    Single Threaded
    




    BenchmarkTools.Trial: 1 sample with 1 evaluation per sample.
     Single result which took 23.210 s (0.12% GC) to evaluate,
     with a memory estimate of 1.00 GiB, over 67216388 allocations.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread its own FMU, as they are not thread safe.
To spread the execution of a function to multiple processes, the function `pmap` can be used.


```julia
println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)
```

    Multi Threaded
    




    BenchmarkTools.Trial: 1 sample with 1 evaluation per sample.
     Single result which took 12.147 s (0.00% GC) to evaluate,
     with a memory estimate of 115.89 KiB, over 2065 allocations.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `n_procs` (or the number of physical cores of your CPU), this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` Julia processes.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
@everywhere unloadFMU(SharedModule.model_fmu)
```

### Summary

In this tutorial it is shown how multiprocessing with `Distributed.jl` can be used to improve the performance for calculating a batch of FMUs.
