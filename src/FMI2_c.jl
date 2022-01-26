#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

FMI2 Data Types
To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2Char = Cchar
const fmi2String = String # TODO: correct it
const fmi2Boolean = Cint
const fmi2Real = Float64
const fmi2Integer = Cint
const fmi2Byte = Char
const fmi2ValueReference = Cuint
const fmi2FMUstate = Ptr{Cvoid}
const fmi2ComponentEnvironment = Ptr{Cvoid}
const fmi2Enum = Array{Array{String}} # TODO: correct it

# custom types
fmi2ValueReferenceFormat = Union{Nothing, String, Array{String,1}, fmi2ValueReference, Array{fmi2ValueReference,1}, Int64, Array{Int64,1}} # wildcard how a user can pass a fmi2ValueReference

"""
Source: FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

Status returned by functions. The status has the following meaning:
fmi2OK – all well
fmi2Warning – things are not quite right, but the computation can continue. Function “logger” was called in the model (see below), and it is expected that this function has shown the prepared information message to the user.
fmi2Discard – this return status is only possible if explicitly defined for the corresponding function
(ModelExchange: fmi2SetReal, fmi2SetInteger, fmi2SetBoolean, fmi2SetString, fmi2SetContinuousStates, fmi2GetReal, fmi2GetDerivatives, fmi2GetContinuousStates, fmi2GetEventIndicators;
CoSimulation: fmi2SetReal, fmi2SetInteger, fmi2SetBoolean, fmi2SetString, fmi2DoStep, fmiGetXXXStatus):
For “model exchange”: It is recommended to perform a smaller step size and evaluate the model equations again, for example because an iterative solver in the model did not converge or because a function is outside of its domain (for example sqrt(<negative number>)). If this is not possible, the simulation has to be terminated.
For “co-simulation”: fmi2Discard is returned also if the slave is not able to return the required status information. The master has to decide if the simulation run can be continued. In both cases, function “logger” was called in the FMU (see below) and it is expected that this function has shown the prepared information message to the user if the FMU was called in debug mode (loggingOn = fmi2True). Otherwise, “logger” should not show a message.
fmi2Error – the FMU encountered an error. The simulation cannot be continued with this FMU instance. If one of the functions returns fmi2Error, it can be tried to restart the simulation from a formerly stored FMU state by calling fmi2SetFMUstate.
This can be done if the capability flag canGetAndSetFMUstate is true and fmi2GetFMUstate was called before in non-erroneous state. If not, the simulation cannot be continued and fmi2FreeInstance or fmi2Reset must be called afterwards.4 Further processing is possible after this call; especially other FMU instances are not affected. Function “logger” was called in the FMU (see below), and it is expected that this function has shown the prepared information message to the user.
fmi2Fatal – the model computations are irreparably corrupted for all FMU instances. [For example, due to a run-time exception such as access violation or integer division by zero during the execution of an fmi function]. Function “logger” was called in the FMU (see below), and it is expected that this function has shown the prepared information message to the user. It is not possible to call any other function for any of the FMU instances.
fmi2Pending – this status is returned only from the co-simulation interface, if the slave executes the function in an asynchronous way. That means the slave starts to compute but returns immediately. The master has to call fmi2GetStatus(..., fmi2DoStepStatus) to determine if the slave has finished the computation. Can be returned only by fmi2DoStep and by fmi2GetStatus (see section 4.2.3).
"""
@enum fmi2Status begin
    fmi2OK
    fmi2Warning
    fmi2Discard
    fmi2Error
    fmi2Fatal
    fmi2Pending
end

"""
Format the fmi2Status into a String
"""
function fmi2StatusString(status::fmi2Status)
    if status == fmi2OK
        return "OK"
    elseif status == fmi2Warning
        return "Warning"
    elseif status == fmi2Discard
        return "Discard"
    elseif status == fmi2Error
        return "Error"
    elseif status == fmi2Fatal
        return "Fatal"
    elseif status == fmi2Pending
        return "Pending"
    else
        return "Unknown"
    end
end

function fmi2StatusString(status::Integer)
    if status == Integer(fmi2OK)
        return "OK"
    elseif status == Integer(fmi2Warning)
        return "Warning"
    elseif status == Integer(fmi2Discard)
        return "Discard"
    elseif status == Integer(fmi2Error)
        return "Error"
    elseif status == Integer(fmi2Fatal)
        return "Fatal"
    elseif status == Integer(fmi2Pending)
        return "Pending"
    else
        return "Unknown"
    end
end

