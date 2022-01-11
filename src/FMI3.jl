#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl
using ZipFile

include("FMI3_c.jl")
include("FMI3_comp.jl")
include("FMI3_md.jl")

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.1. Header Files and Naming of Functions

The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3 <: FMU
    modelName::fmi3String
    instanceName::fmi3String
    fmuResourceLocation::fmi3String

    modelDescription::fmi3ModelDescription

    type::fmi3Type
    # fmi3CallbackLoggerFunction::fmi3CallbackLoggerFunction
    # fmi3CallbackIntermediateUpdateFunction::fmi3CallbackIntermediateUpdateFunction
    instanceEnvironment::fmi3InstanceEnvironment
    components::Array{fmi3Component}

    # TODO in component struct
    previous_z::Array{fmi3Float64}
    rootsFound::Array{fmi3Int32}
    stateEvent::fmi3Boolean
    timeEvent::fmi3Boolean

    # paths of ziped and unziped FMU folders
    path::String
    zipPath::String

    # c-functions
    cInstantiateModelExchange::Ptr{Cvoid}
    cInstantiateCoSimulation::Ptr{Cvoid}
    cInstantiateScheduledExecution::Ptr{Cvoid}

    cGetVersion::Ptr{Cvoid}
    cFreeInstance::Ptr{Cvoid}
    cSetDebugLogging::Ptr{Cvoid}
    cEnterConfigurationMode::Ptr{Cvoid}
    cExitConfigurationMode::Ptr{Cvoid}
    cEnterInitializationMode::Ptr{Cvoid}
    cExitInitializationMode::Ptr{Cvoid}
    cTerminate::Ptr{Cvoid}
    cReset::Ptr{Cvoid}
    cGetFloat32::Ptr{Cvoid}
    cSetFloat32::Ptr{Cvoid}
    cGetFloat64::Ptr{Cvoid}
    cSetFloat64::Ptr{Cvoid}
    cGetInt8::Ptr{Cvoid}
    cSetInt8::Ptr{Cvoid}
    cGetUInt8::Ptr{Cvoid}
    cSetUInt8::Ptr{Cvoid}
    cGetInt16::Ptr{Cvoid}
    cSetInt16::Ptr{Cvoid}
    cGetUInt16::Ptr{Cvoid}
    cSetUInt16::Ptr{Cvoid}
    cGetInt32::Ptr{Cvoid}
    cSetInt32::Ptr{Cvoid}
    cGetUInt32::Ptr{Cvoid}
    cSetUInt32::Ptr{Cvoid}
    cGetInt64::Ptr{Cvoid}
    cSetInt64::Ptr{Cvoid}
    cGetUInt64::Ptr{Cvoid}
    cSetUInt64::Ptr{Cvoid}
    cGetBoolean::Ptr{Cvoid}
    cSetBoolean::Ptr{Cvoid}
    cGetString::Ptr{Cvoid}
    cSetString::Ptr{Cvoid}
    cGetBinary::Ptr{Cvoid}
    cSetBinary::Ptr{Cvoid}
    cGetFMUState::Ptr{Cvoid}
    cSetFMUState::Ptr{Cvoid}
    cFreeFMUState::Ptr{Cvoid}
    cSerializedFMUStateSize::Ptr{Cvoid}
    cSerializeFMUState::Ptr{Cvoid}
    cDeSerializeFMUState::Ptr{Cvoid}
    cGetDirectionalDerivative::Ptr{Cvoid}
    cGetAdjointDerivative::Ptr{Cvoid}
    cEvaluateDiscreteStates::Ptr{Cvoid}
    cGetNumberOfVariableDependencies::Ptr{Cvoid}
    cGetVariableDependencies::Ptr{Cvoid}

    # Co Simulation function calls
    cGetOutputDerivatives::Ptr{Cvoid}
    cEnterStepMode::Ptr{Cvoid}
    cDoStep::Ptr{Cvoid}

    # Model Exchange function calls
    cGetNumberOfContinuousStates::Ptr{Cvoid}
    cGetNumberOfEventIndicators::Ptr{Cvoid}
    cGetContinuousStates::Ptr{Cvoid}
    cGetNominalsOfContinuousStates::Ptr{Cvoid}
    cEnterContinuousTimeMode::Ptr{Cvoid}
    cSetTime::Ptr{Cvoid}
    cSetContinuousStates::Ptr{Cvoid}
    cGetContinuousStateDerivatives::Ptr{Cvoid}
    cGetEventIndicators::Ptr{Cvoid}
    cCompletedIntegratorStep::Ptr{Cvoid}
    cEnterEventMode::Ptr{Cvoid}
    cUpdateDiscreteStates::Ptr{Cvoid}

    # Scheduled Execution function calls
    cSetIntervalDecimal::Ptr{Cvoid}
    cSetIntervalFraction::Ptr{Cvoid}
    cGetIntervalDecimal::Ptr{Cvoid}
    cGetIntervalFraction::Ptr{Cvoid}
    cGetShiftDecimal::Ptr{Cvoid}
    cGetShiftFraction::Ptr{Cvoid}
    cActivateModelPartition::Ptr{Cvoid}

    # c-libraries
    libHandle::Ptr{Nothing}

    # # START: experimental section (to FMIFlux.jl)
    # dependencies::Matrix{fmi2Dependency}

    # t::Real         # current time
    # next_t::Real    # next time

    # x       # current state
    # next_x  # next state

    # dx      # current state derivative
    # simulationResult

    # jac_dxy_x::Matrix{fmi2Real}
    # jac_dxy_u::Matrix{fmi2Real}
    # jac_x::Array{fmi2Real}
    # jac_t::fmi2Real
    # # END: experimental section

    # Constructor
    FMU3() = new()

end


