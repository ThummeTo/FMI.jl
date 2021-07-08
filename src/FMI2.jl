#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl
using ZipFile

using Base.Filesystem: mktempdir

include("FMI2_c.jl")
include("FMI2_comp.jl")
include("FMI2_md.jl")

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 2.0.2 function pointers.
"""
mutable struct FMU2 <: FMU
    modelName::fmi2String
    instanceName::fmi2String
    fmuResourceLocation::fmi2String

    modelDescription::fmi2ModelDescription

    type::fmi2Type
    callbackFunctions::fmi2CallbackFunctions
    components::Array{fmi2Component}

    t::Real         # current time
    next_t::Real    # next time

    x       # current state
    next_x  # next state

    dx      # current state derivative
    simulationResult

    # paths of ziped and unziped FMU folders
    path::String
    zipPath::String

    # c-functions
    cInstantiate::Ptr{Cvoid}
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

    # Constructor
    FMU2() = new()
end

# wrapper functions on the model description
function fmi2GetModelName(fmu::FMU2)
    fmi2GetModelName(fmu.modelDescription)
end
function fmi2GetGUID(fmu::FMU2)
    fmi2GetGUID(fmu.modelDescription)
end
function fmi2GetGenerationTool(fmu::FMU2)
    fmi2GetGenerationTool(fmu.modelDescription)
end
function fmi2GetGenerationDateAndTime(fmu::FMU2)
    fmi2GetGenerationDateAndTime(fmu.modelDescription)
end
function fmi2GetVariableNamingConvention(fmu::FMU2)
    fmi2GetVariableNamingConvention(fmu.modelDescription)
end
function fmi2GetNumberOfEventIndicators(fmu::FMU2)
    fmi2GetNumberOfEventIndicators(fmu.modelDescription)
end

function fmi2CanGetSetState(fmu::FMU2)
    fmi2CanGetSetState(fmu.modelDescription)
end
function fmi2CanSerializeFMUstate(fmu::FMU2)
    fmi2CanSerializeFMUstate(fmu.modelDescription)
end
function fmi2ProvidesDirectionalDerivative(fmu::FMU2)
    fmi2ProvidesDirectionalDerivative(fmu.modelDescription)
end
function fmi2IsCoSimulation(fmu::FMU2)
    fmi2IsCoSimulation(fmu.modelDescription)
end
function fmi2IsModelExchange(fmu::FMU2)
    fmi2IsModelExchange(fmu.modelDescription)
end

"""
Struct to handle FMU simulation data / results.
"""
mutable struct fmi2SimulationResult
    valueReferences::Array{fmi2ValueReference}
    dataPoints::Array
    fmu::FMU2

    fmi2SimulationResult() = new()
end

"""
Collects all data points for variable save index ´i´ inside a fmi2SimulationResult ´sd´.
"""
function fmi2SimulationResultGetValuesAtIndex(sd::fmi2SimulationResult, i)
    collect(dataPoint[i] for dataPoint in sd.dataPoints)
end

"""
Collects all time data points inside a fmi2SimulationResult ´sd´.
"""
function fmi2SimulationResultGetTime(sd::fmi2SimulationResult)
    fmi2SimulationResultGetValuesAtIndex(sd, 1)
end

"""
Collects all data points for variable with value reference ´tvr´ inside a fmi2SimulationResult ´sd´.
"""
function fmi2SimulationResultGetValues(sd::fmi2SimulationResult, tvr::fmi2ValueReference)
    @assert tvr != nothing ["fmi2SimulationResultGetValues(...): value reference is nothing!"]
    @assert length(sd.dataPoints) > 0 ["fmi2SimulationResultGetValues(...): simulation results are empty!"]

    numVars = length(sd.dataPoints[1])-1
    for i in 1:numVars
        vr = sd.valueReferences[i]
        if vr == tvr
            return fmi2SimulationResultGetValuesAtIndex(sd, i+1)
        end
    end

    nothing
end

"""
Collects all data points for variable with value name ´s´ inside a fmi2SimulationResult ´sd´.
"""
function fmi2SimulationResultGetValues(sd::fmi2SimulationResult, s::String)
    fmi2SimulationResultGetValues(sd, fmi2String2ValueReference(sd.fmu, s))
end

"""
Returns an array of ValueReferences coresponding to the variable names.
"""
function fmi2String2ValueReference(md::fmi2ModelDescription, names::Array{String})
    vr = Array{fmi2ValueReference}(undef,0)
    for name in names
        reference = fmi2String2ValueReference(md, name)
        if reference == nothing
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
function fmi2String2ValueReference(md::fmi2ModelDescription, name::String)
    reference = nothing
    if haskey(md.stringValueReferences, name)
        reference = md.stringValueReferences[name]
    else
        @warn "No variable named '$name' found."
    end
    reference
end

function fmi2String2ValueReference(fmu::FMU2, name::Union{String, Array{String}})
    fmi2String2ValueReference(fmu.modelDescription, name)
end

"""
Returns an array of variable names matching a fmi2ValueReference.
"""
function fmi2ValueReference2String(md::fmi2ModelDescription, reference::fmi2ValueReference)
    [k for (k,v) in md.stringValueReferences if v == reference]
end
function fmi2ValueReference2String(md::fmi2ModelDescription, reference::Int64)
    fmi2ValueReference2String(md, fmi2ValueReference(reference))
end

function fmi2ValueReference2String(fmu::FMU2, reference::Union{fmi2ValueReference, Int64})
    fmi2ValueReference2String(fmu.modelDescription, reference)
end

"""
Create a copy of the .fmu file as a .zip folder and unzips it.
Returns the paths to the zipped and unzipped folders.
"""
function fmi2Unzip(pathToFMU::String; unpackPath=nothing)

    fileNameExt = basename(pathToFMU)
    (fileName, fileExt) = splitext(fileNameExt)

    if unpackPath == nothing 
        unpackPath = mktempdir(; prefix="fmifluxjl_", cleanup=true)
    end
        
    zipPath = joinpath(unpackPath, fileName * ".zip")
    unzippedPath = joinpath(unpackPath, fileName)

    # only copy ZIP if not already there
    if !isfile(zipPath)
        cp(pathToFMU, zipPath; force=true)
    end

    @assert isfile(zipPath) ["fmi2Unzip(...): ZIP-Archive couldn't be copied to `$zipPath`."]

    zipAbsPath = isabspath(zipPath) ?  zipPath : joinpath(pwd(), zipPath)
    unzippedAbsPath = isabspath(unzippedPath) ? unzippedPath : joinpath(pwd(), unzippedPath)

    # only unzip if not already done
    if !isdir(unzippedAbsPath)
        mkdir(unzippedAbsPath)

        zarchive = ZipFile.Reader(zipAbsPath)
        for f in zarchive.files
            fileAbsPath = joinpath(unzippedAbsPath, f.name)

            if endswith(f.name,"/") || endswith(f.name,"\\")
                mkpath(fileAbsPath)
            else
                mkpath(dirname(fileAbsPath))
                write(fileAbsPath, read(f))
            end
        end
        close(zarchive)
    end

    @assert isdir(unzippedAbsPath) ["fmi2Unzip(...): ZIP-Archive couldn't be unzipped at `$unzippedPath`."]

    (unzippedPath, zipPath)
end

"""
Checks with dlsym for available function in library.
Prints an info text and returns C_NULL if not (soft-check).
"""
function dlsym_opt(libHandle, symbol)
    addr = dlsym(libHandle, symbol; throw_error=false)
    if addr == nothing
        @info "This FMU does not support optional function '$symbol'."
        addr = Ptr{Cvoid}(C_NULL)
    end
    addr
end

"""
Sets the properties of the fmu by reading the modelDescription.xml.
Retrieves all the pointers of binary functions.

