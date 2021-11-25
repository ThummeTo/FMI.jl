![FMI.jl Logo](https://github.com/ThummeTo/FMI.jl/blob/main/logo/dark/fmijl_logo_640_320.png "FMI.jl Logo")
# FMI.jl

[![][docs-img]](docs-url) [![][test-img]]() 

<!---Dokumentation Variablen--->

[docs-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-url]: https://ThummeTo.github.io/FMI.jl/dev
<!--- Run FMI.jl Tests Variablen--->

[test-img]: https://github.com/ThummeTo/FMI.jl/actions/workflows/Test.yml/badge.svg

<!--- [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://ThummeTo.github.io/FMI.jl/stable) --->

!!! info inline end

    Lorem ipsum dolor sit amet, consectetur
    adipiscing elit. Nulla et euismod nulla.
    Curabitur feugiat, tortor non consequat
    finibus, justo purus auctor massa, nec
    semper lorem quam in massa.

## Features
- 📚 free-to use libraray
- 📊 parameterization, simulation & plotting of CS- and ME-FMUs
- 🩺 event-handling for discontinuous ME-FMUs
- 🛠️ Supports Julia Version 1.6
- 🖥️ tested on: Windows, Ubuntu, macOS

## Documentation Overview
1. [Introduction]()
2. [Tutorials]()
3. [Examples]()
4. [Libary Funktions]()
5. [Relted Publications]()

## Get Started
1. open a Julia-Command-Window, activate your preferred environment

1. go to package manager using ```]``` and type ```add FMI```
```julia
julia> ]

(@v1.6) pkg> add FMI
```

To check that everything is working correctly, you can run the tests bundled with FMI.jl:
```julia
julia> using Pkg

julia> Pkg.test("FMI")
```

In addition, the ```status``` command allows you to check the version of FMI.jl that you have installed.
```julia
julia> ]
(@v1.6) pkg> status FMI
```

For the rest of the tutorial, we will assume that you have installed the package FMI.jl and entered ``Using FMI``, which will load the package:

```julia
julia> using FMI
```
## How can I use FMI.jl?
1. open a Julia-Command-Window, activate your prefered environment
1. goto package manager using ```]```
1. type ```add FMI``` or ```add "https://github.com/ThummeTo/FMI.jl"```
1. have a look inside the ```example``` folder