"""
Sets the properties of the fmu by reading the modelDescription.xml.
Retrieves all the pointers of binary functions.

Returns the instance of the FMU struct.

Via optional argument ```unpackPath```, a path to unpack the FMU can be specified (default: system temporary directory).
"""
function fmi3Load(pathToFMU::String; unpackPath=nothing)
    # Create uninitialized FMU
    fmu = FMU3()
    fmu.components = []

    pathToFMU = normpath(pathToFMU)

    # set paths for fmu handling
    (fmu.path, fmu.zipPath) = fmi3Unzip(pathToFMU; unpackPath=unpackPath) # TODO

    # set paths for modelExchangeScripting and binary
    tmpName = splitpath(fmu.path)
    pathToModelDescription = joinpath(fmu.path, "modelDescription.xml")

    # parse modelDescription.xml
    fmu.modelDescription = fmi3ReadModelDescription(pathToModelDescription) # TODO Matrix mit Dimensions
    fmu.modelName = fmu.modelDescription.modelName
    fmu.instanceName = fmu.modelDescription.modelName
    fmuName = fmi3GetModelIdentifier(fmu.modelDescription) # tmpName[length(tmpName)] TODO

    directoryBinary = ""
    pathToBinary = ""

    if Sys.iswindows()
        directories = [joinpath("binaries", "win64"), joinpath("binaries","x86_64-windows")]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$(fmuName).dll")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is Windows, but can't find valid FMU binary at `$(pathToBinary)` for path `$(fmu.path)`."
    elseif Sys.islinux()
        directories = [joinpath("binaries", "linux64"), joinpath("binaries", "x86_64-linux")]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$(fmuName).so")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is Linux, but can't find valid FMU binary at `$(pathToBinary)` for path `$(fmu.path)`."
    elseif Sys.isapple()
        directories = [joinpath("binaries", "darwin64"), joinpath("binaries", "x86_64-darwin")]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$(fmuName).dylib")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is macOS, but can't find valid FMU binary at `$(pathToBinary)` for path `$(fmu.path)`."
    else
        @assert false "Unsupported target platform. Supporting Windows64, Linux64 and Mac64."
    end

    lastDirectory = pwd()
    cd(directoryBinary)

    # set FMU binary handler
    fmu.libHandle = dlopen(pathToBinary)

    cd(lastDirectory)

    if fmi3IsCoSimulation(fmu) 
        fmu.type = fmi3CoSimulation::fmi3Type
    elseif fmi3IsModelExchange(fmu) 
        fmu.type = fmi3ModelExchange::fmi3Type
    elseif fmi3IsScheduledExecution(fmu) 
        fmu.type = fmi3ScheduledExecution::fmi3Type
    else
        error(unknownFMUType)
    end

    if fmi3IsCoSimulation(fmu) && fmi3IsModelExchange(fmu) 
        @info "fmi3Load(...): FMU supports both CS and ME, using CS as default if nothing specified." # TODO ScheduledExecution
    end

    # make URI ressource location
    tmpResourceLocation = string("file:///", fmu.path)
    tmpResourceLocation = joinpath(tmpResourceLocation, "resources")
    fmu.fmuResourceLocation = replace(tmpResourceLocation, "\\" => "/") # URIs.escapeuri(tmpResourceLocation)

    @info "fmi3Load(...): FMU resources location is `$(fmu.fmuResourceLocation)`"

    # # retrieve functions 
    fmu.cInstantiateModelExchange                  = dlsym(fmu.libHandle, :fmi3InstantiateModelExchange)
    fmu.cInstantiateCoSimulation                   = dlsym(fmu.libHandle, :fmi3InstantiateCoSimulation)
    fmu.cInstantiateScheduledExecution             = dlsym(fmu.libHandle, :fmi3InstantiateScheduledExecution)
    fmu.cGetVersion                                = dlsym(fmu.libHandle, :fmi3GetVersion)
    fmu.cFreeInstance                              = dlsym(fmu.libHandle, :fmi3FreeInstance)
    fmu.cSetDebugLogging                           = dlsym(fmu.libHandle, :fmi3SetDebugLogging)
    fmu.cEnterConfigurationMode                    = dlsym(fmu.libHandle, :fmi3EnterConfigurationMode)
    fmu.cExitConfigurationMode                     = dlsym(fmu.libHandle, :fmi3ExitConfigurationMode)
    fmu.cEnterInitializationMode                   = dlsym(fmu.libHandle, :fmi3EnterInitializationMode)
    fmu.cExitInitializationMode                    = dlsym(fmu.libHandle, :fmi3ExitInitializationMode)
    fmu.cTerminate                                 = dlsym(fmu.libHandle, :fmi3Terminate)
    fmu.cReset                                     = dlsym(fmu.libHandle, :fmi3Reset)
    fmu.cEvaluateDiscreteStates                    = dlsym(fmu.libHandle, :fmi3EvaluateDiscreteStates)
    fmu.cGetNumberOfVariableDependencies           = dlsym(fmu.libHandle, :fmi3GetNumberOfVariableDependencies)
    fmu.cGetVariableDependencies                   = dlsym(fmu.libHandle, :fmi3GetVariableDependencies)

    fmu.cGetFloat32                                = dlsym(fmu.libHandle, :fmi3GetFloat32)
    fmu.cSetFloat32                                = dlsym(fmu.libHandle, :fmi3SetFloat32)
    fmu.cGetFloat64                                = dlsym(fmu.libHandle, :fmi3GetFloat64)
    fmu.cSetFloat64                                = dlsym(fmu.libHandle, :fmi3SetFloat64)
    fmu.cGetInt8                                   = dlsym(fmu.libHandle, :fmi3GetInt8)
    fmu.cSetInt8                                   = dlsym(fmu.libHandle, :fmi3SetInt8)
    fmu.cGetUInt8                                  = dlsym(fmu.libHandle, :fmi3GetUInt8)
    fmu.cSetUInt8                                  = dlsym(fmu.libHandle, :fmi3SetUInt8)
    fmu.cGetInt16                                  = dlsym(fmu.libHandle, :fmi3GetInt16)
    fmu.cSetInt16                                  = dlsym(fmu.libHandle, :fmi3SetInt16)
    fmu.cGetUInt16                                 = dlsym(fmu.libHandle, :fmi3GetUInt16)
    fmu.cSetUInt16                                 = dlsym(fmu.libHandle, :fmi3SetUInt16)
    fmu.cGetInt32                                  = dlsym(fmu.libHandle, :fmi3GetInt32)
    fmu.cSetInt32                                  = dlsym(fmu.libHandle, :fmi3SetInt32)
    fmu.cGetUInt32                                 = dlsym(fmu.libHandle, :fmi3GetUInt32)
    fmu.cSetUInt32                                 = dlsym(fmu.libHandle, :fmi3SetUInt32)
    fmu.cGetInt64                                  = dlsym(fmu.libHandle, :fmi3GetInt64)
    fmu.cSetInt64                                  = dlsym(fmu.libHandle, :fmi3SetInt64)
    fmu.cGetUInt64                                 = dlsym(fmu.libHandle, :fmi3GetUInt64)
    fmu.cSetUInt64                                 = dlsym(fmu.libHandle, :fmi3SetUInt64)
    fmu.cGetBoolean                                = dlsym(fmu.libHandle, :fmi3GetBoolean)
    fmu.cSetBoolean                                = dlsym(fmu.libHandle, :fmi3SetBoolean)

    fmu.cGetString                                 = dlsym_opt(fmu.libHandle, :fmi3GetString)
    fmu.cSetString                                 = dlsym_opt(fmu.libHandle, :fmi3SetString)
    fmu.cGetBinary                                 = dlsym_opt(fmu.libHandle, :fmi3GetBinary)
    fmu.cSetBinary                                 = dlsym_opt(fmu.libHandle, :fmi3SetBinary)

    if fmi3CanGetSetState(fmu)
        fmu.cGetFMUState                           = dlsym_opt(fmu.libHandle, :fmi3GetFMUState)
        fmu.cSetFMUState                           = dlsym_opt(fmu.libHandle, :fmi3SetFMUState)
        fmu.cFreeFMUState                          = dlsym_opt(fmu.libHandle, :fmi3FreeFMUState)
    end

    if fmi3CanSerializeFMUstate(fmu)
        fmu.cSerializedFMUStateSize                = dlsym_opt(fmu.libHandle, :fmi3SerializedFMUStateSize)
        fmu.cSerializeFMUState                     = dlsym_opt(fmu.libHandle, :fmi3SerializeFMUState)
        fmu.cDeSerializeFMUState                   = dlsym_opt(fmu.libHandle, :fmi3DeSerializeFMUState)
    end

    if fmi3ProvidesDirectionalDerivatives(fmu)
        fmu.cGetDirectionalDerivative              = dlsym_opt(fmu.libHandle, :fmi3GetDirectionalDerivative)
    end

    if fmi3ProvidesAdjointDerivatives(fmu)
        fmu.cGetAdjointDerivative              = dlsym_opt(fmu.libHandle, :fmi3GetAdjointDerivative)
    end

    # CS specific function calls
    if fmi3IsCoSimulation(fmu)
        fmu.cGetOutputDerivatives                  = dlsym(fmu.libHandle, :fmi3GetOutputDerivatives)
        fmu.cEnterStepMode                         = dlsym(fmu.libHandle, :fmi3EnterStepMode)
        fmu.cDoStep                                = dlsym(fmu.libHandle, :fmi3DoStep)
    end

    # ME specific function calls
    if fmi3IsModelExchange(fmu)
        fmu.cGetNumberOfContinuousStates           = dlsym(fmu.libHandle, :fmi3GetNumberOfContinuousStates)
        fmu.cGetNumberOfEventIndicators            = dlsym(fmu.libHandle, :fmi3GetNumberOfEventIndicators)
        fmu.cGetContinuousStates                   = dlsym(fmu.libHandle, :fmi3GetContinuousStates)
        fmu.cGetNominalsOfContinuousStates         = dlsym(fmu.libHandle, :fmi3GetNominalsOfContinuousStates)
        fmu.cEnterContinuousTimeMode               = dlsym(fmu.libHandle, :fmi3EnterContinuousTimeMode)
        fmu.cSetTime                               = dlsym(fmu.libHandle, :fmi3SetTime)
        fmu.cSetContinuousStates                   = dlsym(fmu.libHandle, :fmi3SetContinuousStates)
        fmu.cGetContinuousStateDerivatives         = dlsym(fmu.libHandle, :fmi3GetContinuousStateDerivatives) 
        fmu.cGetEventIndicators                    = dlsym(fmu.libHandle, :fmi3GetEventIndicators)
        fmu.cCompletedIntegratorStep               = dlsym(fmu.libHandle, :fmi3CompletedIntegratorStep)
        fmu.cEnterEventMode                        = dlsym(fmu.libHandle, :fmi3EnterEventMode)        
        fmu.cUpdateDiscreteStates                  = dlsym(fmu.libHandle, :fmi3UpdateDiscreteStates)

        fmu.previous_z  = zeros(fmi3Float64, fmi3GetEventIndicators(fmu.modelDescription))
        fmu.rootsFound  = zeros(fmi3Int32, fmi3GetEventIndicators(fmu.modelDescription))
        fmu.stateEvent  = fmi3False
        fmu.timeEvent   = fmi3False
    end

    if fmi3IsScheduledExecution(fmu)
        fmu.cSetIntervalDecimal                    = dlsym(fmu.libHandle, :fmi3SetIntervalDecimal)
        fmu.cSetIntervalFraction                   = dlsym(fmu.libHandle, :fmi3SetIntervalFraction)
        fmu.cGetIntervalDecimal                    = dlsym(fmu.libHandle, :fmi3GetIntervalDecimal)
        fmu.cGetIntervalFraction                   = dlsym(fmu.libHandle, :fmi3GetIntervalFraction)
        fmu.cGetShiftDecimal                       = dlsym(fmu.libHandle, :fmi3GetShiftDecimal)
        fmu.cGetShiftFraction                      = dlsym(fmu.libHandle, :fmi3GetShiftFraction)
        fmu.cActivateModelPartition                = dlsym(fmu.libHandle, :fmi3ActivateModelPartition)
    end
    # # initialize further variables TODO check if needed
    # fmu.jac_x = zeros(Float64, fmu.modelDescription.numberOfContinuousStates)
    # fmu.jac_t = -1.0
    # fmu.jac_dxy_x = zeros(fmi2Real,0,0)
    # fmu.jac_dxy_u = zeros(fmi2Real,0,0)
   
    # dependency matrix 
    # fmu.dependencies

    fmu
