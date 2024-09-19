# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo
using Plots

tStart = 0.0
tStop = 8.0

vrs = ["mass.s"]

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringPendulum1D", "Dymola", "2022x")

myFMU = loadFMU(pathToFMU)
info(myFMU)

c1 = fmi2Instantiate!(myFMU; loggingOn=true)
comp1Address = c1.addr
println(c1)

param1 = Dict("spring.c"=>10.0, "mass_s0"=>1.0)
data1 = simulate(c1, (tStart, tStop); parameters=param1, recordValues=vrs, instantiate=false, freeInstance=false)
fig = plot(data1)

@assert c1.addr === comp1Address

c2 = fmi2Instantiate!(myFMU; loggingOn=true)
comp2Address = c2.addr
println(c2)

@assert comp1Address !== comp2Address

param2 = Dict("spring.c"=>1.0, "mass.s"=>2.0)
data2 = simulateCS(c2, (tStart, tStop);  parameters=param2, recordValues=vrs, instantiate=false, freeInstance=false)
plot!(fig, data2)

@assert c2.addr === comp2Address

unloadFMU(myFMU)
