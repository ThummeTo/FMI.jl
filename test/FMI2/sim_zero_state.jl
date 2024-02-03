#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using DifferentialEquations: Tsit5

t_start = 0.0
t_stop = 8.0
solver=FBDF(autodiff=false)
dtmax = 0.01

extForce_t! = function(t, u)
    u[1] = sin(t)
end 

myFMU = fmiLoad("SpringPendulumExtForce1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

# make a dummy zero-state FMU by overwriting the state field (ToDo: Use an actual zero state FMU from FMIZoo.jl)
myFMU.modelDescription.stateValueReferences = []
myFMU.modelDescription.derivativeValueReferences = []
myFMU.modelDescription.numberOfEventIndicators = 0
myFMU.isZeroState = true

comp = fmiInstantiate!(myFMU; loggingOn=false)
@test comp != 0

# choose FMU or FMUComponent
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
@assert fmuStruct != nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

solution = fmiSimulateME(fmuStruct, (t_start, t_stop); solver=solver, dtmax=dtmax, recordValues=["a"], inputValueReferences=myFMU.modelDescription.inputValueReferences, inputFunction=extForce_t!)
@test isnothing(solution.states)

@test solution.values.t[1] == t_start 
@test solution.values.t[end] == t_stop 

fmiUnload(myFMU)