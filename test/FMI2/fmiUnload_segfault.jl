using FMI, FMIZoo, FMIImport

myFMU = fmiLoad("Feedthrough", "ModelicaReferenceFMUs", "0.0.20", "2.0")
fmiInstantiate!(myFMU)
solution = fmiSimulate(myFMU, (0.0, 1.0))
myFMU = fmi2Unload(myFMU)
myFMU = fmiUnload(myFMU)
p1 = pointer_from_objref(myFMU)
p2 = Ref(myFMU)
fmiInfo(myFMU)
test(myFMU) = fmiUnload
Ptr(myFMU)
Base.unsafe_convert(Ref{Nothing}, myFMU)

mutable struct Foo
    x::Int16
end

convert(::Type{Nothing}, x::FMU2) = (Ref(x)[] = nothing)

myFMU = convert(Nothing, myFMU)
x = Foo(1)
x.x 
function modifyFoo(foo)
    println(foo)
    z = Ref(nothing)
    foo = z[]
    println(foo)
    nothing
end

function test(f::Foo)
    f = modifyFoo(f)
end

test(x)
modifyFoo(Ref{Nothing}(x))

ptr = pointer_from_objref(x)
v = nothing
p = pointer_from_objref(v)
Base.unsafe_convert(Ptr{Nothing}, ptr)
Base.unsafe_load(ptr)
unsafe_pointer_to_objref(ptr)

function (fmu::FMU2)()
    fmu = fmi2Unload(fmu)
end