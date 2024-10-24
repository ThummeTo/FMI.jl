![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png?raw=true "FMI.jl Logo")
# FMI.jl

## What is FMI.jl?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is a free-to-use software library for the Julia programming language which integrates the **F**unctional **M**ock-Up **I**nterface ([fmi-standard.org](https://fmi-standard.org/)): load or create, parameterize, differentiate, linearize, simulate and plot FMUs seamlessly inside the Julia programming language!

| | |
|---|---|
| Documentation | [![Build Docs](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Documentation.yml) [![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://thummeto.github.io/FMI.jl/dev/) |
| Examples | [![Examples (latest)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Example.yml) |
| Tests | [![Test (latest)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLatest.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLatest.yml) [![Test (LTS)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLTS.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/TestLTS.yml) [![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl) |
| FMI cross checks| [![FMI2 Cross Checks](https://github.com/ThummeTo/FMI.jl/actions/workflows/CrossChecks.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/CrossChecks.yml) |
| Package evaluation| [![Run PkgEval](https://github.com/ThummeTo/FMI.jl/actions/workflows/Eval.yml/badge.svg)](https://github.com/ThummeTo/FMI.jl/actions/workflows/Eval.yml) |
| Code coverage | [![Coverage](https://codecov.io/gh/ThummeTo/FMI.jl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ThummeTo/FMI.jl) |
| Collaboration | [![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac) |
| Formatting | [![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle) |

## Breaking Changes in FMI.jl (starting from v0.14.0 until release of v1.0.0)
If you want to migrate your project from [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) < v1.0.0 to >= v1.0.0, you will face some breaking changes - but they are worth it as you will see! We decided to do multiple smaller breaking changes starting with v0.14.0, instead of one big one. Some of them are already implemented (checked), some are still on the todo (unchecked) but will be implemented before releasing v1.0.0.

- [x] Many functions, that are not part of the FMI-standard, had the prefix `fmi2...` or `fmi3...`. This was corrected. Now, only functions that are defined by the standard itself, like e.g. `fmi2Instantiate` are allowed to keep the prefix. Other methods, like `fmi2ValueReferenceToString`, that where added to make this library more comfortable, are now cleaned to be more the Julia way: `valueReferenceToString`. If your code errors, the corresponding function might have lost it's prefix, so try this first.

- [x] Wrapper functions where removed, because that is not the Julia way. In most cases, this will not affect your code.

- [x] [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl) and [*FMIImport.jl*](https://github.com/ThummeTo/FMIImport.jl) were divided into [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl), [*FMIImport.jl*](https://github.com/ThummeTo/FMIImport.jl) and [*FMIBase.jl*](https://github.com/ThummeTo/FMIBase.jl). [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl) now holds the pure standard definition (C-types and -functions), while [*FMIBase.jl*](https://github.com/ThummeTo/FMIBase.jl) holds everything that is needed on top of that in [*FMIImport.jl*](https://github.com/ThummeTo/FMIImport.jl) as well as in [*FMIExport.jl*](https://github.com/ThummeTo/FMIExport.jl).

- [ ] Updated all library examples.

- [ ] Updated all library tests for a better code coverage.

- [ ] We tried to document every function, if you find undocumented user-level functions, please open an issue or PR.

- [ ] Allocations, type stability and code format where optimized and are monitored by CI now.

- [ ] Dependencies are reduced a little, to make the libraries more light-weight.

- [ ] RAM for allocated FMUs, their instances and states, is now auto-released. For maximum performance/safety you can use FMUs in blocks (like file reading/writing).

- [ ] New low-level interfaces are introduced, that fit the SciML-ecosystem. For example, a FMU can still be simulated with `simulate(fmu)`, but one can also decide to create a `prob = FMUProblem(fmu)` (like an `ODEProblem`) and use `solve(prob)` to obtain a solution. Keywords will be adapted to have a fully consistent interface with the remaining SciML-ecosystem.

- [x] Optimization for new Julia LTS v1.10, removing code to keep downward compatibility with old LTS v1.6.

🎉 After all listed features are implemented, v1.0.0 will be released! 🎉 

## How can I use FMI.jl?
1\. Open a Julia-REPL, switch to package mode using `]`, activate your preferred environment.

2\. Install [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):
```julia-repl
(@v1) pkg> add FMI
```

3\. If you want to check that everything works correctly, you can run the tests bundled with [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):
```julia-repl
(@v1) pkg> test FMI
```

4\. Have a look inside the [examples folder](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) in the examples branch or the [examples section](https://thummeto.github.io/FMI.jl/dev/examples/overview/) of the documentation. All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).

## How can I simulate a FMU and plot values?
```julia
using FMI, Plots

# load and instantiate a FMU
fmu = loadFMU(pathToFMU) 

# simulate from t=0.0s until t=10.0s and record the FMU variable named "mass.s"
simData = simulate(fmu, (0.0, 10.0); recordValues=["mass.s"])

# plot it!
plot(simData)

# free memory
unloadFMU(myFMU)
```

## What is currently supported in FMI.jl?
- importing the full FMI 2.0.3 and FMI 3.0.0 command set, including optional specials like `fmi2GetFMUstate`, `fmi2SetFMUstate` and `fmi2GetDirectionalDerivatives`
- parameterization, simulation & plotting of CS- and ME-FMUs
- event-handling for imported discontinuous ME-FMUs

|                                   | **FMI2.0.3** |        | **FMI3.0** |        | **SSP1.0** |        |
|-----------------------------------|--------------|--------|------------|--------|------------|--------|
|                                   | Import       | Export | Import     | Export | Import     | Export |
| CS                                | ✔️✔️         | 🚧    | ✔️✔️      | 📅     | 📅         | 📅      |
| ME (continuous)                   | ✔️✔️         | ✔️✔️ | ✔️✔️      | 📅     | 📅         | 📅      |
| ME (discontinuous)                | ✔️✔️         | ✔️✔️  | ✔️✔️     | 📅     | 📅         | 📅      |
| SE                 		        | 🚫           | 🚫     | 🚧        | 📅     | 🚫         | 🚫     |
| Explicit solvers                  | ✔️✔️         | ✔️✔️  | ✔️✔️      | 📅     | 📅         | 📅      |
| Implicit solvers (autodiff=false) | ✔️✔️         | ✔️✔️  | ✔️✔️      | 📅     | 📅         | 📅      |
| Implicit solvers (autodiff=true)  | ✔️           | ✔️✔️   | ✔️        | 📅     | 📅         | 📅      |
| get/setFMUstate                   | ✔️✔️         | 📅     | ✔️✔️     | 📅     | 🚫         | 🚫      |
| getDirectionalDerivatives         | ✔️✔️         | 📅     | ✔️✔️     | 📅     | 🚫         | 🚫      |
| getAdjointDerivatives             | 🚫           | 🚫     | ✔️✔️      | 📅     | 🚫         | 🚫     |
| FMI Cross Checks                  | ✔️✔️         | 📅     | 📅        | 📅     | 🚫         | 🚫      |
| 64-bit binaries in FMUs           | ✔️✔️         | ✔️✔️  | ✔️✔️      | 📅     | 🚫         | 🚫     |
| 32-bit binaries in FMUs           | ✔️            | 📅     | 📅        | 📅     | 🚫         | 🚫      |

✔️✔️ supported & CI-tested

✔️  beta supported: implemented, but not CI-tested

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
- [*FMIBase.jl*](https://github.com/ThummeTo/FMIBase.jl): Common concepts for import and export of FMUs
- [*FMICore.jl*](https://github.com/ThummeTo/FMICore.jl): C-code wrapper for the FMI-standard
- [*FMISensitivity.jl*](https://github.com/ThummeTo/FMISensitivity.jl): Static and dynamic sensitivities over FMUs
- [*FMIBuild.jl*](https://github.com/ThummeTo/FMIBuild.jl): Compiler/Compilation dependencies for FMIExport.jl
- [*FMIFlux.jl*](https://github.com/ThummeTo/FMIFlux.jl): Machine Learning with FMUs
- [*FMIZoo.jl*](https://github.com/ThummeTo/FMIZoo.jl): A collection of testing and example FMUs

## What Platforms are supported?
[*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is tested (and testing) under Julia Versions *1.6 LTS* (64-bit) and *latest* (64-bit) on Windows *latest* (64-bit, 32-bit) and Ubuntu *latest* (64-bit). Mac (64-bit, 32-bit) and Ubuntu (32-bit) should work, but untested. For the best performance, we recommend using Julia >= 1.7, even if we support and test for the official LTS (1.6.7).

## How to cite?
Tobias Thummerer, Lars Mikelsons and Josef Kircher. 2021. **NeuralFMU: towards structural integration of FMUs into neural networks.** Martin Sjölund, Lena Buffoni, Adrian Pop and Lennart Ochel (Ed.). Proceedings of 14th Modelica Conference 2021, Linköping, Sweden, September 20-24, 2021. Linköping University Electronic Press, Linköping (Linköping Electronic Conference Proceedings ; 181), 297-306. [DOI: 10.3384/ecp21181297](https://doi.org/10.3384/ecp21181297)

## Related publications?
Tobias Thummerer, Johannes Stoljar and Lars Mikelsons. 2022. **NeuralFMU: presenting a workflow for integrating hybrid NeuralODEs into real-world applications.** Electronics 11, 19, 3202. [DOI: 10.3390/electronics11193202](https://doi.org/10.3390/electronics11193202)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons. 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** Journal of Physics: Conference Series 2090, 1, 012155. [DOI: 10.1088/1742-6596/2090/1/012155](https://doi.org/10.1088/1742-6596/2090/1/012155)

## Notes for contributors
Contributors are welcome. Before contributing, please read, understand and follow the [Contributor's Guide on Collaborative Practices for Community Packages](https://github.com/SciML/ColPrac). 
During development of new implementations or optimizations on existing code, one will have to make design decisions that influence the library performance and usability. The following prioritization should be the basis for decision-making:
- **#1 Compliance with standard:** It is the highest priority to be compliant with the FMI standard ([fmi-standard.org](https://fmi-standard.org/)). Identifiers described in the standard must be used. Topologies should follow the specification as far as the possibilities of the Julia programming language allows.
- **#2 Performance:** Because [*FMI.jl*](https://github.com/ThummeTo/FMI.jl) is a simulation tool, performance is very important. This applies to the efficient use of CPU and GPU, but also the conscientious use of RAM and disc space.
- **#3 Usability:** The library should be as usable as possible and feel "the Julia way" (e.g. by using multiple dispatch instead of the "C coding style"), as long as being fully compliant with the FMI standard.
