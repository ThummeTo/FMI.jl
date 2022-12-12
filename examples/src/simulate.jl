# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher, Johannes Stoljar
# Licensed under the MIT license. 
# See LICENSE (https://github.com/thummeto/FMI.jl/blob/main/LICENSE) file in the project root for details.

# imports
using FMI
using FMIZoo
using Plots

tStart = 0.0
tStep = 0.01
tStop = 8.0
tSave = tStart:tStep:tStop

# we use an FMU from the FMIZoo.jl
pathToFMU = get_model_filename("SpringFrictionPendulum1D", "Dymola", "2022x")

myFMU = fmiLoad(pathToFMU)
# fmiLoad("path/to/myFMU.fmu"; unpackPath = "path/to/unpacked/fmu/")

fmiInfo(myFMU)

vrs = ["mass.s", "mass.v"]

dataCS = fmiSimulateCS(myFMU, (tStart, tStop); recordValues=vrs, saveat=tSave)

dataME = fmiSimulateME(myFMU, (tStart, tStop); saveat=tSave)

fmiPlot(dataCS)

fmiPlot(dataME)

fmiUnload(myFMU)
