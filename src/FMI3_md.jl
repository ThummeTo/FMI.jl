# #
# # Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# # Licensed under the MIT license. See LICENSE file in the project root for details.
# #

using EzXML

"""
Extract the FMU variables and meta data from the ModelDescription
"""
function fmi3ReadModelDescription(pathToModellDescription::String)
    md = fmi3ModelDescription()

    md.stringValueReferences = Dict{String, fmi3ValueReference}()
    md.outputValueReferences = Array{fmi3ValueReference}(undef, 0)
    md.inputValueReferences = Array{fmi3ValueReference}(undef, 0)
    md.stateValueReferences = Array{fmi3ValueReference}(undef, 0)
    md.derivativeValueReferences = Array{fmi3ValueReference}(undef, 0)
    md.intermediateUpdateValueReferences = Array{fmi3ValueReference}(undef, 0)

    # CS specific entries
    md.CSmodelIdentifier = ""
    md.CSneedsExecutionTool = false
    md.CScanBeInstantiatedOnlyOncePerProcess = false
    md.CScanGetAndSetFMUstate = false
    md.CScanSerializeFMUstate = false
    md.CSprovidesDirectionalDerivatives = false
    md.CSproivdesAdjointDerivatives = false
    md.CSprovidesPerElementDependencies = false
    md.CScanHandleVariableCommunicationStepSize = false
    md.CSmaxOutputDerivativeOrder = 0
    md.CSprovidesIntermediateUpdate = false
    md.CSrecommendedIntermediateInputSmoothness = 0
    md.CScanReturnEarlyAfterIntermediateUpdate = false
    md.CShasEventMode = false
    md.CSprovidesEvaluateDiscreteStates = false

    # ME specific entries
    md.MEmodelIdentifier = ""
    md.MEcanGetAndSetFMUstate = false
    md.MEcanSerializeFMUstate = false
    md.MEprovidesDirectionalDerivatives = false
    md.MEprovidesAdjointDerivatives = false

    md.enumerations = []
    typedefinitions = nothing
    modelvariables = nothing
    modelstructure = nothing

    doc = readxml(pathToModellDescription)

    root = doc.root

    md.fmiVersion = root["fmiVersion"]
    md.modelName = root["modelName"]
    md.instantiationToken = root["instantiationToken"]
    md.isModelExchange = false
    md.isCoSimulation = false
    md.isScheduledExecution = false
    md.generationTool = parseNodeString(root, "generationTool"; onfail="[Unknown generation tool]")
    md.generationDateAndTime = parseNodeString(root, "generationDateAndTime"; onfail="[Unknown generation date and time]")
    md.variableNamingConvention = parseNodeString(root, "variableNamingConvention"; onfail="[Unknown variable naming convention]")
    md.description = parseNodeString(root, "description"; onfail="[Unknown Description]")

    for node in eachelement(root)

        if node.name == "CoSimulation"
            md.isCoSimulation = true
            md.CSmodelIdentifier                        = node["modelIdentifier"]
            md.CSneedsExecutionTool                     = parseNodeBoolean(node, "needsExecutionTool"                       ; onfail=false)
            md.CScanBeInstantiatedOnlyOncePerProcess    = parseNodeBoolean(node, "canBeInstantiatedOnlyOncePerProcess"      ; onfail=false)
            md.CScanGetAndSetFMUstate                   = parseNodeBoolean(node, "canGetAndSetFMUState"                     ; onfail=false)
            md.CScanSerializeFMUstate                   = parseNodeBoolean(node, "canSerializeFMUstate"                     ; onfail=false)
            md.CSprovidesDirectionalDerivatives         = parseNodeBoolean(node, "providesDirectionalDerivatives"           ; onfail=false)
            md.CSproivdesAdjointDerivatives             = parseNodeBoolean(node, "providesAdjointDerivatives"               ; onfail=false)
            md.CSprovidesPerElementDependencies         = parseNodeBoolean(node, "providesPerElementDependencies"           ; onfail=false)
            md.CScanHandleVariableCommunicationStepSize = parseNodeBoolean(node, "canHandleVariableCommunicationStepSize"   ; onfail=false)
            md.CSmaxOutputDerivativeOrder               = parseNodeInteger(node, "maxOutputDerivativeOrder"                 ; onfail=0)
            md.CSprovidesIntermediateUpdate             = parseNodeBoolean(node, "providesIntermediateUpdate"               ; onfail=false)
            md.CSrecommendedIntermediateInputSmoothness = parseNodeInteger(node, "recommendedIntermediateInputSmoothness"   ; onfail=0)
            md.CScanReturnEarlyAfterIntermediateUpdate  = parseNodeBoolean(node, "canReturnEarlyAfterIntermediateUpdate"    ; onfail=false)
            md.CShasEventMode                           = parseNodeBoolean(node, "hasEventMode"                             ; onfail=false)
            md.CSprovidesEvaluateDiscreteStates         = parseNodeBoolean(node, "providesEvaluateDiscreteStates"           ; onfail=false)

        elseif node.name == "ModelExchange"
            # TODO check if all are included
            md.isModelExchange = true
            md.MEmodelIdentifier                        = node["modelIdentifier"]
            md.MEcanGetAndSetFMUstate                   = parseNodeBoolean(node, "canGetAndSetFMUstate"                     ; onfail=false)
            md.MEcanSerializeFMUstate                   = parseNodeBoolean(node, "canSerializeFMUstate"                     ; onfail=false)
            md.MEprovidesDirectionalDerivatives         = parseNodeBoolean(node, "providesDirectionalDerivatives"           ; onfail=false)
            md.MEprovidesAdjointDerivatives             = parseNodeBoolean(node, "providesAdjointDerivatives"               ; onfail=false)
        elseif node.name == "ScheduledExecution"
            md.isScheduledExecution = true
            md.SEmodelIdentifier                        = node["modelIdentifier"]
            # TODO
        elseif node.name == "TypeDefinitions"
            typedefinitions = node

        elseif node.name == "ModelVariables"
            modelvariables = node

        elseif node.name == "ModelStructure"
            modelstructure = node
        end
    end

    if typedefinitions === nothing
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

    # check all intermediateUpdate variables
    for variable in md.modelVariables
        if Bool(variable.datatype.intermediateUpdate)
            push!(md.intermediateUpdateValueReferences, variable.valueReference)
        end
    end

    md
