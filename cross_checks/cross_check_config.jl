#config
const TOOL_ID = "FMI_jl"
const TOOL_VERSION = "0.9.2"
const FMI_CROSS_CHECK_REPO_NAME = "fmi-cross-check"
const NRMSE_THRESHHOLD = 5
const EXCLUDED_SYSTEMS = ["AMESim", "Test-FMUs", "SimulationX", "Silver"]
const CROSS_CHECK_README_CONTENT = 
"# FMI.jl\n
\n
## How can I use FMI.jl?\n
1\\. Open a Julia-REPL, switch to package mode using `]`, activate your preferred environment.\n
\n
2\\. Install [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):\n
```julia-repl\n
(@v1.6) pkg> add FMI\n
```\n
\n
3\\. If you want to check that everything works correctly, you can run the tests bundled with [*FMI.jl*](https://github.com/ThummeTo/FMI.jl):\n
```julia-repl\n
(@v1.6) pkg> test FMI\n
```\n
\n
4\\. Have a look inside the [examples folder](https://github.com/ThummeTo/FMI.jl/tree/examples/examples) in the examples branch or the [examples section](https://thummeto.github.io/FMI.jl/dev/examples/overview/) of the documentation. All examples are available as Julia-Script (*.jl*), Jupyter-Notebook (*.ipynb*) and Markdown (*.md*).\n
\n
## How can I simulate a FMU and plot values?\n
```julia\n
using FMI, Plots\n
\n
# load and instantiate a FMU\n
myFMU = fmiLoad(pathToFMU)\n
\n
# simulate from t=0.0s until t=10.0s and record the FMU variable named 'mass.s'\n
simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=['mass.s'])\n
\n
# plot it!\n
fmiPlot(simData)\n
\n
# free memory\n
fmiUnload(myFMU)\n
```\n"

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
