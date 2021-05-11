#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI
using Flux
using DifferentialEquations: Tsit5
import Plots

modelFMUPath = joinpath(dirname(@__FILE__), "../model/SpringPendulum1D.fmu")
realFMUPath = joinpath(dirname(@__FILE__), "../model/SpringFrictionPendulum1D.fmu")

t_start = 0.0
t_step = 0.01
t_stop = 5.0

myFMU = fmiLoad(realFMUPath)
fmiInstantiate!(myFMU; loggingOn=false)
fmiSetupExperiment(myFMU, t_start, t_stop)

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)

x0 = fmi2GetContinuousStates(myFMU)

realSimData = fmi2SimulateCS(myFMU, t_step, t_start, t_stop, ["mass.s", "mass.v", "mass.f", "mass.a"], false)
fmiUnload(myFMU)

fmiPlot(realSimData)

displacement = 0.1
myFMU = fmiLoad(modelFMUPath)

fmiInstantiate!(myFMU; loggingOn=false)
fmuSimData = fmiSimulate(myFMU, t_step, t_start, t_stop, ["mass.s", "mass.v", "mass.a"])
fmiReset(myFMU)
fmiSetupExperiment(myFMU, 0.0)

fmi2SetReal(myFMU, "fixed.s0", displacement)
fmi2SetReal(myFMU, "mass_s0", 0.5 + displacement) # das sollte wurst sein oder?

fmiEnterInitializationMode(myFMU)
fmiExitInitializationMode(myFMU)
#x0 = fmi2GetContinuousStates(myFMU)
tData = t_start:t_step:t_stop
posData = fmi2SimulationResultGetValues(realSimData, "mass.s")
velData = fmi2SimulationResultGetValues(realSimData, "mass.v")

# loss function for training
function losssum()
    solution = problem(t_start, x0)

    posNet = collect(data[2] for data in solution.u)
    velNet = collect(data[3] for data in solution.u)

    Flux.Losses.mse(posNet, posData) + Flux.Losses.mse(velNet, velData)
end

# callback function for training
global iterCB = 0
function callb()
    global iterCB += 1

    # freeze first layer parameters (2,4,6) for velocity -> (static) direct feed trough for velocity
    # parameters for position (1,3,5) are learned
    p_net[1][2] = 0.0
    p_net[1][4] = 1.0
    p_net[1][6] = 0.0

    if iterCB % 10 == 1
        avg_ls = losssum()
        display("Loss: $(round(avg_ls, digits=5))   Avg displacement in data: $(round(sqrt(avg_ls / 2.0), digits=5))   Weight/Scale: $(p_net[1][1])   Bias/Offset: $(p_net[1][5])")
    end

end

# NeuralFMU setup
numStates = fmiGetNumberOfStates(myFMU)

net = Chain(inputs -> NeuralFMUInputLayer(myFMU, inputs),
            Dense(numStates, numStates, identity; initW = (out, in) -> [[1.0, 0.0] [0.0, 1.0]], initb = out -> zeros(out)),
            inputs -> fmi2DoStepME(myFMU, 0.0, inputs),
            Dense(numStates, 16, tanh),
            Dense(16, 16, tanh),
            Dense(16, numStates),
            inputs -> NeuralFMUOutputLayer(inputs))

problem = NeuralFMU(net, (t_start, t_stop), Tsit5(), tData)
problem.fmu = myFMU
solutionBefore = problem(t_start, x0)
fmiPlot(myFMU, solutionBefore, true)

# train it ...
p_net = Flux.params(problem)

optim = ADAM()
for i in 1:3
    display("epoch: $i/3")
    Flux.train!(losssum, p_net, Iterators.repeated((), 1000), optim; cb=callb)
end

###### plot results s
solutionAfter = problem(t_start, x0)
fig = Plots.plot(xlabel="t [s]", ylabel="mass position [m]", linewidth=2,
    xtickfontsize=12, ytickfontsize=12,
    xguidefontsize=12, yguidefontsize=12,
    legendfontsize=12, legend=:bottomright)
Plots.plot!(fig, tData, fmi2SimulationResultGetValues(fmuSimData, "mass.s"), label="FMU", linewidth=2)
Plots.plot!(fig, tData, posData, label="reference", linewidth=2)
Plots.plot!(fig, tData, collect(data[2] for data in solutionAfter.u), label="NeuralFMU", linewidth=2)
Plots.savefig(fig, "exampleResult_s.pdf")

