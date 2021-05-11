#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Plots

pathToFMU = joinpath(dirname(@__FILE__), "../model/SpringPendulum1D.fmu")

myFMU = fmiLoad(pathToFMU)
fmiGetVersion(myFMU)
fmiGetTypesPlatform(myFMU)

c = fmiInstantiate!(myFMU; loggingOn=true)

massValueRef = fmi2String2ValueReference(myFMU, "mass.s")
springStiffnessValueRef = fmi2String2ValueReference(myFMU, "spring.c")

fmiSetupExperiment(myFMU, 0.0)

fmiEnterInitializationMode(myFMU)

# read spring stiffnes, set to 10% and set parameter
stiffnes = fmiGetReal(myFMU, springStiffnessValueRef)
stiffnes *= 0.1
fmiSetReal(myFMU, springStiffnessValueRef, stiffnes)

fmiExitInitializationMode(myFMU)

dt = 0.01
t = 0.0

ts = []
ss = []

while t < 10.0
    global t

    fmiDoStep(myFMU, t, dt)

    t += dt
    push!(ts, t)

    massPosition = fmiGetReal(myFMU, massValueRef)
    push!(ss, massPosition)
end

Plots.plot(ts, ss, xlabel="t [s]", ylabel="mass.s [m]", legend=false)

fmiUnload(myFMU)
