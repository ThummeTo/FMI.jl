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

const FMI3False = false
const FMI3True = true

# TODO docs
@enum fmi3causality begin
    # _parameter
    # calculatedParameter
    # input
    # output
    # _local
    # independent
    structuralParameter
end

# TODO docs
@enum fmi3variability begin
    # constant
    # fixed
    # tunable
    # discrete
    # continuous
    placeholder
end

# TODO docs
@enum fmi3initial begin
    # exact
    # approx
    # calculated
    placeb
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


mutable struct fmi3ModelVariable
    #mandatory
    name::fmi3String
    valueReference::fmi3ValueReference
    # datatype::datatypeVariable

    # Optional
    description::fmi3String

    causality::fmi3causality
    variability::fmi3variability
    # initial::fmi3initial ist in fmi3 optional

    # dependencies 
    dependencies #::Array{fmi2Integer}
    dependenciesKind #::Array{fmi2String}

    # Constructor for not further specified ScalarVariables
    function fmi3ModelVariable(name, valueReference)
        new(name, Cint(valueReference), datatypeVariable(), "", _local::fmi2causality, continuous::fmi2variability, calculated::fmi2initial)
    end

    # Constructor for fully specified ScalarVariable
    function fmi3ModelVariable(name, valueReference, datatype, description, causalityString, variabilityString, initialString, dependencies, dependenciesKind)

        var = continuous::fmi3variability
        cau = _local::fmi3causality
        init = calculated::fmi3initial
        #check if causality, variability and initial are correct
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

        if !occursin(initialString, string(instances(fmi3initial)))
            display("Error: initial not known")
        else
            for i in 0:(length(instances(fmi3initial))-1)
                if initialString == string(fmi3initial(i))
                    init = fmi3initial(i)
                end
            end
        end
        new(name, valueReference, datatype, description, cau, var, init, dependencies, dependenciesKind)
    end
end

mutable struct fmi3datatypeVariable
    # # mandatory
    # datatype::Union{Type{fmi3String}, Type{fmi3Float64}, Type{fmi3Int64}, Type{fmi3Boolean}, Type{fmi3Enum}}
    # declaredType::fmi3String

    # # Optional
    # start::Union{fmi2Integer, fmi2Real, fmi2Boolean, fmi3String, Nothing}
    # min::Union{fmi2Integer, fmi2Real, Nothing}
    # max::Union{fmi2Integer, fmi2Real, Nothing}
    # quantity::Union{fmi3String, Nothing}
    # unit::Union{fmi3String, Nothing}
    # displayUnit::Union{fmi3String, Nothing}
    # relativeQuantity::Union{fmi2Boolean, Nothing}
    # nominal::Union{fmi2Real, Nothing}
    # unbounded::Union{fmi2Boolean, Nothing}
    # derivative::Union{Unsigned, Nothing}
    # reinit::Union{fmi2Boolean, Nothing}

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
    # guid::String
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