Returns the instance of the FMU struct.
"""
function fmi2Load(pathToFMU::String; unpackPath=nothing)
    # Create uninitialized FMU
    fmu = FMU2()
    fmu.components = []

    pathToFMU = realpath(pathToFMU)

    # set paths for fmu handling
    (fmu.path, fmu.zipPath) = fmi2Unzip(pathToFMU; unpackPath=unpackPath)

    # set paths for modelExchangeScripting and binary
    tmpName = splitpath(fmu.path)
    pathToModelDescription = joinpath(fmu.path, "modelDescription.xml")

    # parse modelDescription.xml
    fmu.modelDescription = fmi2readModelDescription(pathToModelDescription)
    fmu.modelName = fmu.modelDescription.modelName
    fmu.instanceName = fmu.modelDescription.modelName
    fmuName = fmi2GetModelIdentifier(fmu.modelDescription) # tmpName[length(tmpName)]

    directoryBinary = ""
    pathToBinary = ""

    if Sys.iswindows()
        directories = ["binaries/win64", "binaries/x86_64-windows"]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$fmuName.dll")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is Windows, but can't find valid FMU binary."
    elseif Sys.islinux()
        directories = ["binaries/linux64", "binaries/x86_64-linux"]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$fmuName.so")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is Linux, but can't find valid FMU binary."
    elseif Sys.isapple()
        directories = ["binaries/darwin64", "binaries/x86_64-darwin"]
        for directory in directories
            directoryBinary = joinpath(fmu.path, directory)
            if isdir(directoryBinary)
                pathToBinary = joinpath(directoryBinary, "$fmuName.dylib")
                break
            end
        end
        @assert isfile(pathToBinary) "Target platform is macOS, but can't find valid FMU binary."
    else
        @assert false "Unknown target platform."
    end

    lastDirectory = pwd()
    cd(directoryBinary)

    # set FMU binary handler
    fmu.libHandle = dlopen(pathToBinary)

    cd(lastDirectory)

    if fmi2IsCoSimulation(fmu)
        fmu.type = fmi2CoSimulation::fmi2Type
    elseif fmi2IsModelExchange(fmu)
        fmu.type = fmi2ModelExchange::fmi2Type
    else
        error(unknownFMUType)
    end

    if fmi2IsCoSimulation(fmu) && fmi2IsModelExchange(fmu)
        @info "fmi2Load(...): FMU supports both CS and ME, using CS as default if nothing specified."
    end

    tmpResourceLocation = string("file:/", fmu.path)
    tmpResourceLocation = joinpath(tmpResourceLocation, "resources")
    fmu.fmuResourceLocation = replace(tmpResourceLocation, "\\" => "/") # URIs.escapeuri(tmpResourceLocation) # replace(tmpResourceLocation, "\\" => "/")
    @info "FMU ressource location: $(fmu.fmuResourceLocation)"

    # retrieve functions
    fmu.cInstantiate                  = dlsym(fmu.libHandle, :fmi2Instantiate)
    fmu.cGetTypesPlatform             = dlsym(fmu.libHandle, :fmi2GetTypesPlatform)
    fmu.cGetVersion                   = dlsym(fmu.libHandle, :fmi2GetVersion)
    fmu.cFreeInstance                 = dlsym(fmu.libHandle, :fmi2FreeInstance)
    fmu.cSetDebugLogging              = dlsym(fmu.libHandle, :fmi2SetDebugLogging)
    fmu.cSetupExperiment              = dlsym(fmu.libHandle, :fmi2SetupExperiment)
    fmu.cEnterInitializationMode      = dlsym(fmu.libHandle, :fmi2EnterInitializationMode)
    fmu.cExitInitializationMode       = dlsym(fmu.libHandle, :fmi2ExitInitializationMode)
    fmu.cTerminate                    = dlsym(fmu.libHandle, :fmi2Terminate)
    fmu.cReset                        = dlsym(fmu.libHandle, :fmi2Reset)
    fmu.cGetReal                      = dlsym(fmu.libHandle, :fmi2GetReal)
    fmu.cSetReal                      = dlsym(fmu.libHandle, :fmi2SetReal)
    fmu.cGetInteger                   = dlsym(fmu.libHandle, :fmi2GetInteger)
    fmu.cSetInteger                   = dlsym(fmu.libHandle, :fmi2SetInteger)
    fmu.cGetBoolean                   = dlsym(fmu.libHandle, :fmi2GetBoolean)
    fmu.cSetBoolean                   = dlsym(fmu.libHandle, :fmi2SetBoolean)

    fmu.cGetString                    = dlsym_opt(fmu.libHandle, :fmi2GetString)
    fmu.cSetString                    = dlsym_opt(fmu.libHandle, :fmi2SetString)

    if fmi2CanGetSetState(fmu)
        fmu.cGetFMUstate                  = dlsym_opt(fmu.libHandle, :fmi2GetFMUstate)
        fmu.cSetFMUstate                  = dlsym_opt(fmu.libHandle, :fmi2SetFMUstate)
        fmu.cFreeFMUstate                 = dlsym_opt(fmu.libHandle, :fmi2FreeFMUstate)
    end

    if fmi2CanSerializeFMUstate(fmu)
        fmu.cSerializedFMUstateSize       = dlsym_opt(fmu.libHandle, :fmi2SerializedFMUstateSize)
        fmu.cSerializeFMUstate            = dlsym_opt(fmu.libHandle, :fmi2SerializeFMUstate)
        fmu.cDeSerializeFMUstate          = dlsym_opt(fmu.libHandle, :fmi2DeSerializeFMUstate)
    end

    if fmi2ProvidesDirectionalDerivative(fmu)
        fmu.cGetDirectionalDerivative     = dlsym_opt(fmu.libHandle, :fmi2GetDirectionalDerivative)
    end

    # CS specific function calls
    if fmi2IsCoSimulation(fmu)
        fmu.cSetRealInputDerivatives      = dlsym(fmu.libHandle, :fmi2SetRealInputDerivatives)
        fmu.cGetRealOutputDerivatives     = dlsym(fmu.libHandle, :fmi2GetRealOutputDerivatives)
        fmu.cDoStep                       = dlsym(fmu.libHandle, :fmi2DoStep)
        fmu.cCancelStep                   = dlsym(fmu.libHandle, :fmi2CancelStep)
        fmu.cGetStatus                    = dlsym(fmu.libHandle, :fmi2GetStatus)
        fmu.cGetRealStatus                = dlsym(fmu.libHandle, :fmi2GetRealStatus)
        fmu.cGetIntegerStatus             = dlsym(fmu.libHandle, :fmi2GetIntegerStatus)
        fmu.cGetBooleanStatus             = dlsym(fmu.libHandle, :fmi2GetBooleanStatus)
        fmu.cGetStringStatus              = dlsym(fmu.libHandle, :fmi2GetStringStatus)
    end

    # ME specific function calls
    if fmi2IsModelExchange(fmu)
        fmu.cEnterContinuousTimeMode      = dlsym(fmu.libHandle, :fmi2EnterContinuousTimeMode)
        fmu.cGetContinuousStates          = dlsym(fmu.libHandle, :fmi2GetContinuousStates)
        fmu.cGetDerivatives               = dlsym(fmu.libHandle, :fmi2GetDerivatives)
        fmu.cSetTime                      = dlsym(fmu.libHandle, :fmi2SetTime)
        fmu.cSetContinuousStates          = dlsym(fmu.libHandle, :fmi2SetContinuousStates)
        fmu.cCompletedIntegratorStep      = dlsym(fmu.libHandle, :fmi2CompletedIntegratorStep)
        fmu.cEnterEventMode               = dlsym(fmu.libHandle, :fmi2EnterEventMode)
        fmu.cNewDiscreteStates            = dlsym(fmu.libHandle, :fmi2NewDiscreteStates)
        fmu.cGetEventIndicators           = dlsym(fmu.libHandle, :fmi2GetEventIndicators)
        fmu.cGetNominalsOfContinuousStates= dlsym(fmu.libHandle, :fmi2GetNominalsOfContinuousStates)
    end

    fmu
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
        println("\t\t$(vr) $(fmi2ValueReference2String(fmu, vr))")
    end

    println("\tOutputs:\t\t\t$(length(fmu.modelDescription.outputValueReferences))")
    for vr in fmu.modelDescription.outputValueReferences
        println("\t\t$(vr) $(fmi2ValueReference2String(fmu, vr))")
    end

    println("\tStates:\t\t\t\t$(length(fmu.modelDescription.stateValueReferences))")
    for vr in fmu.modelDescription.stateValueReferences
        println("\t\t$(vr) $(fmi2ValueReference2String(fmu, vr))")
    end

    println("\tSupports Co-Simulation:\t\t$(fmi2IsCoSimulation(fmu))")
    if fmi2IsCoSimulation(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.CSmodelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.CScanGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.CScanSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.CSprovidesDirectionalDerivative)")

        println("\t\tVar. com. steps:\t$(fmu.modelDescription.CScanHandleVariableCommunicationStepSize)")
        println("\t\tInput interpol.:\t$(fmu.modelDescription.CScanInterpolateInputs)")
        println("\t\tMax order out. der.:\t$(fmu.modelDescription.CSmaxOutputDerivativeOrder)")
    end

    println("\tSupports Model-Exchange:\t$(fmi2IsModelExchange(fmu))")
    if fmi2IsModelExchange(fmu)
        println("\t\tModel identifier:\t$(fmu.modelDescription.MEmodelIdentifier)")
        println("\t\tGet/Set State:\t\t$(fmu.modelDescription.MEcanGetAndSetFMUstate)")
        println("\t\tSerialize State:\t$(fmu.modelDescription.MEcanSerializeFMUstate)")
        println("\t\tDir. Derivatives:\t$(fmu.modelDescription.MEprovidesDirectionalDerivative)")
    end

    println("##################### End information for FMU #####################")
end

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available the CoSimulation Simulation is started
"""
function fmi2Simulate(fmu::FMU2, t_start::Real = 0.0, t_stop::Real = 1.0;
                      recordValues::fmi2ValueReferenceFormat = nothing, saveat=[], setup=true)
    fmi2Simulate(fmu.components[end], t_start, t_stop;
                 recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
Starts a simulation of a CS-FMU instance.
"""
function fmi2SimulateCS(fmu::FMU2, t_start::Real, t_stop::Real;
                        recordValues::fmi2ValueReferenceFormat = nothing, saveat=[], setup=true)
    fmi2SimulateCS(fmu.components[end], t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup)
end

"""
TODO
"""
function fmi2SimulateME(fmu::FMU2, t_start::Real, t_stop::Real;
                        recordValues::fmi2ValueReferenceFormat = nothing, saveat = [], setup = true, solver = nothing)
    fmi2SimulateME(fmu.components[end], t_start, t_stop;
                   recordValues=recordValues, saveat=saveat, setup=setup, solver=solver)
end

"""
Unload a FMU.

Free the allocated memory, close the binaries and remove temporary zip and unziped fmu model description.
"""
function fmi2Unload(fmu::FMU2, cleanUp::Bool = true)

    while length(fmu.components) > 0
        fmi2FreeInstance!(fmu.components[end])
    end

    dlclose(fmu.libHandle)

    # the components are removed from the component list via call to fmi2FreeInstance!
    @assert length(fmu.components) == 0 "fmi2Unload(...): Failure during deleting components, $(length(fmu.components)) remaining in stack."

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
Returns a string representing the header file used to compile the fmi2 functions.function

Returns "default" by default

For more information call ?fmi2GetTypesPlatform
"""
function fmi2GetTypesPlatform(fmu::FMU2)
    fmi2GetTypesPlatform(fmu.cGetTypesPlatform)
end

"""
Returns the version of the FMI Standard used in this FMU

For more information call ?fmi2GetVersion
"""
function fmi2GetVersion(fmu::FMU2)
    fmi2GetVersion(fmu.cGetVersion)
end

"""
Create a new instance of the given fmu, adds a logger if logginOn == true.

Returns the instance of a new FMU component.

For more information call ?fmi2Instantiate
"""
function fmi2Instantiate!(fmu::FMU2; visible::Bool = false, loggingOn::Bool = false)

    ptrLogger = @cfunction(cbLogger, Cvoid, (Ptr{Cvoid}, Ptr{Cchar}, Cuint, Ptr{Cchar}, Ptr{Cchar}))
    ptrAllocateMemory = @cfunction(cbAllocateMemory, Ptr{Cvoid}, (Csize_t, Csize_t))
    ptrFreeMemory = @cfunction(cbFreeMemory, Cvoid, (Ptr{Cvoid},))
    ptrStepFinished = C_NULL
    fmu.callbackFunctions = fmi2CallbackFunctions(ptrLogger, ptrAllocateMemory, ptrFreeMemory, ptrStepFinished, C_NULL)

    compAddr = fmi2Instantiate(fmu.cInstantiate, fmu.instanceName, fmu.type, fmu.modelDescription.guid, fmu.fmuResourceLocation, fmu.callbackFunctions, fmi2Boolean(visible), fmi2Boolean(loggingOn))

    if compAddr == Ptr{Cvoid}(C_NULL)
        @error "fmi2Instantiate!(...): Instantiation failed!"
        return nothing
    end

    component = fmi2Component(compAddr, fmu)
    push!(fmu.components, component)
    component
end

"""
Free the allocated memory used for the logger and fmu2 instance and destroy the instance.

For more information call ?fmi2FreeInstance
"""
function fmi2FreeInstance!(fmu::FMU2)
    fmi2FreeInstance!(fmu.components[end])
    pop!(fmu.components)
    nothing
end

"""
Set the DebugLogger for the FMU

For more information call ?fmi2SetDebugLogging
"""
function fmi2SetDebugLogging(fmu::FMU2)
    fmi2SetDebugLogging(fmu.components[end])
end

"""
Setup the simulation but without defining all of the parameters

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(fmu::FMU2, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)
    fmi2SetupExperiment(fmu.components[end], startTime, stopTime; tolerance=tolerance)
end

"""
FMU enters Initialization mode

For more information call ?fmi2EnterInitializationMode
"""
function fmi2EnterInitializationMode(fmu::FMU2)
    fmi2EnterInitializationMode(fmu.components[end])
end

"""
FMU exits Initialization mode

For more information call ?fmi2ExitInitializationMode
"""
function fmi2ExitInitializationMode(fmu::FMU2)
    fmi2ExitInitializationMode(fmu.components[end])
end

"""
Informs FMU that simulation run is terminated

For more information call ?fmi2Terminate
"""
function fmi2Terminate(fmu::FMU2)
    fmi2Terminate(fmu.components[end])
end

"""
Resets FMU

For more information call ?fmi2Reset
"""
function fmi2Reset(fmu::FMU2)
    fmi2Reset(fmu.components[end])
end

"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal(fmu::FMU2, vr::fmi2ValueReferenceFormat)
    fmi2GetReal(fmu.components[end], vr)
end

"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal!(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})
    fmi2GetReal!(fmu.components[end], vr, values)
end

"""
Set the values of an array of fmi2Real variables

For more information call ?fmi2SetReal
"""
function fmi2SetReal(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Real}, <:Real})
    fmi2SetReal(fmu.components[end], vr, values)
end

"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(fmu::FMU2, vr::fmi2ValueReferenceFormat)
    fmi2GetInteger(fmu.components[end], vr)
end

"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger!(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})
    fmi2GetInteger!(fmu.components[end], vr, values)
end

"""
Set the values of an array of fmi2Integer variables

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{<:Integer}, <:Integer})
    fmi2SetInteger(fmu.components[end], vr, values)