end

# wrapper functions on the model description
function fmi3GetModelName(fmu::FMU3)
    fmi3GetModelName(fmu.modelDescription)
end
function fmi3GetInstantiationToken(fmu::FMU3)
    fmi3GetInstantiationToken(fmu.modelDescription)
end
function fmi3GetGenerationTool(fmu::FMU3)
    fmi3GetGenerationTool(fmu.modelDescription)
end
function fmi3GetGenerationDateAndTime(fmu::FMU3)
    fmi3GetGenerationDateAndTime(fmu.modelDescription)
end
function fmi3GetVariableNamingConvention(fmu::FMU3)
    fmi3GetVariableNamingConvention(fmu.modelDescription)
end

function fmi3CanGetSetState(fmu::FMU3)
    fmi3CanGetSetState(fmu.modelDescription)
end
function fmi3CanSerializeFMUstate(fmu::FMU3)
    fmi3CanSerializeFMUstate(fmu.modelDescription)
end
function fmi3ProvidesDirectionalDerivatives(fmu::FMU3)
    fmi3ProvidesDirectionalDerivatives(fmu.modelDescription)
end
function fmi3ProvidesAdjointDerivatives(fmu::FMU3)
    fmi3ProvidesAdjointDerivatives(fmu.modelDescription)
end
function fmi3IsCoSimulation(fmu::FMU3)
    fmi3IsCoSimulation(fmu.modelDescription)
