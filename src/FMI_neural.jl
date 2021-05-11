#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Zygote: @adjoint
using Flux, DiffEqFlux
using OrdinaryDiffEq

include("fmi2_neural.jl")

mutable struct NeuralFMU
    neuralODE::NeuralODE
    solution::ODESolution
    fmu

    NeuralFMU() = new()
end

# helper to add an additional time state later used to setup time inside the FMU
function NeuralFMUInputLayer(fmu, inputs)
    t = inputs[1]
    x = inputs[2:end]
    #fmu.next_t = t
    x
end

function NeuralFMUInputLayer_FMU_Top(fmu, inputs)
    t = inputs[1]
    x = inputs[2:end]
    fmiDoStepME(fmu, t, x)
end

# helper to add an additional time state later used to setup time inside the FMU
function NeuralFMUOutputLayer(inputs)
    dt = 1.0
    dx = inputs
    vcat([dt], dx)

end

""" Constructs a NeuralFMU where the FMU is at a unknown location inside of the NN. """
function NeuralFMU(model, tspan, alg=nothing, saveat=[])
    nfmu = NeuralFMU()

    ext_model = model # Chain(deepcopy(model.layers)...)

    nfmu.neuralODE = NeuralODE(ext_model, tspan, alg, saveat=saveat) #, p=Flux.params(ext_model))

    nfmu
end

""" Constructs a NeuralFMU where the FMU is in front of (top) the NN.
Inputs into the NN are one input for every state derivative of the ME-FMU. """
function NeuralFMU_FMU_Top(fmu::FMU2, model, tspan, alg=nothing, saveat=[], useTimeInput=false)
    nfmu = NeuralFMU()
    nfmu.fmu = fmu

    modelInputs = size(net.layers[1].weight)[2]
    modelOutputs = size(net.layers[end].weight)[1]

    @assert (modelInputs == fmiGetNumberOfStates(fmu)) ["NeuralFMU_FMU_Top(...): Number of model (chain) inputs must match number of FMU states!"]
    @assert (modelOutputs == fmiGetNumberOfStates(fmu)) ["NeuralFMU_FMU_Top(...): Number of model (chain) outputs must match number of FMU states!"]

    ext_model = Chain(inputs -> NeuralFMUInputLayer_FMU_Top(nfmu.fmu, inputs),
                          model.layers...,
                          inputs -> NeuralFMUOutputLayer(inputs))

    nfmu.neuralODE = NeuralODE(ext_model, tspan, alg, saveat=saveat)

    nfmu
end

function (nfmu::NeuralFMU)(t0, x0, setup::Bool=false, reset::Bool=false)
    nfmu([t0, x0...], setup, reset) # vcat([t0], x0)
end

function (nfmu::NeuralFMU)(val0, setup::Bool=false, reset::Bool=false)

    t0 = val0[1]

    if setup
        fmiSetupExperiment(nfmu.fmu, t0)
        fmiEnterInitializationMode(nfmu.fmu)
        fmiExitInitializationMode(nfmu.fmu)
    end

    nfmu.solution = nfmu.neuralODE(val0)

    if reset
        fmiReset(nfmu.fmu)
    end

    nfmu.solution
end

# adapting the Flux functions
function Flux.params(neuralfmu::NeuralFMU)
    Flux.params(neuralfmu.neuralODE)
end

# custom gradients
function fmiDoStepME(fmu::FMU2, t, x)
    fmi2DoStepME(fmu, t, x)
end

function fmiDoStepME_Gradient(c̄, fmu::FMU2, t, x)
    fmi2DoStepME_Gradient(c̄, fmu, t, x)
end

@adjoint fmiDoStepME(fmu, t, x) = fmiDoStepME(fmu, t, x), c̄ -> fmiDoStepME_Gradient(c̄, fmu, t, x)

# define neutral gradients for ccall-functions
function neutralGradient(c̄)
    c̄
end
#@adjoint fmiSetupExperiment(fmu, startTime, stopTime) = fmiSetupExperiment(fmu, startTime, stopTime), c̄ -> neutralGradient(c̄)
#@adjoint fmiEnterInitializationMode(fmu) = fmiEnterInitializationMode(fmu), c̄ -> neutralGradient(c̄)
#@adjoint fmiExitInitializationMode(fmu) = fmiExitInitializationMode(fmu), c̄ -> neutralGradient(c̄)
#@adjoint fmiReset(fmu) = fmiReset(fmu), c̄ -> neutralGradient(c̄)