"""
Source: FMISpec2.0.2[p.19-22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The struct contains pointers to functions provided by the environment to be used by the FMU. It is not allowed to change these functions between fmi2Instantiate(..) and fmi2Terminate(..) calls. Additionally, a pointer to the environment is provided (componentEnvironment) that needs to be passed to the “logger” function, in order that the logger function can utilize data from the environment, such as mapping a valueReference to a string. In the unlikely case that fmi2Component is also needed in the logger, it has to be passed via argument componentEnvironment. Argument componentEnvironment may be a null pointer. The componentEnvironment pointer is also passed to the stepFinished(..) function in order that the environment can provide an efficient way to identify the slave that called stepFinished(..).
"""
mutable struct fmi2CallbackFunctions
    logger::Ptr{Cvoid}
    allocateMemory::Ptr{Cvoid}
    freeMemory::Ptr{Cvoid}
    stepFinished::Ptr{Cvoid}
    componentEnvironment::Ptr{Cvoid}
end

"""
Source: FMISpec2.0.2[p.21]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that is called in the FMU, usually if an fmi2XXX function, does not behave as desired. If “logger” is called with “status = fmi2OK”, then the message is a pure information message. “instanceName” is the instance name of the model that calls this function. “category” is the category of the message. The meaning of “category” is defined by the modeling environment that generated the FMU. Depending on this modeling environment, none, some or all allowed values of “category” for this FMU are defined in the modelDescription.xml file via element “<fmiModelDescription><LogCategories>”, see section 2.2.4. Only messages are provided by function logger that have a category according to a call to fmi2SetDebugLogging (see below). Argument “message” is provided in the same way and with the same format control as in function “printf” from the C standard library. [Typically, this function prints the message and stores it optionally in a log file.]
"""
function cbLogger(componentEnvironment::Ptr{Cvoid},
            instanceName::Ptr{Cchar},
            status::Cuint,
            category::Ptr{Cchar},
            message::Ptr{Cchar})
    _message = unsafe_string(message)
    _category = unsafe_string(category)
    _status = fmi2StatusString(status)
    _instanceName = unsafe_string(instanceName)

    if status == Integer(fmi2OK)
        @info "[$_status][$_category][$_instanceName]: $_message"
    elseif status == Integer(fmi2Warning)
        @warn "[$_status][$_category][$_instanceName]: $_message"
        #@assert false ["[$_status][$_category][$_instanceName]: $_message"]
    else
        @error "[$_status][$_category][$_instanceName]: $_message"
    end

    nothing
end

"""
Source: FMISpec2.0.2[p.21-22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that is called in the FMU if memory needs to be allocated. If attribute “canNotUseMemoryManagementFunctions = true” in <fmiModelDescription><ModelExchange / CoSimulation>, then function allocateMemory is not used in the FMU and a void pointer can be provided. If this attribute has a value of “false” (which is the default), the FMU must not use malloc, calloc or other memory allocation functions. One reason is that these functions might not be available for embedded systems on the target machine. Another reason is that the environment may have optimized or specialized memory allocation functions. allocateMemory returns a pointer to space for a vector of nobj objects, each of size “size” or NULL, if the request cannot be satisfied. The space is initialized to zero bytes [(a simple implementation is to use calloc from the C standard library)].
"""
function cbAllocateMemory(nobj::Csize_t, size::Csize_t)
    ptr = Libc.calloc(nobj, size)
    #display("$ptr: Allocated $nobj x $size bytes.")
	ptr
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that must be called in the FMU if memory is freed that has been allocated with allocateMemory. If a null pointer is provided as input argument obj, the function shall perform no action [(a simple implementation is to use free from the C standard library; in ANSI C89 and C99, the null pointer handling is identical as defined here)]. If attribute “canNotUseMemoryManagementFunctions = true” in <fmiModelDescription><ModelExchange / CoSimulation>, then function freeMemory is not used in the FMU and a null pointer can be provided.
"""
function cbFreeMemory(obj::Ptr{Cvoid})
    #display("$obj: Freed.")
	Libc.free(obj)
    nothing
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Optional call back function to signal if the computation of a communication step of a co-simulation slave is finished. A null pointer can be provided. In this case the master must use fmiGetStatus(..) to query the status of fmi2DoStep. If a pointer to a function is provided, it must be called by the FMU after a completed communication step.
"""
function cbStepFinished(componentEnvironment::Ptr{Cvoid}, status::Cuint)
    #display("Step finished.")
    nothing
end

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

FMI2 Value constants
To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2True = fmi2Boolean(true)
const fmi2False = fmi2Boolean(false)

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Argument fmuType defines the type of the FMU:
- fmi2ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi2CoSimulation: Black box interface for co-simulation.
"""
@enum fmi2Type begin
    fmi2ModelExchange
    fmi2CoSimulation
end

"""
Source: FMISpec2.0.2[p.48]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines the causality of the variable. Allowed values of this enumeration:

"parameter": Independent parameter (a data value that is constant during the simulation and is provided by the environment and cannot be used in connections). variability must be "fixed" or "tunable". initial must be exact or not present (meaning exact).
"calculatedParameter": A data value that is constant during the simulation and is computed during initialization or when tunable parameters change. variability must be "fixed" or "tunable". initial must be "approx", "calculated" or not present (meaning calculated).
"input": The variable value can be provided from another model or slave. It is not allowed to define initial.
"output": The variable value can be used by another model or slave. The algebraic relationship to the inputs is defined via the dependencies attribute of <fmiModelDescription><ModelStructure><Outputs><Unknown>.
"local": Local variable that is calculated from other variables or is a continuous-time state (see section 2.2.8). It is not allowed to use the variable value in another model or slave.
"independent": The independent variable (usually “time”). All variables are a function of this independent variable. variability must be "continuous". At most one ScalarVariable of an FMU can be defined as "independent". If no variable is defined as "independent", it is implicitly present with name = "time" and unit = "s". If one variable is defined as "independent", it must be defined as "Real" without a "start" attribute. It is not allowed to call function fmi2SetReal on an "independent" variable. Instead, its value is initialized with fmi2SetupExperiment and after initialization set by fmi2SetTime for ModelExchange and by arguments currentCommunicationPoint and communicationStepSize of fmi2DoStep for CoSimulation. [The actual value can be inquired with fmi2GetReal.]
The default of causality is “local”. A continuous-time state must have causality = "local" or "output", see also section 2.2.8.
[causality = "calculatedParameter" and causality = "local" with variability = "fixed" or "tunable" are similar. The difference is that a calculatedParameter can be used in another model or slave, whereas a local variable cannot. For example, when importing an FMU in a Modelica environment, a "calculatedParameter" should be imported in a public section as final parameter, whereas a "local" variable should be imported in a protected section of the model.]
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
@enum fmi2causality begin
    fmi2parameter
    fmi2calculatedParameter
    fmi2input
    fmi2output
    fmi2local
    fmi2independent
end

"""
Source: FMISpec2.0.2[p.49]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines the time dependency of the variable, in other words, it defines the time instants when a variable can change its value.

"constant": The value of the variable never changes.
"fixed": The value of the variable is fixed after initialization, in other words, after fmi2ExitInitializationMode was called the variable value does not change anymore.
"tunable": The value of the variable is constant between external events (ModelExchange) and between Communication Points (Co-Simulation) due to changing variables with causality = "parameter" or "input" and variability = "tunable". Whenever a parameter or input signal with variability = "tunable" changes, an event is triggered externally (ModelExchange), or the change is performed at the next Communication Point (Co-Simulation) and the variables with variability = "tunable" and causality = "calculatedParameter" or "output" must be newly computed.
"discrete": ModelExchange: The value of the variable is constant between external and internal events (= time, state, step events defined implicitly in the FMU). Co-Simulation: By convention, the variable is from a “real” sampled data system and its value is only changed at Communication Points (also inside the slave).
"continuous": Only a variable of type = “Real” can be “continuous”. ModelExchange: No restrictions on value changes. Co-Simulation: By convention, the variable is from a differential
The default is “continuous”.
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
@enum fmi2variability begin
    fmi2constant
    fmi2fixed
    fmi2tunable
    fmi2discrete
    fmi2continuous
end

"""
Source: FMISpec2.0.2[p.48]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines how the variable is initialized. It is not allowed to provide a value for initial if causality = "input" or "independent":

"exact": The variable is initialized with the start value (provided under Real, Integer, Boolean, String or Enumeration).
"approx": The variable is an iteration variable of an algebraic loop and the iteration at initialization starts with the start value.
"calculated": The variable is calculated from other variables during initialization. It is not allowed to provide a “start” value.
If initial is not present, it is defined by the table below based on causality and variability. If initial = exact or approx, or causality = ″input″, a start value must be provided. If initial = calculated, or causality = ″independent″, it is not allowed to provide a start value.
If fmiSetXXX is not called on a variable with causality = ″input″, then the FMU must use the start value as value of this input.
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
@enum fmi2initial begin
    fmi2exact
    fmi2approx
    fmi2calculated
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

CoSimulation specific Enum representing state of fmu after fmi2DoStep returned fmi2Pending.
"""
@enum fmi2StatusKind begin
    fmi2DoStepStatus
    fmi2PendingStatus
    fmi2LastSuccessfulTime
    fmi2Terminated
end

# this is a custom type to catch the internal state of the component 
@enum fmi2ComponentState begin
    fmi2ModelSetableFMUstate
    fmi2ModelUnderEvaluation
    fmi2ModelInitialized
end
"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
"""
mutable struct fmi2Component
    compAddr::Ptr{Nothing}
    fmu
    state::fmi2ComponentState
end

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