end

"""
Returns the tag 'modelName' from the model description.
"""
function fmi3GetModelName(md::fmi3ModelDescription)#, escape::Bool = true)
    md.modelName
end

"""
Returns the tag 'instantionToken' from the model description.
"""
function fmi3GetInstantiationToken(md::fmi3ModelDescription)
    md.instantiationToken
end

"""
Returns the tag 'generationtool' from the model description.
"""
function fmi3GetGenerationTool(md::fmi3ModelDescription)
    md.generationTool
end

"""
Returns the tag 'generationdateandtime' from the model description.
"""
function fmi3GetGenerationDateAndTime(md::fmi3ModelDescription)
    md.generationDateAndTime
end

"""
Returns the tag 'varaiblenamingconvention' from the model description.
"""
function fmi3GetVariableNamingConvention(md::fmi3ModelDescription)
    md.variableNamingConvention
end


# """
# Returns if the FMU model description contains `dependency` information.
# """
# function fmi2DependenciesSupported(md::fmi2ModelDescription)
#     for mv in md.modelVariables
#         if mv.dependencies != nothing && length(mv.dependencies) > 0
#             return true
#         end
#     end 

#     return false
# end

"""
Returns the tag 'modelIdentifier' from CS or ME section.
"""
function fmi3GetModelIdentifier(md::fmi3ModelDescription)
    if fmi3IsCoSimulation(md)
        return md.CSmodelIdentifier
    elseif fmi3IsModelExchange(md)
        return md.MEmodelIdentifier
    else
        @assert false "fmi3GetModelName(...): FMU does not support ME or CS!"
    end
end

