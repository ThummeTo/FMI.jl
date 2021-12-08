#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

macro scopedenum(T, syms...)
    counter = 0 
    function key_value(x)
        if hasproperty(x, :args)
            k = x.args[1]
            v = x.args[2]
        else
            k = x
            v = counter
            counter += 1
        end
        return k,v
    end

    if length(syms) == 1 && syms[1] isa Expr && syms[1].head === :block
        syms = syms[1].args
    end

    syms = Tuple(x for x in syms if ~(x isa LineNumberNode))
    _syms = [key_value(x) for x in syms if ~(x isa LineNumberNode)]

    blk = esc(:(
        module $(Symbol("$(T)Module"))
            using JSON3
            export $T
            struct $T
                value::Int64
            end
            const NAME2VALUE = $(Dict(String(x[1])=>Int64(x[2]) for x in _syms))
            $T(str::String) = $T(NAME2VALUE[str])
            const VALUE2NAME = $(Dict(Int64(x[2])=>String(x[1]) for x in _syms))
            Base.string(e::$T) = VALUE2NAME[e.value]
            Base.getproperty(::Type{$T}, sym::Symbol) = haskey(NAME2VALUE, String(sym)) ? $T(String(sym)) : getfield($T, sym)
            Base.show(io::IO, e::$T) = print(io, string($T, ".", string(e), " = ", e.value))
            Base.propertynames(::Type{$T}) = $([x[1] for x in _syms])
            JSON3.StructType(::Type{$T}) = JSON3.StructTypes.StringType()

            function _itr(res)
                isnothing(res) && return res
                value, state = res
                return ($T(value), state)
            end
            Base.iterate(::Type{$T}) = _itr(iterate(keys(VALUE2NAME)))
            Base.iterate(::Type{$T}, state) = _itr(iterate(keys(VALUE2NAME), state))
        end
    ))
    top = Expr(:toplevel, blk)
    push!(top.args, :(using .$(Symbol("$(T)Module"))))
    return top
end
"""
Source: FMISpec3.0, Version 5b80c29:2.2.2. Platform Dependent Definitions

To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section. 
All definitions in this section are provided in the header file fmi3PlatformTypes.h. It is required to use this definition for all binary FMUs.
"""
const fmi3Float32 = Float32
const fmi3Float64 = Float64
const fmi3Int8 = Cchar
const fmi3UInt8 = Cuchar
const fmi3Int16 = Cshort
const fmi3UInt16 = Cushort
const fmi3Int32 = Cint
const fmi3UInt32 = Cuint
const fmi3Int64 = Clonglong
const fmi3UInt64 = Culonglong
const fmi3Boolean = Cint
const fmi3Char = Cchar
const fmi3String = String # TODO: correct it
const fmi3Byte = Cuchar
const fmi3Binary = Ptr{fmi3Byte}
const fmi3ValueReference = Cint
const fmi3FMUState = Ptr{Cvoid}
const fmi3InstanceEnvironment = Ptr{Cvoid}
const fmi3Enum = Array{Array{String}} # TODO: correct it
const fmi3Clock = Cint

# custom types
fmi3ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi3ValueReference, Array{fmi3ValueReference,1}, Int64, Array{Int64,1}} # wildcard how a user can pass a fmi2ValueReference


const fmi3False = fmi3Boolean(false)
const fmi3True = fmi3Boolean(true)

# TODO docs
@scopedenum fmi3causality begin
    _parameter
    calculatedParameter
    input
    output
    _local
    independent
    structuralParameter
end

# TODO docs
@scopedenum fmi3variability begin
    constant
    fixed
    tunable
    discrete
    continuous
end

# TODO docs
@scopedenum fmi3initial begin
    exact
    approx
    calculated
end
"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Argument fmuType defines the type of the FMU:
- fmi2ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi2CoSimulation: Black box interface for co-simulation.
"""
@enum fmi3Type begin
    fmi3ModelExchange
    fmi3CoSimulation
    fmi3ScheduledExecution
end

# TODO: Callback functions
# """
# Source: FMISpec2.0.2[p.19-22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

