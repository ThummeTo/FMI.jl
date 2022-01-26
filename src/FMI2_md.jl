#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using EzXML

"""
Extract the FMU variables and meta data from the ModelDescription
"""
function fmi2ReadModelDescription(pathToModellDescription::String)
    md = fmi2ModelDescription()

    md.stringValueReferences = Dict{String, fmi2ValueReference}()
    md.outputValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.inputValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.stateValueReferences = Array{fmi2ValueReference}(undef, 0)
    md.derivativeValueReferences = Array{fmi2ValueReference}(undef, 0)

    # CS specific entries
    md.CSmodelIdentifier = ""
    md.CScanHandleVariableCommunicationStepSize = false
    md.CScanInterpolateInputs = false
    md.CSmaxOutputDerivativeOrder = -1
    md.CScanGetAndSetFMUstate = false
    md.CScanSerializeFMUstate = false
    md.CSprovidesDirectionalDerivative = false

    # ME specific entries
    md.MEmodelIdentifier = ""
    md.MEcanGetAndSetFMUstate = false
    md.MEcanSerializeFMUstate = false
    md.MEprovidesDirectionalDerivative = false

    md.enumerations = []
    typedefinitions = nothing
    modelvariables = nothing
    modelstructure = nothing

    doc = readxml(pathToModellDescription)

    root = doc.root

    md.fmiVersion = root["fmiVersion"]
    md.modelName = root["modelName"]
    md.guid = root["guid"]
    md.isModelExchange = false
    md.isCoSimulation = false
    md.generationTool = parseNodeString(root, "generationTool"; onfail="[Unknown generation tool]")
    md.generationDateAndTime = parseNodeString(root, "generationDateAndTime"; onfail="[Unknown generation date and time]")
    md.variableNamingConvention = parseNodeString(root, "variableNamingConvention"; onfail="[Unknown variable naming convention]")
    md.numberOfEventIndicators = parseNodeInteger(root, "numberOfEventIndicators"; onfail=0)
    md.description = parseNodeString(root, "description"; onfail="[Unknown Description]")

    md.defaultStartTime = nothing
    md.defaultStopTime = nothing
    md.defaultTolerance = nothing
    md.defaultStepSize = nothing

    for node in eachelement(root)

        if node.name == "CoSimulation" || node.name == "ModelExchange"
            if node.name == "CoSimulation"
                md.isCoSimulation = true
                md.CSmodelIdentifier                        = node["modelIdentifier"]
                md.CScanHandleVariableCommunicationStepSize = parseNodeBoolean(node, "canHandleVariableCommunicationStepSize"   ; onfail=false)
                md.CScanInterpolateInputs                   = parseNodeBoolean(node, "canInterpolateInputs"                     ; onfail=false)
                md.CSmaxOutputDerivativeOrder               = parseNodeInteger(node, "maxOutputDerivativeOrder"                 ; onfail=-1)
                md.CScanGetAndSetFMUstate                   = parseNodeBoolean(node, "canGetAndSetFMUstate"                     ; onfail=false)
                md.CScanSerializeFMUstate                   = parseNodeBoolean(node, "canSerializeFMUstate"                     ; onfail=false)
                md.CSprovidesDirectionalDerivative          = parseNodeBoolean(node, "providesDirectionalDerivative"            ; onfail=false)
            end

            if node.name == "ModelExchange"
                md.isModelExchange = true
                md.MEmodelIdentifier                        = node["modelIdentifier"]
                md.MEcanGetAndSetFMUstate                   = parseNodeBoolean(node, "canGetAndSetFMUstate"                     ; onfail=false)
                md.MEcanSerializeFMUstate                   = parseNodeBoolean(node, "canSerializeFMUstate"                     ; onfail=false)
                md.MEprovidesDirectionalDerivative          = parseNodeBoolean(node, "providesDirectionalDerivative"            ; onfail=false)
            end
        elseif node.name == "TypeDefinitions"
            typedefinitions = node

        elseif node.name == "ModelVariables"
            modelvariables = node

        elseif node.name == "ModelStructure"
            modelstructure = node

        elseif node.name == "DefaultExperiment"
            md.defaultStartTime                             = parseNodeReal(node, "startTime")
            md.defaultStopTime                              = parseNodeReal(node, "stopTime")
            md.defaultTolerance                             = parseNodeReal(node, "tolerance")
            md.defaultStepSize                              = parseNodeReal(node, "stepSize")
        end
    end

    if typedefinitions == nothing
        md.enumerations = []
    else
        md.enumerations = createEnum(typedefinitions)
    end

    md.valueReferences = []
    md.valueReferenceIndicies = Dict{Integer,Integer}()

    derivativeindices = getDerivativeIndices(modelstructure)
    md.modelVariables = parseModelVariables(modelvariables, md, derivativeindices)

    # parse model dependencies (if available)
    for element in eachelement(modelstructure)
        if element.name == "Derivatives" || element.name == "InitialUnknowns"
            parseDependencies(element, md)
        elseif element.name == "Outputs"

        else
            @warn "Unknown tag `$(element.name)` for node `ModelStructure`."
        end
    end

    # creating an index for value references (fast look-up for dependencies)
    for i in 1:length(md.valueReferences)
        md.valueReferenceIndicies[md.valueReferences[i]] = i
    end 

    md