"""
Returns true, if the FMU supports the getting/setting of states
"""
function fmi3CanGetSetState(md::fmi3ModelDescription)
    if md.CScanGetAndSetFMUstate || md.MEcanGetAndSetFMUstate
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU state can be serialized
"""
function fmi3CanSerializeFMUstate(md::fmi3ModelDescription)
    if md.CScanSerializeFMUstate || md.MEcanSerializeFMUstate
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU provides directional derivatives
"""
function fmi3ProvidesDirectionalDerivatives(md::fmi3ModelDescription)
    if md.CSprovidesDirectionalDerivatives || md.MEprovidesDirectionalDerivatives
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU provides adjoint derivatives
"""
function fmi3ProvidesAdjointDerivatives(md::fmi3ModelDescription)
    if md.CSproivdesAdjointDerivatives || md.MEprovidesAdjointDerivatives
        return true
    else
        return false
    end
end

"""
Returns true, if the FMU supports co simulation
"""
function fmi3IsCoSimulation(md::fmi3ModelDescription)
    md.isCoSimulation
end

"""
Returns true, if the FMU supports model exchange
"""
function fmi3IsModelExchange(md::fmi3ModelDescription)
    md.isModelExchange
end

function fmi3IsScheduledExecution(md::fmi3ModelDescription)
    md.isScheduledExecution
end

# Returns the indices of the state derivatives.
function fmi3getDerivativeIndices(node::EzXML.Node)
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
                        der = fmi3Integer[]
                    else
                        der = collect(parse(fmi3Integer, e) for e in der)
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
function parseModelVariables(nodes::EzXML.Node, md::fmi3ModelDescription, derivativeIndices)
    lastValueReference = fmi3ValueReference(0)
    derivativeIndex = nothing
    if derivativeIndices != []
        derivativeIndex = pop!(derivativeIndices)
    end
    numberOfVariables = 0
    for node in eachelement(nodes)
        numberOfVariables += 1
    end
    modelVariables = Array{fmi3ModelVariable}(undef, numberOfVariables)
    index = 1
    # TODO bis hhierierher
    for node in eachelement(nodes)
        name = node["name"]
        ValueReference = parse(fmi3ValueReference, (node["valueReference"]))
        description = ""
        causality = ""
        variability = ""

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
        datatype = fmi3setDatatypeVariables(node, md)

        dependencies = []
        dependenciesKind = []

        if derivativeIndex !== nothing
            if index == derivativeIndex[1]
                push!(md.stateValueReferences, lastValueReference)
                push!(md.derivativeValueReferences, ValueReference)
    
                if derivativeIndices != []
                    derivativeIndex = pop!(derivativeIndices)
                end
            end
        end

        modelVariables[index] = fmi3ModelVariable(name, ValueReference, datatype, description, causality, variability, dependencies, dependenciesKind)

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
    modelVariables
end

# # Parses the model variables of the FMU model description.
# function parseDependencies(nodes::EzXML.Node, md::fmi2ModelDescription)
#     for node in eachelement(nodes)
        
#         if node.name == "Unknown"

#             index = 0
#             dependencies = nothing
#             dependenciesKind = nothing

#             if haskey(node, "index") && haskey(node, "dependencies") && haskey(node, "dependenciesKind")
#                 index = parseInteger(node["index"])
#                 dependencies = node["dependencies"]
#                 dependenciesKind = node["dependenciesKind"]

#                 if length(dependencies) > 0 && length(dependenciesKind) > 0
#                     dependenciesSplit = split(dependencies, " ")
#                     dependenciesKindSplit = split(dependenciesKind, " ")

#                     if length(dependenciesSplit) != length(dependenciesKindSplit)
#                         @warn "Length of field dependencies ($(length(dependenciesSplit))) doesn't match length of dependenciesKind ($(length(dependenciesKindSplit)))."
#                     else
#                         md.modelVariables[index].dependencies = vcat(md.modelVariables[index].dependencies, collect(parseInteger(s) for s in dependenciesSplit)) 
#                         md.modelVariables[index].dependenciesKind = vcat(md.modelVariables[index].dependenciesKind,  dependenciesKindSplit)
#                     end
#                 else 
#                     md.modelVariables[index].dependencies = []
#                     md.modelVariables[index].dependenciesKind = []
#                 end
#             else 
#                 @warn "Invalid entry for node `Unknown` in `ModelStructure`."
#             end
#         else 
#             @warn "Unknown entry in `ModelStructure` named `$(node.name)`."
#         end 
#     end
# end

# """ 
# Returns the model variable(s) fitting the value reference.
# """
# function fmi2ModelVariablesForValueReference(md::fmi2ModelDescription, vr::fmi2ValueReference)
#     ar = []
#     for modelVariable in md.modelVariables
#         if modelVariable.valueReference == vr 
#             push!(ar, modelVariable)
#         end 
#     end 
#     ar
# end