end

"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(fmu::FMU2, vr::fmi2ValueReferenceFormat)
    fmi2GetBoolean(fmu.components[end], vr)
end

"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean!(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    fmi2GetBoolean!(fmu.components[end], vr, values)
end

"""
Set the values of an array of fmi2Boolean variables

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{Bool}, Bool})
    fmi2SetBoolean(fmu.components[end], vr, values)
end

"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString(fmu::FMU2, vr::fmi2ValueReferenceFormat)
    fmi2GetString(fmu.components[end], vr)
end

"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString!(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})
    fmi2GetString!(fmu.components[end], vr, values)
end

"""
Set the values of an array of fmi2String variables

For more information call ?fmi2SetString
"""
function fmi2SetString(fmu::FMU2, vr::fmi2ValueReferenceFormat, values::Union{Array{String}, String})
    fmi2SetString(fmu.components[end], vr, values)
end

"""
Get the pointer to the current FMU state

For more information call ?fmi2GetFMUstate
"""
function fmi2GetFMUstate(fmu::FMU2)
    state = fmi2FMUstate()
    stateRef = Ref(state)
    fmi2GetFMUstate(fmu.components[end], stateRef)
    state = stateRef[]
    state
end

"""
Set the FMU to the given fmi2FMUstate

For more information call ?fmi2SetFMUstate
"""
function fmi2SetFMUstate(fmu::FMU2, state::fmi2FMUstate)
    fmi2SetFMUstate(fmu.components[end], state)
end

"""
Free the allocated memory for the FMU state