# The struct contains pointers to functions provided by the environment to be used by the FMU. It is not allowed to change these functions between fmi2Instantiate(..) and fmi2Terminate(..) calls. Additionally, a pointer to the environment is provided (componentEnvironment) that needs to be passed to the “logger” function, in order that the logger function can utilize data from the environment, such as mapping a valueReference to a string. In the unlikely case that fmi2Component is also needed in the logger, it has to be passed via argument componentEnvironment. Argument componentEnvironment may be a null pointer. The componentEnvironment pointer is also passed to the stepFinished(..) function in order that the environment can provide an efficient way to identify the slave that called stepFinished(..).
# """
# mutable struct fmi3CallbackLoggerFunction
#     logger::Ptr{Cvoid}
# end

# mutable struct fmi3CallbackIntermediateUpdateFunction
#     intermediateUpdate::Ptr{Cvoid}
# end
"""
Source: FMISpec2.0.2[p.21]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that is called in the FMU, usually if an fmi2XXX function, does not behave as desired. If “logger” is called with “status = fmi2OK”, then the message is a pure information message. “instanceName” is the instance name of the model that calls this function. “category” is the category of the message. The meaning of “category” is defined by the modeling environment that generated the FMU. Depending on this modeling environment, none, some or all allowed values of “category” for this FMU are defined in the modelDescription.xml file via element “<fmiModelDescription><LogCategories>”, see section 2.2.4. Only messages are provided by function logger that have a category according to a call to fmi2SetDebugLogging (see below). Argument “message” is provided in the same way and with the same format control as in function “printf” from the C standard library. [Typically, this function prints the message and stores it optionally in a log file.]
"""
function fmi3CallbackLogMessage(instanceEnvironment::Ptr{Cvoid},
            status::Cuint,
            category::Ptr{Cchar},
            message::Ptr{Cchar})
    # _message = unsafe_string(message)
    # _category = unsafe_string(category)
    # _status = fmi2StatusString(status)
    println("Info: LogMessage")
    # if status == Integer(fmi3OK)
    #     @info "[$_status][$_category]: $_message"
    # elseif status == Integer(fmi3Warning)
    #     @warn "[$_status][$_category]: $_message"
    # else
    #     @error "[$_status][$_category]: $_message"
    # end

    nothing
end

"""
TODO UPdate Source: FMISpec2.0.2[p.21-22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that is called in the FMU if memory needs to be allocated. If attribute “canNotUseMemoryManagementFunctions = true” in <fmiModelDescription><ModelExchange / CoSimulation>, then function allocateMemory is not used in the FMU and a void pointer can be provided. If this attribute has a value of “false” (which is the default), the FMU must not use malloc, calloc or other memory allocation functions. One reason is that these functions might not be available for embedded systems on the target machine. Another reason is that the environment may have optimized or specialized memory allocation functions. allocateMemory returns a pointer to space for a vector of nobj objects, each of size “size” or NULL, if the request cannot be satisfied. The space is initialized to zero bytes [(a simple implementation is to use calloc from the C standard library)].
"""
function fmi3CallbackIntermediateUpdate(instanceEnvironment::Ptr{Cvoid},
    intermediateUpdateTime::fmi3Float64,
    clocksTicked::fmi3Boolean,
    intermediateVariableSetRequested::fmi3Boolean,
    intermediateVariableGetAllowed::fmi3Boolean,
    intermediateStepFinished::fmi3Boolean,
    canReturnEarly::fmi3Boolean,
    earlyReturnRequested::Ptr{fmi3Boolean},
    earlyReturnTime::Ptr{fmi3Float64})
    @warn "To be implemented!"
    #display("$ptr: Allocated $nobj x $size bytes.")
end

# """
# Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

