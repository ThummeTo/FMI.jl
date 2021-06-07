#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

dt = 0.01
t_start = 0.0
t_stop = 8.0

pathToFMU = joinpath(dirname(@__FILE__), "../model/SpringFrictionPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)

@test fmiInstantiate!(myFMU; loggingOn=false) != 0

@test fmiSetupExperiment(myFMU, 0.0) == 0
@test fmiEnterInitializationMode(myFMU) == 0
@test fmiExitInitializationMode(myFMU) == 0

solution = fmiSimulateME(myFMU, dt, t_start, t_stop)
@test length(solution.u) > 0
@test length(solution.t) > 0
# ToDo: Time series comparision

fmiUnload(myFMU)