For more information call ?fmi2FreeFMUstate
"""
function fmi2FreeFMUstate(fmu::FMU2, state::fmi2FMUstate)
    stateRef = Ref(state)
    fmi2FreeFMUstate(fmu.components[end], stateRef)
    state = stateRef[]
end

"""
Returns the size of a byte vector the FMU can be stored in

For more information call ?fmi2SerzializedFMUstateSize
"""
function fmi2SerializedFMUstateSize(fmu::FMU2, state::fmi2FMUstate)
    size = 0
    sizeRef = Ref(Csize_t(size))
    fmi2SerializedFMUstateSize(fmu.components[end], state, sizeRef)
    size = sizeRef[]
end

"""
Serialize the data in the FMU state pointer

For more information call ?fmi2SerzializeFMUstate
"""
function fmi2SerializeFMUstate(fmu::FMU2, state::fmi2FMUstate)
    size = fmi2SerializedFMUstateSize(fmu, state)
    serializedState = Array{fmi2Byte}(undef, size)
    fmi2SerializeFMUstate(fmu.components[end], state, serializedState, size)
    serializedState
end

"""
Deserialize the data in the serializedState fmi2Byte field

For more information call ?fmi2DeSerzializeFMUstate
"""
function fmi2DeSerializeFMUstate(fmu::FMU2, serializedState::Array{fmi2Byte})
    size = length(serializedState)
    state = fmi2FMUstate()
    stateRef = Ref(state)
    fmi2DeSerializeFMUstate(fmu.components[end], serializedState, Csize_t(size), stateRef)
    state = stateRef[]
end

"""
Computes directional derivatives

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi2GetDirectionalDerivative(fmu::FMU2,
                                      vUnknown_ref::Array{fmi2ValueReference},
                                      vKnown_ref::Array{fmi2ValueReference},
                                      dvKnown::Array{fmi2Real} = Array{fmi2Real}([]))

    nKnown = Csize_t(length(vKnown_ref))
    nUnknown = Csize_t(length(vUnknown_ref))

    if length(dvKnown) < nKnown
        dvKnown = ones(fmi2Real, nKnown)
    end

    dvUnknown = zeros(fmi2Real, nUnknown)

    fmi2GetDirectionalDerivative!(fmu.components[end], vUnknown_ref, nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown)

    dvUnknown
