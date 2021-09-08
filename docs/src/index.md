
# FMI.jl Documentation

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language, which integrates FMI ([fmi-standard.org](http://fmi-standard.org/)): load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!

## How can I install FMI.jl?
1. open a Julia-Command-Window, activate your preferred environment
1. go to package manager using ```]``` and type ```add FMI```
```
julia> ]

(v.1.5.4)> add FMI
```

If you want to check that everything works correctly, you can run the tests bundled with FMI.jl:
```
julia> using Pkg

julia> Pkg.test("FMI")
```

Additionally, you can check the version of FMI.jl that you have installed with the ```status``` command.
```
julia> ]
(v.1.5.4)> status FMI
```

Throughout the rest of the tutorial we assume that you have installed the FMI.jl package and have typed ```using FMI``` which loads the package:

```
julia> using FMI
```

## How the documentation is structured?
Having a high-level overview of how this documentation is structured will help you know where to look for certain things. The xxx main parts of the documentation are :
- The __Tutorials__ section explains all the necessary steps to work with the library.
- The __examples__ section gives insight in what is possible with this Library while using short and easily understandable code snippets
- The __library functions__ sections contains all the documentation to the functions provided by this library

## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- the full FMI command set

## What is under development in FMI.jl?
- more examples
- FMI 3.0 and SSP 1.0 support

## What Platforms are supported?
FMI.jl is tested under Julia 1.5.4 on Windows, Linux and MacOS.

## Interested in Hybrid Modeling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).
