![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png?raw=true "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is a free-to-use software library for the Julia programming language which integrates the **F**unctional **M**ock-Up **I**nterface ([fmi-standard.org](http://fmi-standard.org/)): load or create, parameterize, differentiate, simulate and plot FMUs seamlessly inside the Julia programming language!

[![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://ThummeTo.github.io/FMI.jl/dev) 
[![Test (latest)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLatest.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLatest.yml)
[![Test (LTS)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLTS.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLTS.yml)
[![FMI2 Cross Checks (latest)](https://github.com/ThummeTo/FMI.jl/actions/workflows/CrossChecks.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/CrossChecks.yml)
[![Examples (latest)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml)
[![Build Docs](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml)
[![Run PkgEval](https://github.com/ThummeTo/FMI.jl/actions/workflows/Eval.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Eval.yml)
[![Coverage](https://codecov.io/gh/ThummeTo/FMI.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ThummeTo/FMI.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


## How can I use FMI.jl?
1\. Open a Julia-REPL, switch to package mode using `]`, activate your preferred environment.

2\. Install [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):
```julia-repl
(@v1.X) pkg> add FMI
```

3\. If you want to check that everything works correctly, you can run the tests bundled with [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):
```julia-repl
(@v1.X) pkg> test FMI
```

4\. Have a look inside the [examples folder](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) in the examples branch or the [examples section](https://thummeto.github.io/FMI.jl/dev/examples/overview/) of the documentation. All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).

## How can I simulate a FMU and plot values?
```julia
using FMI, Plots

# load and instantiate a FMU
myFMU = fmiLoad(pathToFMU)

# simulate from t=0.0s until t=10.0s and record the FMU variable named "mass.s"
simData = fmiSimulate(myFMU, (0.0, 10.0); recordValues=["mass.s"])

# plot it!
fmiPlot(simData)

# free memory
fmiUnload(myFMU)
```

## What is currently supported in FMI.jl?
- importing the full FMI 2.0.3 and FMI 3.0.0 command set, including optional specials like `fmi2GetState`, `fmi2SetState` and `fmi2GetDirectionalDerivatives`
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for imported discontinuous ME-FMUs

|                                   | **FMI2.0.3** |        | **FMI3.0** |        | **SSP1.0** |        |
|-----------------------------------|--------------|--------|------------|--------|------------|--------|
|                                   | Import       | Export | Import     | Export | Import     | Export |
| CS                                | ✔️✔️         | 🚧     | ✔️          | 📅     | 📅         | 📅      |
| ME (continuous)                   | ✔️✔️         | ✔️✔️   | 🚧          | 📅     | 📅         | 📅      |
| ME (discontinuous)                | ✔️✔️         | ✔️✔️   | 🚧          | 📅     | 📅         | 📅      |
| SE                 		    | 🚫           | 🚫     | 🚧          | 📅     | 🚫         | 🚫     |
| Explicit solvers                  | ✔️✔️         | ✔️✔️   | ✔️          | 📅     | 📅         | 📅      |
| Implicit solvers (autodiff=false) | ✔️✔️         | 🚧     | ✔️          | 📅     | 📅         | 📅      |
| Implicit solvers (autodiff=true)  | ✔️✔️         | 🚧     | 🚧          | 📅     | 📅         | 📅      |
| get/setState                      | ✔️✔️         | 📅     | ✔️          | 📅     | 🚫         | 🚫      |
| getDirectionalDerivatives         | ✔️✔️         | 📅     | ✔️          | 📅     | 🚫         | 🚫      |
| getAdjointDerivatives             | 🚫           | 🚫     | ✔️          | 📅     | 🚫         | 🚫     |
| FMI Cross Checks                  | ✔️✔️         | 📅     | 📅          | 📅     | 🚫         | 🚫      |

✔️✔️ supported & tested

✔️  beta supported (implemented), but untested

🚧 work in progress

📅  planned

🚫  not supported by the corresponding FMI standard (not applicable)

❌  not planned

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

## What Platforms are supported?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is tested (and testing) under Julia Versions *1.6 LTS* (64-bit) and *latest* (64-bit) on Windows *latest* (64-bit) and Ubuntu *latest* (64-bit). Mac and Julia (32-bit) should work, but untested. For the best performance, we recommend using Julia >= 1.7.

## How to cite?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** Martin Sjölund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Linköping, Sweden, September 20-24, 2021. Linköping University Electronic Press, Linköping (Linköping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

## Related publications?
Tobias Thummerer, Johannes Stoljar and Lars Mikelsons. 2022. **NeuralFMU: presenting a workflow for integrating hybrid NeuralODEs into real-world applications.** Electronics 11, 19, 3202. [DOI: 10.3390/electronics11193202](https://doi.org/10.3390/electronics11193202)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons. 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** Journal of Physics: Conference Series 2090, 1, 012155. [DOI: 10.1088/1742-6596/2090/1/012155](https://doi.org/10.1088/1742-6596/2090/1/012155)

## Notes for contributors
Contributors are welcome. Before contributing, please read, understand and follow the [Contributor's Guide on Collaborative Practices for Community Packages](https://github.com/SciML/ColPrac). 
During development of new implementations or optimizations on exisitng code, one will have to make design decissions that influence the library performance and usability. The following priorization should be the basis for decision-making:
- **#1 Compliance with standard:** It is the highest priority to be compliant with the FMI standard ([fmi-standard.org](http://fmi-standard.org/)). Identifiers described in the standard must be used. Topologies should follow the specification as far as the possibilities of the Julia programming language allows.
- **#2 Performance:** Because [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is a simulation tool, performance is very important. This applies to the efficient use of CPU and GPU, but also the conscientious use of RAM and disc space.
- **#3 Usability:** The library should be as usable as possible, as long as being fully compliant with the FMI standard.

## Interested in Hybrid Modelling in Julia using FMUs?
See [*FMIFlux.jl*](https://github.com/ThummeTo/FMIFlux.jl).
