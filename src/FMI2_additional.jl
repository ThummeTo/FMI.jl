#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI2_additional.jl` (FMU add functions)?
# - high-level functions, that are useful, but not part of the FMI-spec [exported]

using Base.Filesystem: mktempdir

using FMIImport: FMU2, fmi2ModelDescription
using FMIImport: fmi2Boolean, fmi2Real, fmi2Integer, fmi2Byte, fmi2String, fmi2FMUstate
using FMIImport: fmi2True, fmi2False
using FMIImport: fmi2StatusKind, fmi2Status
using FMIImport: fmi2DependencyKindUnknown, fmi2DependencyKindDependent, fmi2DependencyKindFixed
using FMIImport: fmi2CallbackFunctions

""" 
Returns how a variable depends on another variable based on the model description.
"""
function fmi2VariableDependsOnVariable(fmu::FMU2, vr1::fmi2ValueReference, vr2::fmi2ValueReference) 
    i1 = fmu.modelDescription.valueReferenceIndicies[vr1]
    i2 = fmu.modelDescription.valueReferenceIndicies[vr2]
    return fmi2GetDependencies(fmu)[i1, i2]
end

"""
Returns the FMU's dependency-matrix for fast look-ups on dependencies between value references.

Entries are from type fmi2DependencyKind.
"""
function fmi2GetDependencies(fmu::FMU2)
    if !isdefined(fmu, :dependencies)
        dim = length(fmu.modelDescription.valueReferences)
        @info "fmi2GetDependencies: Started building dependency matrix $(dim) x $(dim) ..."

        if fmi2DependenciesSupported(fmu.modelDescription)
            fmu.dependencies = fill(fmi2DependencyKindUnknown, dim, dim)

            for i in 1:dim
                modelVariable = fmi2ModelVariablesForValueReference(fmu.modelDescription, fmu.modelDescription.valueReferences[i])[1]
    
                if modelVariable.dependencies != nothing
                    indicies = collect(fmu.modelDescription.valueReferenceIndicies[fmu.modelDescription.modelVariables[dependency].valueReference] for dependency in modelVariable.dependencies)
                    dependenciesKind = modelVariable.dependenciesKind

                    k = 1
                    for j in 1:dim 
                        if j in indicies
                            if dependenciesKind[k] == "fixed"
                                fmu.dependencies[i,j] = fmi2DependencyKindFixed
                            elseif dependenciesKind[k] == "dependent"
                                fmu.dependencies[i,j] = fmi2DependencyKindDependent
                            else 
                                @warn "Unknown dependency kind for index ($i, $j) = `$(dependenciesKind[k])`."
                            end
                            k += 1
                        end
                    end
                end
            end 
        else 
            fmu.dependencies = fill(fmi2DependencyKindUnknown, dim, dim)
        end

        @info "fmi2GetDependencies: Building dependency matrix $(dim) x $(dim) finished."
    end 

    fmu.dependencies
end

function fmi2PrintDependencies(fmu::FMU2)
    dep = fmi2GetDependencies(fmu)
    ni, nj = size(dep)

    for i in 1:ni
        str = ""
        for j in 1:nj
            str = "$(str) $(Integer(dep[i,j]))"
        end 
        println(str)
    end
end

"""
Prints FMU related information.
"""
function fmi2Info(fmu::FMU2)
    println("#################### Begin information for FMU ####################")

    println("\tModel name:\t\t\t$(fmi2GetModelName(fmu))")
    println("\tFMI-Version:\t\t\t$(fmi2GetVersion(fmu))")
    println("\tGUID:\t\t\t\t$(fmi2GetGUID(fmu))")
    println("\tGeneration tool:\t\t$(fmi2GetGenerationTool(fmu))")
    println("\tGeneration time:\t\t$(fmi2GetGenerationDateAndTime(fmu))")
    println("\tVar. naming conv.:\t\t$(fmi2GetVariableNamingConvention(fmu))")
    println("\tEvent indicators:\t\t$(fmi2GetNumberOfEventIndicators(fmu))")

    println("\tInputs:\t\t\t\t$(length(fmu.modelDescription.inputValueReferences))")
    for vr in fmu.modelDescription.inputValueReferences
        println("\t\t$(vr) $(fmi2ValueReferenceToString(fmu, vr))")
    end

    println("\tOutputs:\t\t\t$(length(fmu.modelDescription.outputValueReferences))")
    for vr in fmu.modelDescription.outputValueReferences
        println("\t\t$(vr) $(fmi2ValueReferenceToString(fmu, vr))")
    end

    println("\tStates:\t\t\t\t$(length(fmu.modelDescription.stateValueReferences))")
    for vr in fmu.modelDescription.stateValueReferences
        println("\t\t$(vr) $(fmi2ValueReferenceToString(fmu, vr))")
    end

    println("\tSupports Co-Simulation:\t\t$(fmi2IsCoSimulation(fmu))")
    if fmi2IsCoSimulation(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.coSimulation.modelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.coSimulation.canGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.coSimulation.canSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.coSimulation.providesDirectionalDerivative)")

        println("\t\tVar. com. steps:\t$(fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize)")
        println("\t\tInput interpol.:\t$(fmu.modelDescription.coSimulation.canInterpolateInputs)")
        println("\t\tMax order out. der.:\t$(fmu.modelDescription.coSimulation.maxOutputDerivativeOrder)")
    end

    println("\tSupports Model-Exchange:\t$(fmi2IsModelExchange(fmu))")
    if fmi2IsModelExchange(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.modelExchange.modelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.modelExchange.canGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.modelExchange.canSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.modelExchange.providesDirectionalDerivative)")
    end

    println("##################### End information for FMU #####################")
end