end
function fmi3IsModelExchange(fmu::FMU3)
    fmi3IsModelExchange(fmu.modelDescription)
end
function fmi3IsScheduledExecution(fmu::FMU3)
    fmi3IsScheduledExecution(fmu.modelDescription)
end
# TODO unused
"""
Struct to handle FMU simulation data / results.
"""
mutable struct fmi3SimulationResult
    valueReferences::Array{fmi3ValueReference}
    dataPoints::Array
    fmu::FMU3

    fmi3SimulationResult() = new()
end

"""
Collects all data points for variable save index ´i´ inside a fmi3SimulationResult ´sd´.
"""
function fmi3SimulationResultGetValuesAtIndex(sd::fmi3SimulationResult, i)
    collect(dataPoint[i] for dataPoint in sd.dataPoints)
end

"""
Collects all time data points inside a fmi3SimulationResult ´sd´.
"""
function fmi3SimulationResultGetTime(sd::fmi3SimulationResult)
    fmi3SimulationResultGetValuesAtIndex(sd, 1)
end

"""
Collects all data points for variable with value reference ´tvr´ inside a fmi3SimulationResult ´sd´.
"""
function fmi3SimulationResultGetValues(sd::fmi3SimulationResult, tvr::fmi3ValueReference)
    @assert tvr !== nothing ["fmi3SimulationResultGetValues(...): value reference is nothing!"]
    @assert length(sd.dataPoints) > 0 ["fmi3SimulationResultGetValues(...): simulation results are empty!"]

    numVars = length(sd.dataPoints[1])-1
    for i in 1:numVars
        vr = sd.valueReferences[i]
        if vr == tvr
            return fmi3SimulationResultGetValuesAtIndex(sd, i+1)
        end
    end

    nothing
end

"""
Collects all data points for variable with value name ´s´ inside a fmi3SimulationResult ´sd´.
"""
function fmi3SimulationResultGetValues(sd::fmi3SimulationResult, s::String)
    fmi3SimulationResultGetValues(sd, fmi3String2ValueReference(sd.fmu, s))
end

"""
Returns an array of ValueReferences coresponding to the variable names.
"""
function fmi3String2ValueReference(md::fmi3ModelDescription, names::Array{String})
    vr = Array{fmi3ValueReference}(undef,0)
    for name in names
        reference = fmi3String2ValueReference(md, name)
        if reference === nothing
            @warn "Value reference for variable '$name' not found, skipping."
        else
            push!(vr, reference)
        end
    end
    vr
end

"""
Returns the ValueReference coresponding to the variable name.
"""
function fmi3String2ValueReference(md::fmi3ModelDescription, name::String)
    reference = nothing
    if haskey(md.stringValueReferences, name)
        reference = md.stringValueReferences[name]
    else
        @warn "No variable named '$name' found."
    end
    reference
end

function fmi3String2ValueReference(fmu::FMU3, name::Union{String, Array{String}})
    fmi3String2ValueReference(fmu.modelDescription, name)
end

"""
Returns an array of variable names matching a fmi3ValueReference.
"""
function fmi3ValueReference2String(md::fmi3ModelDescription, reference::fmi3ValueReference)
    [k for (k,v) in md.stringValueReferences if v == reference]
end
function fmi3ValueReference2String(md::fmi3ModelDescription, reference::Int64)
    fmi3ValueReference2String(md, fmi3ValueReference(reference))
end

function fmi3ValueReference2String(fmu::FMU3, reference::Union{fmi3ValueReference, Int64})
    fmi3ValueReference2String(fmu.modelDescription, reference)
end