# Function that must be called in the FMU if memory is freed that has been allocated with allocateMemory. If a null pointer is provided as input argument obj, the function shall perform no action [(a simple implementation is to use free from the C standard library; in ANSI C89 and C99, the null pointer handling is identical as defined here)]. If attribute “canNotUseMemoryManagementFunctions = true” in <fmiModelDescription><ModelExchange / CoSimulation>, then function freeMemory is not used in the FMU and a null pointer can be provided.
# """
# function cbFreeMemory(obj::Ptr{Cvoid})
#     #display("$obj: Freed.")
# 	Libc.free(obj)
#     nothing
# end

# """
# Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

# Optional call back function to signal if the computation of a communication step of a co-simulation slave is finished. A null pointer can be provided. In this case the master must use fmiGetStatus(..) to query the status of fmi2DoStep. If a pointer to a function is provided, it must be called by the FMU after a completed communication step.
# """
# function cbStepFinished(componentEnvironment::Ptr{Cvoid}, status::Cuint)
#     #display("Step finished.")
#     nothing
# end



mutable struct fmi3datatypeVariable
    # mandatory TODO clock
    datatype::Union{Type{fmi3String}, Type{fmi3Float64}, Type{fmi3Float32}, Type{fmi3Int8}, Type{fmi3UInt8}, Type{fmi3Int16}, Type{fmi3UInt16}, Type{fmi3Int32}, Type{fmi3UInt32}, Type{fmi3Int64}, Type{fmi3UInt64}, Type{fmi3Boolean}, Type{fmi3Binary}, Type{fmi3Char}, Type{fmi3Byte}, Type{fmi3Enum}}
    

    # Optional
    canHandleMultipleSet::Union{fmi3Boolean, Nothing}
    intermediateUpdate::fmi3Boolean
    previous::Union{fmi3UInt32, Nothing}
    clocks
    declaredType::Union{fmi3String, Nothing}
    start::Union{fmi3String, fmi3Float32, fmi3Float64, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64, fmi3Boolean, fmi3Binary, fmi3Char, fmi3Byte, fmi3Enum, Array{fmi3Float32}, Array{fmi3Float64}, Array{fmi3Int32}, Array{fmi3UInt32}, Array{fmi3Int64}, Array{fmi3UInt64},  Nothing}
    min::Union{fmi3Float64,fmi3Int32, fmi3UInt32, fmi3Int64, Nothing}
    max::Union{fmi3Float64,fmi3Int32, fmi3UInt32, fmi3Int64, Nothing}
    initial::Union{fmi3initial, Nothing}
    quantity::Union{fmi3String, Nothing}
    unit::Union{fmi3String, Nothing}
    displayUnit::Union{fmi3String, Nothing}
    relativeQuantity::Union{fmi3Boolean, Nothing}
    nominal::Union{fmi3Float64, Nothing}
    unbounded::Union{fmi3Boolean, Nothing}
    derivative::Union{fmi3UInt32, Nothing}
    reinit::Union{fmi3Boolean, Nothing}
    mimeType::Union{fmi3String, Nothing}
    maxSize::Union{fmi3UInt32, Nothing}

    # # used by Clocks TODO
    # canBeDeactivated::Union{fmi3Boolean, Nothing}
    # priority::Union{fmi3UInt32, Nothing}
    # intervall
    # intervallDecimal::Union{fmi3Float32, Nothing}
    # shiftDecimal::Union{fmi3Float32, Nothing}
    # supportsFraction::Union{fmi3Boolean, Nothing}
    # resolution::Union{fmi3UInt64, Nothing}
    # intervallCounter::Union{fmi3UInt64, Nothing}
    # shitftCounter::Union{fmi3Int32, Nothing}

    # additional (not in spec)
    unknownIndex::Integer 
    dependencies::Array{Integer}
    dependenciesValueReferences::Array{fmi2ValueReference}

    # Constructor
    fmi3datatypeVariable() = new()
end

