![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png "FMI.jl Logo")
# FMI.jl
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://ThummeTo.github.io/FMI.jl/dev) [![](https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml/badge.svg)]() 
<!--- [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ThummeTo.github.io/FMI.jl/stable) --->


## Features
- 📚 free-to use libraray
- 📊 parameterization, simulation & plotting of CS- and ME-FMUs
- 🩺 event-handling for discontinuous ME-FMUs
- 🛠️ Supports Julia Version 1.6
- 🖥️ tested on :

| Windows | Ubuntu | IOS |
| ------- | ------ | --- |
| <img src="https://upload.wikimedia.org/wikipedia/commons/5/5f/Windows_logo_-_2012.svg"> | <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo-ubuntu_cof-orange-hex.svg/1200px-Logo-ubuntu_cof-orange-hex.svg.png" width = "80"> | <img src = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png" width = "80">|

## Documentation Overview
1. ```Intorduction```
2. ```Tutorials```
3. ```Examples```
4. ```Libary Funktions```
5. ```Relted Publications```

> continue to the [documentation](https://thummeto.github.io/FMI.jl/dev/)


## Get Started

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
- the full FMI 2.0.1 command set, including optional specials like getState, setState and getDirectionalDerivative
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- ...

## What is under development in FMI.jl?
- FMI 3.0 and SSP 1.0 support
- FMI Cross Checks
- more examples
- ...

## What Platforms are supported?
FMI.jl is tested (and testing) under Julia Versions 1.6 and *nightly* on Windows (latest) and Ubuntu (latest). Mac should work, but untested.

## How to cite? Related publications?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** In Martin Sjölund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Linköping, Sweden, September 20-24, 2021. Linköping University Electronic Press, Linköping (Linköping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** (10th International Conference on Mathematical Modeling in Physical Sciences, Preprint, Accepted) [arXiv:2109.04880](https://arxiv.org/abs/2109.04880)

## Interested in Hybrid Modelling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).
