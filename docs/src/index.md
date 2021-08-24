
# FMI.jl Documentation

## What is FMI.jl?
FMI.jl is a free-to-use software library for the Julia programming language, which integrates FMI ([fmi-standard.org](http://fmi-standard.org/)): load, instantiate, parameterize and simulate FMUs seamlessly inside the Julia programming language!

## How can I use FMI.jl?
1. open a Julia-Command-Window, activate your prefered environment
1. goto package manager using ```]```
1. type ```add "https://github.com/ThummeTo/FMI.jl"```

## How the documentation is structured?
Having a high-level overview of how this documentation is structured will help you know where to look for certain things. The xxx main parts of the documentation are :
- The __examples__ section gives insight in what is possible with this Library while using short and easily understandable code snippets
- The __library functions__ sections contains all the documentation to the functions provided by this library

## What is currently supported in FMI.jl?
- simulation / plotting of CS- and ME-FMUs
- event-handling for discontinuous ME-FMUs
- the full FMI command set (except ```getFMUState``` and ```setFMUState```)
- ...

## What is under development in FMI.jl?
- Linux support
- documentation
- more examples
- support for ```getFMUState``` and ```setFMUState```
- FMI 3.0 and SSP 1.0 support
- ...

## What Platforms are supported?
FMI.jl is tested under Julia 1.5.4 on Windows.

## Interested in Hybrid Modelling in Julia using FMUs?
See [FMIFlux.jl](https://github.com/ThummeTo/FMIFlux.jl).
