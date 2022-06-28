
# FMI.jl Documentation

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language, which integrates FMI ([fmi-standard.org](http://fmi-standard.org/)): load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!

## How can I install FMI.jl?
1. open a Julia-Command-Window, activate your preferred environment
1. go to package manager using ```]``` and type ```add FMI```
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

Throughout the rest of the tutorial we assume that you have installed the FMI.jl package and have typed ```using FMI``` which loads the package:

```julia
julia> using FMI
```

## How the documentation is structured?
Having a high-level overview of how this documentation is structured will help you know where to look for certain things. The xxx main parts of the documentation are :
- The __Examples__ section gives insight in what is possible with this Library while using short and easily understandable code snippets
- The __Library Functions__ sections contains all the documentation to the functions provided by this library

## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- the full FMI command set

## What is under development in FMI.jl?
- FMI 3.0 and SSP 1.0 support
- FMI Cross Checks
- more examples
- ...

## What Platforms are supported?
FMI.jl is tested (and testing) under Julia Version 1.6 and latest on Windows (latest) and Ubuntu (latest). Mac should work, but untested.

## How to cite? Related publications?
Tobias Thummerer, Josef Kircher, Lars Mikelsons 2021 **NeuralFMU: Towards Structural Integration of FMUs into Neural Networks** (14th Modelica Conference, Preprint, Accepted) [arXiv:2109.04351](https://arxiv.org/abs/2109.04351)

Tobias Thummerer, Johannes Tintenherr, Lars Mikelsons 2021 **Hybrid modeling of the human cardiovascular system using NeuralFMUs** (10th International Conference on Mathematical Modeling in Physical Sciences, Preprint, Accepted) [arXiv:2109.04880](https://arxiv.org/abs/2109.04880)

## Interested in Hybrid Modeling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).

# FMI.jl Library Index
```@index
```
