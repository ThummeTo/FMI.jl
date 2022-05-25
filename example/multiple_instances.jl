# imports
using FMI
using FMIZoo
using Plots

tStart = 0.0
tStop = 8.0

vrs = ["mass.s"]

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringPendulum1D", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)

comp1 = fmiInstantiate!(myFMU; loggingOn=true)
comp1Address= comp1.compAddr
println(comp1)

param1 = Dict("spring.c"=>10.0, "mass_s0"=>1.0)
data1 = fmiSimulate(comp1, tStart, tStop; parameters=param1, recordValues=vrs, instantiate=false)
fig = fmiPlot(data1)

@assert comp1.compAddr === comp1Address

comp2 = fmiInstantiate!(myFMU; loggingOn=true)
comp2Address= comp2.compAddr
println(comp2)

@assert comp1Address !== comp2Address

param2 = Dict("spring.c"=>1.0, "mass.s"=>2.0)
data2 = fmiSimulateCS(comp2, tStart, tStop;  parameters=param2, recordValues=vrs, instantiate=false)
fmiPlot!(fig, data2)

@assert comp2.compAddr === comp2Address

fmiUnload(myFMU)