end

"""
Computes directional derivatives

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi2GetDirectionalDerivative(fmu::FMU2,
                                      vUnknown_ref::fmi2ValueReference,
                                      vKnown_ref::fmi2ValueReference,
                                      dvKnown::fmi2Real = 1.0,
                                      dvUnknown::fmi2Real = 1.0)

    fmi2GetDirectionalDerivative(fmu, [vUnknown_ref], [vKnown_ref], [dvKnown])[1]
end

"""
Sets the n-th time derivative of real input variables.

vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi2SetRealInputDerivatives
"""
function fmi2SetRealInputDerivatives(fmu::FMU2, vr::fmi2ValueReference, nvr::Cint, order::Integer, value::Real)
    fmi2SetRealInputDerivatives(fmu.components[end], vr, nvr, fmi2Integer(order), fmi2Real(value))
end

"""
Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables

For more information call ?fmi2GetRealOutputDerivatives
"""
function fmi2GetRealOutputDerivatives(fmu::FMU2, vr::fmi2ValueReference, nvr::Cint, order::Integer, value::Real)
    fmi2GetRealOutputDerivatives(fmu.components[end], vr, nvr, fmi2Integer(order), fmi2Real(value))
end

"""
The computation of a time step is started.

For more information call ?fmi2DoStep
"""
function fmi2DoStep(fmu::FMU2, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
    fmi2DoStep(fmu.components[end], fmi2Real(currentCommunicationPoint), fmi2Real(communicationStepSize), fmi2Boolean(noSetFMUStatePriorToCurrentPoint))
end

function fmi2DoStep(fmu::FMU2, communicationStepSize::Real)
    fmi2DoStep(fmu.components[end], fmi2Real(fmu.t), fmi2Real(communicationStepSize), fmi2True)
    fmu.t += communicationStepSize
end

"""
Cancels a DoStep that didn't finish correctly

