# FMU Parameter Optimization
Tutorial by Tobias Thummerer

## License


```julia
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.
```

## Introduction to the example
This example shows how a parameter optimization can be set up for a FMU. The goal is to fit FMU parameters (and initial states), so that a reference trajectory is fit as good as possible.

Note, that this tutorial covers optimization *without* gradient information. Basically, *FMI.jl* supports gradient based optimization, too.

## Other formats
Besides, this [Jupyter Notebook](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameter_optimization.ipynb) there is also a [Julia file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameter_optimization.jl) with the same name, which contains only the code cells and for the documentation there is a [Markdown file](https://github.com/thummeto/FMI.jl/blob/examples/examples/src/parameter_optimization.md) corresponding to the notebook.  

## Getting started

### Installation prerequisites
|     | Description                       | Command                   |
|:----|:----------------------------------|:--------------------------|
| 1.  | Enter Package Manager via         | ]                         |
| 2.  | Install FMI via                   | add FMI                   | 
| 3.  | Install FMIZoo via                | add FMIZoo                | 
| 4.  | Install Optim  via                | add Optim                 | 
| 5.  | Install Plots  via                | add Plots                 | 

## Code section

To run the example, the previously installed packages must be included. 


```julia
# imports
using FMI
using FMIZoo
using Optim
using Plots
```

### Simulation setup

Next, the start time and end time of the simulation are set.


```julia
tStart = 0.0
tStop = 5.0
tStep = 0.1
tSave = tStart:tStep:tStop
```

### Import FMU

In the next lines of code the FMU model from *FMIZoo.jl* is loaded and the information about the FMU is shown.


```julia
# we use an FMU from the FMIZoo.jl
fmu = fmiLoad("SpringPendulum1D", "Dymola", "2022x"; type=:ME)
fmiInfo(fmu)
```

Now, the optimization objective (the function to minimize) needs to be defined. In this case, we just want to do a simulation and compare it to a regular `sin` wave.


```julia
s_tar = 1.0 .+ sin.(tSave)

# a function to simulate the FMU for given parameters
function simulateFMU(p)
    s0, v0, c, m = p # unpack parameters: s0 (start position), v0 (start velocity), c (spring constant) and m (pendulum mass)

    # pack the parameters into a dictionary
    paramDict = Dict{String, Any}()
    paramDict["spring.c"] = c 
    paramDict["mass.m"] = m

    # pack the start state
    x0 = [s0, v0]

    # simulate with given start stae and parameters
    sol = fmiSimulate(fmu, (tStart, tStop); x0=x0, parameters=paramDict, saveat=tSave)

    # get state with index 1 (the position) from the solution
    s_res = fmiGetSolutionState(sol, 1; isIndex=true) 

    return s_res
end

# the optimization objective
function objective(p)
    s_res = simulateFMU(p)

    # return the position error sum between FMU simulation (s_res) and target (s_tar)
    return sum(abs.(s_tar .- s_res))    
end
```

Now let's see how far we are away for our guess parameters:


```julia
s0 = 0.0 
v0 = 0.0
c = 1.0
m = 1.0 
p = [s0, v0, c, m]

obj_before = objective(p) # not really good!
```

Let's have a look on the differences:


```julia
s_fmu = simulateFMU(p); # simulate the position

plot(tSave, s_fmu; label="FMU")
plot!(tSave, s_tar; label="Optimization target")
```

Not that good. So let's do a bit of optimization!


```julia
opt = Optim.optimize(objective, p; iterations=250) # do max. 250 iterations
obj_after = opt.minimum # much better!
p_res = opt.minimizer # the optimized parameters
```

Looks promising, let's have a look on the results plot:


```julia
s_fmu = simulateFMU(p_res); # simulate the position

plot(tSave, s_fmu; label="FMU")
plot!(tSave, s_tar; label="Optimization target")
```

Actually a pretty fit! If you have higher requirements, check out the *Optim.jl* library.

### Summary

This tutorial showed how a parameter (and start value) optimization can be performed on a FMU with a gradient free optimizer. This tutorial will be extended soon to further show how convergence for large parameter spaces can be improoved!
