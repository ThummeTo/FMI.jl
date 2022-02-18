![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language which integrates FMI ([fmi-standard.org](http://fmi-standard.org/)): load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!

**Please notice: A detailed documentation and well formatted doc-strings are under construction and well be published soon.**

[![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://ThummeTo.github.io/FMI.jl/dev) 
[![CI Testing](https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions)
[![Coverage](https://codecov.io/gh/ThummeTo/FMI.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ThummeTo/FMI.jl)


## How can I use FMI.jl?
1. open a Julia-Command-Window, activate your preferred environment
1. goto package manager using ```]```
1. type ```add FMI``` or ```add "https://github.com/ThummeTo/FMI.jl"```
1. have a look inside the ```example``` folder

## How can I simulate a FMU and plot values?
```julia
# load and instantiate a FMU
myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU)

# simulate from t=0.0s until t=10.0s and record the FMU variable named "mass.s"
success, simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=["mass.s"])

# plot it!
plot(myFMU, ["mass.s"], simData)

# free memory
fmiUnload(myFMU)
```

## What is currently supported in FMI.jl?
- importing the full FMI 2.0.3 command set, including optional specials like getState, setState and getDirectionalDerivative
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for imported discontinuous ME-FMUs

|                           | **FMI2.0.3** |        | **FMI3.0 beta** |        |
|---------------------------|--------------|--------|-----------------|--------|
|                           | Import       | Export | Import          | Export |
| CS                        | ✓✓           | ~~     | ~~              | ~      |
| ME (continuous)           | ✓✓           | ✓✓     | ~~              | ~      |
| ME (discontinuous)        | ✓✓           | ✓✓     | ~~              | ~      |
| Explicit solvers          | ✓✓           | ~~     | ~~              | ~      |
| Implicit solvers (AD)     | ✓✓           | ~~     | ~~              | ~      |
| get/setState              | ✓✓           | ~      | ~~              | ~      |
| getDirectionalDerivatives | ✓✓           | ~      | ~~              | ~      |
| getAjointDerivatives      | -            | -      | ~~              | ~      |

✓✓ supported & tested

✓  supported (beta)

~~ work in progress

~  planned

\-  not supported by the corresponding FMI standard

x  not planned

## What FMI.jl-Library to use?
![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/docs/src/assets/FMI_JL_family.png "FMI.jl Family")
To keep dependencies nice and clean, the old FMI.jl had been split into new packages:
- **FMI.jl:** High level loading, manipulationg, saving or building entire FMUs from scratch
- **FMIImport.jl:** Importing FMUs into Julia
- **FMIExport.jl:** Exporting FMUs from Julia Code
- **FMICore.jl:** C-code wrapper for the FMI-standard
- **FMIBuild.jl:** Compiler dependencies for FMIExport.jl, holds dependencies not suitable for exported FMUs
- **FMIFlux.jl:** Machine Learning with FMUs (differentiation over FMUs)

## What is further under development in FMI.jl?
- FMI Cross Checks
- more examples
- ...

## What is planned for FMI.jl?
- SSP 1.0 support
- more examples
- ...

## What Platforms are supported?
FMI.jl is tested (and testing) under Julia Versions *1.6.5 LTS* (64-bit) and *latest* (64-bit) on Windows *latest* (64-bit) and Ubuntu *latest* (64-bit). Mac and Julia (32-bit) should work, but untested.

## How to cite? Related publications?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** Martin Sjölund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Linköping, Sweden, September 20-24, 2021. Linköping University Electronic Press, Linköping (Linköping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** Journal of Physics: Conference Series 2090, 1, 012155. [DOI: 10.1088/1742-6596/2090/1/012155](https://doi.org/10.1088/1742-6596/2090/1/012155)

## Interested in Hybrid Modelling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).
