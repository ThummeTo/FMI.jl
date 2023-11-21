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
fmu = fmiLoad("SpringFrictionPendulum1D", "Dymola", "2022x")
fmiInfo(fmu)

simData = fmiSimulate(fmu, (tStart, tStop); recordValues=["mass.s"], saveat=tSave)
plot(simData)

fmiUnload(fmu)

fmu = fmiLoad(pathToFMU)

instanceFMU = fmi2Instantiate!(fmu)

fmi2SetupExperiment(instanceFMU, tStart, tStop)
# set initial model states
fmi2EnterInitializationMode(instanceFMU)
# get initial model states
fmi2ExitInitializationMode(instanceFMU)

values = []

for t in tSave
    # set model inputs if any
    # ...

    fmi2DoStep(instanceFMU, tStep)
    
    # get model outputs
    value = fmi2GetReal(instanceFMU, "mass.s")
    push!(values, value)
end

plot(tSave, values)

fmi2Terminate(instanceFMU)
fmi2FreeInstance!(instanceFMU)
fmi2Unload(fmu)
