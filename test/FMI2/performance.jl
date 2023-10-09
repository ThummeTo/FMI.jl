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

using FMI, FMI.FMIImport, FMI.FMIImport.FMICore, FMIZoo
using BenchmarkTools, Test

fmu = fmiLoad("BouncingBall1D", "Dymola", "2022x"; type=:ME)

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
vrs_str = ["mass_radius", "der(mass_v)"]
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
@test allocs <= 1       # allocation of one tuple, containing the model description
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
@test allocs <= 1       # allocation for on-the-fly string conversion
@test memory <= 64 

b = @benchmarkable getReal($c, $vrs_str)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 2       # allocation for on-the-fly string conversion AND allocating an array for the results
@test memory <= 144

########## get derivatives ##########

buffer = zeros(fmi2Real, 2)
nx = Csize_t(length(buffer))

function getDerivatives!(c, buffer, nx)
    fmi2GetDerivatives!(c, buffer, nx)
    return nothing
end

function getDerivatives!(c, buffer)
    fmi2GetDerivatives!(c, buffer)
    return nothing
end

function getDerivatives(c)
    fmi2GetDerivatives(c)
    return nothing
end

b = @benchmarkable getDerivatives!($c, $buffer, $nx)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

b = @benchmarkable getDerivatives!($c, $buffer)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 0
@test memory <= 0

b = @benchmarkable getDerivatives($c)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1       # this is the allocation for the 1 result array
@test memory <= 80      # this is memory for 2 array elements and the array pointer (+1)

########## f(x) evaluation / right-hand side ########## 

c.solution = FMU2Solution(c)
fmi2Reset(c)
fmi2EnterInitializationMode(c)
fmi2ExitInitializationMode(c)

import FMI.FMIImport.FMICore: eval!

cRef = UInt64(pointer_from_objref(c))
dx = zeros(fmi2Real, 2)
y = zeros(fmi2Real, 0)
y_refs = zeros(fmi2ValueReference, 0)
x = zeros(fmi2Real, 2)
u = zeros(fmi2Real, 0)
u_refs = zeros(fmi2ValueReference, 0)
p = zeros(fmi2Real, 0)
p_refs = zeros(fmi2ValueReference, 0)
ec = zeros(fmi2Real, 0)
ec_idcs = zeros(fmi2ValueReference, 0)
t = -1.0
b = @benchmarkable eval!($cRef, $dx, $y, $y_refs, $x, $u, $u_refs, $p, $p_refs, $ec, $ec_idcs, $t)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 1
@test memory <= 80     # ToDo: ?

b = @benchmarkable $c(dx=$dx, y=$y, y_refs=$y_refs, x=$x, u=$u, u_refs=$u_refs, p=$p, p_refs=$p_refs, ec=$ec, ec_idcs=$ec_idcs, t=$t)
min_time, memory, allocs = evalBenchmark(b)
@test allocs <= 5   # `ignore_derivatives` causes an extra 3 allocations (48 bytes)
@test memory <= 208 # ToDo: What is the remaning 1 allocation (112 Bytes) compared to `eval!`?

_p = ()
b = @benchmarkable FMI.fx($c, $dx, $x, $_p, $t, nothing)
min_time, memory, allocs = evalBenchmark(b)
# ToDo: This is too much, but currently necessary to be compatible with all AD-frameworks, as well as ForwardDiffChainRules
@test allocs <= 6
@test memory <= 224 # ToDo: What is the remaning 1 allocation (16 Bytes) compared to `c(...)`?

# using FMISensitivity
# import FMISensitivity.ForwardDiff
# import FMISensitivity.ReverseDiff
# function fun(_x)
#     eval!(cRef, dx, y, y_refs, _x, u, u_refs, p, p_refs, ec, ec_idcs, t)
# end
# config = ForwardDiff.JacobianConfig(fun, x, ForwardDiff.Chunk{length(x)}())

# b = @benchmarkable ForwardDiff.jacobian($fun, $x, $config)
# min_time, memory, allocs = evalBenchmark(b)
# # ToDo: This is too much!
# @test allocs <= 250
# @test memory <= 13000

# b = @benchmarkable ReverseDiff.jacobian($fun, $x)
# min_time, memory, allocs = evalBenchmark(b)
# # ToDo: This is too much!
# @test allocs <= 150
# @test memory <= 10000