# Parses a Bool value represented by a string.
function fmi3parseBoolean(s::Union{String, SubString{String}}; onfail=nothing)
    if s == "true"
        return true
    elseif s == "false"
        return false
    else
        @assert onfail != nothing ["parseBoolean(...) unknown boolean value '$s'."]
        return onfail
    end
end

function fmi3parseNodeBoolean(node, key; onfail=nothing)
    if haskey(node, key)
        return fmi3parseBoolean(node[key]; onfail=onfail)
    else
        return onfail
    end
end

# Parses an Integer value represented by a string.
function fmi3parseInteger(s::Union{String, SubString{String}}; onfail=nothing)
    if onfail == nothing
        return parse(Int, s)
    else
        try
            return parse(Int, s)
        catch
            return onfail
        end
    end
end

function fmi3parseNodeInteger(node, key; onfail=nothing)
    if haskey(node, key)
        return fmi3parseInteger(node[key]; onfail=onfail)
    else
        return onfail
    end
end

function fmi3parseNodeString(node, key; onfail=nothing)
    if haskey(node, key)
        return node[key]
    else
        return onfail
    end
end

# Parses a fmi2Boolean value represented by a string.
function parseFMI3Boolean(s::Union{String, SubString{String}})
    if fmi3parseBoolean(s)
        return fmi3True
    else
        return fmi3False
    end
end