If return argument fmi2eventInfo->newDiscreteStatesNeeded = fmi2True, the FMU should stay in Event Mode, and the FMU requires to set new inputs to the FMU (fmi2SetXXX on inputs) to compute and get the outputs (fmi2GetXXX on outputs) and to call fmi2NewDiscreteStates again. Depending on the connection with other FMUs, the environment shall
- call fmi2Terminate, if terminateSimulation = fmi2True is returned by at least one FMU.
- call fmi2EnterContinuousTimeMode if all FMUs return newDiscreteStatesNeeded = fmi2False.
- stay in Event Mode otherwise.
When the FMU is terminated, it is assumed that an appropriate message is printed by the logger function (see section 2.1.5) to explain the reason for the termination.
If nominalsOfContinuousStatesChanged = fmi2True, then the nominal values of the states have changed due to the function call and can be inquired with fmi2GetNominalsOfContinuousStates.
If valuesOfContinuousStatesChanged = fmi2True. then at least one element of the continuous state vector has changed its value due to the function call. The new values of the states can be retrieved with fmi2GetContinuousStates or individually for each state for which reinit = "true" by calling getReal. If no element of the continuous state vector has changed its value, valuesOfContinuousStatesChanged must return fmi2False. [If fmi2True would be returned in this case, an infinite event loop may occur.]
If nextEventTimeDefined = fmi2True, then the simulation shall integrate at most until time = nextEventTime, and shall call fmi2EnterEventMode at this time instant. If integration is stopped before nextEventTime, for example, due to a state event, the definition of nextEventTime becomes obsolete.
"""
mutable struct fmi2EventInfo
    newDiscreteStatesNeeded::fmi2Boolean
    terminateSimulation::fmi2Boolean
    nominalsOfContinuousStatesChanged::fmi2Boolean
    valuesOfContinuousStatesChanged::fmi2Boolean
    nextEventTimeDefined::fmi2Boolean
    nextEventTime::fmi2Real

    fmi2EventInfo() = new()
end

"""
Source: FMISpec2.0.2[p.40]: 2.2.3 Definition of Types (TypeDefinitions)
        FMISpec2.0.2[p.56]: 2.2.7 Definition of Model Variables (ModelVariables)
"""
mutable struct fmi2DatatypeVariable
    # mandatory
    datatype::Union{Nothing, Type{fmi2String}, Type{fmi2Real}, Type{fmi2Integer}, Type{fmi2Boolean}, Type{fmi2Enum}}
    declaredType::fmi2String

    # Optional
    start::Union{fmi2Integer, fmi2Real, fmi2Boolean, fmi2String, Nothing}
    min::Union{fmi2Integer, fmi2Real, Nothing}
    max::Union{fmi2Integer, fmi2Real, Nothing}
    quantity::Union{fmi2String, Nothing}
    unit::Union{fmi2String, Nothing}
    displayUnit::Union{fmi2String, Nothing}
    relativeQuantity::Union{fmi2Boolean, Nothing}
    nominal::Union{fmi2Real, Nothing}
    unbounded::Union{fmi2Boolean, Nothing}
    derivative::Union{Unsigned, Nothing}
    reinit::Union{fmi2Boolean, Nothing}

    # additional (not in spec)
    #unknownIndex::Intger 
    #dependencies::Array{Intger}
    #dependenciesValueReferences::Array{fmi2ValueReference}

    # Constructor
    fmi2DatatypeVariable() = new()
end

"""
Source: FMISpec2.0.2[p.46]: 2.2.7 Definition of Model Variables (ModelVariables)

The fmi2ScalarVariable specifies the type and argument of every exposed variable in the fmu
"""
mutable struct fmi2ScalarVariable
    #mandatory
    name::fmi2String
    valueReference::fmi2ValueReference
    datatype::fmi2DatatypeVariable

    # Optional
    description::fmi2String
    causality::fmi2causality
    variability::fmi2variability
    initial::fmi2initial

    # dependencies 
    dependencies #::Array{fmi2Integer}
    dependenciesKind #::Array{fmi2String}

    # Constructor for not further specified ScalarVariables
    function fmi2ScalarVariable(name, valueReference)
        new(name, Cint(valueReference), fmi2DatatypeVariable(), "", fmi2local::fmi2causality, fmi2continuous::fmi2variability, fmi2calculated::fmi2initial)
    end

    # Constructor for fully specified ScalarVariable
    function fmi2ScalarVariable(name, valueReference, datatype, description, causalityString, variabilityString, initialString, dependencies, dependenciesKind)

        var = fmi2continuous::fmi2variability
        cau = fmi2local::fmi2causality
        init = fmi2calculated::fmi2initial
        #check if causality, variability and initial are correct
        if !occursin(variabilityString, string(instances(fmi2variability)))
            display("Error: variability not known")
        else
            for i in 0:(length(instances(fmi2variability))-1)
                if "fmi2" * variabilityString == string(fmi2variability(i))
                    var = fmi2variability(i)
                end
            end
        end

        if !occursin(causalityString, string(instances(fmi2causality)))
            display("Error: causality not known")
        else
            for i in 0:(length(instances(fmi2causality))-1)
                if "fmi2" * causalityString == string(fmi2causality(i))
                    cau = fmi2causality(i)
                end
            end
        end

        if !occursin(initialString, string(instances(fmi2initial)))
            display("Error: initial not known")
        else
            for i in 0:(length(instances(fmi2initial))-1)
                if "fmi2" * initialString == string(fmi2initial(i))
                    init = fmi2initial(i)
                end
            end
        end
        new(name, valueReference, datatype, description, cau, var, init, dependencies, dependenciesKind)
    end
end

"""
Source: FMISpec2.0.2[p.34]: 2.2.1 Definition of an FMU (fmiModelDescription)

