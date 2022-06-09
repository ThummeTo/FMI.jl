# Manipulate a function
Tutorial by Jonas Wilfert, Tobias Thummerer

## License
Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar, Jonas Wilfert

Licensed under the MIT license. See [LICENSE](https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

## Motivation
This Julia Package *FMI.jl* is motivated by the use of simulation models in Julia. Here the FMI specification is implemented. FMI (*Functional Mock-up Interface*) is a free standard ([fmi-standard.org](http://fmi-standard.org/)) that defines a container and an interface to exchange dynamic models using a combination of XML files, binaries and C code zipped into a single file. The user can thus use simulation models in the form of an FMU (*Functional Mock-up Units*). Besides loading the FMU, the user can also set values for parameters and states and simulate the FMU both as co-simulation and model exchange simulation.

## Introduction to the example
This example shows how to parallelize the computation of an FMU in FMI.jl. We can compute a batch of FMU-evaluations in parallel with different initial settings.
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multithreading**, check `distributed.ipynb` for multiprocessing.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/main/example/parallel.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/main/example/parallel.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/parallel.md) corresponding to the notebook.  


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

Checking the amount of threads:


```julia
Threads.nthreads()
```




    1



### Simulation setup

Next, the start time and end time of the simulation are set. Here we also decide the size of the batch.


```julia
t_start = 0.0
t_step = 0.1
t_stop = 10.0
tspan = (t_start, t_stop)
tData = collect(t_start:t_step:t_stop)

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))

```




    16-element Vector{Vector{Float64}}:
     [0.7629844945301301, 0.3537198584927763]
     [0.4664106037618314, 0.4523486687565046]
     [0.0523533214734031, 0.9896556002676622]
     [0.9986690786055015, 0.9644758352412715]
     [0.20487381010138317, 0.7355642361985026]
     [0.3168523873602296, 0.3766700340248357]
     [0.26916336433610155, 0.7808085720860316]
     [0.9815989075932303, 0.4627220637302396]
     [0.6526009420034311, 0.8457886921949676]
     [0.6858930145471303, 0.024883478950249227]
     [0.02813925278418239, 0.5537248366875844]
     [0.9818660410253524, 0.6690071633660948]
     [0.7479314446641203, 0.8900059621781162]
     [0.290489198784079, 0.5288057278088896]
     [0.8171770300422248, 0.17394398355924556]
     [0.15129906880193134, 0.7782623879994741]



We need to instantiate one FMU for each parallel execution, as they cannot share state.


```julia
realFMU = fmiLoad("SpringPendulum1D", "Dymola", "2022x")
fmiInstantiate!(realFMU)


realFMUBatch = [fmiLoad("SpringPendulum1D", "Dymola", "2022x") for _ in 1:batchSize]
fmiInstantiate!.(realFMUBatch)
```

    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_AWoaxU/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_AWoaxU/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_MwSzGT/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_MwSzGT/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_uPsa3U/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_uPsa3U/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_AsC5yU/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_AsC5yU/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_bPPCxW/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_bPPCxW/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_vvaMhW/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_vvaMhW/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_RJ3bEU/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_RJ3bEU/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_gpxyPV/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_gpxyPV/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_E2P63U/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_E2P63U/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_0yiJpW/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_0yiJpW/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_fpvhgW/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_fpvhgW/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_UPha0X/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_UPha0X/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_NMfaIT/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_NMfaIT/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_N0oxdV/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_N0oxdV/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_oV2yQT/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_oV2yQT/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_NOeiVX/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_NOeiVX/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193
    ┌ Info: fmi2Unzip(...): Successfully unzipped 153 files at `/tmp/fmijl_MVb9UW/SpringPendulum1D`.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:75
    ┌ Info: fmi2Load(...): FMU resources location is `file:////tmp/fmijl_MVb9UW/SpringPendulum1D/resources`
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:190
    ┌ Info: fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified.
    └ @ FMIImport /home/runner/.julia/packages/FMIImport/DJ6oi/src/FMI2_ext.jl:193





    16-element Vector{FMU2Component}:
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005857c00
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005857840
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005ac3e50
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000052a6ee0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005c466c0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005c9d1c0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005797d00
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000057aa010
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005295020
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005969ec0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000052b54c0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005607480
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000055f0ad0
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000052a4280
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x0000000005298180
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing
     FMU:            SpringPendulum1D
    InstanceName:   [not defined]
    Address:        Ptr{Nothing} @0x00000000055ee260
    State:          fmi2ComponentStateInstantiated
    Logging:        false
    FMU time:       -Inf
    FMU states:     nothing



We define a helper function to calculate the FMU and combine it into an Matrix.


```julia
function runCalcFormatted(fmu::FMU2, x0::Vector{Float64}, recordValues::Vector{String}=["mass.s", "mass.v"])
    data = fmiSimulateME(fmu, t_start, t_stop; recordValues=recordValues, saveat=tData, x0=x0, showProgress=false, dtmax=1e-4)
    return reduce(hcat, data.states.u)
end
```




    runCalcFormatted (generic function with 2 methods)



Running a single evaluation is pretty quick, therefore the speed can be better tested with BenchmarkTools.


```julia
@benchmark data = runCalcFormatted(realFMU, rand(2))
```




    BenchmarkTools.Trial: 16 samples with 1 evaluation.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m311.346 ms[22m[39m … [35m329.313 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m6.23% … 5.94%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m315.051 ms               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m6.25%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m316.322 ms[22m[39m ± [32m  5.263 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m6.64% ± 0.98%
    
      [39m█[39m█[39m [39m [39m [39m [39m▁[39m▁[39m [39m [39m▁[39m▁[34m [39m[39m▁[39m▁[39m [39m▁[32m [39m[39m▁[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m [39m 
      [39m█[39m█[39m▁[39m▁[39m▁[39m▁[39m█[39m█[39m▁[39m▁[39m█[39m█[34m▁[39m[39m█[39m█[39m▁[39m█[32m▁[39m[39m█[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      311 ms[90m           Histogram: frequency by time[39m          329 ms [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m146.80 MiB[39m, allocs estimate[90m: [39m[33m3002434[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(realFMU, i) for i in input_values)
```

    Single Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m5.073 s[39m (7.25% GC) to evaluate,
     with a memory estimate of [33m2.29 GiB[39m, over [33m48038932[39m allocations.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread it's own fmu, as they are not thread safe.
To spread the execution of a function to multiple threads, the library `Folds` can be used.


```julia
println("Multi Threaded")
@benchmark Folds.collect(runCalcFormatted(fmu, i) for (fmu, i) in zip(realFMUBatch, input_values))
```

    Multi Threaded





    BenchmarkTools.Trial: 1 sample with 1 evaluation.
     Single result which took [34m5.052 s[39m (7.25% GC) to evaluate,
     with a memory estimate of [33m2.29 GiB[39m, over [33m48039014[39m allocations.



### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
fmiUnload(realFMU)
fmiUnload.(realFMUBatch)
```




    16-element Vector{Nothing}:
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing
     nothing



### Summary

In this tutorial it is shown how multi threading with `Folds.jl` can be used to improve the performance for calculating a Batch of FMUs.
