# Multithreading
Tutorial by Jonas Wilfert, Tobias Thummerer

🚧 This tutorial is under revision and will be replaced by an up-to-date version soon 🚧

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](https://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Unit*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

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
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multithreading.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multithreading.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multithreading.md) corresponding to the notebook.  


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
using DifferentialEquations
```

    [33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mError requiring `FMIImport` from `FMIZoo`
    [33m[1m│ [22m[39m  exception =
    [33m[1m│ [22m[39m   UndefVarError: `fmi2Load` not defined
    [33m[1m│ [22m[39m   Stacktrace:
    [33m[1m│ [22m[39m     [1] [0m[1mgetproperty[22m[0m[1m([22m[90mx[39m::[0mModule, [90mf[39m::[0mSymbol[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mBase.jl:31[24m[39m
    [33m[1m│ [22m[39m     [2] top-level scope
    [33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:46[24m[39m
    [33m[1m│ [22m[39m     [3] [0m[1meval[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m     [4] [0m[1meval[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:6[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m     [5] [0m[1m(::FMIZoo.var"#14#20")[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:101[24m[39m
    [33m[1m│ [22m[39m     [6] [0m[1mmacro expansion[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m[4mtiming.jl:395[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m     [7] [0m[1merr[22m[0m[1m([22m[90mf[39m::[0mAny, [90mlistener[39m::[0mModule, [90mmodname[39m::[0mString, [90mfile[39m::[0mString, [90mline[39m::[0mAny[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:47[24m[39m
    [33m[1m│ [22m[39m     [8] [0m[1m(::FMIZoo.var"#13#19")[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:100[24m[39m
    [33m[1m│ [22m[39m     [9] [0m[1mwithpath[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpath[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:37[24m[39m
    [33m[1m│ [22m[39m    [10] [0m[1m(::FMIZoo.var"#12#18")[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:99[24m[39m
    [33m[1m│ [22m[39m    [11] [0m[1mlistenpkg[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpkg[39m::[0mBase.PkgId[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:20[24m[39m
    [33m[1m│ [22m[39m    [12] [0m[1mmacro expansion[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:98[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [13] [0m[1m__init__[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:42[24m[39m
    [33m[1m│ [22m[39m    [14] [0m[1mrun_module_init[22m[0m[1m([22m[90mmod[39m::[0mModule, [90mi[39m::[0mInt64[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1197[24m[39m
    [33m[1m│ [22m[39m    [15] [0m[1mregister_restored_modules[22m[0m[1m([22m[90msv[39m::[0mCore.SimpleVector, [90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1185[24m[39m
    [33m[1m│ [22m[39m    [16] [0m[1m_include_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString, [90mocachepath[39m::[0mString, [90mdepmods[39m::[0mVector[90m{Any}[39m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1129[24m[39m
    [33m[1m│ [22m[39m    [17] [0m[1m_require_search_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90msourcepath[39m::[0mString, [90mbuild_id[39m::[0mUInt128[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1655[24m[39m
    [33m[1m│ [22m[39m    [18] [0m[1m_require[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90menv[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2012[24m[39m
    [33m[1m│ [22m[39m    [19] [0m[1m__require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1886[24m[39m
    [33m[1m│ [22m[39m    [20] [0m[1m#invoke_in_world#3[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [21] [0m[1minvoke_in_world[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [22] [0m[1m_require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1877[24m[39m
    [33m[1m│ [22m[39m    [23] [0m[1mmacro expansion[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1864[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [24] [0m[1mmacro expansion[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mlock.jl:270[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [25] [0m[1m__require[22m[0m[1m([22m[90minto[39m::[0mModule, [90mmod[39m::[0mSymbol[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1827[24m[39m
    [33m[1m│ [22m[39m    [26] [0m[1m#invoke_in_world#3[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [27] [0m[1minvoke_in_world[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [28] [0m[1mrequire[22m[0m[1m([22m[90minto[39m::[0mModule, [90mmod[39m::[0mSymbol[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1820[24m[39m
    [33m[1m│ [22m[39m    [29] [0m[1meval[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [30] [0m[1minclude_string[22m[0m[1m([22m[90mmapexpr[39m::[0mtypeof(REPL.softscope), [90mmod[39m::[0mModule, [90mcode[39m::[0mString, [90mfilename[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2160[24m[39m
    [33m[1m│ [22m[39m    [31] [0m[1mexecute_request[22m[0m[1m([22m[90msocket[39m::[0mZMQ.Socket, [90mkernel[39m::[0mIJulia.Kernel, [90mmsg[39m::[0mIJulia.Msg[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4mexecute_request.jl:129[24m[39m
    [33m[1m│ [22m[39m    [32] [0m[1m#invokelatest#2[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:892[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [33] [0m[1minvokelatest[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:889[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [34] [0m[1meventloop[22m[0m[1m([22m[90msocket[39m::[0mZMQ.Socket, [90mkernel[39m::[0mIJulia.Kernel[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4meventloop.jl:26[24m[39m
    [33m[1m│ [22m[39m    [35] [0m[1m(::IJulia.var"#40#43"{IJulia.Kernel})[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4meventloop.jl:71[24m[39m
    [33m[1m└ [22m[39m[90m@ Requires C:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\require.jl:51[39m
    

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
     [0.7768264173226263, 0.4002275745626398]



We need to instantiate one FMU for each parallel execution, as they cannot be easily shared among different threads.


```julia
# a single FMU to compare the performance
realFMU = loadFMU("SpringPendulum1D", "Dymola", "2022x")