The “ModelVariables” element of fmiModelDescription is the central part of the model description. It provides the static information of all exposed variables.
"""
mutable struct fmi2ModelDescription # ToDo: Move, this shouls not be part of FMI2_c.jl-file
    # FMI model description
    fmiVersion::String
    modelName::String
    guid::String
    generationTool::String
    generationDateAndTime::String
    variableNamingConvention::String

    CSmodelIdentifier::String
    CScanHandleVariableCommunicationStepSize::Bool
    CScanInterpolateInputs::Bool
    CSmaxOutputDerivativeOrder::Int
    CScanGetAndSetFMUstate::Bool
    CScanSerializeFMUstate::Bool
    CSprovidesDirectionalDerivative::Bool

    MEmodelIdentifier::String
    MEcanGetAndSetFMUstate::Bool
    MEcanSerializeFMUstate::Bool
    MEprovidesDirectionalDerivative::Bool

    # helpers
    isCoSimulation::Bool
    isModelExchange::Bool

    description::String

    # Model variables
    modelVariables::Array{fmi2ScalarVariable,1}

    # additionals
    valueReferences::Array{fmi2ValueReference}

    inputValueReferences::Array{fmi2ValueReference}
    outputValueReferences::Array{fmi2ValueReference}
    stateValueReferences::Array{fmi2ValueReference}
    derivativeValueReferences::Array{fmi2ValueReference}

    numberOfContinuousStates::Int
    numberOfEventIndicators::Int
    enumerations::fmi2Enum

    stringValueReferences

    # Constructor for uninitialized struct
    fmi2ModelDescription() = new()

    # additional fields (non-FMI-specific)
    valueReferenceIndicies::Dict{Integer,Integer}

    # default experiment 
    defaultStartTime::Union{Real,Nothing}
    defaultStopTime::Union{Real,Nothing}
    defaultTolerance::Union{Real,Nothing}
    defaultStepSize::Union{Real,Nothing}
end

# Common function for ModelExchange & CoSimulation
"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function returns a new instance of an FMU.
"""
function fmi2Instantiate(cfunc::Ptr{Nothing},
                         instanceName::fmi2String,
                         fmuType::fmi2Type,
                         fmuGUID::fmi2String,
                         fmuResourceLocation::fmi2String,
                         functions::fmi2CallbackFunctions,
                         visible::fmi2Boolean,
                         loggingOn::fmi2Boolean)

    compAddr = ccall(cfunc,
                     Ptr{Cvoid},
                     (Cstring, Cint, Cstring, Cstring,
                     Ptr{Cvoid}, Cint, Cint),
                     instanceName, fmuType, fmuGUID, fmuResourceLocation,
                     Ref(functions), visible, loggingOn)

    compAddr
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface.
If a null pointer is provided for “c”, the function call is ignored (does not have an effect).