For more information call ?fmi2CancelStep
"""
function fmi2CancelStep(fmu::FMU2)
    fmi2CancelStep(fmu.components[end])
end

"""
Informs Master of fmi2Status

For more information call ?fmi2GetStatus
"""
function fmi2GetStatus(fmu::FMU2, s::fmi2StatusKind, value::fmi2Status)
    fmi2GetStatus(fmu.components[end], s, value)
end

"""
Informs Master of fmi2Status of fmi2Real

For more information call ?fmi2GetRealStatus
"""
function fmi2GetRealStatus(fmu::FMU2, s::fmi2StatusKind, value::Real)
    fmi2GetRealStatus(fmu.components[end], s, fmi2Real(value))
end

"""
Informs Master of fmi2Status of fmi2Integer

For more information call ?fmi2GetIntegerStatus
"""
function fmi2GetIntegerStatus(fmu::FMU2, s::fmi2StatusKind, value::Integer)
    fmi2GetIntegerStatus(fmu.components[end], s, fmi2Integer(value))
end

"""
Informs Master of fmi2Status of fmi2Boolean

For more information call ?fmi2GetBooleanStatus
"""
function fmi2GetBooleanStatus(fmu::FMU2, s::fmi2StatusKind, value::Bool)
    fmi2GetBooleanStatus(fmu.components[end], s, fmiBoolean(value))
end

"""
Informs Master of fmi2Status of fmi2String

