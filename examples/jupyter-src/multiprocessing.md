# Multiprocessing
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
Parallelization can be achieved using multithreading or using multiprocessing. This example shows **multiprocessing**, check `multithreading.ipynb` for multithreading.
Advantage of multithreading is a lower communication overhead as well as lower RAM usage.
However in some cases multiprocessing can be faster as the garbage collector is not shared.


The model used is a one-dimensional spring pendulum with friction. The object-orientated structure of the *SpringFrictionPendulum1D* can be seen in the following graphic.

![svg](https://github.com/thummeto/FMI.jl/blob/main/docs/src/examples/pics/SpringFrictionPendulum1D.svg?raw=true)  


## Target group
The example is primarily intended for users who work in the field of simulations. The example wants to show how simple it is to use FMUs in Julia.


## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/jupyter-src/multiprocessing.md) corresponding to the notebook.  


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
@everywhere using DifferentialEquations
@everywhere using BenchmarkTools
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
    [33m[1m│ [22m[39m    [29] top-level scope
    [33m[1m│ [22m[39m   [90m    @[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mmacros.jl:200[24m[39m
    [33m[1m│ [22m[39m    [30] [0m[1meval[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [31] [0m[1minclude_string[22m[0m[1m([22m[90mmapexpr[39m::[0mtypeof(REPL.softscope), [90mmod[39m::[0mModule, [90mcode[39m::[0mString, [90mfilename[39m::[0mString[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2160[24m[39m
    [33m[1m│ [22m[39m    [32] [0m[1mexecute_request[22m[0m[1m([22m[90msocket[39m::[0mZMQ.Socket, [90mkernel[39m::[0mIJulia.Kernel, [90mmsg[39m::[0mIJulia.Msg[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4mexecute_request.jl:129[24m[39m
    [33m[1m│ [22m[39m    [33] [0m[1m#invokelatest#2[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:892[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [34] [0m[1minvokelatest[22m
    [33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:889[24m[39m[90m [inlined][39m
    [33m[1m│ [22m[39m    [35] [0m[1meventloop[22m[0m[1m([22m[90msocket[39m::[0mZMQ.Socket, [90mkernel[39m::[0mIJulia.Kernel[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4meventloop.jl:26[24m[39m
    [33m[1m│ [22m[39m    [36] [0m[1m(::IJulia.var"#40#43"{IJulia.Kernel})[22m[0m[1m([22m[0m[1m)[22m
    [33m[1m│ [22m[39m   [90m    @[39m [32mIJulia[39m [90mC:\Users\runneradmin\.julia\packages\IJulia\Vl5w1\src\[39m[90m[4meventloop.jl:71[24m[39m
    [33m[1m└ [22m[39m[90m@ Requires C:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\require.jl:51[39m
    

          From worker 3:	[33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mError requiring `FMIImport` from `FMIZoo`
          From worker 3:	[33m[1m│ [22m[39m  exception =
          From worker 3:	[33m[1m│ [22m[39m   UndefVarError: `fmi2Load` not defined
          From worker 3:	[33m[1m│ [22m[39m   Stacktrace:
          From worker 3:	[33m[1m│ [22m[39m     [1] [0m[1mgetproperty[22m[0m[1m([22m[90mx[39m::[0mModule, [90mf[39m::[0mSymbol[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mBase.jl:31[24m[39m
          From worker 3:	[33m[1m│ [22m[39m     [2] top-level scope
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:46[24m[39m
          From worker 3:	[33m[1m│ [22m[39m     [3] [0m[1meval[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m     [4] [0m[1meval[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:6[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m     [5] [0m[1m(::FMIZoo.var"#14#20")[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:101[24m[39m
          From worker 3:	[33m[1m│ [22m[39m     [6] [0m[1mmacro expansion[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m[4mtiming.jl:395[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m     [7] [0m[1merr[22m[0m[1m([22m[90mf[39m::[0mAny, [90mlistener[39m::[0mModule, [90mmodname[39m::[0mString, [90mfile[39m::[0mString, [90mline[39m::[0mAny[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:47[24m[39m
          From worker 3:	[33m[1m│ [22m[39m     [8] [0m[1m(::FMIZoo.var"#13#19")[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:100[24m[39m
          From worker 3:	[33m[1m│ [22m[39m     [9] [0m[1mwithpath[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpath[39m::[0mString[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:37[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [10] [0m[1m(::FMIZoo.var"#12#18")[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:99[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [11] [0m[1mlistenpkg[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpkg[39m::[0mBase.PkgId[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:20[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [12] [0m[1mmacro expansion[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:98[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [13] [0m[1m__init__[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:42[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [14] [0m[1mrun_module_init[22m[0m[1m([22m[90mmod[39m::[0mModule, [90mi[39m::[0mInt64[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1197[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [15] [0m[1mregister_restored_modules[22m[0m[1m([22m[90msv[39m::[0mCore.SimpleVector, [90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1185[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [16] [0m[1m_include_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString, [90mocachepath[39m::[0mString, [90mdepmods[39m::[0mVector[90m{Any}[39m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1129[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [17] [0m[1m_require_search_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90msourcepath[39m::[0mString, [90mbuild_id[39m::[0mUInt128[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1655[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [18] [0m[1m_require[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2012[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [19] [0m[1m__require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1886[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [20] [0m[1m#invoke_in_world#3[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [21] [0m[1minvoke_in_world[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [22] [0m[1m_require_prelocked[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1877[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [23] [0m[1m_require_prelocked[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1876[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [24] [0m[1mmacro expansion[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mlock.jl:270[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [25] [0m[1mrequire[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1871[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [26] [0m[1m(::Distributed.var"#2#4"{Base.PkgId})[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mDistributed.jl:83[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [27] [0m[1m#invokelatest#2[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:892[24m[39m[90m [inlined][39m
          From worker 3:	[33m[1m│ [22m[39m    [28] [0m[1minvokelatest[22m[0m[1m([22m::[0mAny[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4messentials.jl:889[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [29] [0m[1m(::Distributed.var"#122#124"{Distributed.CallWaitMsg})[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:303[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [30] [0m[1mrun_work_thunk[22m[0m[1m([22m[90mthunk[39m::[0mDistributed.var"#122#124"[90m{Distributed.CallWaitMsg}[39m, [90mprint_error[39m::[0mBool[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:70[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [31] [0m[1mrun_work_thunk[22m[0m[1m([22m[90mrv[39m::[0mDistributed.RemoteValue, [90mthunk[39m::[0mFunction[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:79[24m[39m
          From worker 3:	[33m[1m│ [22m[39m    [32] [0m[1m(::Distributed.var"#108#110"{Distributed.RemoteValue, Distributed.var"#122#124"{Distributed.CallWaitMsg}})[22m[0m[1m([22m[0m[1m)[22m
          From worker 3:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:88[24m[39m
          From worker 3:	[33m[1m└ [22m[39m[90m@ Requires C:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\require.jl:51[39m
          From worker 2:	[33m[1m┌ [22m[39m[33m[1mWarning: [22m[39mError requiring `FMIImport` from `FMIZoo`
          From worker 2:	[33m[1m│ [22m[39m  exception =
          From worker 2:	[33m[1m│ [22m[39m   UndefVarError: `fmi2Load` not defined
          From worker 2:	[33m[1m│ [22m[39m   Stacktrace:
          From worker 2:	[33m[1m│ [22m[39m     [1] [0m[1mgetproperty[22m[0m[1m([22m[90mx[39m::[0mModule, [90mf[39m::[0mSymbol[0m[1m)[22m

    
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mBase.jl:31[24m[39m
          From worker 2:	[33m[1m│ [22m[39m     [2] top-level scope
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:46[24m[39m
          From worker 2:	[33m[1m│ [22m[39m     [3] [0m[1meval[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mboot.jl:385[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m     [4] [0m[1meval[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:6[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m     [5] [0m[1m(::FMIZoo.var"#14#20")[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:101[24m[39m
          From worker 2:	[33m[1m│ [22m[39m     [6] [0m[1mmacro expansion[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m[4mtiming.jl:395[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m     [7] [0m[1merr[22m[0m[1m([22m[90mf[39m::[0mAny, [90mlistener[39m::[0mModule, [90mmodname[39m::[0mString, [90mfile[39m::[0mString, [90mline[39m::[0mAny[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:47[24m[39m
          From worker 2:	[33m[1m│ [22m[39m     [8] [0m[1m(::FMIZoo.var"#13#19")[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:100[24m[39m
          From worker 2:	[33m[1m│ [22m[39m     [9] [0m[1mwithpath[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpath[39m::[0mString[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:37[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [10] [0m[1m(::FMIZoo.var"#12#18")[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:99[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [11] [0m[1mlistenpkg[22m[0m[1m([22m[90mf[39m::[0mAny, [90mpkg[39m::[0mBase.PkgId[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [36mRequires[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:20[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [12] [0m[1mmacro expansion[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mC:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\[39m[90m[4mrequire.jl:98[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [13] [0m[1m__init__[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [35mFMIZoo[39m [90mC:\Users\runneradmin\.julia\packages\FMIZoo\Yw7SL\src\[39m[90m[4mFMIZoo.jl:42[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [14] [0m[1mrun_module_init[22m[0m[1m([22m[90mmod[39m::[0mModule, [90mi[39m::[0mInt64[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1197[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [15] [0m[1mregister_restored_modules[22m[0m[1m([22m[90msv[39m::[0mCore.SimpleVector, [90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1185[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [16] [0m[1m_include_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90mpath[39m::[0mString, [90mocachepath[39m::[0mString, [90mdepmods[39m::[0mVector[90m{Any}[39m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1129[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [17] [0m[1m_require_search_from_serialized[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90msourcepath[39m::[0mString, [90mbuild_id[39m::[0mUInt128[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1655[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [18] [0m[1m_require[22m[0m[1m([22m[90mpkg[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:2012[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [19] [0m[1m__require_prelocked[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId, [90menv[39m::[0mNothing[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1886[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [20] [0m[1m#invoke_in_world#3[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:926[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [21] [0m[1minvoke_in_world[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:923[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [22] [0m[1m_require_prelocked[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1877[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [23] [0m[1m_require_prelocked[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mloading.jl:1876[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [24] [0m[1mmacro expansion[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4mlock.jl:270[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [25] [0m[1mrequire[22m[0m[1m([22m[90muuidkey[39m::[0mBase.PkgId[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4mloading.jl:1871[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [26] [0m[1m(::Distributed.var"#2#4"{Base.PkgId})[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mDistributed.jl:83[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [27] [0m[1m#invokelatest#2[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90m.\[39m[90m[4messentials.jl:892[24m[39m[90m [inlined][39m
          From worker 2:	[33m[1m│ [22m[39m    [28] [0m[1minvokelatest[22m[0m[1m([22m::[0mAny[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [90mBase[39m [90m.\[39m[90m[4messentials.jl:889[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [29] [0m[1m(::Distributed.var"#122#124"{Distributed.CallWaitMsg})[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:303[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [30] [0m[1mrun_work_thunk[22m[0m[1m([22m[90mthunk[39m::[0mDistributed.var"#122#124"[90m{Distributed.CallWaitMsg}[39m, [90mprint_error[39m::[0mBool[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:70[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [31] [0m[1mrun_work_thunk[22m[0m[1m([22m[90mrv[39m::[0mDistributed.RemoteValue, [90mthunk[39m::[0mFunction[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:79[24m[39m
          From worker 2:	[33m[1m│ [22m[39m    [32] [0m[1m(::Distributed.var"#108#110"{Distributed.RemoteValue, Distributed.var"#122#124"{Distributed.CallWaitMsg}})[22m[0m[1m([22m[0m[1m)[22m
          From worker 2:	[33m[1m│ [22m[39m   [90m    @[39m [32mDistributed[39m [90mC:\hostedtoolcache\windows\julia\1.10.11\x64\share\julia\stdlib\v1.10\Distributed\src\[39m[90m[4mprocess_messages.jl:88[24m[39m
          From worker 2:	[33m[1m└ [22m[39m[90m@ Requires C:\Users\runneradmin\.julia\packages\Requires\1eCOK\src\require.jl:51[39m
    

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
          From worker 2:	Hello World!
          From worker 3:	Hello World!
    

### Simulation setup

Next, the batch size and input values are defined.


```julia

# Best if batchSize is a multiple of the threads/cores
batchSize = 16

# Define an array of arrays randomly
input_values = collect(collect.(eachrow(rand(batchSize,2))))
```




    16-element Vector{Vector{Float64}}:
     [0.02442851601728213, 0.5610568135245778]
     [0.2732873909568746, 0.04614190794982875]
     [0.03385047786870887, 0.4571891493493089]
     [0.8906603612894561, 0.7344596536944313]
     [0.49647816122199706, 0.46296522873718027]
     [0.7331804487791137, 0.43739324716893535]
     [0.2782227370140673, 0.12982170806943394]
     [0.14687063914806076, 0.8824321610028086]
     [0.35952608506115613, 0.059645041335219195]
     [0.7050583738230213, 0.04781370812475727]
     [0.05226678619854597, 0.5484899029312109]
     [0.5484869235725381, 0.9625119887878714]
     [0.9325960059993951, 0.10178231394399129]
     [0.23323682197286766, 0.5345176045739863]
     [0.5227156311468691, 0.5111694634124148]
     [0.14418229144725647, 0.014453796321238332]



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




    BenchmarkTools.Trial: 3 samples with 1 evaluation per sample.
     Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m2.135 s[22m[39m … [35m  2.162 s[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.52% … 1.08%
     Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.140 s              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.52%
     Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m2.145 s[22m[39m ± [32m14.303 ms[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.69% ± 0.35%
    
      [34m█[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m█[39m [39m 
      [34m█[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[32m▁[39m[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m█[39m [39m▁
      2.13 s[90m         Histogram: frequency by time[39m        2.16 s [0m[1m<[22m
    
     Memory estimate[90m: [39m[33m296.15 MiB[39m, allocs estimate[90m: [39m[33m4101765[39m.



### Single Threaded Batch Execution
To compute a batch we can collect multiple evaluations. In a single threaded context we can use the same FMU for every call.


```julia
println("Single Threaded")
@benchmark collect(runCalcFormatted(SharedModule.model_fmu, i) for i in input_values)
```

    Single Threaded
    




    BenchmarkTools.Trial: 1 sample with 1 evaluation per sample.
     Single result which took [34m34.864 s[39m (0.47% GC) to evaluate,
     with a memory estimate of [33m4.63 GiB[39m, over [33m65628228[39m allocations.



### Multithreaded Batch Execution
In a multithreaded context we have to provide each thread its own FMU, as they are not thread safe.
To spread the execution of a function to multiple processes, the function `pmap` can be used.


```julia
println("Multi Threaded")
@benchmark pmap(i -> runCalcFormatted(SharedModule.model_fmu, i), input_values)
```

    Multi Threaded
    




    BenchmarkTools.Trial: 1 sample with 1 evaluation per sample.
     Single result which took [34m17.885 s[39m (0.00% GC) to evaluate,
     with a memory estimate of [33m126.09 KiB[39m, over [33m2413[39m allocations.



As you can see, there is a significant speed-up in the median execution time. But: The speed-up is often much smaller than `n_procs` (or the number of physical cores of your CPU), this has different reasons. For a rule of thumb, the speed-up should be around `n/2` on a `n`-core-processor with `n` Julia processes.

### Unload FMU

After calculating the data, the FMU is unloaded and all unpacked data on disc is removed.


```julia
@everywhere unloadFMU(SharedModule.model_fmu)
```

### Summary

In this tutorial it is shown how multiprocessing with `Distributed.jl` can be used to improve the performance for calculating a batch of FMUs.
