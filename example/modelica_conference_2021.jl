#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

################################## INSTALLATION ###############################################
# (1) Enter Package Manager via     ]
# (2) Install FMI via               add FMI     or    add "https://github.com/ThummeTo/FMI.jl"
################################ END INSTALLATION #############################################

using FMI

# this FMU runs under Windows and Linux
pathToFMU = joinpath(dirname(@__FILE__), "../model/OpenModelica/v1.17.0/SpringFrictionPendulum1D.fmu")

# this FMU runs only under Windows
if Sys.iswindows()
    pathToFMU = joinpath(dirname(@__FILE__), "../model/Dymola/2020x/SpringFrictionPendulum1D.fmu")
end

# this is how you can quickly simulate a FMU
myFMU = fmiLoad(pathToFMU)
fmiInstantiate!(myFMU)
rvs = ["mass.s"]
_, simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=rvs)
fmiPlot(myFMU, rvs, simData)
fmiUnload(myFMU)

# this is how you can simulate a FMU with more possibilities
myFMU = fmiLoad(pathToFMU)
fmuComp = fmiInstantiate!(myFMU)
fmiSetupExperiment(fmuComp, 0.0, 10.0)
fmiEnterInitializationMode(fmuComp)
fmiExitInitializationMode(fmuComp)
dt = 0.1
ts = 0.0:dt:(10.0-dt)
for t in ts
    fmiDoStep(fmuComp, dt)
end
fmiTerminate(fmuComp)
fmiFreeInstance!(fmuComp)
fmiUnload(myFMU)
