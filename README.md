![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/lite/fmijl_logo_640_320.png "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language which integrates FMI ([fmi-standard.org](http://fmi-standard.org/)): load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://ThummeTo.github.io/FMI.jl/dev) [![](https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml/badge.svg)]() 
<!--- [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ThummeTo.github.io/FMI.jl/stable) --->

## How can I use FMI.jl?
1. open a Julia-Command-Window, activate your prefered environment
1. goto package manager using ```]```
1. type ```add FMI``` or ```add "https://github.com/ThummeTo/FMI.jl"```
1. have a look inside the ```example``` folder

## How can I simulate a FMU and plot values?
```julia
# load and instantiate a FMU
myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU)

# simulate from t=0.0s until t=10.0s and record the FMU variable named "mass.s"
simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=["mass.s"])

# plot it!
fmiPlot(simData)

# free memory
fmiUnload(myFMU)
```

## What is currently supported in FMI.jl?
- the full FMI command set, including optional specials like getState, setState and getDirectionalDerivative
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- ...

## What is under development in FMI.jl?
- FMI 3.0 and SSP 1.0 support
- FMI Cross Checks
- more examples
- ...

## What Platforms are supported?
FMI.jl is tested (and testing) under Julia Version 1.5, 1.6 and latest on Windows (latest) and Ubuntu (latest). Mac should work, but untested.

## How to cite? Related publications?
Tobias Thummerer, Josef Kircher, Lars Mikelsons 2021 "NeuralFMU: Towards Structural Integration of FMUs into Neural Networks" (14th Modelica Conference, Preprint, Accepted) [arXiv:2109.04351](https://arxiv.org/abs/2109.04351)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 "Hybrid modeling of the human cardiovascular system using NeuralFMUs" (10th International Conference on Mathematical Modeling in Physical Sciences, Preprint, Accepted) [arXiv:2109.04880](https://arxiv.org/abs/2109.04880)

## Interested in Hybrid Modelling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).