"""
Create a copy of the .fmu file as a .zip folder and unzips it.
Returns the paths to the zipped and unzipped folders.

Via optional argument ```unpackPath```, a path to unpack the FMU can be specified (default: system temporary directory).
"""
function fmi3Unzip(pathToFMU::String; unpackPath=nothing)

    fileNameExt = basename(pathToFMU)
    (fileName, fileExt) = splitext(fileNameExt)
        
    if unpackPath === nothing
        # cleanup=true leads to issues with automatic testing on linux server.
        unpackPath = mktempdir(; prefix="fmijl_", cleanup=false)
    end

    zipPath = joinpath(unpackPath, fileName * ".zip")
    unzippedPath = joinpath(unpackPath, fileName)

    # only copy ZIP if not already there
    if !isfile(zipPath)
        cp(pathToFMU, zipPath; force=true)
    end

    @assert isfile(zipPath) ["fmi3Unzip(...): ZIP-Archive couldn't be copied to `$zipPath`."]

    zipAbsPath = isabspath(zipPath) ?  zipPath : joinpath(pwd(), zipPath)
    unzippedAbsPath = isabspath(unzippedPath) ? unzippedPath : joinpath(pwd(), unzippedPath)

    @assert isfile(zipAbsPath) ["fmi3Unzip(...): Can't deploy ZIP-Archive at `$(zipAbsPath)`."]

    numFiles = 0

    # only unzip if not already done
    if !isdir(unzippedAbsPath)
        mkpath(unzippedAbsPath)

        zarchive = ZipFile.Reader(zipAbsPath)
        for f in zarchive.files
            fileAbsPath = normpath(joinpath(unzippedAbsPath, f.name))

            if endswith(f.name,"/") || endswith(f.name,"\\")
                mkpath(fileAbsPath) # mkdir(fileAbsPath)

                @assert isdir(fileAbsPath) ["fmi3Unzip(...): Can't create directory `$(f.name)` at `$(fileAbsPath)`."]
            else
                # create directory if not forced by zip file folder
                mkpath(dirname(fileAbsPath))

                numBytes = write(fileAbsPath, read(f))
                
                if numBytes == 0
                    @info "fmi3Unzip(...): Written file `$(f.name)`, but file is empty."
                end

                @assert isfile(fileAbsPath) ["fmi3Unzip(...): Can't unzip file `$(f.name)` at `$(fileAbsPath)`."]
                numFiles += 1
            end
        end
        close(zarchive)
    end

    @assert isdir(unzippedAbsPath) ["fmi3Unzip(...): ZIP-Archive couldn't be unzipped at `$(unzippedPath)`."]
    @info "fmi3Unzip(...): Successfully unzipped $numFiles files at `$unzippedAbsPath`."

    (unzippedAbsPath, zipAbsPath)
end

"""
Unload a FMU.

Free the allocated memory, close the binaries and remove temporary zip and unziped FMU model description.
"""
function fmi3Unload(fmu::FMU3, cleanUp::Bool = true)

    while length(fmu.components) > 0
        fmi3FreeInstance!(fmu.components[end])
    end

    dlclose(fmu.libHandle)

    # the components are removed from the component list via call to fmi3FreeInstance!
    @assert length(fmu.components) == 0 "fmi3Unload(...): Failure during deleting components, $(length(fmu.components)) remaining in stack."

    if cleanUp
        try
            rm(fmu.path; recursive = true, force = true)
            rm(fmu.zipPath; recursive = true, force = true)
        catch e
            @warn "Cannot delete unpacked data on disc. Maybe some files are opened in another application."
        end
    end
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateModelExchange
"""
function fmi3InstantiateModelExchange!(fmu::FMU3; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(fmi3CallbackLogMessage, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))

    compAddr = fmi3InstantiateModelExchange(fmu.cInstantiateModelExchange, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), fmu.instanceEnvironment, ptrLogger)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateModelExchange!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateCoSimulation
"""
function fmi3InstantiateCoSimulation!(fmu::FMU3; visible::Bool = false, loggingOn::Bool = false, eventModeUsed::Bool = false, ptrIntermediateUpdate=nothing)

    ptrLogger = @cfunction(fmi3CallbackLogMessage, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))
    if ptrIntermediateUpdate === nothing
        ptrIntermediateUpdate = @cfunction(fmi3CallbackIntermediateUpdate, Cvoid, (Ptr{Cvoid}, fmi3Float64, fmi3Boolean, fmi3Boolean, fmi3Boolean, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Float64}))
    end
    if fmu.modelDescription.CShasEventMode 
        mode = eventModeUsed
    else
        mode = false
    end
    # fmu.fmi3CallbackLoggerFunction = fmi3CallbackLoggerFunction(ptrLogger) #, ptrAllocateMemory, ptrFreeMemory, ptrStepFinished, C_NULL)
    # fmu.fmi3CallbackIntermediateUpdateFunction = fmi3CallbackIntermediateUpdateFunction(ptrIntermediateUpdate)
    compAddr = fmi3InstantiateCoSimulation(fmu.cInstantiateCoSimulation, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), 
                                            fmi3Boolean(mode), fmi3Boolean(fmu.modelDescription.CScanReturnEarlyAfterIntermediateUpdate), fmu.modelDescription.intermediateUpdateValueReferences, Csize_t(length(fmu.modelDescription.intermediateUpdateValueReferences)), fmu.instanceEnvironment, ptrLogger, ptrIntermediateUpdate)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateCoSimulation!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi3InstantiateScheduledExecution
"""
function fmi3InstantiateScheduledExecution!(fmu::FMU3, ptrlockPreemption::Ptr{Cvoid}, ptrunlockPreemption::Ptr{Cvoid}; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(fmi3CallbackLogMessage, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}))
    ptrClockUpdate = @cfunction(fmi3CallbackClockUpdate, Cvoid, (Ptr{Cvoid}, ))

    compAddr = fmi3InstantiateScheduledExecution(fmu.cInstantiateScheduledExecution, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi3Boolean(visible), fmi3Boolean(loggingOn), fmu.instanceEnvironment, ptrLogger, ptrClockUpdate, ptrlockPreemption, ptrunlockPreemption)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi3InstantiateScheduledExecution!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end


"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.4. Inquire Version Number of Header Files

Returns the version of the FMI Standard used in this FMU.

For more information call ?fmi3GetVersion
"""
function fmi3GetVersion(fmu::FMU3)
    fmi3GetVersion(fmu.cGetVersion)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Sets debug logging for the FMU.

For more information call ?fmi3SetDebugLogging
"""
function fmi3SetDebugLogging(fmu::FMU3)
    fmi3SetDebugLogging(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

FMU enters Initialization mode.

For more information call ?fmi3EnterInitializationMode
"""
function fmi3EnterInitializationMode(fmu::FMU3, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)
    fmi3EnterInitializationMode(fmu.components[end], startTime, stopTime; tolerance = tolerance)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

