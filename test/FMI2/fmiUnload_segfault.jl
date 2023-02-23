using FMI, FMIZoo, FMIImport

myFMU = fmiLoad("Feedthrough", "ModelicaReferenceFMUs", "0.0.20", "2.0")
fmiInstantiate!(myFMU)
solution = fmiSimulate(myFMU, (0.0, 1.0))
myFMU = fmi2Unload(myFMU)
fmiUnload(myFMU)
typeof(myFMU)
stateRef = Ref(myFMU)
stateRef = Ptr{Nothing}(0)
myFMU = stateRef
typeof(myFMU)
myFMU = nothing
typeof(myFMU)
fmiInfo(myFMU)

mutable struct Foo
    x::Int16
end

x = Foo(1)
x.x 
function modifyFoo(foo)
    println(foo)
    # z = Ref(foo)
    # println(z)
    z = Ref(nothing)
    foo = z[]
    # println(Ref(Ref(foo)))
    println(foo)
    nothing
    # foo = nothing
    # foo
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