mutable struct fmi3ModelVariable
    #mandatory
    name::fmi3String
    valueReference::fmi3ValueReference
    datatype::fmi3datatypeVariable

    # Optional
    description::fmi3String

    causality::fmi3causality
    variability::fmi3variability
    # initial::fmi3initial ist in fmi3 optional

    # dependencies 
    dependencies #::Array{fmi2Integer}
    dependenciesKind #::Array{fmi2String}

    # Constructor for not further specified Model variable
    function fmi3ModelVariable(name, valueReference)
        new(name, Clonglong(valueReference), fmi3datatypeVariable(), "", _local::fmi3causality, continuous::fmi3variability)
    end

    # Constructor for fully specified ScalarVariable
    function fmi3ModelVariable(name, valueReference, type, description, causalityString, variabilityString, dependencies, dependenciesKind)
        var = fmi3variability.continuous
        # if datatype.datatype == fmi3Float32 || datatype.datatype == fmi3Float64
        #     var = continuous::fmi3variability
        # else
        #     var = discretes
        # end
        cau = fmi3causality._local
        #check if causality and variability are correct
    
        for i in fmi3variability
            if variabilityString == string(i)
                var = i
            end
        end

        for i in fmi3causality
            if causalityString == string(i)
                cau = i
            end
        end

        # if !occursin(initialString, string(instances(fmi3initial)))
        #     display("Error: initial not known")
        # else
        #     for i in 0:(length(instances(fmi3initial))-1)
        #         if initialString == string(fmi3initial(i))
        #             init = fmi3initial(i)
        #         end
        #     end
        # end
        new(name, valueReference, type, description, cau, var, dependencies, dependenciesKind)
    end
end

# TODO: Model description
mutable struct fmi3ModelDescription
    # FMI model description
    fmiVersion::String
    modelName::String
    generationTool::String
    generationDateAndTime::String
    variableNamingConvention::String
    instantiationToken::String  # replaces GUID

    CSmodelIdentifier::String
    CSneedsExecutionTool::Bool
    CScanBeInstantiatedOnlyOncePerProcess::Bool
    CScanGetAndSetFMUstate::Bool
    CScanSerializeFMUstate::Bool
    CSprovidesDirectionalDerivatives::Bool
    CSproivdesAdjointDerivatives::Bool
    CSprovidesPerElementDependencies::Bool
    CScanHandleVariableCommunicationStepSize::Bool
    CSmaxOutputDerivativeOrder::UInt
    CSprovidesIntermediateUpdate::Bool
    CSrecommendedIntermediateInputSmoothness::Int
    CScanReturnEarlyAfterIntermediateUpdate::Bool
    CShasEventMode::Bool
    CSprovidesEvaluateDiscreteStates::Bool

    MEmodelIdentifier::String
    MEcanGetAndSetFMUstate::Bool
    MEcanSerializeFMUstate::Bool
    MEprovidesDirectionalDerivatives::Bool
    MEprovidesAdjointDerivatives::Bool

    SEmodelIdentifier::String
    SEcanGetAndSetFMUstate::Bool
    SEcanSerializeFMUstate::Bool
    SEprovidesDirectionalDerivatives::Bool
    SEprovidesAdjointDerivatives::Bool


    # helpers
    isCoSimulation::Bool
    isModelExchange::Bool
    isScheduledExecution::Bool

    description::String

    # Model variables
    modelVariables::Array{fmi3ModelVariable,1}

    # additionals
    valueReferences::Array{fmi3ValueReference}

    inputValueReferences::Array{fmi3ValueReference}
    outputValueReferences::Array{fmi3ValueReference}
    stateValueReferences::Array{fmi3ValueReference}
    derivativeValueReferences::Array{fmi3ValueReference}
    intermediateUpdateValueReferences::Array{fmi3ValueReference}

    numberOfContinuousStates::Int
    numberOfEventIndicators::Int
    enumerations::fmi3Enum

    stringValueReferences

    # Constructor for uninitialized struct
    fmi3ModelDescription() = new()

    # additional fields (non-FMI-specific)
    valueReferenceIndicies::Dict{Integer,Integer}
end

