####
#Support Script for manual testing
####


using FMI
using FMIZoo
using FMICore
using Plots

tStart = 0.0
tStop = 8.0

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

myFMU = fmiLoad("https://github.com/modelica/fmi-cross-check/raw/master/fmus/2.0/me/win64/CATIA/R2016x/DFFREG/DFFREG.fmu")

fmiInfo(myFMU)

simData = fmiSimulate(myFMU, tStart, tStop)
display(simData)
#fig = fmiPlot(simData, states=false)

#fmiUnload(myFMU)