end

"""
Returns startTime from DefaultExperiment if defined else defaults to nothing.
"""
function fmi2GetDefaultStartTime(md::fmi2ModelDescription)
    md.defaultStartTime
end

"""
Returns stopTime from DefaultExperiment if defined else defaults to nothing.
"""
function fmi2GetDefaultStopTime(md::fmi2ModelDescription)
    md.defaultStopTime
end

"""
Returns tolerance from DefaultExperiment if defined else defaults to nothing.
"""
function fmi2GetDefaultTolerance(md::fmi2ModelDescription)
    md.defaultTolerance
end

"""
Returns stepSize from DefaultExperiment if defined else defaults to nothing.
"""
function fmi2GetDefaultStepSize(md::fmi2ModelDescription)
    md.defaultStepSize
end

"""
Returns the tag 'modelName' from the model description.
"""
function fmi2GetModelName(md::fmi2ModelDescription)#, escape::Bool = true)
    md.modelName
end

"""
Returns the tag 'guid' from the model description.
"""
function fmi2GetGUID(md::fmi2ModelDescription)
    md.guid
end

"""
Returns the tag 'generationtool' from the model description.
"""
function fmi2GetGenerationTool(md::fmi2ModelDescription)
    md.generationTool
end

"""
Returns the tag 'generationdateandtime' from the model description.
"""
function fmi2GetGenerationDateAndTime(md::fmi2ModelDescription)
    md.generationDateAndTime
end

"""
Returns the tag 'varaiblenamingconvention' from the model description.
"""
function fmi2GetVariableNamingConvention(md::fmi2ModelDescription)
    md.variableNamingConvention
end

"""
Returns the tag 'numberOfEventIndicators' from the model description.
"""
function fmi2GetNumberOfEventIndicators(md::fmi2ModelDescription)
    md.numberOfEventIndicators
end

"""
Returns if the FMU model description contains `dependency` information.
"""
function fmi2DependenciesSupported(md::fmi2ModelDescription)
    for mv in md.modelVariables
        if mv.dependencies != nothing && length(mv.dependencies) > 0
            return true
        end
    end 

    return false
end

"""
Returns the tag 'modelIdentifier' from CS or ME section.
"""
function fmi2GetModelIdentifier(md::fmi2ModelDescription; type=nothing)
    
    if type === nothing
        if fmi2IsCoSimulation(md)
            return md.CSmodelIdentifier
        elseif fmi2IsModelExchange(md)
            return md.MEmodelIdentifier
        else
            @assert false "fmi2GetModelName(...): FMU does not support ME or CS!"
        end
    elseif type == fmi2CoSimulation
        return md.CSmodelIdentifier
    elseif type == fmi2ModelExchange
        return md.MEmodelIdentifier
    end
end