# TODO update docs
"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
"""
mutable struct fmi3Component
    compAddr::Ptr{Nothing}
    fmu
end

# TODO: 
function fmi3InstantiateModelExchange(cfunc::Ptr{Nothing},
        instanceName::fmi3String,
        fmuinstantiationToken::fmi3String,
        fmuResourceLocation::fmi3String,
        visible::fmi3Boolean,
        loggingOn::fmi3Boolean,
        instanceEnvironment::fmi3InstanceEnvironment,
        logMessage::Ptr{Cvoid})

    compAddr = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, fmuinstantiationToken, fmuResourceLocation,
        visible, loggingOn, instanceEnvironment, logMessage)

    compAddr
end

function fmi3InstantiateCoSimulation(cfunc::Ptr{Nothing},
    instanceName::fmi3String,
    fmuinstantiationToken::fmi3String,
    fmuResourceLocation::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    eventModeUsed::fmi3Boolean,
    earlyReturnAllowed::fmi3Boolean,
    requiredIntermediateVariables::Array{fmi3ValueReference},
    nRequiredIntermediateVariables::Csize_t,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    intermediateUpdate::Ptr{Cvoid})

    compAddr = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Cint, Cint, Ptr{fmi3ValueReference}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, fmuinstantiationToken, fmuResourceLocation,
        visible, loggingOn, eventModeUsed, earlyReturnAllowed, requiredIntermediateVariables,
        nRequiredIntermediateVariables, instanceEnvironment, logMessage, intermediateUpdate)

    compAddr
end

# TODO docs
function fmi3FreeInstance!(c::fmi3Component)

    ind = findall(x->x==c, c.fmu.components)
    deleteat!(c.fmu.components, ind)
    ccall(c.fmu.cFreeInstance, Cvoid, (Ptr{Cvoid},), c.compAddr)

    nothing
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”
"""
function fmi3GetVersion(cfunc::Ptr{Nothing})

    fmi3Version = ccall(cfunc,
                        Cstring,
                        ())

    unsafe_string(fmi3Version)
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi3SetDebugLogging(c::fmi3Component, logginOn::fmi3Boolean, nCategories::Unsigned, categories::Ptr{Nothing})
    status = ccall(c.fmu.cSetDebugLogging,
                   Cuint,
                   (Ptr{Nothing}, Cint, Csize_t, Ptr{Nothing}),
                   c.compAddr, logginOn, nCategories, categories)
    status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <ScalarVariable initial = "exact" or "approx"> can be set with the “fmi2SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.2.7). Setting other variables is not allowed. Furthermore, fmi2SetupExperiment must be called at least once before calling fmi2EnterInitializationMode, in order that startTime is defined.
"""
function fmi3EnterInitializationMode(c::fmi3Component,toleranceDefined::fmi3Boolean,
    tolerance::fmi3Float64,
    startTime::fmi3Float64,
    stopTimeDefined::fmi3Boolean,
    stopTime::fmi3Float64)
    ccall(c.fmu.cEnterInitializationMode,
          Cuint,
          (Ptr{Nothing}, fmi3Boolean, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Float64),
          c.compAddr, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to exit Initialization Mode.
"""
function fmi3ExitInitializationMode(c::fmi3Component)
    ccall(c.fmu.cExitInitializationMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU that the simulation run is terminated.
"""
function fmi3Terminate(c::fmi3Component)
    ccall(c.fmu.cTerminate, Cuint, (Ptr{Nothing},), c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi2Instantiate would have been called.
"""
function fmi3Reset(c::fmi3Component)
    ccall(c.fmu.cReset, Cuint, (Ptr{Nothing},), c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetFloat32!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Float32}, nvalue::Csize_t)
    ccall(c.fmu.cGetFloat32,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetFloat32(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Float32}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetFloat32,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetFloat64!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Float64}, nvalue::Csize_t)
    ccall(c.fmu.cGetFloat64,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetFloat64(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Float64}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetFloat64,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetInt8!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int8}, nvalue::Csize_t)
    ccall(c.fmu.cGetInt8,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetInt8(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int8}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetInt8,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetUInt8!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3UInt8}, nvalue::Csize_t)
    ccall(c.fmu.cGetUInt8,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetUInt8(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int8}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetUInt8,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetInt16!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int16}, nvalue::Csize_t)
    ccall(c.fmu.cGetInt16,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetInt16(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int16}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetInt16,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetUInt16!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3UInt16}, nvalue::Csize_t)
    ccall(c.fmu.cGetUInt16,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetUInt16(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int16}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetUInt16,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetInt32!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int32}, nvalue::Csize_t)
    ccall(c.fmu.cGetInt32,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetInt32(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int32}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetInt32,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetUInt32!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3UInt32}, nvalue::Csize_t)
    ccall(c.fmu.cGetUInt32,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetUInt32(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int32}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetUInt32,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetInt64!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int64}, nvalue::Csize_t)
    ccall(c.fmu.cGetInt64,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetInt64(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int64}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetInt64,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetUInt64!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3UInt64}, nvalue::Csize_t)
    ccall(c.fmu.cGetUInt64,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetUInt64(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Int64}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetUInt64,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetBoolean!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Boolean}, nvalue::Csize_t)
    ccall(c.fmu.cGetBoolean,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
          c.compAddr, vr, nvr, value, nvalue)