Removes the component from the FMUs component list.
"""
function fmi2FreeInstance!(c::fmi2Component)

    ind = findall(x->x==c, c.fmu.components)
    deleteat!(c.fmu.components, ind)
    ccall(c.fmu.cFreeInstance, Cvoid, (Ptr{Cvoid},), c.compAddr)

    nothing
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the string to uniquely identify the “fmi2TypesPlatform.h” header file used for compilation of the functions of the FMU.
The standard header file, as documented in this specification, has fmi2TypesPlatform set to “default” (so this function usually returns “default”).
"""
function fmi2GetTypesPlatform(cfunc::Ptr{Nothing})

    typesPlatform = ccall(cfunc,
                          Cstring,
                          ())

    unsafe_string(typesPlatform)
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”
"""
function fmi2GetVersion(cfunc::Ptr{Nothing})

    fmi2Version = ccall(cfunc,
                        Cstring,
                        ())

    unsafe_string(fmi2Version)
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetDebugLogging(c::fmi2Component, logginOn::fmi2Boolean, nCategories::Unsigned, categories::Ptr{Nothing})
    status = ccall(c.fmu.cSetDebugLogging,
                   Cuint,
                   (Ptr{Nothing}, Cint, Csize_t, Ptr{Nothing}),
                   c.compAddr, logginOn, nCategories, categories)
    status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to setup the experiment. This function must be called after fmi2Instantiate and before fmi2EnterInitializationMode is called.The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetupExperiment(c::fmi2Component,
    toleranceDefined::fmi2Boolean,
    tolerance::fmi2Real,
    startTime::fmi2Real,
    stopTimeDefined::fmi2Boolean,
    stopTime::fmi2Real)

    status = ccall(c.fmu.cSetupExperiment,
                Cuint,
                (Ptr{Nothing}, Cint, Cdouble, Cdouble, Cint, Cdouble),
                c.compAddr, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)

    if status > Integer(fmi2Warning::fmi2Status)
        throw(fmi2Error(status))
    end

    status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <ScalarVariable initial = "exact" or "approx"> can be set with the “fmi2SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.2.7). Setting other variables is not allowed. Furthermore, fmi2SetupExperiment must be called at least once before calling fmi2EnterInitializationMode, in order that startTime is defined.
"""
function fmi2EnterInitializationMode(c::fmi2Component)
    ccall(c.fmu.cEnterInitializationMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to exit Initialization Mode.
"""
function fmi2ExitInitializationMode(c::fmi2Component)
    c.state = fmi2ModelInitialized
    ccall(c.fmu.cExitInitializationMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU that the simulation run is terminated.
"""
function fmi2Terminate(c::fmi2Component)
    if c.state != fmi2ModelInitialized
        @warn "fmi2Terminate(_): Should be only called in FMU state `modelInitialized`."
    end
    c.state = fmi2ModelSetableFMUstate
    ccall(c.fmu.cTerminate, Cuint, (Ptr{Nothing},), c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi2Instantiate would have been called.
"""
function fmi2Reset(c::fmi2Component)
    if c.state != fmi2ModelSetableFMUstate
        @warn "fmi2Reset(_): Should be only called in FMU state `modelSetableFMUstate`."
    end
    c.state = fmi2ModelUnderEvaluation
    ccall(c.fmu.cReset, Cuint, (Ptr{Nothing},), c.compAddr)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetReal!(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Real})
    ccall(c.fmu.cGetReal,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
          c.compAddr, vr, nvr, value)
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetReal(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Real})
    status = ccall(c.fmu.cSetReal,
                Cuint,
                (Ptr{Nothing},Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetInteger!(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Integer})
    status = ccall(c.fmu.cGetInteger,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetInteger(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Integer})
    status = ccall(c.fmu.cSetInteger,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetBoolean!(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Boolean})
    status = ccall(c.fmu.cGetBoolean,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetBoolean(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Array{fmi2Boolean})
    status = ccall(c.fmu.cSetBoolean,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetString!(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Vector{Ptr{Cchar}})
    status = ccall(c.fmu.cGetString,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t,  Ptr{Cchar}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetString(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, value::Union{Array{Ptr{Cchar}}, Array{Ptr{UInt8}}})
    status = ccall(c.fmu.cSetString,
                Cuint,
                (Ptr{Nothing},Ptr{fmi2ValueReference}, Csize_t, Ptr{Cchar}),
                c.compAddr, vr, nvr, value)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi2GetFMUstate(c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(c.fmu.cGetFMUstate,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2FMUstate}),
                c.compAddr, FMUstate)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi2SetFMUstate(c::fmi2Component, FMUstate::fmi2FMUstate)
    status = ccall(c.fmu.cSetFMUstate,
                Cuint,
                (Ptr{Nothing}, fmi2FMUstate),
                c.compAddr, FMUstate)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2FreeFMUstate frees all memory and other resources allocated with the fmi2GetFMUstate call for this FMUstate.
"""
function fmi2FreeFMUstate(c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(c.fmu.cFreeFMUstate,
                Cuint,
                (Ptr{Nothing}, Ptr{fmi2FMUstate}),
                c.compAddr, FMUstate)
    status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializedFMUstateSize returns the size of the byte vector, in order that FMUstate can be stored in it.
"""
function fmi2SerializedFMUstateSize(c::fmi2Component, FMUstate::fmi2FMUstate, size::Ref{Csize_t})
    status = ccall(c.fmu.cSerializedFMUstateSize,
                Cuint,
                (Ptr{Nothing}, Ptr{Cvoid}, Ptr{Csize_t}),
                c.compAddr, FMUstate, size)
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi2SerializeFMUstate(c::fmi2Component, FMUstate::fmi2FMUstate, serialzedState::Array{fmi2Byte}, size::Csize_t)
    status = ccall(c.fmu.cSerializeFMUstate,
                Cuint,
                (Ptr{Nothing}, Ptr{Cvoid}, Ptr{Cchar}, Csize_t),
                c.compAddr, FMUstate, serialzedState, size)
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi2DeSerializeFMUstate(c::fmi2Component, serialzedState::Array{fmi2Byte}, size::Csize_t, FMUstate::Ref{fmi2FMUstate})
    status = ccall(c.fmu.cDeSerializeFMUstate,
                Cuint,
                (Ptr{Nothing}, Ptr{Cchar}, Csize_t, Ptr{fmi2FMUstate}),
                c.compAddr, serialzedState, size, FMUstate)
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.9 Getting Partial Derivatives

This function computes the directional derivatives of an FMU.
"""
function fmi2GetDirectionalDerivative!(c::fmi2Component,
                                       vUnknown_ref::Array{fmi2ValueReference},
                                       nUnknown::Csize_t,
                                       vKnown_ref::Array{fmi2ValueReference},
                                       nKnown::Csize_t,
                                       dvKnown::Array{fmi2Real},
                                       dvUnknown::AbstractArray)
    @assert fmi2ProvidesDirectionalDerivative(c.fmu) ["fmi2GetDirectionalDerivative!(...): This FMU does not support build-in directional derivatives!"]
    ccall(c.fmu.cGetDirectionalDerivative,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2ValueReference}, Csize_t, Ptr{Cdouble}, Ptr{Cdouble}),
          c.compAddr, vUnknown_ref, nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown)
    
end

# Functions specificly for isCoSimulation
"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Sets the n-th time derivative of real input variables.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2SetRealInputDerivatives(c::fmi2Component, vr::Array{fmi2ValueReference}, nvr::Csize_t, order::Array{fmi2Integer}, value::Array{fmi2Real})
    status = ccall(c.fmu.cSetRealInputDerivatives,
                Cuint,
                (Ptr{Nothing}, Ptr{Cint}, Csize_t, Ptr{Cint}, Ptr{Cdouble}),
                c.compAddr, vr, nvr, order, value)
end

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2GetRealOutputDerivatives(c::fmi2Component,  vr::Array{fmi2ValueReference}, nvr::Csize_t, order::Array{fmi2Integer}, value::Array{fmi2Real})
    ccall(c.fmu.cGetRealOutputDerivatives,
                Cuint,
                (Ptr{Nothing}, Ptr{Cint}, Csize_t, Ptr{Cint}, Ptr{Cdouble}),
                c.compAddr, vr, nvr, order, value)
end

"""
Source: FMISpec2.0.2[p.104]: 4.2.2 Computation

The computation of a time step is started.
"""
function fmi2DoStep(c::fmi2Component, currentCommunicationPoint::fmi2Real, communicationStepSize::fmi2Real, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    @assert c.fmu.cDoStep != C_NULL ["fmi2DoStep(...): This FMU does not support fmi2DoStep, probably it's a ME-FMU with no CS-support?"]
    ccall(c.fmu.cDoStep, Cuint,
          (Ptr{Nothing}, Cdouble, Cdouble, Cint),
          c.compAddr, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint)
end

"""
Source: FMISpec2.0.2[p.105]: 4.2.2 Computation

Can be called if fmi2DoStep returned fmi2Pending in order to stop the current asynchronous execution.
"""
function fmi2CancelStep(c::fmi2Component)
    ccall(c.fmu.cCancelStep, Cuint, (Ptr{Nothing},), c.compAddr)
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStatus!(c::fmi2Component, s::fmi2StatusKind, value)
    rtype = nothing
    if s == fmi2Terminated
        rtype = fmi2Boolean
    else 
        @assert false "fmi2GetStatus!(_, $(s), $(value)): StatusKind $(s) not implemented yet, please open an issue."
    end
    @assert typeof(value) == rtype "fmi2GetStatus!(_, $(s), $(value)): Type of value ($(typeof(value))) doesn't fit type of return type $(rtype). Change type of value to $(rtype) or change status kind."
    
    status = fmi2Error
    if rtype == fmi2Boolean
        status = ccall(c.fmu.cGetRealStatus,
                    Cuint,
                    (Ptr{Nothing}, Ptr{Nothing}, Ptr{fmi2Boolean}),
                    c.compAddr, s, Ref(value))
    end 
    status
end
function fmi2GetStatus(c::fmi2Component, s::fmi2StatusKind)
    rtype = nothing
    if s == fmi2Terminated
        rtype = fmi2Boolean
    else 
        @assert false "fmi2GetStatus(_, $(s)): StatusKind $(s) not implemented yet, please open an issue."
    end
    value = zeros(rtype, 1)

    status = fmi2Error
    if rtype == fmi2Boolean
        status = ccall(c.fmu.cGetStatus,
                    Cuint,
                    (Ptr{Nothing}, fmi2StatusKind, Ptr{fmi2Boolean}),
                    c.compAddr, s, value)
    end 

    status, value[1]
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
# ToDo: Missing "!", test implementation!
function fmi2GetRealStatus(c::fmi2Component, s::fmi2StatusKind, value::fmi2Real)
    status = ccall(c.fmu.cGetRealStatus,
                Cuint,
                (Ptr{Nothing}, Ptr{Nothing}, Ptr{fmi2Real}),
                c.compAddr, s, Ref(value))
    status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
# ToDo: Missing "!", test implementation!
function fmi2GetIntegerStatus(c::fmi2Component, s::fmi2StatusKind, value::fmi2Integer)
    status = ccall(c.fmu.cGetIntegerStatus,
                Cuint,
                (Ptr{Nothing}, Ptr{Nothing}, Ptr{fmi2Integer}),
                c.compAddr, s, Ref(value))
    status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
# ToDo: Missing "!", test implementation!
function fmi2GetBooleanStatus(c::fmi2Component, s::fmi2StatusKind, value::fmi2Boolean)
    status = ccall(c.fmu.cGetBooleanStatus,
                Cuint,
                (Ptr{Nothing}, Ptr{Nothing}, Ptr{fmi2Boolean}),
                c.compAddr, s, Ref(value))
    status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
# ToDo: Missing "!", test implementation!
function fmi2GetStringStatus(c::fmi2Component, s::fmi2StatusKind, value::fmi2String)
    status = ccall(c.fmu.cGetStringStatus,
                Cuint,
                (Ptr{Nothing}, Ptr{Nothing}, Ptr{fmi2String}),
                c.compAddr, s, Ref(value))
    status
end

# Model Exchange specific Functions

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi2SetTime(c::fmi2Component, time::fmi2Real)
    ccall(c.fmu.cSetTime,
          Cuint,
          (Ptr{Nothing}, fmi2Real),
          c.compAddr, time)
end

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi2SetContinuousStates(c::fmi2Component,
                                 x::Array{fmi2Real},
                                 nx::Csize_t)
    ccall(c.fmu.cSetContinuousStates,
         Cuint,
         (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
         c.compAddr, x, nx)
end

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi2EnterEventMode(c::fmi2Component)
    ccall(c.fmu.cEnterEventMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The FMU is in Event Mode and the super dense time is incremented by this call.
"""
function fmi2NewDiscreteStates(c::fmi2Component, eventInfo::fmi2EventInfo)
    status = ccall(c.fmu.cNewDiscreteStates,
                    Cuint,
                    (Ptr{Nothing}, Ptr{fmi2EventInfo}),
                    c.compAddr, Ref(eventInfo))
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi2EnterContinuousTimeMode(c::fmi2Component)
    ccall(c.fmu.cEnterContinuousTimeMode,
          Cuint,
          (Ptr{Nothing},),
          c.compAddr)
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

This function must be called by the environment after every completed step of the integrator provided the capability flag completedIntegratorStepNotNeeded = false.
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated
"""
function fmi2CompletedIntegratorStep!(c::fmi2Component,
                                      noSetFMUStatePriorToCurrentPoint::fmi2Boolean,
                                      enterEventMode::fmi2Boolean,
                                      terminateSimulation::fmi2Boolean)
    ccall(c.fmu.cCompletedIntegratorStep,
          Cuint,
          (Ptr{Nothing}, fmi2Boolean, Ptr{fmi2Boolean}, Ptr{fmi2Boolean}),
          c.compAddr, noSetFMUStatePriorToCurrentPoint, Ref(enterEventMode), Ref(terminateSimulation))
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute state derivatives at the current time instant and for the current states.
"""
function fmi2GetDerivatives(c::fmi2Component,
                            derivatives::Array{fmi2Real},
                            nx::Csize_t)
    ccall(c.fmu.cGetDerivatives,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
          c.compAddr, derivatives, nx)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute event indicators at the current time instant and for the current states.
"""
function fmi2GetEventIndicators(c::fmi2Component, eventIndicators::Array{fmi2Real}, ni::Csize_t)
    status = ccall(c.fmu.cGetEventIndicators,
                    Cuint,
                    (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
                    c.compAddr, eventIndicators, ni)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the new (continuous) state vector x.
"""
function fmi2GetContinuousStates(c::fmi2Component,
                                 x::Array{fmi2Real},
                                 nx::Csize_t)
    ccall(c.fmu.cGetContinuousStates,
          Cuint,
          (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
          c.compAddr, x, nx)
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the nominal values of the continuous states.
"""
function fmi2GetNominalsOfContinuousStates(c::fmi2Component, x_nominal::Array{fmi2Real}, nx::Csize_t)
    status = ccall(c.fmu.cGetNominalsOfContinuousStates,
                    Cuint,
                    (Ptr{Nothing}, Ptr{fmi2Real}, Csize_t),
                    c.compAddr, x_nominal, nx)
end
