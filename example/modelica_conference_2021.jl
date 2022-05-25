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

simData = fmiSimulate(myFMU, tStart, tStop; recordValues=["mass.s"], saveat=tSave)
fmiPlot(simData)

fmiUnload(myFMU)

myFMU = fmiLoad(pathToFMU);

instanceFMU = fmiInstantiate!(myFMU)

fmiSetupExperiment(instanceFMU, tStart, tStop)
fmiEnterInitializationMode(instanceFMU)
# set initial model states
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
