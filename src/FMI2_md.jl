#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using EzXML

include("FMI2_c.jl")

"""Extract the FMU variables and meta data from the ModelDescription"""
function fmi2readModelDescription(pathToModellDescription::String)
    md = fmi2ModelDescription()
    md.stringValueReferences = Dict{String, fmi2ValueReference}()
    md.outputValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.inputValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.stateValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.derivativeValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.enumerations = []
    typedefinitions = nothing
    modelvariables = nothing
    modelstructure = nothing

    doc = readxml(pathToModellDescription)

    root = doc.root

    md.fmiVersion = root["fmiVersion"]
    md.modelName = root["modelName"]
    md.guid = root["guid"]
    md.isModelExchange = fmi2False
    md.isCoSimulation = fmi2False
    md.numberOfEventIndicators = parse(fmi2Integer, root["numberOfEventIndicators"])
    if haskey(root, "description")
        md.description = root["description"]
    else
        md.description = "no Description"
    end

    for node in eachelement(root)

        if node.name == "CoSimulation"
            md.isCoSimulation = fmi2True
        elseif node.name == "ModelExchange"
            md.isModelExchange = fmi2True
        end
        if node.name == "TypeDefinitions"
            typedefinitions = node
        end

        if node.name == "ModelVariables"
            modelvariables = node
        end
        if node.name == "ModelStructure"
            modelstructure = node
        end
    end
    md.enumerations = createEnum(typedefinitions)
    derivatives = getDerivativesIndex(modelstructure)
    md.modelVariables = setScalarVariables(modelvariables, md, derivatives)
    md
end
"""returns the indices of the state derivatives"""
function getDerivativesIndex(node::EzXML.Node)
    indexes = Array{Int}(undef,0)
    for element in eachelement(node)
        if element.name == "Derivatives"
            for derivative in eachelement(element)
                push!(indexes, parse(Int, derivative["index"]))
            end
        end
    end
    sort!(indexes, rev=true)
end

"""read the model variables of the FMU and parse them"""
function setScalarVariables(nodes::EzXML.Node, md::fmi2ModelDescription, derivatives::Array{Int})
    lastValueReference = fmi2ValueReference(0)
    derivative = nothing
    if derivatives != []
        derivative = pop!(derivatives)
    end
    numberOfVariables = 0
    for node in eachelement(nodes)
        numberOfVariables += 1
    end
    scalarVariables = Array{fmi2ScalarVariable}(undef, numberOfVariables)
    index = 1

    for node in eachelement(nodes)
        name = node["name"]
        ValueReference = parse(fmi2ValueReference, (node["valueReference"]))
        description = ""
        causality = ""
        variability = ""
        initial = ""
        if haskey(node, "description")
            description = node["description"]
        end
        if haskey(node, "causality")
            causality = node["causality"]
        end
        if haskey(node, "variability")
            variability = node["variability"]
        end
        if haskey(node, "initial")
            initial = node["initial"]
        end
        datatype = setDatatypeVariables(node, md)
        scalarVariables[index] = fmi2ScalarVariable(name, ValueReference, datatype, description, causality, variability, initial)

        if causality == "output"
            push!(md.outputValueReferences, ValueReference)
        elseif causality == "input"
            push!(md.inputValueReferences, ValueReference)
        end
        md.stringValueReferences[name] = ValueReference

        if index == derivative
            push!(md.stateValueReferences, lastValueReference)
            push!(md.derivativeValueReferences, ValueReference)
            if derivatives != []
                derivative = pop!(derivatives)
            end
        end
        lastValueReference = ValueReference
        index += 1
    end
    md.numberOfContinuousStates = length(md.stateValueReferences)
    scalarVariables
end

"""parse a fmi2Boolean value represented by a string"""
function parseFMI2Boolean(s::String)
    if s == "true"
        return fmi2True
    elseif s == "false"
        return fmi2False
    else
        @assert false ["setDatatypeVariables(...) unknown start value for boolean type: ´$(typenode["start"])´"]
    end
    nothing
end