For more information call ?fmi2GetStringStatus
"""
function fmi2GetStringStatus(fmu::FMU2, s::fmi2StatusKind, value::String)
    fmi2GetStringStatus(fmu.components[end], s, fmiString(value))
end

"""
Set independent variable time and reinitialize chaching of variables that depend on time

For more information call ?fmi2SetTime
"""
function fmi2SetTime(fmu::FMU2, time::Real)
    fmu.t = time
    fmi2SetTime(fmu.components[end], fmi2Real(time))
end

"""
Set a new (continuous) state vector and reinitialize chaching of variables that depend on states

For more information call ?fmi2SetContinuousStates
"""
function fmi2SetContinuousStates(fmu::FMU2, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    fmu.x = x
    fmi2SetContinuousStates(fmu.components[end], Array{fmi2Real}(x), nx)
end

"""
The model enters Event Mode

For more information call ?fmi2EnterEventMode
"""
function fmi2EnterEventMode(fmu::FMU2)
    fmi2EnterEventMode(fmu.components[end])
end

"""
Increment the super dense time in event mode

For more information call ?fmi2NewDiscreteStates
"""
function fmi2NewDiscreteStates(fmu::FMU2)
    eventInfo = fmi2EventInfo()
    fmi2NewDiscreteStates(fmu.components[end], eventInfo)
    eventInfo
end

"""
The model enters Continuous-Time Mode

