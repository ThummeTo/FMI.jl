# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo
using Plots

tStart = 0.0
tStep = 0.1
tStop = 8.0
tSave = tStart:tStep:tStop

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
fmiInfo(myFMU)

simData = fmiSimulate(myFMU, (tStart, tStop); recordValues=["mass.s"], saveat=tSave)
fmiPlot(simData)

fmiUnload(myFMU)

myFMU = fmiLoad(pathToFMU);

instanceFMU = fmiInstantiate!(myFMU)

fmiSetupExperiment(instanceFMU, tStart, tStop)
# set initial model states
fmiEnterInitializationMode(instanceFMU)
# get initial model states
fmiExitInitializationMode(instanceFMU)

for t in tSave
    # set model inputs 
    # ...
    fmiDoStep(instanceFMU, tStep)
    # get model outputs
    # ...
end

fmiTerminate(instanceFMU)
fmiFreeInstance!(instanceFMU)
fmiUnload(myFMU)
