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
pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

myFMU = loadFMU(pathToFMU)
# loadFMU("path/to/myFMU.fmu"; unpackPath = "path/to/unpacked/fmu/")

info(myFMU)

vrs = ["mass.s", "mass.v"]

dataCS = simulateCS(myFMU, (tStart, tStop); recordValues=vrs, saveat=tSave)

dataME = simulateME(myFMU, (tStart, tStop); saveat=tSave)

plot(dataCS)

plot(dataME)

unloadFMU(myFMU)