###### plot results v
solutionAfter = problem(t_start, x0)
fig = Plots.plot(xlabel="t [s]", ylabel="mass velocity [m/s]", linewidth=2,
    xtickfontsize=12, ytickfontsize=12,
    xguidefontsize=12, yguidefontsize=12,
    legendfontsize=12, legend=:bottomright)
Plots.plot!(fig, tData, fmi2SimulationResultGetValues(fmuSimData, "mass.v"), label="FMU", linewidth=2)
Plots.plot!(fig, tData, velData, label="reference", linewidth=2)
Plots.plot!(fig, tData, collect(data[3] for data in solutionAfter.u), label="NeuralFMU", linewidth=2)
Plots.savefig(fig, "exampleResult_v.pdf")

# write training parameters *p_net* back to *net* with data offset *c*
function transferParams!(net, p_net, c=0)
    numLayers = length(net.layers)
    for l in 1:numLayers
        ni = size(net.layers[l].weight,2)
        no = size(net.layers[l].weight,1)

        w = zeros(no, ni)
        b = zeros(no)

        for i in 1:ni
            for o in 1:no
                w[o,i] = p_net[1][c + (i-1)*no + (o-1)]
            end
        end

        c += ni*no

        for o in 1:no
            b[o] = p_net[1][c + (o-1)]
        end

        c += no

        copy!(net.layers[l].weight, w)
        copy!(net.layers[l].bias, b)
    end
end

###### friction model extraction
layers = problem.neuralODE.model.layers[4:6]
net_bottom = Chain(layers...)
transferParams!(net_bottom, p_net, 7)

s_neural = collect(data[2] for data in solutionAfter.u)
v_neural = collect(data[3] for data in solutionAfter.u)

s_fmu = fmi2SimulationResultGetValues(fmuSimData, "mass.s")
v_fmu = fmi2SimulationResultGetValues(fmuSimData, "mass.v")
a_fmu = fmi2SimulationResultGetValues(fmuSimData, "mass.a")

f_real = fmi2SimulationResultGetValues(realSimData, "mass.f")
s_real = fmi2SimulationResultGetValues(realSimData, "mass.s")
v_real = fmi2SimulationResultGetValues(realSimData, "mass.v")
a_real = fmi2SimulationResultGetValues(realSimData, "mass.a")

fs = zeros(length(v_real))
for i in 1:length(v_real)
    fs[i] = -net_bottom([v_real[i], 0.0])[2]
end

fig = Plots.plot(xlabel="v [m/s]", ylabel="friction force [N]", linewidth=2,
    xtickfontsize=12, ytickfontsize=12,
    xguidefontsize=12, yguidefontsize=12,
    legendfontsize=12, legend=:bottomright)

mat = hcat(v_real, zeros(length(v_real)))
mat[sortperm(mat[:, 1]), :]
Plots.plot!(fig, mat[:,1], mat[:,2], label="FMU", linewidth=2)

mat = hcat(v_real, f_real)
mat[sortperm(mat[:, 1]), :]
Plots.plot!(fig, mat[:,1], mat[:,2], label="reference", linewidth=2)

mat = hcat(v_real, fs)
mat[sortperm(mat[:, 1]), :]
Plots.plot!(fig, mat[:,1], mat[:,2], label="NeuralFMU", linewidth=2)

Plots.savefig(fig, "frictionModel.pdf")

#########
layers = problem.neuralODE.model.layers[2:2]
net_top = Chain(layers...)
transferParams!(net_top, p_net, 1)

disp_s = zeros(length(s_real))
for i in 1:length(s_real)
    disp_s[i] = net_top([s_real[i], 0.0])[1] - s_real[i] - displacement
end

fig = Plots.plot(xlabel="t [s]", ylabel="displacement [m]", linewidth=2,
    xtickfontsize=12, ytickfontsize=12,
    xguidefontsize=12, yguidefontsize=12,
    legendfontsize=12, legend=:topright)

Plots.plot!(fig, [t_start, t_stop], [displacement, displacement], label="FMU", linewidth=2)
Plots.plot!(fig, [t_start, t_stop], [0.0, 0.0], label="reference", linewidth=2)
Plots.plot!(fig, tData, disp_s, label="NeuralFMU", linewidth=2)

Plots.savefig(fig, "displacementModel.pdf")

fmiUnload(myFMU)