"""
Returns true, if the FMU supports the getting/setting of states
"""
function fmi2CanGetSetState(md::fmi2ModelDescription)
    if md.CScanGetAndSetFMUstate || md.MEcanGetAndSetFMUstate
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU state can be serialized
"""
function fmi2CanSerializeFMUstate(md::fmi2ModelDescription)
    if md.CScanSerializeFMUstate || md.MEcanSerializeFMUstate
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU provides directional derivatives
"""
function fmi2ProvidesDirectionalDerivative(md::fmi2ModelDescription)
    if md.CSprovidesDirectionalDerivative || md.MEprovidesDirectionalDerivative
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU supports co simulation
"""
function fmi2IsCoSimulation(md::fmi2ModelDescription)
    md.isCoSimulation
end

"""
Returns true, if the FMU supports model exchange
"""
function fmi2IsModelExchange(md::fmi2ModelDescription)
    md.isModelExchange
end

# Returns the indices of the state derivatives.
function getDerivativeIndices(node::EzXML.Node)
    indices = []
    for element in eachelement(node)
        if element.name == "Derivatives"
            for derivative in eachelement(element)
                ind = parse(Int, derivative["index"])
                der = nothing 
                derKind = nothing 

                if haskey(derivative, "dependencies")
                    der = split(derivative["dependencies"], " ")

                    if der[1] == ""
                        der = fmi2Integer[]
                    else
                        der = collect(parse(fmi2Integer, e) for e in der)
                    end
                end 

                if haskey(derivative, "dependenciesKind")
                    derKind = split(derivative["dependenciesKind"], " ")
                end 

                push!(indices, (ind, der, derKind))
            end
        end
    end
    sort!(indices, rev=true)
end

# Parses the model variables of the FMU model description.
function parseModelVariables(nodes::EzXML.Node, md::fmi2ModelDescription, derivativeIndices)
    lastValueReference = fmi2ValueReference(0)
    derivativeIndex = nothing
    if derivativeIndices != []
        derivativeIndex = pop!(derivativeIndices)
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

        if !(ValueReference in md.valueReferences)
            push!(md.valueReferences, ValueReference)
        end

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
        datatype = fmi2SetDatatypeVariables(node, md)

        dependencies = []
        dependenciesKind = []

        if derivativeIndex != nothing
            if index == derivativeIndex[1]
                push!(md.stateValueReferences, lastValueReference)
                push!(md.derivativeValueReferences, ValueReference)
    
                if derivativeIndices != []
                    derivativeIndex = pop!(derivativeIndices)
                end
            end
        end

        scalarVariables[index] = fmi2ScalarVariable(name, ValueReference, datatype, description, causality, variability, initial, dependencies, dependenciesKind)

        if causality == "output"
            push!(md.outputValueReferences, ValueReference)
        elseif causality == "input"
            push!(md.inputValueReferences, ValueReference)
        end
        md.stringValueReferences[name] = ValueReference

        lastValueReference = ValueReference
        index += 1
    end
    md.numberOfContinuousStates = length(md.stateValueReferences)
    scalarVariables
end

# Parses the model variables of the FMU model description.
function parseDependencies(nodes::EzXML.Node, md::fmi2ModelDescription)
    for node in eachelement(nodes)
        
        if node.name == "Unknown"

            index = 0
            dependencies = nothing
            dependenciesKind = nothing

            if haskey(node, "index")
                index = parseInteger(node["index"])
                dependencies = "" 
                dependenciesKind = ""

                if haskey(node, "dependencies")
                    dependencies = node["dependencies"]
                end 

                if haskey(node, "dependenciesKind")
                    dependenciesKind = node["dependenciesKind"]
                end

                if length(dependencies) > 0 && length(dependenciesKind) > 0
                    dependenciesSplit = split(dependencies, " ")
                    dependenciesKindSplit = split(dependenciesKind, " ")

                    if length(dependenciesSplit) != length(dependenciesKindSplit)
                        @warn "Length of field dependencies ($(length(dependenciesSplit))) doesn't match length of dependenciesKind ($(length(dependenciesKindSplit)))."
                    else
                        md.modelVariables[index].dependencies = vcat(md.modelVariables[index].dependencies, collect(parseInteger(s) for s in dependenciesSplit)) 
                        md.modelVariables[index].dependenciesKind = vcat(md.modelVariables[index].dependenciesKind,  dependenciesKindSplit)
                    end
                else 
                    md.modelVariables[index].dependencies = []
                    md.modelVariables[index].dependenciesKind = []
                end
            else 
                @warn "Invalid entry for node `Unknown` in `ModelStructure`, missing entry `index`."
            end
        else 
            @warn "Unknown entry in `ModelStructure` named `$(node.name)`."
        end 
    end
end

""" 
Returns the model variable(s) fitting the value reference.
"""
function fmi2ModelVariablesForValueReference(md::fmi2ModelDescription, vr::fmi2ValueReference)
    ar = []
    for modelVariable in md.modelVariables
        if modelVariable.valueReference == vr 
            push!(ar, modelVariable)
        end 
    end 
    ar
end

# Parses a Bool value represented by a string.
function parseBoolean(s::Union{String, SubString{String}}; onfail=nothing)
    if s == "true"
        return true
    elseif s == "false"
        return false
    else
        @assert onfail != nothing ["parseBoolean(...) unknown boolean value '$s'."]
        return onfail
    end
end

function parseNodeBoolean(node, key; onfail=nothing)
    if haskey(node, key)
        return parseBoolean(node[key]; onfail=onfail)
    else
        return onfail
    end
end

# Parses an Integer value represented by a string.
function parseInteger(s::Union{String, SubString{String}}; onfail=nothing)
    if onfail == nothing
        return parse(fmi2Integer, s)
    else
        try
            return parse(fmi2Integer, s)
        catch
            return onfail
        end
    end
end

function parseNodeInteger(node, key; onfail=nothing)
    if haskey(node, key)
        return parseInteger(node[key]; onfail=onfail)
    else
        return onfail
    end
end

# Parses a real value represented by a string.
function parseReal(s::Union{String, SubString{String}}; onfail=nothing)
    if onfail == nothing
        return parse(fmi2Real, s)
    else
        try
            return parse(fmi2Real, s)
        catch
            return onfail
        end
    end
end

function parseNodeReal(node, key; onfail=nothing)
    if haskey(node, key)
        return parseReal(node[key]; onfail=onfail)
    else
        return onfail
    end
end

function parseNodeString(node, key; onfail=nothing)
    if haskey(node, key)
        return node[key]
    else
        return onfail
    end
end

# Parses a fmi2Boolean value represented by a string.
function parseFMI2Boolean(s::Union{String, SubString{String}})
    if parseBoolean(s)
        return fmi2True
    else
        return fmi2False
    end
end

# set the datatype and attributes of an model variable
function fmi2SetDatatypeVariables(node::EzXML.Node, md::fmi2ModelDescription)
    type = fmi2DatatypeVariable()
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
    type.datatype = nothing

    if typename == "Real"
        type.datatype = fmi2Real
    elseif typename == "String"
        type.datatype = fmi2String
    elseif typename == "Boolean"
        type.datatype = fmi2Boolean
    elseif typename == "Integer"
        type.datatype = fmi2Integer
    elseif typename == "Enumeration"
        type.datatype = fmi2Enum
    else 
        @warn "Unknown data type `$(type.datatype)`."
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
                    type.start = md.enumerations[i][1 + parse(fmi2Integer, typenode["start"])] # find the enum value and set it
                end
            end
        elseif typename == "String"
            type.start = typenode["start"]
        else
            @warn "setDatatypeVariables(...) unimplemented start value type $typename"
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
        type.relativeQuantity = convert(fmi2Boolean, parse(Bool, typenode["relativeQuantity"]))
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

#=
Read all enumerations from the modeldescription and store them in a matrix. First entries are the enum names
-------------------------------------------
Example:
"enum1name" "value1"    "value2"
"enum2name" "value1"    "value2"
=#
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