"""set the datatype and attributes of an model variable"""
function setDatatypeVariables(node::EzXML.Node, md::fmi2ModelDescription)
    type = datatypeVariable()
    typenode = node.firstelement
    typename = typenode.name
    type.start = nothing
    type.min = nothing
    type.max = nothing
    type.quantity = nothing
    type.unit = nothing
    type.displayUnit = nothing
    type.relativeQuantity = nothing
    type.nominal = nothing
    type.unbounded = nothing
    type.derivative = nothing
    type.reinit = nothing
    if typename == "Real"
        type.datatype = fmi2Real
    elseif typename == "String"
        type.datatype = fmi2String
    elseif typename == "Boolean"
        type.datatype = fmi2Boolean
    elseif typename == "Integer"
        type.datatype = fmi2Integer
    else
        type.datatype = fmi2Enum
    end

    if haskey(typenode, "declaredType")
        type.declaredType = typenode["declaredType"]
    end

    if haskey(typenode, "start")
        if typename == "Real"
            type.start = parse(fmi2Real, typenode["start"])
        elseif typename == "Integer"
            type.start = parse(fmi2Integer, typenode["start"])
        elseif typename == "Boolean"
            type.start = parseFMI2Boolean(typenode["start"])
        elseif typename == "Enumeration"
            for i in 1:length(md.enumerations)
                if type.declaredType == md.enumerations[i][1] # identify the enum by the name
                    type.start = md.enumerations[i][1 + parse(Int, typenode["start"])] # find the enum value and set it
                end
            end
        else
            display("[WARNING]: setDatatypeVariables(...) unimplemented start value type $typename")
            type.start = typenode["start"]
        end
    end

    if haskey(typenode, "min") && (type.datatype == fmi2Real || type.datatype == fmi2Integer || type.datatype == fmi2Enum)
        if type.datatype == fmi2Real
            type.min = parse(fmi2Real, typenode["min"])
        else
            type.min = parse(fmi2Integer, typenode["min"])
        end
    end
    if haskey(typenode, "max") && (type.datatype == fmi2Real || type.datatype == fmi2Integer || type.datatype == fmi2Enum)
        if type.datatype == fmi2Real
            type.max = parse(fmi2Real, typenode["max"])
        elseif type.datatype == fmi2Integer
            type.max = parse(fmi2Integer, typenode["max"])
        end
    end
    if haskey(typenode, "quantity") && (type.datatype == fmi2Real || type.datatype == fmi2Integer || type.datatype == fmi2Enum)
        type.quantity = typenode["quantity"]
    end
    if haskey(typenode, "unit") && type.datatype == fmi2Real
        type.unit = typenode["unit"]
    end
    if haskey(typenode, "displayUnit") && type.datatype == fmi2Real
        type.displayUnit = typenode["displayUnit"]
    end
    if haskey(typenode, "relativeQuantity") && type.datatype == fmi2Real
        type.relativeQuantity = parse(fmi2Boolean, typenode["relativeQuantity"])
    end
    if haskey(typenode, "nominal") && type.datatype == fmi2Real
        type.nominal = parse(fmi2Real, typenode["nominal"])
    end
    if haskey(typenode, "unbounded") && type.datatype == fmi2Real
        type.unbounded = parse(fmi2Boolean, typenode["unbounded"])
    end
    if haskey(typenode, "derivative") && type.datatype == fmi2Real
        type.derivative = parse(fmi2Integer, typenode["derivative"])
    end
    if haskey(typenode, "reinit") && type.datatype == fmi2Real
        type.reinit = parseFMI2Boolean(typenode["reinit"])
    end
    type
end
"""
Read all enumerations from the modeldescription and store them in a matrix. First entries are the enum names
-------------------------------------------
Example:
"enum1name" "value1"    "value2"
"enum2name" "value1"    "value2"

"""
function createEnum(node::EzXML.Node)
    enum = 1
    idx = 1
    enumerations = []
    for simpleType in eachelement(node)
        name = simpleType["name"]
        for type in eachelement(simpleType)
            if type.name == "Enumeration"
                enum = []
                push!(enum, name)
                for item in eachelement(type)
                    push!(enum, item["name"])
                end
                push!(enumerations, enum)
            end
        end
    end
    enumerations
end
