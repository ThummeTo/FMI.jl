#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
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
const fmi3FMUstate = Ptr{Cvoid}
const fmi3ComponentEnvironment = Ptr{Cvoid}
const fmi3Enum = Array{Array{String}} # TODO: correct it

const fmi3False = fmi3Boolean(false)
const fmi3True = fmi3Boolean(true)

# TODO docs
@enum fmi3causality begin
    _parameter
    calculatedParameter
    input
    output
    _local
    independent
    structuralParameter
end

# TODO docs
@enum fmi3variability begin
    constant
    fixed
    tunable
    discrete
    continuous
end

# TODO docs
@enum fmi3initial begin
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




mutable struct fmi3datatypeVariable
    # mandatory TODO clock
    datatype::Union{Type{fmi3String}, Type{fmi3Float64}, Type{fmi3Float32}, Type{fmi3Int8}, Type{fmi3UInt8}, Type{fmi3Int16}, Type{fmi3UInt16}, Type{fmi3Int32}, Type{fmi3UInt32}, Type{fmi3Int64}, Type{fmi3UInt64}, Type{fmi3Boolean}, Type{fmi3Binary}, Type{fmi3Char}, Type{fmi3Byte}, Type{fmi3Enum}}
    

    # Optional
    canHandleMultipleSet::Union{fmi3Boolean, Nothing}
    intermediateUpdate::Union{fmi3Boolean, Nothing}
    previous::Union{fmi3UInt32, Nothing}
    clocks
    declaredType::Union{fmi3String, Nothing}
    start::Union{fmi3String, fmi3Float64, fmi3Float32, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64, fmi3Boolean, fmi3Binary, fmi3Char, fmi3Byte, fmi3Enum, Nothing}
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
        var = continuous::fmi3variability
        # if datatype.datatype == fmi3Float32 || datatype.datatype == fmi3Float64
        #     var = continuous::fmi3variability
        # else
        #     var = discretes
        # end
        cau = _local::fmi3causality
        #check if causality and variability are correct
        if !occursin(variabilityString, string(instances(fmi3variability)))
            display("Error: variability not known")
        else
            for i in 0:(length(instances(fmi3variability))-1)
                if variabilityString == string(fmi3variability(i))
                    var = fmi3variability(i)
                end
            end
        end

        if !occursin(causalityString, string(instances(fmi3causality)))
            display("Error: causality not known")
        else
            for i in 0:(length(instances(fmi3causality))-1)
                if causalityString == string(fmi3causality(i))
                    cau = fmi3causality(i)
                end
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
    CScanHandleVariableCommunicationStepSize::Bool
    CSmaxOutputDerivativeOrder::Int
    CScanGetAndSetFMUstate::Bool
    CScanSerializeFMUstate::Bool
    CSprovidesDirectionalDerivatives::Bool
    CSproivdesAdjointDerivatives::Bool

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

# TODO: fmi3Component struct

# TODO: 
# fmi3InstantiateModelExchange
# fmi3InstantiateCoSimulation
# fmi3InstantiateScheduledExecution
# fmi3 ...