end


"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetBoolean(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Boolean}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetBoolean,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetString!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Vector{Ptr{Cchar}}, nvalue::Csize_t)
    status = ccall(c.fmu.cGetString,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t,  Ptr{Cchar}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetString(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Union{Array{Ptr{Cchar}}, Array{Ptr{UInt8}}}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetString,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{Cchar}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

# TODO not working yet
"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetBinary!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Binary}, nvalue::Csize_t)
    status = ccall(c.fmu.cGetBinary,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t,  fmi3Binary, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetBinary(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Binary}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetBinary,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Binary}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3GetClock!(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Clock}, nvalue::Csize_t)
    status = ccall(c.fmu.cGetClock,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t,  Ptr{fmi3Clock}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi3SetClock(c::fmi3Component, vr::Array{fmi3ValueReference}, nvr::Csize_t, value::Array{fmi3Clock}, nvalue::Csize_t)
    status = ccall(c.fmu.cSetBinary,
                Cuint,
                (Ptr{Nothing},Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Clock}, Csize_t),
                c.compAddr, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi3GetFMUState(c::fmi3Component, FMUstate::Ref{fmi3FMUState})
    status = ccall(c.fmu.cGetFMUState,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3FMUState}),
                c.compAddr, FMUstate)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi3SetFMUState(c::fmi3Component, FMUstate::fmi3FMUState)
    status = ccall(c.fmu.cSetFMUState,
                Cuint,
                (Ptr{Nothing}, fmi3FMUState),
                c.compAddr, FMUstate)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2FreeFMUstate frees all memory and other resources allocated with the fmi2GetFMUstate call for this FMUstate.
"""
function fmi3FreeFMUState(c::fmi3Component, FMUstate::Ref{fmi3FMUState})
    status = ccall(c.fmu.cFreeFMUState,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3FMUState}),
                c.compAddr, FMUstate)
    status
end

# TODO keeps crashing Julia
"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializedFMUstateSize returns the size of the byte vector, in order that FMUstate can be stored in it.
"""
function fmi3SerializedFMUStateSize(c::fmi3Component, FMUstate::fmi3FMUState, size::Ref{Csize_t})
    status = ccall(c.fmu.cSerializedFMUStateSize,
                Cuint,
                (Ptr{Nothing}, Ptr{Cvoid}, Ptr{Csize_t}),
                c.compAddr, FMUstate, size)
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi3SerializeFMUState(c::fmi3Component, FMUstate::fmi3FMUState, serialzedState::Array{fmi3Byte}, size::Csize_t)
    status = ccall(c.fmu.cSerializeFMUState,
                Cuint,
                (Ptr{Nothing}, Ptr{Cvoid}, Ptr{Cchar}, Csize_t),
                c.compAddr, FMUstate, serialzedState, size)
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi3DeSerializeFMUState(c::fmi3Component, serialzedState::Array{fmi3Byte}, size::Csize_t, FMUstate::Ref{fmi3FMUState})
    status = ccall(c.fmu.cDeSerializeFMUState,
                Cuint,
                (Ptr{Nothing}, Ptr{Cchar}, Csize_t, Ptr{fmi3FMUState}),
                c.compAddr, serialzedState, size, FMUstate)
