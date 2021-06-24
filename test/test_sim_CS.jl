#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

pathToFMU = joinpath(dirname(@__FILE__), "..", "model", ENV["EXPORTINGTOOL"], "SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

@test fmiInstantiate!(myFMU; loggingOn=false) != 0

dt = 0.01
t_start = 0.0
t_stop = 8.0

data = fmiSimulateCS(myFMU, dt, t_start, t_stop, ["mass.s", "mass.v"])
@test length(data.dataPoints) > 0
@test length(data.dataPoints[1]) > 0
# ToDo: Time series comparision

fmiUnload(myFMU)