FMU exits Initialization mode.

For more information call ?fmi3ExitInitializationMode
"""
function fmi3ExitInitializationMode(fmu::FMU3)
    fmi3ExitInitializationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.4. Super State: Initialized

Informs FMU that simulation run is terminated.

For more information call ?fmi3Terminate
"""
function fmi3Terminate(fmu::FMU3)
    fmi3Terminate(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Resets FMU.

For more information call ?fmi3Reset
"""
function fmi3Reset(fmu::FMU3)
    fmi3Reset(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float32 variables.

For more information call ?fmi3GetFloat32
"""
function fmi3GetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetFloat32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float32 variables.

For more information call ?fmi3GetFloat32!
"""
function fmi3GetFloat32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    fmi3GetFloat32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Float32 variables.

For more information call ?fmi3SetFloat32
"""
function fmi3SetFloat32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float32}, fmi3Float32})
    fmi3SetFloat32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float64 variables.

For more information call ?fmi3GetFloat64
"""
function fmi3GetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetFloat64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Float64 variables.

For more information call ?fmi3GetFloat64!
"""
function fmi3GetFloat64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    fmi3GetFloat64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Float64 variables.

For more information call ?fmi3SetFloat64
"""
function fmi3SetFloat64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Float64}, fmi3Float64})
    fmi3SetFloat64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int8 variables.

For more information call ?fmi3GetInt8
"""
function fmi3GetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetInt8(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int8 variables.

For more information call ?fmi3GetInt8!
"""
function fmi3GetInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    fmi3GetInt8!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int8 variables.

For more information call ?fmi3SetInt8
"""
function fmi3SetInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int8}, fmi3Int8})
    fmi3SetInt8(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt8 variables.

For more information call ?fmi3GetUInt8
"""
function fmi3GetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetUInt8(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt8 variables.

For more information call ?fmi3GetUInt8!
"""
function fmi3GetUInt8!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    fmi3GetUInt8!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt8 variables.

For more information call ?fmi3SetUInt8
"""
function fmi3SetUInt8(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt8}, fmi3UInt8})
    fmi3SetUInt8(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int16 variables.

For more information call ?fmi3GetInt16
"""
function fmi3GetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetInt16(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int16 variables.

For more information call ?fmi3GetInt16!
"""
function fmi3GetInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    fmi3GetInt16!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int16 variables.

For more information call ?fmi3SetInt16
"""
function fmi3SetInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int16}, fmi3Int16})
    fmi3SetInt16(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt16 variables.

For more information call ?fmi3GetUInt16
"""
function fmi3GetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetUInt16(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt16 variables.

For more information call ?fmi3GetUInt16!
"""
function fmi3GetUInt16!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    fmi3GetUInt16!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt16 variables.

For more information call ?fmi3SetUInt16
"""
function fmi3SetUInt16(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt16}, fmi3UInt16})
    fmi3SetUInt16(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int32 variables.

For more information call ?fmi3GetInt32
"""
function fmi3GetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetInt32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int32 variables.

For more information call ?fmi3GetInt32!
"""
function fmi3GetInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    fmi3GetInt32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int32 variables.

For more information call ?fmi3SetInt32
"""
function fmi3SetInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int32}, fmi3Int32})
    fmi3SetInt32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt32 variables.

For more information call ?fmi3GetUInt32
"""
function fmi3GetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetUInt32(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt32 variables.

For more information call ?fmi3GetUInt32!
"""
function fmi3GetUInt32!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    fmi3GetUInt32!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt32 variables.

For more information call ?fmi3SetUInt32
"""
function fmi3SetUInt32(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt32}, fmi3UInt32})
    fmi3SetUInt32(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int64 variables.

For more information call ?fmi3GetInt64
"""
function fmi3GetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetInt64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Int64 variables.

For more information call ?fmi3GetInt64!
"""
function fmi3GetInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    fmi3GetInt64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Int64 variables.

For more information call ?fmi3SetInt64
"""
function fmi3SetInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Int64}, fmi3Int64})
    fmi3SetInt64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt64 variables.

For more information call ?fmi3GetUInt64
"""
function fmi3GetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetUInt64(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3UInt64 variables.

For more information call ?fmi3GetUInt64!
"""
function fmi3GetUInt64!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    fmi3GetUInt64!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3UInt64 variables.