For more information call ?fmi2EnterContinuousTimeMode
"""
function fmi2EnterContinuousTimeMode(fmu::FMU2)
    fmi2EnterContinuousTimeMode(fmu.components[end])
end

"""
This function must be called by the environment after every completed step
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated

For more information call ?fmi2CompletedIntegratorStep
"""
function fmi2CompletedIntegratorStep(fmu::FMU2,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    enterEventMode = fmi2Boolean(false)
    terminateSimulation = fmi2Boolean(false)
    status = fmi2CompletedIntegratorStep!(fmu.components[end],
                                         noSetFMUStatePriorToCurrentPoint,
                                         enterEventMode,
                                         terminateSimulation)
    (status, enterEventMode, terminateSimulation)
end

"""
Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi2GetDerivatives
"""
function  fmi2GetDerivatives(fmu::FMU2)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    derivatives = zeros(fmi2Real, nx)
    fmi2GetDerivatives(fmu.components[end], derivatives, nx)
    derivatives
end

"""
Returns the event indicators of the FMU

For more information call ?fmi2GetEventIndicators
"""
function fmi2GetEventIndicators(fmu::FMU2)
    ni = Csize_t(fmu.modelDescription.numberOfEventIndicators)
    eventIndicators = zeros(fmi2Real, ni)
    fmi2GetEventIndicators(fmu.components[end], eventIndicators, ni)
    eventIndicators
end

"""
Return the new (continuous) state vector x

For more information call ?fmi2GetContinuousStates
"""
function fmi2GetContinuousStates(fmu::FMU2)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetContinuousStates(fmu.components[end], x, nx)
    x
end

"""
Return the nominal values of the continuous states.

For more information call ?fmi2GetNominalsOfContinuousStates
"""
function fmi2GetNominalsOfContinuousStates(fmu::FMU2)
    nx = Csize_t(fmu.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetNominalsOfContinuousStates(fmu.components[end], x, nx)
    x
end
