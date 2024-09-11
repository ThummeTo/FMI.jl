# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo
using Plots
using DifferentialEquations

tStart = 0.0
tStep = 0.01
tStop = 8.0
tSave = tStart:tStep:tStop

# we use an FMU from the FMIZoo.jl
fmu = loadFMU("SpringPendulumExtForce1D", "Dymola", "2022x"; type=:ME) # load FMU in ME-Mode ("Model Exchange")

# input function format "t", dependent on `t` (time)
function extForce_t(t::Real, u::AbstractArray{<:Real})
    u[1] = sin(t)
end 

# simulate while setting inputs
data_extForce_t = simulate(fmu, (tStart, tStop);                 # FMU, start and stop time
                          solver = Tsit5(),
                          saveat=tSave,                         # timepoints for the ODE solution to be saved
                          inputValueReferences=["extForce"],    # the value references that should be set (inputs)
                          inputFunction=extForce_t,             # the input function to be used
                          dtmax=1e-2,                           # limit max step size to capture inputs
                          showProgress=false)                   # disable progress bar
plot(data_extForce_t)

# input function format "cxt", dependent on `c` (component), `x` (state) and `t` (time)
function extForce_cxt(c::Union{FMU2Component, Nothing}, x::Union{AbstractArray{<:Real}, Nothing}, t::Real, u::AbstractArray{<:Real})
    x1 = 0.0
    if x != nothing # this check is important, because inputs may be needed before the system state is known
        x1 = x[1] 
    end
    u[1] = sin(t) * x1
    nothing
end 

# simulate while setting inputs
data_extForce_cxt = simulate(fmu, (tStart, tStop); saveat=tSave, inputValueReferences=["extForce"], inputFunction=extForce_cxt, dtmax=1e-2, showProgress=false)
plot(data_extForce_cxt)

unloadFMU(fmu)
