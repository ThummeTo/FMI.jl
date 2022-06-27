#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import ForwardDiff
import Zygote

using FMI.FMIImport: fmi2SampleDirectionalDerivative, fmi2GetJacobian, fmi2SetContinuousStates

FMUPaths = [get_model_filename("SpringFrictionPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]),
            get_model_filename("BouncingBall1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])]

t_start = 0.0
t_step = 0.01
t_stop = 5.0
tData = t_start:t_step:t_stop

for FMUPath in FMUPaths
    myFMU = fmiLoad(FMUPath)
    comp = fmiInstantiate!(myFMU; loggingOn=false)

    fmiSetupExperiment(comp, t_start, t_stop)
    fmiEnterInitializationMode(comp)
    fmiExitInitializationMode(comp)

    x0 = fmiGetContinuousStates(comp)
    numStates = length(x0)

    dx = zeros(numStates)
    t = 0.0
    p = []

    # Jacobians for x0
    FD_jac = ForwardDiff.jacobian(x -> FMI.fx(comp, dx, x, p, t), x0)
    ZG_jac = Zygote.jacobian(FMI.fx, comp, dx, x0, p, t)[3]
    fmiSetContinuousStates(comp, x0)
    samp_jac = fmi2SampleDirectionalDerivative(comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)
    auto_jac = fmi2GetJacobian(comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

    @test (abs.(auto_jac -   FD_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)
    @test (abs.(auto_jac -   ZG_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)
    @test (abs.(auto_jac - samp_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)
    #@info "A: $(auto_jac)"
    #@info "S: $(samp_jac)"

    # Jacobians for random x0 / dx
    x0 = x0 + rand(numStates)
    dx = dx + rand(numStates)
    FD_jac = ForwardDiff.jacobian(x -> FMI.fx(comp, dx, x, p, t), x0)
    ZG_jac = Zygote.jacobian(FMI.fx, comp, dx, x0, p, t)[3]
    fmi2SetContinuousStates(comp, x0)
    samp_jac = fmi2SampleDirectionalDerivative(comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)
    auto_jac = fmi2GetJacobian(comp, comp.fmu.modelDescription.derivativeValueReferences, comp.fmu.modelDescription.stateValueReferences)

    @test (abs.(auto_jac -   FD_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)
    @test (abs.(auto_jac -   ZG_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)
    @test (abs.(auto_jac - samp_jac) .< ones(numStates, numStates).*1e-6) == ones(Bool, numStates, numStates)

    fmiUnload(myFMU)
end
