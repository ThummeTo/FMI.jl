#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl
using ZipFile

include("FMI3_c.jl")
# include("FMI3_comp.jl")
include("FMI3_md.jl")

"""
IN PROGRESS:
The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3 <: FMU
    modelName::fmi3String
    instanceName::fmi3String
    fmuResourceLocation::fmi3String

    modelDescription::fmi3ModelDescription

    type::fmi3Type
    callbackFunctions::fmi3CallbackFunctions
    instanceEnvironment::fmi3InstanceEnvironment
    components::Array{fmi3Component}

    # paths of ziped and unziped FMU folders
    path::String
    zipPath::String

    # c-functions
    cInstantiateModelExchange::Ptr{Cvoid}
    cGetTypesPlatform::Ptr{Cvoid}
    cGetVersion::Ptr{Cvoid}
    cFreeInstance::Ptr{Cvoid}
    cSetDebugLogging::Ptr{Cvoid}
    cSetupExperiment::Ptr{Cvoid}
    cEnterInitializationMode::Ptr{Cvoid}
    cExitInitializationMode::Ptr{Cvoid}
    cTerminate::Ptr{Cvoid}
    cReset::Ptr{Cvoid}
    cGetReal::Ptr{Cvoid}
    cSetReal::Ptr{Cvoid}
    cGetInteger::Ptr{Cvoid}
    cSetInteger::Ptr{Cvoid}
    cGetBoolean::Ptr{Cvoid}
    cSetBoolean::Ptr{Cvoid}
    cGetString::Ptr{Cvoid}
    cSetString::Ptr{Cvoid}
    cGetFMUstate::Ptr{Cvoid}
    cSetFMUstate::Ptr{Cvoid}
    cFreeFMUstate::Ptr{Cvoid}
    cSerializedFMUstateSize::Ptr{Cvoid}
    cSerializeFMUstate::Ptr{Cvoid}
    cDeSerializeFMUstate::Ptr{Cvoid}
    cGetDirectionalDerivative::Ptr{Cvoid}

    # Co Simulation function calls
    cSetRealInputDerivatives::Ptr{Cvoid}
    cGetRealOutputDerivatives::Ptr{Cvoid}
    cDoStep::Ptr{Cvoid}
    cCancelStep::Ptr{Cvoid}
    cGetStatus::Ptr{Cvoid}
    cGetRealStatus::Ptr{Cvoid}
    cGetIntegerStatus::Ptr{Cvoid}
    cGetBooleanStatus::Ptr{Cvoid}
    cGetStringStatus::Ptr{Cvoid}

    # Model Exchange function calls
    cEnterContinuousTimeMode::Ptr{Cvoid}
    cGetContinuousStates::Ptr{Cvoid}
    cGetDerivatives::Ptr{Cvoid}
    cSetTime::Ptr{Cvoid}
    cSetContinuousStates::Ptr{Cvoid}
    cCompletedIntegratorStep::Ptr{Cvoid}
    cEnterEventMode::Ptr{Cvoid}
    cNewDiscreteStates::Ptr{Cvoid}
    cGetEventIndicators::Ptr{Cvoid}
    cGetNominalsOfContinuousStates::Ptr{Cvoid}

    # c-libraries
    libHandle::Ptr{Nothing}

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix{fmi2Dependency}

    t::Real         # current time
    next_t::Real    # next time

    x       # current state
    next_x  # next state

    dx      # current state derivative
    simulationResult

    jac_dxy_x::Matrix{fmi2Real}
    jac_dxy_u::Matrix{fmi2Real}
    jac_x::Array{fmi2Real}
    jac_t::fmi2Real
    # END: experimental section

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

    if fmi3IsCoSimulation(fmu) # TODO
        fmu.type = fmi3CoSimulation::fmi3Type
    elseif fmi3IsModelExchange(fmu) #TODO
        fmu.type = fmi3ModelExchange::fmi3Type
    elseif fmi3IsScheduledExecution(fmu) # TODO
        fmu.type = fmi3ScheduledExecution::fmi3Type
    else
        error(unknownFMUType)
    end

    if fmi3IsCoSimulation(fmu) && fmi3IsModelExchange(fmu) # TODO
        @info "fmi3Load(...): FMU supports both CS and ME, using CS as default if nothing specified." # TODO ScheduledExecution
    end

    # make URI ressource location
    tmpResourceLocation = string("file:///", fmu.path)
    tmpResourceLocation = joinpath(tmpResourceLocation, "resources")
    fmu.fmuResourceLocation = replace(tmpResourceLocation, "\\" => "/") # URIs.escapeuri(tmpResourceLocation)

    @info "fmi3Load(...): FMU resources location is `$(fmu.fmuResourceLocation)`"

    # # retrieve functions TODO check new Names and availability in FMI3
    fmu.cInstantiateModelExchange                  = dlsym(fmu.libHandle, :fmi3InstantiateModelExchange)
    # fmu.cGetTypesPlatform             = dlsym(fmu.libHandle, :fmi2GetTypesPlatform)
    # fmu.cGetVersion                   = dlsym(fmu.libHandle, :fmi2GetVersion)
    # fmu.cFreeInstance                 = dlsym(fmu.libHandle, :fmi2FreeInstance)
    # fmu.cSetDebugLogging              = dlsym(fmu.libHandle, :fmi2SetDebugLogging)
    # fmu.cSetupExperiment              = dlsym(fmu.libHandle, :fmi2SetupExperiment)
    # fmu.cEnterInitializationMode      = dlsym(fmu.libHandle, :fmi2EnterInitializationMode)
    # fmu.cExitInitializationMode       = dlsym(fmu.libHandle, :fmi2ExitInitializationMode)
    # fmu.cTerminate                    = dlsym(fmu.libHandle, :fmi2Terminate)
    # fmu.cReset                        = dlsym(fmu.libHandle, :fmi2Reset)
    # fmu.cGetReal                      = dlsym(fmu.libHandle, :fmi2GetReal)
    # fmu.cSetReal                      = dlsym(fmu.libHandle, :fmi2SetReal)
    # fmu.cGetInteger                   = dlsym(fmu.libHandle, :fmi2GetInteger)
    # fmu.cSetInteger                   = dlsym(fmu.libHandle, :fmi2SetInteger)
    # fmu.cGetBoolean                   = dlsym(fmu.libHandle, :fmi2GetBoolean)
    # fmu.cSetBoolean                   = dlsym(fmu.libHandle, :fmi2SetBoolean)

    # fmu.cGetString                    = dlsym_opt(fmu.libHandle, :fmi2GetString)
    # fmu.cSetString                    = dlsym_opt(fmu.libHandle, :fmi2SetString)

    # if fmi2CanGetSetState(fmu)
    #     fmu.cGetFMUstate                  = dlsym_opt(fmu.libHandle, :fmi2GetFMUstate)
    #     fmu.cSetFMUstate                  = dlsym_opt(fmu.libHandle, :fmi2SetFMUstate)
    #     fmu.cFreeFMUstate                 = dlsym_opt(fmu.libHandle, :fmi2FreeFMUstate)
    # end

    # if fmi2CanSerializeFMUstate(fmu)
    #     fmu.cSerializedFMUstateSize       = dlsym_opt(fmu.libHandle, :fmi2SerializedFMUstateSize)
    #     fmu.cSerializeFMUstate            = dlsym_opt(fmu.libHandle, :fmi2SerializeFMUstate)
    #     fmu.cDeSerializeFMUstate          = dlsym_opt(fmu.libHandle, :fmi2DeSerializeFMUstate)
    # end

    # if fmi2ProvidesDirectionalDerivative(fmu)
    #     fmu.cGetDirectionalDerivative     = dlsym_opt(fmu.libHandle, :fmi2GetDirectionalDerivative)
    # end

    # # CS specific function calls
    # if fmi2IsCoSimulation(fmu)
    #     fmu.cSetRealInputDerivatives      = dlsym(fmu.libHandle, :fmi2SetRealInputDerivatives)
    #     fmu.cGetRealOutputDerivatives     = dlsym(fmu.libHandle, :fmi2GetRealOutputDerivatives)
    #     fmu.cDoStep                       = dlsym(fmu.libHandle, :fmi2DoStep)
    #     fmu.cCancelStep                   = dlsym(fmu.libHandle, :fmi2CancelStep)
    #     fmu.cGetStatus                    = dlsym(fmu.libHandle, :fmi2GetStatus)
    #     fmu.cGetRealStatus                = dlsym(fmu.libHandle, :fmi2GetRealStatus)
    #     fmu.cGetIntegerStatus             = dlsym(fmu.libHandle, :fmi2GetIntegerStatus)
    #     fmu.cGetBooleanStatus             = dlsym(fmu.libHandle, :fmi2GetBooleanStatus)
    #     fmu.cGetStringStatus              = dlsym(fmu.libHandle, :fmi2GetStringStatus)
    # end

    # # ME specific function calls
    # if fmi2IsModelExchange(fmu)
    #     fmu.cEnterContinuousTimeMode      = dlsym(fmu.libHandle, :fmi2EnterContinuousTimeMode)
    #     fmu.cGetContinuousStates          = dlsym(fmu.libHandle, :fmi2GetContinuousStates)
    #     fmu.cGetDerivatives               = dlsym(fmu.libHandle, :fmi2GetDerivatives)
    #     fmu.cSetTime                      = dlsym(fmu.libHandle, :fmi2SetTime)
    #     fmu.cSetContinuousStates          = dlsym(fmu.libHandle, :fmi2SetContinuousStates)
    #     fmu.cCompletedIntegratorStep      = dlsym(fmu.libHandle, :fmi2CompletedIntegratorStep)
    #     fmu.cEnterEventMode               = dlsym(fmu.libHandle, :fmi2EnterEventMode)
    #     fmu.cNewDiscreteStates            = dlsym(fmu.libHandle, :fmi2NewDiscreteStates)
    #     fmu.cGetEventIndicators           = dlsym(fmu.libHandle, :fmi2GetEventIndicators)
    #     fmu.cGetNominalsOfContinuousStates= dlsym(fmu.libHandle, :fmi2GetNominalsOfContinuousStates)
    # end

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
function fmi3GetNumberOfEventIndicators(fmu::FMU3)
    fmi3GetNumberOfEventIndicators(fmu.modelDescription)
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
"""
Create a copy of the .fmu file as a .zip folder and unzips it.
Returns the paths to the zipped and unzipped folders.