For more information call ?fmi3SetUInt64
"""
function fmi3SetUInt64(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3UInt64}, fmi3UInt64})
    fmi3SetUInt64(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Boolean variables.

For more information call ?fmi3GetBoolean
"""
function fmi3GetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetBoolean(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Boolean variables.

For more information call ?fmi3GetBoolean!
"""
function fmi3GetBoolean!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool, Array{fmi3Boolean}})
    fmi3GetBoolean!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Boolean variables.

For more information call ?fmi3SetBoolean
"""
function fmi3SetBoolean(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    fmi3SetBoolean(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3String variables.

For more information call ?fmi3GetString
"""
function fmi3GetString(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetString(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3String variables.

For more information call ?fmi3GetString!
"""
function fmi3GetString!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    fmi3GetString!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3String variables.

For more information call ?fmi3SetString
"""
function fmi3SetString(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{String}, String})
    fmi3SetString(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Binary variables.

For more information call ?fmi3GetBinary
"""
function fmi3GetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetBinary(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Binary variables.

For more information call ?fmi3GetBinary!
"""
function fmi3GetBinary!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Binary}, fmi3Binary})
    fmi3GetBinary!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Binary variables.

For more information call ?fmi3SetBinary
"""
function fmi3SetBinary(fmu::FMU3, vr::fmi3ValueReferenceFormat, valueSizes::Union{Array{Csize_t}, Csize_t}, values::Union{Array{fmi3Binary}, fmi3Binary})
    fmi3SetBinary(fmu.components[end], vr, valueSizes, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Clock variables.

For more information call ?fmi3GetClock
"""
function fmi3GetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat)
    fmi3GetClock(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Get the values of an array of fmi3Clock variables.

For more information call ?fmi3GetClock!
"""
function fmi3GetClock!(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    fmi3GetClock!(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Set the values of an array of fmi3Clock variables.

For more information call ?fmi3SetClock
"""
function fmi3SetClock(fmu::FMU3, vr::fmi3ValueReferenceFormat, values::Union{Array{fmi3Clock}, fmi3Clock})
    fmi3SetBinary(fmu.components[end], vr, values)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Get the pointer to the current FMU state.

For more information call ?fmi3GetFMUState
"""
function fmi3GetFMUState(fmu::FMU3)
    state = fmi3FMUState()
    stateRef = Ref(state)
    fmi3GetFMUState(fmu.components[end], stateRef)
    state = stateRef[]
    state
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Set the FMU to the given fmi3FMUstate.

For more information call ?fmi3SetFMUState
"""
function fmi3SetFMUState(fmu::FMU3, state::fmi3FMUState)
    fmi3SetFMUState(fmu.components[end], state)
end

"""
function fmi3FreeFMUState(c::fmi3Component, FMUstate::Ref{fmi3FMUState})

Free the allocated memory for the FMU state.

For more information call ?fmi3FreeFMUState
"""
function fmi3FreeFMUState(fmu::FMU3, state::fmi3FMUState)
    stateRef = Ref(state)
    fmi3FreeFMUState(fmu.components[end], stateRef)
    state = stateRef[]
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Returns the size of a byte vector the FMU can be stored in.

For more information call ?fmi3SerzializedFMUStateSize
"""
function fmi3SerializedFMUStateSize(fmu::FMU3, state::fmi3FMUState)
    size = 0
    sizeRef = Ref(Csize_t(size))
    fmi3SerializedFMUStateSize(fmu.components[end], state, sizeRef)
    size = sizeRef[]
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Serialize the data in the FMU state pointer.

For more information call ?fmi3SerializeFMUState
"""
function fmi3SerializeFMUState(fmu::FMU3, state::fmi3FMUState)
    size = fmi3SerializedFMUStateSize(fmu, state)
    serializedState = Array{fmi3Byte}(undef, size)
    fmi3SerializeFMUState(fmu.components[end], state, serializedState, size)
    serializedState
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

Deserialize the data in the serializedState fmi3Byte field.

For more information call ?fmi3DeSerializeFMUState
"""
function fmi3DeSerializeFMUState(fmu::FMU3, serializedState::Array{fmi3Byte})
    size = length(serializedState)
    state = fmi3FMUState()
    stateRef = Ref(state)
    fmi3DeSerializeFMUState(fmu.components[end], serializedState, Csize_t(size), stateRef)
    state = stateRef[]
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)

    fmi3GetDirectionalDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

    fmi3GetDirectionalDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves directional derivatives in-place.

For more information call ?fmi3GetDirectionalDerivative
"""
function fmi3GetDirectionalDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 

    fmi3GetDirectionalDerivative!(fmu.components[end], unknowns, knowns, sensitivity, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::fmi3ValueReference,
                                      knowns::fmi3ValueReference,
                                      seed::fmi3Float64 = 1.0)

    fmi3GetAdjointDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative(fmu::FMU3,
                                      unknowns::Array{fmi3ValueReference},
                                      knowns::Array{fmi3ValueReference},
                                      seed::Array{fmi3Float64} = Array{fmi3Float64}([]))

    fmi3GetAdjointDerivative(fmu.components[end], unknowns, knowns, seed)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

Retrieves adjoint derivatives.

For more information call ?fmi3GetAdjointDerivative
"""
function fmi3GetAdjointDerivative!(fmu::FMU3,
    unknowns::Array{fmi3ValueReference},
    knowns::Array{fmi3ValueReference},
    sensitivity::Array{fmi3Float64},
    seed::Array{fmi3Float64} = Array{fmi3Float64}([])) 

    fmi3GetAdjointDerivative!(fmu.components[end], unknowns, knowns, sensitivity, seed)
end
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi3GetOutputDerivatives
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReferenceFormat, order::Array{Integer})
    fmi3GetOutputDerivatives(fmu.components[end], vr, order)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi3GetOutputDerivatives
"""
function fmi3GetOutputDerivatives(fmu::FMU3, vr::fmi3ValueReference, order::Integer)
    fmi3GetOutputDerivatives(fmu.components[end], vr, order)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

If the importer needs to change structural parameters, it must move the FMU into Configuration Mode using fmi3EnterConfigurationMode.
For more information call ?fmi3EnterConfigurationMode
"""
function fmi3EnterConfigurationMode(fmu::FMU3)
    fmi3EnterConfigurationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of continuous states.
This function can only be called in Model Exchange. 
For more information call ?fmi3GetNumberOfContinuousStates
"""
function fmi3GetNumberOfContinuousStates(fmu::FMU3)
    fmi3GetNumberOfContinuousStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of event indicators.
This function can only be called in Model Exchange.
For more information call ?fmi3GetNumberOfEventIndicators
"""
function fmi3GetNumberOfEventIndicators(fmu::FMU3)
    fmi3GetNumberOfEventIndicators(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The number of dependencies of a given variable, which may change if structural parameters are changed, can be retrieved by calling the following function:
For more information call ?fmi3GetNumberOfVariableDependencies
"""
function fmi3GetNumberOfVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    fmi3GetNumberOfVariableDependencies(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the states at the current time instant.
For more information call ?fmi3GetContinuousStates
"""
function fmi3GetContinuousStates(fmu::FMU3)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi3Float64, nx)
    fmi3GetContinuousStates(fmu.components[end], x, nx)
    x
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The dependencies (of type dependenciesKind) can be retrieved by calling the function fmi3GetVariableDependencies.
For more information call ?fmi3GetVariableDependencies
"""
function fmi3GetVariableDependencies(fmu::FMU3, vr::Union{fmi3ValueReference, String})
    fmi3GetVariableDependencies(fmu.components[end], vr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the nominal values of the continuous states.

For more information call ?fmi3GetNominalsOfContinuousStates
"""
function fmi3GetNominalsOfContinuousStates(fmu::FMU3)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi3Float64, nx)
    fmi3GetNominalsOfContinuousStates(fmu.components[end], x, nx)
    x
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

This function is called to trigger the evaluation of fdisc to compute the current values of discrete states from previous values. 
The FMU signals the support of fmi3EvaluateDiscreteStates via the capability flag providesEvaluateDiscreteStates.
    
For more information call ?fmi3EvaluateDiscreteStates
"""
function fmi3EvaluateDiscreteStates(fmu::FMU3)
    fmi3EvaluateDiscreteStates(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function is called to signal a converged solution at the current super-dense time instant. fmi3UpdateDiscreteStates must be called at least once per super-dense time instant.

For more information call ?fmi3UpdateDiscreteStates!
"""
function fmi3UpdateDiscreteStates!(fmu::FMU3)
    fmi3UpdateDiscreteStates!(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

The model enters Continuous-Time Mode.

For more information call ?fmi3EnterContinuousTimeMode
"""
function fmi3EnterContinuousTimeMode(fmu::FMU3)
    fmi3EnterContinuousTimeMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function must be called to change from Event Mode into Step Mode in Co-Simulation.

For more information call ?fmi3EnterStepMode
"""
function fmi3EnterStepMode(fmu::FMU3)
    fmi3EnterStepMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.6. State: Configuration Mode

Exits the Configuration Mode and returns to state Instantiated.

For more information call ?fmi3ExitConfigurationMode
"""
function fmi3ExitConfigurationMode(fmu::FMU3)
    fmi3ExitConfigurationMode(fmu.components[end])
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set independent variable time and reinitialize chaching of variables that depend on time.

For more information call ?fmi3SetTime
"""
function fmi3SetTime(fmu::FMU3, time::Real)
    fmu.t = time
    fmi3SetTime(fmu.components[end], fmi3Float64(time))
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new (continuous) state vector and reinitialize chaching of variables that depend on states.

For more information call ?fmi3SetContinuousStates
"""
function fmi3SetContinuousStates(fmu::FMU3, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    # fmu.x = x
    fmi3SetContinuousStates(fmu.components[end], Array{fmi3Float64}(x), nx)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi3GetContinuousStateDerivatives
"""
function  fmi3GetContinuousStateDerivatives(fmu::FMU3)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    derivatives = zeros(fmi3Float64, nx)
    fmi3GetContinuousStateDerivatives(fmu.components[end], derivatives, nx)
    derivatives
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Returns the event indicators of the FMU.

For more information call ?fmi3GetEventIndicators
"""
function fmi3GetEventIndicators(fmu::FMU3)
    ni = Csize_t(fmu.modelDescription.numberOfEventIndicators)
    eventIndicators = zeros(fmi3Float64, ni)
    fmi3GetEventIndicators(fmu.components[end], eventIndicators, ni)
    eventIndicators
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

This function must be called by the environment after every completed step
If enterEventMode == fmi3True, the event mode must be entered
If terminateSimulation == fmi3True, the simulation shall be terminated

For more information call ?fmi3CompletedIntegratorStep
"""
function fmi3CompletedIntegratorStep(fmu::FMU3,
                                     noSetFMUStatePriorToCurrentPoint::fmi3Boolean)
    fmi3CompletedIntegratorStep(fmu.components[end], noSetFMUStatePriorToCurrentPoint)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

The model enters Event Mode.

For more information call ?fmi3EnterEventMode
"""
function fmi3EnterEventMode(fmu::FMU3, stepEvent::Bool, stateEvent::Bool, rootsFound::Array{fmi3Int32}, nEventIndicators::Integer, timeEvent::Bool)
    fmi3EnterEventMode(fmu.components[end], stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 4.2.1. State: Step Mode

The computation of a time step is started.

For more information call ?fmi3DoStep
"""
function fmi3DoStep(fmu::FMU3, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool, eventEncountered::fmi3Boolean, terminateSimulation::fmi3Boolean, earlyReturn::fmi3Boolean, lastSuccessfulTime::fmi3Float64)
    refeventEncountered = Ref(eventEncountered)
    refterminateSimulation = Ref(terminateSimulation)
    refearlyReturn = Ref(earlyReturn)
    reflastSuccessfulTime = Ref(lastSuccessfulTime)
    fmi3DoStep(fmu.components[end], fmi3Float64(currentCommunicationPoint), fmi3Float64(communicationStepSize), fmi3Boolean(noSetFMUStatePriorToCurrentPoint), refeventEncountered, refterminateSimulation, refearlyReturn, reflastSuccessfulTime)
    eventEncountered = refeventEncountered[]
    terminateSimulation = refterminateSimulation[]
    earlyReturn = refearlyReturn[]
    lastSuccessfulTime = reflastSuccessfulTime[]
end
# function fmi3DoStep(fmu::FMU3, communicationStepSize::Real)
#     fmi3DoStep(fmu.components[end], fmi3Float64(fmu.t), fmi3Float64(communicationStepSize), fmi2True)
#     fmu.t += communicationStepSize
# end
"""
Starts a simulation of the fmu instance for the matching fmu type. If both types are available, CS is preferred over ME.
"""
function fmi3Simulate(fmu::FMU3, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)
    fmi3Simulate(fmu.components[end], t_start, t_stop;
                 recordValues=recordValues, saveat=saveat, setup=setup)
end
"""
Starts a simulation of a FMU in CS-mode.
"""
function fmi3SimulateCS(fmu::FMU3, t_start::Real, t_stop::Real;
                        recordValues::fmi3ValueReferenceFormat = nothing, saveat=[], setup=true)
    fmi3SimulateCS(fmu.components[end], t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
Starts a simulation of a FMU in ME-mode.
"""
function fmi3SimulateME(fmu::FMU3, t_start::Real, t_stop::Real; kwargs...)
    fmi3SimulateME(fmu.components[end], t_start, t_stop; kwargs...)
end