end

# TODO Clocks and dependencies functions

# TODO Modeldescription for testing anpassen
"""
Source: FMISpec2.0.2[p.26]: 2.1.9 Getting Partial Derivatives

This function computes the directional derivatives of an FMU.
"""
function fmi3GetDirectionalDerivative!(c::fmi3Component,
                                       unknowns::Array{fmi3ValueReference},
                                       nUnknowns::Csize_t,
                                       knowns::Array{fmi3ValueReference},
                                       nKnowns::Csize_t,
                                       seed::Array{fmi3Float64},
                                       nSeed::Csize_t,
                                       sensitivity::Array{fmi3Float64},
                                       nSensitivity::Csize_t)
    @assert fmi3ProvidesDirectionalDerivative(c.fmu) ["fmi3GetDirectionalDerivative!(...): This FMU does not support build-in directional derivatives!"]
    ccall(c.fmu.cGetDirectionalDerivative,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c.compAddr, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)
    
end

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi3GetOutputDerivatives(c::fmi3Component,  vr::fmi3ValueReference, nValueReferences::Csize_t, order::fmi3Int32, values::fmi3Float64, nValues::Csize_t)
    status = ccall(c.fmu.cGetOutputDerivatives,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Ptr{Cdouble}, Csize_t),
                c.compAddr, Ref(vr), nValueReferences, Ref(order), Ref(values), nValues)
end

function fmi3EnterConfigurationMode(c::fmi3Component)
    ccall(c.fmu.cEnterConfigurationMode,
            Cuint,
            (Ptr{Nothing},),
            c.compAddr)
end

function fmi3GetNumberOfContinuousStates(c::fmi3Component, nContinuousStates::Csize_t)
    ccall(c.fmu.cGetNumberOfContinuousStates,
            Cuint,
            (Ptr{Nothing}, Ptr{Csize_t}),
            c.compAddr, Ref(nContinuousStates))
end

function fmi3GetNumberOfEventIndicators(c::fmi3Component, nEventIndicators::Ref{Csize_t})
    ccall(c.fmu.cGetNumberOfEventIndicators,
            Cuint,
            (Ptr{Nothing}, Ptr{Csize_t}),
            c.compAddr, nEventIndicators)
end

function fmi3GetContinuousStates(c::fmi3Component, nominals::Array{fmi3Float64}, nContinuousStates::Csize_t)
    ccall(c.fmu.cGetContinuousStates,
            Cuint,
            (Ptr{Nothing}, Ptr{fmi3Float64}, Csize_t),
            c.compAddr, nominals, nContinuousStates)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the nominal values of the continuous states.