Via optional argument ```unpackPath```, a path to unpack the FMU can be specified (default: system temporary directory).
"""
function fmi3Unzip(pathToFMU::String; unpackPath=nothing)

    fileNameExt = basename(pathToFMU)
    (fileName, fileExt) = splitext(fileNameExt)
        
    if unpackPath == nothing
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
                    @info "fmi2Unzip(...): Written file `$(f.name)`, but file is empty."
                end

                @assert isfile(fileAbsPath) ["fmi2Unzip(...): Can't unzip file `$(f.name)` at `$(fileAbsPath)`."]
                numFiles += 1
            end
        end
        close(zarchive)
    end

    @assert isdir(unzippedAbsPath) ["fmi2Unzip(...): ZIP-Archive couldn't be unzipped at `$(unzippedPath)`."]
    @info "fmi2Unzip(...): Successfully unzipped $numFiles files at `$unzippedAbsPath`."

    (unzippedAbsPath, zipAbsPath)
end
""" 
Returns how a variable depends on another variable based on the model description.
"""
function fmi3VariableDependsOnVariable(fmu::FMU2, vr1::fmi2ValueReference, vr2::fmi2ValueReference) # TODO check what it does
    i1 = fmu.modelDescription.valueReferenceIndicies[vr1]
    i2 = fmu.modelDescription.valueReferenceIndicies[vr2]
    return fmi2GetDependencies(fmu)[i1, i2]
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

    # the components are removed from the component list via call to fmi2FreeInstance!
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
TODO: FMI specification reference.

Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi2Instantiate
"""
function fmi3InstantiateModelExchange!(fmu::FMU3; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(fmi3CallbackLogMessage, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}, Ptr{Cchar}))
    # ptrAllocateMemory = @cfunction(cbAllocateMemory, Ptr{Cvoid}, (Csize_t, Csize_t))
    # ptrFreeMemory = @cfunction(cbFreeMemory, Cvoid, (Ptr{Cvoid},))
    # ptrStepFinished = C_NULL
    fmu.callbackFunctions = fmi3CallbackFunctions(ptrLogger) #, ptrAllocateMemory, ptrFreeMemory, ptrStepFinished, C_NULL)

    compAddr = fmi3InstantiateModelExchange(fmu.cInstantiateModelExchange, fmu.instanceName, fmu.modelDescription.instantiationToken, fmu.fmuResourceLocation, fmi2Boolean(visible), fmi2Boolean(loggingOn), fmu.instanceEnvironment, fmu.callbackFunctions)

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi2Instantiate!(...): Instantiation failed!"
        return nothing
    end

    component = fmi3Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end