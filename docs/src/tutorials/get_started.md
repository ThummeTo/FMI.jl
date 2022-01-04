## [Get Sarted](@id Get_started)

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