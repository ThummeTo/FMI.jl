![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png?raw=true "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is a free-to-use software library for the Julia programming language which integrates the **F**unctional **M**ock-Up **I**nterface ([fmi-standard.org](http://fmi-standard.org/)): load or create, parameterize, simulate and plot FMUs seamlessly inside the Julia programming language!

[![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://ThummeTo.github.io/FMI.jl/dev) 
[![Run Tests](https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml)
[![Run Examples](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml)
[![Build Docs](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml)
[![Coverage](https://codecov.io/gh/ThummeTo/FMI.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ThummeTo/FMI.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


## How can I use FMI.jl?
1. Open a Julia-REPL, activate your preferred environment.
1. Goto Package-Manager (if not already), install FMI.jl.
    ```julia
    julia> ]

    (@v1.6) pkg> add FMI
    ```

    If you want to check that everything works correctly, you can run the tests bundled with FMI.jl:
    ```julia
    julia> using Pkg

    julia> Pkg.test("FMI")
    ```

    Additionally, you can check the version of FMI.jl that you have installed with the ```status``` command.
    ```julia
    julia> ]
    (@v1.6) pkg> status FMI
    ```
1. Have a look inside the [examples folder](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) in the examples branch or the [examples section](https://thummeto.github.io/FMI.jl/dev/examples/overview/) of the documentation. All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).

## How can I simulate a FMU and plot values?
```julia
using FMI, Plots

# load and instantiate a FMU
myFMU = fmiLoad(pathToFMU)

# simulate from t=0.0s until t=10.0s and record the FMU variable named "mass.s"
simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=["mass.s"])

# plot it!
fmiPlot(simData)

# free memory
fmiUnload(myFMU)
```

## What is currently supported in FMI.jl?
- importing the full FMI 2.0.3 and FMI 3.0.0 command set, including optional specials like `fmi2GetState`, `fmi2SetState` and `fmi2GetDirectionalDerivatives`
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for imported discontinuous ME-FMUs

|                                   | **FMI2.0.3** |        | **FMI3.0** |        |
|-----------------------------------|--------------|--------|------------|--------|
|                                   | Import       | Export | Import     | Export |
| CS                                | ✓✓           | ~~     | ✓          | ~      |
| ME (continuous)                   | ✓✓           | ✓✓     | ✓          | ~      |
| ME (discontinuous)                | ✓✓           | ✓✓     | ✓          | ~      |
| SE                 		             | -            | -      | ✓          | ~      |
| Explicit solvers                  | ✓✓           | ✓✓     | ✓          | ~      |
| Implicit solvers (autodiff=false) | ✓✓           | ~~     | ✓          | ~      |
| Implicit solvers (autodiff=true)  | ✓            | ~~     | ~~         | ~      |
| get/setState                      | ✓✓           | ~      | ✓          | ~      |
| getDirectionalDerivatives         | ✓✓           | ~      | ✓          | ~      |
| getAdjointDerivatives             | -            | -      | ✓          | ~      |

✓✓ supported & tested

✓  beta supported, untested

~~ work in progress

~  planned

\-  not supported by the corresponding FMI standard

x  not planned

## What FMI.jl-Library to use?
![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/docs/src/assets/FMI_JL_family.png?raw=true "FMI.jl Family")
To keep dependencies nice and clean, the original package [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) had been split into new packages:
- [*FMI.jl*](https://github.com/ThummeTo/FMI.jl): High level loading, manipulating, saving or building entire FMUs from scratch
- [*FMIImport.jl*](https://github.com/ThummeTo/FMIImport.jl): Importing FMUs into Julia
- [*FMIExport.jl*](https://github.com/ThummeTo/FMIExport.jl): Exporting stand-alone FMUs from Julia Code
- [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl): C-code wrapper for the FMI-standard
- [*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl): Compiler/Compilation dependencies for FMIExport.jl
- [*FMIFlux.jl*](https://github.com/ThummeTo/FMIFlux.jl): Machine Learning with FMUs (differentiation over FMUs)
- [*FMIZoo.jl*](https://github.com/ThummeTo/FMIZoo.jl): A collection of testing and example FMUs

## What is further under development in FMI.jl?
- FMI Cross Checks (as soon as the successor is available)
- nice documentation & doc-strings
- more examples/tutorials
- ...

## What is planned for FMI.jl?
- SSP 1.0 support
- ...

## What Platforms are supported?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is tested (and testing) under Julia Versions *1.6.5 LTS* (64-bit) and *latest* (64-bit) on Windows *latest* (64-bit) and Ubuntu *latest* (64-bit). Mac and Julia (32-bit) should work, but untested.

## How to cite? Related publications?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** Martin Sjölund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Linköping, Sweden, September 20-24, 2021. Linköping University Electronic Press, Linköping (Linköping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** Journal of Physics: Conference Series 2090, 1, 012155. [DOI: 10.1088/1742-6596/2090/1/012155](https://doi.org/10.1088/1742-6596/2090/1/012155)

## Interested in Hybrid Modelling in Julia using FMUs?
See [*FMIFlux.jl*](https://github.com/ThummeTo/FMIFlux.jl).
