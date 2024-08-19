#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations

t_start = 0.0
t_stop = 8.0
solver = Tsit5()

inputFct! = function (t, u)
    u[1] = sin(t)
    return nothing
end

fmuStruct, fmu = getFMUStruct("IO", :ME)
@test fmu.isZeroState # check if zero state is identified

solution = simulateME(
    fmuStruct,
    (t_start, t_stop);
    solver = solver,
    recordValues = ["y_real"], # , "y_boolean", "y_integer"], # [ToDo] different types to record
    inputValueReferences = ["u_real"], # [ToDo] different types to set
    inputFunction = inputFct!,
)

@test isnothing(solution.states)
@test solution.values.t[1] == t_start
@test solution.values.t[end] == t_stop
@test isapprox(
    collect(u[1] for u in solution.values.saveval),
    sin.(solution.values.t);
    atol = 1e-6,
)

unloadFMU(fmu)