"""
function fmi3GetNominalsOfContinuousStates(c::fmi3Component, x_nominal::Array{fmi3Float64}, nx::Csize_t)
    status = ccall(c.fmu.cGetNominalsOfContinuousStates,
                    Cuint,
                    (Ptr{Nothing}, Ptr{fmi3Float64}, Csize_t),
                    c.compAddr, x_nominal, nx)
end

function fmi3EvaluateDiscreteStates(c::fmi3Component)
    ccall(c.fmu.cEvaluateDiscreteStates,
            Cuint,
            (Ptr{Nothing},),
            c.compAddr)
end

# TODO implementation in FMI3.jl and FMI3_comp.jl
function fmi3UpdateDiscreteStates(c::fmi3Component, disreteStatesNeedUpdate::fmi3Boolean, terminateSimulation::fmi3Boolean, 
                                    nominalsOfContinuousStatesChanged::fmi3Boolean, valuesOfContinuousStatesChanged::fmi3Boolean,
                                    nextEventTimeDefined::fmi3Boolean, nextEventTime::fmi3Float64)
    ccall(c.fmu.cUpdateDiscreteStates,
            Cuint,
            (Ptr{Nothing}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
            c.compAddr, Ref(disreteStatesNeedUpdate), Ref(terminateSimulation), Ref(nominalsOfContinuousStatesChanged), Ref(valuesOfContinuousStatesChanged), Ref(nextEventTimeDefined), Ref(nextEventTime))
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi3EnterContinuousTimeMode(c::fmi3Component)
    ccall(c.fmu.cEnterContinuousTimeMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

function fmi3EnterStepMode(c::fmi3Component)
    ccall(c.fmu.cEnterStepMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

function fmi3ExitConfigurationMode(c::fmi3Component)
    ccall(c.fmu.cExitConfigurationMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi3SetTime(c::fmi3Component, time::fmi3Float64)
    ccall(c.fmu.cSetTime,
          Cuint,
          (Ptr{Nothing}, fmi3Float64),
          c.compAddr, time)
end

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi3SetContinuousStates(c::fmi3Component,
                                 x::Array{fmi3Float64},
                                 nx::Csize_t)
    ccall(c.fmu.cSetContinuousStates,
         Cuint,
         (Ptr{Nothing}, Ptr{fmi3Float64}, Csize_t),
         c.compAddr, x, nx)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute state derivatives at the current time instant and for the current states.
"""
function fmi3GetContinuousStateDerivatives(c::fmi3Component,
                            derivatives::Array{fmi3Float64},
                            nx::Csize_t)
    ccall(c.fmu.cGetContinuousStateDerivatives,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
          c.compAddr, derivatives, nx)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute event indicators at the current time instant and for the current states.
"""
function fmi3GetEventIndicators(c::fmi3Component, eventIndicators::Array{fmi3Float64}, ni::Csize_t)
    status = ccall(c.fmu.cGetEventIndicators,
                    Cuint,
                    (Ptr{Nothing}, Ptr{fmi3Float64}, Csize_t),
                    c.compAddr, eventIndicators, ni)
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

This function must be called by the environment after every completed step of the integrator provided the capability flag completedIntegratorStepNotNeeded = false.
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated
"""
function fmi3CompletedIntegratorStep!(c::fmi3Component,
                                      noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                                      enterEventMode::fmi3Boolean,
                                      terminateSimulation::fmi3Boolean)
    ccall(c.fmu.cCompletedIntegratorStep,
          Cuint,
          (Ptr{Nothing}, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}),
          c.compAddr, noSetFMUStatePriorToCurrentPoint, Ref(enterEventMode), Ref(terminateSimulation))
end

# TODO implement in FMI3.jl and FMI3_comp.jl
"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi3EnterEventMode(c::fmi3Component, stepEvent::fmi3Boolean, stateEvent::fmi3Boolean, rootsFound::Array{fmi3Int32}, nEventIndicators::Csize_t, timeEvent::fmi3Boolean)
    ccall(c.fmu.cEnterEventMode,
          Cuint,
          (Ptr{Nothing},fmi3Boolean, fmi3Boolean, Ptr{fmi3Int32}, Csize_t, fmi3Boolean),
          c.compAddr, stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
end

# TODO implement in FMI3.jl and FMI3_comp.jl
"""
Source: FMISpec2.0.2[p.104]: 4.2.2 Computation

The computation of a time step is started.
"""
function fmi3DoStep(c::fmi3Component, currentCommunicationPoint::fmi3Float64, communicationStepSize::fmi3Float64, noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                    eventEncountered::fmi3Boolean, terminateSimulation::fmi3Boolean, earlyReturn::fmi3Boolean, lastSuccessfulTime::fmi3Float64)
    @assert c.fmu.cDoStep != C_NULL ["fmi3DoStep(...): This FMU does not support fmi3DoStep, probably it's a ME-FMU with no CS-support?"]

    ccall(c.fmu.cDoStep, Cuint,
          (Ptr{Nothing}, fmi3Float64, fmi3Float64, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
          c.compAddr, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint, Ref(eventEncountered), Ref(terminateSimulation), Ref(earlyReturn), Ref(lastSuccessfulTime))
end