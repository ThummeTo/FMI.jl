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


mutable struct fmi3ModelVariable
    #mandatory
    name::fmi2String
    valueReference::fmi2ValueReference
    datatype::datatypeVariable

    # Optional
    description::fmi2String
    causality::fmi2causality
    variability::fmi2variability
    initial::fmi2initial

    # dependencies 
    dependencies #::Array{fmi2Integer}
    dependenciesKind #::Array{fmi2String}

    # Constructor for not further specified ScalarVariables
    function fmi3ModelVariable(name, valueReference)
        new(name, Cint(valueReference), datatypeVariable(), "", _local::fmi2causality, continuous::fmi2variability, calculated::fmi2initial)
    end

    # Constructor for fully specified ScalarVariable
    function fmi3ModelVariable(name, valueReference, datatype, description, causalityString, variabilityString, initialString, dependencies, dependenciesKind)

        var = continuous::fmi2variability
        cau = _local::fmi2causality
        init = calculated::fmi2initial
        #check if causality, variability and initial are correct
        if !occursin(variabilityString, string(instances(fmi2variability)))
            display("Error: variability not known")
        else
            for i in 0:(length(instances(fmi2variability))-1)
                if variabilityString == string(fmi2variability(i))
                    var = fmi2variability(i)
                end
            end
        end

        if !occursin(causalityString, string(instances(fmi2causality)))
            display("Error: causality not known")
        else
            for i in 0:(length(instances(fmi2causality))-1)
                if causalityString == string(fmi2causality(i))
                    cau = fmi2causality(i)
                end
            end
        end

        if !occursin(initialString, string(instances(fmi2initial)))
            display("Error: initial not known")
        else
            for i in 0:(length(instances(fmi2initial))-1)
                if initialString == string(fmi2initial(i))
                    init = fmi2initial(i)
                end
            end
        end
        new(name, valueReference, datatype, description, cau, var, init, dependencies, dependenciesKind)
    end
end

mutable struct fmi3datatypeVariable
    # mandatory
    datatype::Union{Type{fmi2String}, Type{fmi2Real}, Type{fmi2Integer}, Type{fmi2Boolean}, Type{fmi2Enum}}
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
    datatypeVariable() = new()
end

# TODO: Model description
mutable struct fmi3ModelDescription
    # FMI model description
    fmiVersion::String
    modelName::String
    guid::String
    generationTool::String
    generationDateAndTime::String
    variableNamingConvention::String
    instantiationToken::String

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
    enumerations::fmi2Enum

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