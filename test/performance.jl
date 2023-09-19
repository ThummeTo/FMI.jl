#
# Copyright (c) 2023 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# this is temporary until it's implemented in native Julia, see:
# https://discourse.julialang.org/t/debug-has-massive-performance-impact/103974/19
using Logging 
if Sys.iswindows()
    Logging.disable_logging(Logging.Debug)
end

using FMI, FMIImport, FMICore, FMIZoo
using BenchmarkTools, Test

fmu = fmiLoad("VLDM", "Dymola", "2020x"; type=:ME)
c = fmi2Instantiate!(fmu)

function evalBenchmark(b)
    res = run(b)
    min_time = min(res.times...)
    memory = res.memory 
    allocs = res.allocs
    return min_time, memory, allocs 
end

########## enter / exit initialization mode ##########

function enterExitInitializationModeReset(c)
    fmi2Reset(c)
    fmi2EnterInitializationMode(c)
    fmi2ExitInitializationMode(c)
    return nothing 
end

b = @benchmarkable enterExitInitializationModeReset($c)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

########## string-value-reference conversion ##########

buffer = zeros(fmi2Real, 2)
vrs_str = ["dynamics.accelerationCalculation.limIntegrator.u", "dynamics.accelerationCalculation.limIntegrator.y"]
vrs = prepareValueReference(fmu, vrs_str)

function stringToValueReference(md, name)
    fmi2StringToValueReference(md, name)
    return nothing
end

b = @benchmarkable stringToValueReference($fmu.modelDescription, $vrs_str[1])
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

b = @benchmarkable stringToValueReference($fmu.modelDescription, $vrs_str)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1
@test memory <= 64

########## get real ##########

vrs = prepareValueReference(fmu, vrs_str)

function getReal!(c, vrs, buffer)
    fmi2GetReal!(c, vrs, buffer)
    return nothing
end
function getReal(c, vrs)
    fmi2GetReal(c, vrs)
    return nothing
end

b = @benchmarkable getReal!($c, $vrs, $buffer)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

b = @benchmarkable getReal!($c, $vrs_str, $buffer)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1
@test memory <= 64 

b = @benchmarkable getReal($c, $vrs_str)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 2
@test memory <= 144

########## get derivatives ##########

buffer = zeros(fmi2Real, 6)

function getDerivatives!(c, buffer)
    fmi2GetDerivatives!(c, buffer)
    return nothing
end

function getDerivatives(c)
    fmi2GetDerivatives(c)
    return nothing
end

b = @benchmarkable getDerivatives!($c, $buffer)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

b = @benchmarkable getDerivatives($c)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1
@test memory <= 112

########## f(x) evaluation / right-hand side ########## 

c.solution = FMU2Solution(c)
fmi2Reset(c)
fmi2EnterInitializationMode(c)
fmi2ExitInitializationMode(c)

import FMI.FMIImport.FMICore: eval!

cRef = UInt64(pointer_from_objref(c))
dx = zeros(fmi2Real, 6)
y = zeros(fmi2Real, 0)
y_refs = zeros(fmi2ValueReference, 0)
x = zeros(fmi2Real, 6)
u = zeros(fmi2Real, 0)
u_refs = zeros(fmi2ValueReference, 0)
p = zeros(fmi2Real, 0)
p_refs = zeros(fmi2ValueReference, 0)
t = -1.0
b = @benchmarkable eval!($cRef, $dx, $y, $y_refs, $x, $u, $u_refs, $p, $p_refs, $t)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1
@test memory <= 112

function test1(c)
    cRef = nothing
    #ignore_derivatives() do
        cRef = pointer_from_objref(c)
        cRef = UInt64(cRef)
    #end
end

dx = zeros(fmi2Real, 6)
y = zeros(fmi2Real, 0)
y_refs = zeros(fmi2ValueReference, 0)
x = zeros(fmi2Real, 6)
u = zeros(fmi2Real, 0)
u_refs = zeros(fmi2ValueReference, 0)
p = zeros(fmi2Real, 0)
p_refs = zeros(fmi2ValueReference, 0)
t = -1.0
b = @benchmarkable $c(dx=$dx, y=$y, y_refs=$y_refs, x=$x, u=$u, u_refs=$u_refs, p=$p, p_refs=$p_refs, t=$t)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 4   # `ignore_derivatives` causes an extra 3 allocations (48 bytes)
@test memory <= 160

x = zeros(fmi2Real, 6)
dx = zeros(fmi2Real, 6)
p = zeros(fmi2Real, 0)
t = -1.0
b = @benchmarkable FMI.fx($c, $dx, $x, $p, $t)
min_time, memory, allocs = evalBenchmark(b)
# ToDo: This is too much, but currently necessary to be compatible with all AD-frameworks, as well as ForwardDiffChainRules
@test allocs <= 5
@test memory <= 176

using FMISensitivity
import FMISensitivity.ForwardDiff
import FMISensitivity.ReverseDiff
function fun(_x)
    eval!(cRef, dx, y, y_refs, _x, u, u_refs, p, p_refs, t)
end
config = ForwardDiff.JacobianConfig(fun, x, ForwardDiff.Chunk{length(x)}())

b = @benchmarkable ForwardDiff.jacobian($fun, $x, $config)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 850
@test memory <= 53000

b = @benchmarkable ReverseDiff.jacobian($fun, $x)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 350
@test memory <= 18000