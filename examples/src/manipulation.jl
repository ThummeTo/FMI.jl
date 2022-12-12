# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMI: fmiSetFctGetReal
using FMIZoo
using FMICore
using Plots

tStart = 0.0
tStop = 8.0

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)

fmiInfo(myFMU)

vrs = ["mass.s"]

simData = fmiSimulateME(myFMU, (tStart, tStop); recordValues=vrs)

fig = fmiPlot(simData, states=false)

# save, where the original `fmi2GetReal` function was stored, so we can access it in our new function
originalGetReal = myFMU.cGetReal

function myGetReal!(c::fmi2Component, vr::Union{Array{fmi2ValueReference}, Ptr{fmi2ValueReference}}, 
                    nvr::Csize_t, value::Union{Array{fmi2Real}, Ptr{fmi2Real}})
    # first, we do what the original function does
    status = fmi2GetReal!(originalGetReal, c, vr, nvr, value)

    # if we have a pointer to an array, we must interprete it as array to access elements
    if isa(value, Ptr{fmi2Real})
        value = unsafe_wrap(Array{fmi2Real}, value, nvr, own=false)
    end

    # now, we multiply every value by two (just for fun!)
    for i in 1:nvr 
        value[i] *= 2.0 
    end 

    # return the original status
    return status
end

# no we overwrite the original function
fmiSetFctGetReal(myFMU, myGetReal!)

simData = fmiSimulateME(myFMU, (tStart, tStop); recordValues=vrs)
fmiPlot!(fig, simData; states=false, style=:dash)

fmiUnload(myFMU)
