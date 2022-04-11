#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

################################## INSTALLATION ###############################################
# (1) Enter Package Manager via     ]
# (2) Install FMI via               add FMI     or    add "https://github.com/ThummeTo/FMI.jl"
################################ END INSTALLATION #############################################

using FMI
import FMIZoo

# we use a FMU from the FMIZoo.jl
pathToFMU = FMIZoo.get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

# this is how you can quickly simulate a FMU
myFMU = fmiLoad(pathToFMU)
simData = fmiSimulate(myFMU, 0.0, 10.0; recordValues=["mass.s"])

# ... and plot it
using Plots
fmiPlot(simData)

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
    # set model inputs 
    # ...

    fmiDoStep(fmuComp, dt)

    # get model outputs
    # ...
end
fmiTerminate(fmuComp)
fmiFreeInstance!(fmuComp)
fmiUnload(myFMU)
