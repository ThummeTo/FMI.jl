#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Cristof Baumgartner
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

#config
const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"
const NRMSE_THRESHHOLD = 5
const EXCLUDED_SYSTEMS = ["AMESim", "Test-FMUs", "SimulationX", "Silver"]
const CROSS_CHECK_README_CONTENT = 
"# FMI.jl

## How can I use FMI.jl?
1\\. Open a Julia-REPL, switch to package mode using `]`, activate your preferred environment.\n

2\\. Install [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):\n
```julia-repl
(@v1.6) pkg> add FMI
```

3\\. If you want to check that everything works correctly, you can run the tests bundled with [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):\n
```julia-repl
(@v1.6) pkg> test FMI
```

4\\. Have a look inside the [examples folder](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) in the examples branch or the [examples section](https://thummeto.github.io/FMI.jl/dev/examples/overview/) of the documentation. All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).

## How can I simulate a FMU and plot values?
```julia
using FMI, Plots

# load and instantiate a FMU
myFMU = fmiLoad(pathToFMU)

# simulate from t=0.0s until t=10.0s and record the FMU variable named 'mass.s'
simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=['mass.s'])

# plot it!
fmiPlot(simData)

# free memory
fmiUnload(myFMU)
```"

#static strings
const ME = "me"
const CS = "cs"
const WIN64 = "win64"

mutable struct FmuCrossCheck
    fmiVersion::String
    type::String
    os::String
    system::String
    systemVersion::String
    fmuCheck::String
    notCompliant::Bool
    result::Union{Float64,Missing,Nothing}
    success::Union{Bool,Missing}
    skipped::Union{Bool,Missing}
    error::Union{String,Missing,Nothing}
end
