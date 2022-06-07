#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI3_additional.jl` (FMU add functions)?
# - high-level functions, that are useful, but not part of the FMI-spec [exported]

using Base.Filesystem: mktempdir

using FMIImport: FMU3, fmi3ModelDescription
using FMIImport: fmi3Float32, fmi3Float64, fmi3Int8, fmi3Int16, fmi3Int32, fmi3Int64, fmi3Boolean, fmi3String, fmi3Binary, fmi3UInt8, fmi3UInt16, fmi3UInt32, fmi3UInt64, fmi3Byte
using FMIImport: fmi3Clock, fmi3FMUState
using FMIImport: fmi3True, fmi3False
using FMIImport: fmi3DependencyKindDependent, fmi3DependencyKindFixed
using FMIImport: fmi3CallbackLogger, fmi3CallbackIntermediateUpdate, fmi3CallbackClockUpdate, fmi3Instance
import FMIImport: fmi3VariableNamingConventionFlat, fmi3VariableNamingConventionStructured

""" 
Returns how a variable depends on another variable based on the model description.
"""
function fmi3VariableDependsOnVariable(fmu::FMU3, vr1::fmi3ValueReference, vr2::fmi3ValueReference) 
    i1 = fmu.modelDescription.valueReferenceIndicies[vr1]
    i2 = fmu.modelDescription.valueReferenceIndicies[vr2]
    return fmi3GetDependencies(fmu)[i1, i2]
end

"""
Returns the FMU's dependency-matrix for fast look-ups on dependencies between value references.

Entries are from type fmi3DependencyKind.
"""
function fmi3GetDependencies(fmu::FMU3)
    if !isdefined(fmu, :dependencies)
        dim = length(fmu.modelDescription.valueReferences)
        @info "fmi3GetDependencies: Started building dependency matrix $(dim) x $(dim) ..."

        if fmi3DependenciesSupported(fmu.modelDescription)
            fmu.dependencies = fill(nothing, dim, dim)

            for i in 1:dim
                modelVariable = fmi3ModelVariablesForValueReference(fmu.modelDescription, fmu.modelDescription.valueReferences[i])[1]
    
                if modelVariable.dependencies !== nothing
                    indicies = collect(fmu.modelDescription.valueReferenceIndicies[fmu.modelDescription.modelVariables[dependency].valueReference] for dependency in modelVariable.dependencies)
                    dependenciesKind = modelVariable.dependenciesKind

                    k = 1
                    for j in 1:dim 
                        if j in indicies
                            if dependenciesKind[k] == "fixed"
                                fmu.dependencies[i,j] = fmi3DependencyKindFixed
                            elseif dependenciesKind[k] == "dependent"
                                fmu.dependencies[i,j] = fmi3DependencyKindDependent
                            else 
                                @warn "Unknown dependency kind for index ($i, $j) = `$(dependenciesKind[k])`."
                            end
                            k += 1
                        end
                    end
                end
            end 
        else 
            fmu.dependencies = fill(nothing, dim, dim)
        end

        @info "fmi3GetDependencies: Building dependency matrix $(dim) x $(dim) finished."
    end 

    fmu.dependencies
end

function fmi3PrintDependencies(fmu::FMU2)
    dep = fmi3GetDependencies(fmu)
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
function fmi3Info(fmu::FMU3)
    println("#################### Begin information for FMU ####################")

    println("\tModel name:\t\t\t$(fmi3GetModelName(fmu))")
    println("\tFMI-Version:\t\t\t$(fmi3GetVersion(fmu))")
    println("\tInstantiation Token:\t\t\t\t$(fmi3GetInstantiationToken(fmu))")
    println("\tGeneration tool:\t\t$(fmi3GetGenerationTool(fmu))")
    println("\tGeneration time:\t\t$(fmi3GetGenerationDateAndTime(fmu))")
    print("\tVar. naming conv.:\t\t")
    if fmi3GetVariableNamingConvention(fmu) == fmi3VariableNamingConventionFlat
        println("flat")
    elseif fmi3GetVariableNamingConvention(fmu) == fmi3VariableNamingConventionStructured
        println("structured")
    else 
        println("[unknown]")
    end
    println("\tEvent indicators:\t\t$(fmi3GetNumberOfEventIndicators(fmu))")

    println("\tInputs:\t\t\t\t$(length(fmu.modelDescription.inputValueReferences))")
    for vr in fmu.modelDescription.inputValueReferences
        println("\t\t$(vr) $(fmi3ValueReferenceToString(fmu, vr))")
    end

    println("\tOutputs:\t\t\t$(length(fmu.modelDescription.outputValueReferences))")
    for vr in fmu.modelDescription.outputValueReferences
        println("\t\t$(vr) $(fmi3ValueReferenceToString(fmu, vr))")
    end

    println("\tStates:\t\t\t\t$(length(fmu.modelDescription.stateValueReferences))")
    for vr in fmu.modelDescription.stateValueReferences
        println("\t\t$(vr) $(fmi3ValueReferenceToString(fmu, vr))")
    end

    println("\tSupports Co-Simulation:\t\t$(fmi3IsCoSimulation(fmu))")
    if fmi3IsCoSimulation(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.coSimulation.modelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.coSimulation.canGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.coSimulation.canSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.coSimulation.providesDirectionalDerivatives)")
        println("\t\tAdj. Derivatives:\t$(fmu.modelDescription.coSimulation.providesAdjointDerivatives)")
        println("\t\tEvent Mode:\t$(fmu.modelDescription.coSimulation.hasEventMode)")

        println("\t\tVar. com. steps:\t$(fmu.modelDescription.coSimulation.canHandleVariableCommunicationStepSize)")
        println("\t\tInput interpol.:\t$(fmu.modelDescription.coSimulation.canInterpolateInputs)")
        println("\t\tMax order out. der.:\t$(fmu.modelDescription.coSimulation.maxOutputDerivativeOrder)")
    end

    println("\tSupports Model-Exchange:\t$(fmi3IsModelExchange(fmu))")
    if fmi3IsModelExchange(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.modelExchange.modelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.modelExchange.canGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.modelExchange.canSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.modelExchange.providesDirectionalDerivatives)")
        println("\t\tAdj. Derivatives:\t$(fmu.modelDescription.modelExchange.providesAdjointDerivatives)")
    end

    println("\tSupports Scheduled-Execution:\t$(fmi3IsScheduledExecution(fmu))")
    if fmi3IsScheduledExecution(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.scheduledExecution.modelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.scheduledExecution.canGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.scheduledExecution.canSerializeFMUstate)")
        println("\t\tNeeds Execution Tool:\t$(fmu.modelDescription.scheduledExecution.needsExecutionTool)")
        println("\t\tInstantiated Once Per Process:\t$(fmu.modelDescription.scheduledExecution.canBeInstantiatedOnlyOncePerProcess)")
        println("\t\tPer Element Dependencies:\t$(fmu.modelDescription.scheduledExecution.providesPerElementDependencies)")
        
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.scheduledExecution.providesDirectionalDerivatives)")
        println("\t\tAdj. Derivatives:\t$(fmu.modelDescription.scheduledExecution.providesAdjointDerivatives)")
    end

    println("##################### End information for FMU #####################")
end