# set the datatype and attributes of an model variable
function fmi3setDatatypeVariables(node::EzXML.Node, md::fmi3ModelDescription)
    type = fmi3datatypeVariable()
    typename = node.name
    type.canHandleMultipleSet = nothing
    type.intermediateUpdate = false
    type.previous = nothing
    type.clocks = nothing
    type.declaredType = nothing
    type.start = nothing
    type.min = nothing
    type.max = nothing
    type.initial = nothing
    type.quantity = nothing
    type.unit = nothing
    type.displayUnit = nothing
    type.relativeQuantity = nothing
    type.nominal = nothing
    type.unbounded = nothing
    type.derivative = nothing
    type.reinit = nothing
    type.mimeType = nothing
    type.maxSize = nothing

    if typename == "Float32"
        type.datatype = fmi3Float32
    elseif typename == "Float64"
        type.datatype = fmi3Float64
    elseif typename == "Int8"
        type.datatype = fmi3Int8
    elseif typename == "UInt8"
        type.datatype = fmi3UInt8
    elseif typename == "Int16"
        type.datatype = fmi3Int16
    elseif typename == "UInt16"
        type.datatype = fmi3UInt16
    elseif typename == "Int32"
        type.datatype = fmi3Int32
    elseif typename == "UInt32"
        type.datatype = fmi3UInt32
    elseif typename == "Int64"
        type.datatype = fmi3Int64
    elseif typename == "UInt64"
        type.datatype = fmi3UInt64
    elseif typename == "Boolean"
        type.datatype = fmi3Boolean
    elseif typename == "Binary" # nicht sicher wie diese Datentypen in der modelDescription ausschauen
        type.datatype = fmi3Binary
    elseif typename == "Char"
        type.datatype = fmi3Char
    elseif typename == "String"
        type.datatype = fmi3String
    elseif typename == "Byte"
        type.datatype = fmi3Byte
    elseif typename == "Enum"
        type.datatype = fmi3Enum
    else
        @warn "Datatype for the variable $(node["name"]) is unknown!"
    end

    if haskey(node, "declaredType")
        type.declaredType = node["declaredType"]
    end

    if haskey(node, "initial")
        if !occursin(node["initial"], string(instances(fmi3initial)))
            display("Error: initial not known")
        else
            for i in 0:(length(instances(fmi3initial))-1)
                if node["initial"] == string(fmi3initial(i))
                    type.initial = fmi3initial(i)
                end
            end
        end
    end

    if haskey(node, "start")
        if typename == "Float32"
            type.start = parse(fmi3Float32, node["start"])
        elseif typename == "Float64"
            type.start = parse(fmi3Float32, node["start"])
        elseif typename == "Int8"
            type.start = parse(fmi3Int8, node["start"])
        elseif typename == "UInt8"
            type.start = parse(fmi3UInt8, node["start"])
        elseif typename == "Int16"
            type.start = parse(fmi3Int16, node["start"])
        elseif typename == "UInt16"
            type.start = parse(fmi3UInt16, node["start"])
        elseif typename == "Int32"
            type.start = parse(fmi3Int32, node["start"])
        elseif typename == "UInt32"
            type.start = parse(fmi3UInt32, node["start"])
        elseif typename == "Int64"
            type.start = parse(fmi3Int64, node["start"])
        elseif typename == "UInt64"
            type.start = parse(fmi3UInt64, node["start"]) 
        elseif typename == "Boolean"
            type.start = parseFMI3Boolean(node["start"])
        elseif typename == "Binary"
            type.start = pointer(node["start"])
        elseif typename == "Char"
            type.start = parse(fmi3Char, node["start"])
        elseif typename == "String"
            type.start = parse(fmi3String, node["start"])
        elseif typename == "Byte"
            type.start = parse(fmi3Byte, node["start"])
        elseif typename == "Enum"
            for i in 1:length(md.enumerations)
                if type.declaredType == md.enumerations[i][1] # identify the enum by the name
                    type.start = md.enumerations[i][1 + parse(Int, node["start"])] # find the enum value and set it
                end
            end
        else
            @warn "setDatatypeVariables(...) unimplemented start value type $typename"
            type.start = node["start"]
        end
    end
    if haskey(node, "intermediateUpdate")
        type.intermediateUpdate = true
    end

    if haskey(node, "min") && (type.datatype != fmi3Binary || type.datatype != fmiBoolean)
        if type.datatype == fmi3Float32 || type.datatype == fmi3Float64
            type.min = parse(fmi3Float64, node["min"])
        elseif type.datatype == fmi3Enum
            type.min = parse(fmi3Int64, node["min"])
        elseif type.datatype == fmi3Int8 || type.datatype == fmi3Int16 || type.datatype == fmi3Int32 || type.datatype == fmi3Int64
            type.min = parse(fmi3Int32, node["min"])
        else
            type.min = parse(fmi3UInt32, node["min"])
        end
    end
    if haskey(node, "max") && (type.datatype != fmi3Binary || type.datatype != fmiBoolean)
        if type.datatype == fmi3Float32 || type.datatype == fmi3Float64
            type.max = parse(fmi3Float64, node["max"])
        elseif type.datatype == fmi3Enum
            type.max = parse(fmi3Int64, node["max"])
        elseif type.datatype == fmi3Int8 || type.datatype == fmi3Int16 || type.datatype == fmi3Int32 || type.datatype == fmi3Int64
            type.max = parse(fmi3Int32, node["max"])
        else
            type.max = parse(fmi3UInt32, node["max"])
        end
    end
    if haskey(node, "quantity") && (type.datatype != Boolean || type.datatype != fmi3Binary)
        type.quantity = node["quantity"]
    end
    if haskey(node, "unit") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.unit = node["unit"]
    end
    if haskey(node, "displayUnit") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.displayUnit = node["displayUnit"]
    end
    if haskey(node, "relativeQuantity") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.relativeQuantity = parseFMI3Boolean(node["relativeQuantity"])
    else
        type.relativeQuantity = fmi3False
    end
    if haskey(node, "nominal") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.nominal = parse(fmi3Float64, node["nominal"])
    end
    if haskey(node, "unbounded") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.unbounded = parseFMI3Boolean(node["unbounded"])
    else
        type.unbounded = fmi3False
    end
    if haskey(node, "derivative") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.derivative = parse(fmi3UInt32, node["derivative"])
    end
    if haskey(node, "reinit") && (type.datatype == fmi3Float32 || type.datatype == fmi3Float64)
        type.reinit = parseFMI3Boolean(node["reinit"])
    end
    if haskey(node, "mimeType") && type.datatype == fmi3Binary
        type.mimeType = node["mimeType"]
    else
        type.mimeType = "application/octet"
    end
    if haskey(node, "maxSize") && type.datatype == fmi3Binary
        type.maxSize = parse(fmi3UInt32, node["maxSize"])
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
function fmi3createEnum(node::EzXML.Node)
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