# the FMU batch
realFMUBatch = [loadFMU("SpringPendulum1D", "Dymola", "2022x") for _ in 1:batchSize]
```




    1-element Vector{FMU2}:
     Model name:	SpringPendulum1D
    Type:		1



We define a helper function to calculate the FMU solution and combine it into a matrix.


```julia
function runCalcFormatted(fmu::FMU2, x0::Vector{Float64}, recordValues::Vector{String}=["mass.s", "mass.v"])
    data = simulateME(fmu, tspan; recordValues=recordValues, saveat=tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```




    runCalcFormatted (generic function with 2 methods)



Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(realFMU, rand(2))
```




    BenchmarkTools.Trial: 3 samples with 1 evaluation per sample.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m2.107 s[22m[39m … [35m  2.193 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.44% … 1.01%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.113 s              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.44%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m2.138 s[22m[39m ± [32m48.418 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.61% ± 0.36%
    
      [34m█[39m[39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      2.11 s[90m         Histogram: frequency by time[39m        2.19 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m296.15 MiB[39m, allocs estimate[90m: [39m[33m4101765[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(realFMU, i) for i in input_values)
```

    Single Threaded
    




    BenchmarkTools.Trial: 3 samples with 1 evaluation per sample.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m2.101 s[22m[39m … [35m 2.112 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.44% … 0.43%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.101 s             [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.43%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m2.105 s[22m[39m ± [32m6.566 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.41% ± 0.04%
    
      [34m█[39m[39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      2.1 s[90m         Histogram: frequency by time[39m        2.11 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m296.15 MiB[39m, allocs estimate[90m: [39m[33m4101768[39m.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread its own FMU, as they are not thread safe.
To spread the execution of a function to multiple threads, the library `Folds` can be used.


```julia
println("Multi Threaded")
@benchmark Folds.collect(runCalcFormatted(fmu, i) for (fmu, i) in zip(realFMUBatch, input_values))
```

    Multi Threaded
    




    BenchmarkTools.Trial: 3 samples with 1 evaluation per sample.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m2.099 s[22m[39m … [35m  2.120 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.46% … 0.38%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.101 s              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.39%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m2.107 s[22m[39m ± [32m11.612 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.41% ± 0.04%
    
      [34m█[39m[39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      2.1 s[90m          Histogram: frequency by time[39m        2.12 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m296.15 MiB[39m, allocs estimate[90m: [39m[33m4101783[39m.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `Threads.nthreads()`, this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` threads for the Julia process.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
unloadFMU(realFMU)
unloadFMU.(realFMUBatch)
```




    1-element Vector{Nothing}:
     nothing



### Summary

In this tutorial it is shown how multithreading with `Folds.jl` can be used to improve the performance for calculating a batch of FMUs.
