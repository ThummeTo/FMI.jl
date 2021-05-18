#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl
using ZipFile

include("FMI2_md.jl")

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 2.0.2 function pointers
"""
mutable struct FMU2
    modelName::fmi2String
    instanceName::fmi2String
    fmuResourceLocation::fmi2String
    fmuGUID::fmi2String
    # fmi2FMUstate::fmi2FMUstate
    # eventInfo::fmi2EventInfo  currently not supported

    modelDescription::fmi2ModelDescription

    # Other stuff
    fmuType::fmi2Type
    callbackFunctions::fmi2CallbackFunctions
    components::Array{fmi2Component}

    t::Real # current time
    next_t::Real

    # paths of ziped and unziped FMU folders
    fmu2Path::fmi2String
    zipPath::fmi2String

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

    # c-function pointers (helpers)
    libHandle::Ptr{Nothing}
    cbLibHandle::Ptr{Nothing}
    libLoggerHandle::Ptr{Nothing}
    cAllocateFmi2CallbackFunctions::Ptr{Cvoid}
    cFreeFmi2CallbackFunctions::Ptr{Cvoid}

    # sensitivity logging for backward pass
    sensitivities

    # Constructor
    FMU2() = new()
end

""" struct to handle FMU simulation data / results """
mutable struct fmi2SimulationResult
    valueReferences::Array{fmi2ValueReference}
    dataPoints::Array
    fmu::FMU2

    fmi2SimulationResult() = new()
end

""" collects all data points for variable save index ´i´ inside a fmi2SimulationResult ´sd´ """
function fmi2SimulationResultGetValuesAtIndex(sd::fmi2SimulationResult, i)
    collect(dataPoint[i] for dataPoint in sd.dataPoints)
end

""" collects all time data points inside a fmi2SimulationResult ´sd´ """
function fmi2SimulationResultGetTime(sd::fmi2SimulationResult)
    fmi2SimulationResultGetValuesAtIndex(sd, 1)
end

""" collects all data points for variable with value reference ´tvr´ inside a fmi2SimulationResult ´sd´ """
function fmi2SimulationResultGetValues(sd::fmi2SimulationResult, tvr::fmi2ValueReference)
    @assert tvr != nothing ["fmi2SimulationResultGetValues(...): value referrnce is nothing!"]
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

""" collects all data points for variable with value name ´s´ inside a fmi2SimulationResult ´sd´ """
function fmi2SimulationResultGetValues(sd::fmi2SimulationResult, s::String)
    fmi2SimulationResultGetValues(sd, fmi2String2ValueReference(sd.fmu, s))
end

"""
Returns the ValueReference coresponding to the variable name
"""
function fmi2String2ValueReference(fmu2::FMU2, name::String)
    reference = nothing
    if haskey(fmu2.modelDescription.stringValueReferences, name)
        reference = fmu2.modelDescription.stringValueReferences[name]
    else
        display("[WARNING]: no variable with this name found")
    end
    reference
end

"""
Returns an array of ValueReferences coresponding to the variable names
"""
function fmi2String2ValueReference(fmu2::FMU2, names::Array{String})
    vr = Array{fmi2ValueReference}(undef,0)
    for string in names
        reference = fmi2String2ValueReference(fmu2, string)
        if reference == nothing
            display("[ERROR]: valueReference not found")
        else
            push!(vr, reference)
        end
    end
    vr
end
"""
Returns an array of variable names matching a fmi2ValueReference
"""
function fmi2ValueReference2String(fmu2::FMU2, reference::fmi2ValueReference)
    variables = [k for (k,v) in fmu2.modelDescription.stringValueReferences if v == reference]
end

"""
create a copy of the .fmu file as a .zip folder and unzips it
returns the paths to the ziped and ziped folders
"""
function fmi2Unzip(pathTofmu::String)
    # set paths for fmu handling
    zipname = splitext(pathTofmu)
    zipPath = string(zipname[1], ".zip")
    unzipedfmuPath = string(zipname[1], "/")

    if !isdir(unzipedfmuPath)
        cp(pathTofmu, zipPath; force = true)
        mkdir(unzipedfmuPath)

        fileFullPath = isabspath(zipPath) ?  zipPath : joinpath(pwd(),zipPath)
        basePath = dirname(fileFullPath)
        outPath = (unzipedfmuPath == "" ? basePath : (isabspath(unzipedfmuPath) ? unzipedfmuPath : joinpath(pwd(),unzipedfmuPath)))
        isdir(outPath) ? "" : mkdir(outPath)
        zarchive = ZipFile.Reader(fileFullPath)
        for f in zarchive.files
            fullFilePath = joinpath(outPath,f.name)
            if (endswith(f.name,"/") || endswith(f.name,"\\"))
                #mkdir(fullFilePath)
                mkpath(fullFilePath)
            else
                mkpath(dirname(fullFilePath))
                write(fullFilePath, read(f))
            end
        end
        close(zarchive)

        # InfoZIP.unzip(zipPath, unzipedfmuPath)
    end

    @assert isdir(unzipedfmuPath) ["Error:FMU not loaded"]

    (unzipedfmuPath, zipPath)
end

"""
sets the properties of the fmu by reading the modelDescription.xml
retrieve all the pointers of DLL functions for later @userplot

returns the instance of the fmu struct
"""
function fmi2Load(pathTofmu2::String)
    # Create uninitialized FMU
    fmu_2 = FMU2()
    fmu_2.components = []

    # set paths for fmu handling
    (fmu_2.fmu2Path, fmu_2.zipPath) = fmi2Unzip(pathTofmu2)

    # set paths for modelExchangeScripting and Dll
    tmpName = splitpath(fmu_2.fmu2Path)
    fmuName = tmpName[length(tmpName)]
    pathToModelDescription = joinpath(fmu_2.fmu2Path, "modelDescription.xml")
    directoryDLL = joinpath(fmu_2.fmu2Path, "binaries/win64")
    pathToDLL = joinpath(directoryDLL, "$fmuName.dll")

    # parse modelDescription.xml
    fmu_2.modelDescription = fmi2readModelDescription(pathToModelDescription)
    fmu_2.modelName = fmu_2.modelDescription.modelName
    fmu_2.instanceName = fmu_2.modelDescription.modelName

    lastDirectory = pwd()
    cd(directoryDLL)

    # set FMU DLL handler
    fmu_2.libHandle = dlopen(pathToDLL)

    cd(dirname(@__FILE__))

    cbLibPath = joinpath(dirname(@__FILE__),"callbackFunctions/binaries/win64/callbackFunctions.dll")

    # check permission to execute the DLL
    perm = filemode(cbLibPath)
    permRWX = 16895
    if perm != permRWX
        chmod(cbLibPath, permRWX; recursive=true)
    end

    # set helper function
    fmu_2.cbLibHandle = dlopen(cbLibPath)

    cd(lastDirectory)

    # set fmu properties
    fmu_2.fmuGUID = fmu_2.modelDescription.guid

    if fmu_2.modelDescription.isCoSimulation == fmi2True &&
        fmu_2.modelDescription.isModelExchange == fmi2True
        display("[INFO]: fmi2Load: FMU supports both CS and ME, using CS as default if nothing specified.")
    end

    if fmu_2.modelDescription.isCoSimulation == fmi2True
        fmu_2.fmuType = fmi2CoSimulation::fmi2Type
    elseif fmu_2.modelDescription.isModelExchange == fmi2True
        fmu_2.fmuType = fmi2ModelExchange::fmi2Type
    else
        error(unknownFMUType)
    end

    tmpResourceLocation = string("file:/", fmu_2.fmu2Path)
    tmpResourceLocation = joinpath(tmpResourceLocation, "resources")
    fmu_2.fmuResourceLocation = replace(tmpResourceLocation, "\\" => "/")
    display("[INFO]: FMU ressource location: $(fmu_2.fmuResourceLocation)")
    # fmu_2.eventInfo = EventInfo()

    # retrieve functions
    fmu_2.cInstantiate                  = dlsym(fmu_2.libHandle, :fmi2Instantiate)
    fmu_2.cGetTypesPlatform             = dlsym(fmu_2.libHandle, :fmi2GetTypesPlatform)
    fmu_2.cGetVersion                   = dlsym(fmu_2.libHandle, :fmi2GetVersion)
    fmu_2.cFreeInstance                 = dlsym(fmu_2.libHandle, :fmi2FreeInstance)
    fmu_2.cSetDebugLogging              = dlsym(fmu_2.libHandle, :fmi2SetDebugLogging)
    fmu_2.cSetupExperiment              = dlsym(fmu_2.libHandle, :fmi2SetupExperiment)
    fmu_2.cEnterInitializationMode      = dlsym(fmu_2.libHandle, :fmi2EnterInitializationMode)
    fmu_2.cExitInitializationMode       = dlsym(fmu_2.libHandle, :fmi2ExitInitializationMode)
    fmu_2.cTerminate                    = dlsym(fmu_2.libHandle, :fmi2Terminate)
    fmu_2.cReset                        = dlsym(fmu_2.libHandle, :fmi2Reset)
    fmu_2.cGetReal                      = dlsym(fmu_2.libHandle, :fmi2GetReal)
    fmu_2.cSetReal                      = dlsym(fmu_2.libHandle, :fmi2SetReal)
    fmu_2.cGetInteger                   = dlsym(fmu_2.libHandle, :fmi2GetInteger)
    fmu_2.cSetInteger                   = dlsym(fmu_2.libHandle, :fmi2SetInteger)
    fmu_2.cGetBoolean                   = dlsym(fmu_2.libHandle, :fmi2GetBoolean)
    fmu_2.cSetBoolean                   = dlsym(fmu_2.libHandle, :fmi2SetBoolean)
    fmu_2.cGetString                    = dlsym(fmu_2.libHandle, :fmi2GetString)
    fmu_2.cSetString                    = dlsym(fmu_2.libHandle, :fmi2SetString)
    fmu_2.cGetFMUstate                  = dlsym(fmu_2.libHandle, :fmi2GetFMUstate)
    fmu_2.cSetFMUstate                  = dlsym(fmu_2.libHandle, :fmi2SetFMUstate)
    fmu_2.cFreeFMUstate                 = dlsym(fmu_2.libHandle, :fmi2FreeFMUstate)
    fmu_2.cSerializedFMUstateSize       = dlsym(fmu_2.libHandle, :fmi2SerializedFMUstateSize)
    fmu_2.cSerializeFMUstate            = dlsym(fmu_2.libHandle, :fmi2SerializeFMUstate)
    fmu_2.cDeSerializeFMUstate          = dlsym(fmu_2.libHandle, :fmi2DeSerializeFMUstate)
    fmu_2.cGetDirectionalDerivative     = dlsym(fmu_2.libHandle, :fmi2GetDirectionalDerivative)
    fmu_2.cSetRealInputDerivatives      = dlsym(fmu_2.libHandle, :fmi2SetRealInputDerivatives)
    fmu_2.cGetRealOutputDerivatives     = dlsym(fmu_2.libHandle, :fmi2GetRealOutputDerivatives)
    fmu_2.cDoStep                       = dlsym(fmu_2.libHandle, :fmi2DoStep)
    fmu_2.cCancelStep                   = dlsym(fmu_2.libHandle, :fmi2CancelStep)
    fmu_2.cGetStatus                    = dlsym(fmu_2.libHandle, :fmi2GetStatus)
    fmu_2.cGetRealStatus                = dlsym(fmu_2.libHandle, :fmi2GetRealStatus)
    fmu_2.cGetIntegerStatus             = dlsym(fmu_2.libHandle, :fmi2GetIntegerStatus)
    fmu_2.cGetBooleanStatus             = dlsym(fmu_2.libHandle, :fmi2GetBooleanStatus)
    fmu_2.cGetStringStatus              = dlsym(fmu_2.libHandle, :fmi2GetStringStatus)

    # Model Exchange function calls
    fmu_2.cEnterContinuousTimeMode      = dlsym(fmu_2.libHandle, :fmi2EnterContinuousTimeMode)
    fmu_2.cGetContinuousStates          = dlsym(fmu_2.libHandle, :fmi2GetContinuousStates)
    fmu_2.cGetDerivatives               = dlsym(fmu_2.libHandle, :fmi2GetDerivatives)
    fmu_2.cSetTime                      = dlsym(fmu_2.libHandle, :fmi2SetTime)
    fmu_2.cSetContinuousStates          = dlsym(fmu_2.libHandle, :fmi2SetContinuousStates)
    fmu_2.cCompletedIntegratorStep      = dlsym(fmu_2.libHandle, :fmi2CompletedIntegratorStep)
    fmu_2.cEnterEventMode               = dlsym(fmu_2.libHandle, :fmi2EnterEventMode)
    fmu_2.cNewDiscreteStates            = dlsym(fmu_2.libHandle, :fmi2NewDiscreteStates)
    fmu_2.cGetEventIndicators           = dlsym(fmu_2.libHandle, :fmi2GetEventIndicators)
    fmu_2.cGetNominalsOfContinuousStates= dlsym(fmu_2.libHandle, :fmi2GetNominalsOfContinuousStates)

    # custom callback function calls
    fmu_2.cAllocateFmi2CallbackFunctions = dlsym(fmu_2.cbLibHandle, :allocateFmi2CallbackFunctions)
    fmu_2.cFreeFmi2CallbackFunctions = dlsym(fmu_2.cbLibHandle, :freeFmi2CallbackFunctions)

    fmu_2
end

"""
Starts a simulation of the fmu instance for the matching fmu type, if both types are available the CoSimulation Simulation is started
"""
function fmi2Simulate(fmu2::FMU2, dt::Real, t_start::Real = 0.0, t_stop::Real = 1.0, recordValues::Union{Array{fmi2ValueReference}, Array{String}} = [])

    if fmu2.fmuType == fmi2CoSimulation::fmi2Type
        fmi2SimulateCS(fmu2, dt, t_start, t_stop, recordValues)
    elseif fmu2.fmuType == fmi2ModelExchange::fmi2Type
        fmi2SimulateME(fmu2, dt, t_start, t_stop)
    else
        error(unknownFMUType)
    end
end

function fmi2SimulateCS(fmu2::FMU2, dt::Real, t_start::Real, t_stop::Real, recordValues::Array{fmi2ValueReference} = [], setup=true)

    if setup
        fmi2SetupExperiment(fmu2, t_start, t_stop)
        fmiEnterInitializationMode(fmu2)
        fmiExitInitializationMode(fmu2)
    end

    t = t_start

    sd = nothing
    record = length(recordValues) > 0

    numDigits = length(string(round(Integer, 1/dt)))

    if record
        sd = fmi2SimulationResult()
        sd.valueReferences = recordValues
        sd.dataPoints = []
        sd.fmu = fmu2

        values = fmi2GetReal(fmu2, sd.valueReferences)
        push!(sd.dataPoints, (t, values...))

        while t < t_stop
            fmiDoStep(fmu2, t, dt)
            t = round(t + dt, digits=numDigits)

            values = fmi2GetReal(fmu2, sd.valueReferences)
            push!(sd.dataPoints, (t, values...))
        end
    else
        while t < t_stop
            fmiDoStep(fmu2, t, dt)
            t = round(t + dt, digits=numDigits)
        end
    end

    sd
end

function fmi2SimulateCS(fmu2::FMU2, dt::Real, t_start::Real, t_stop::Real, recordValues::Array{String}, setup=true)
    vr = fmi2String2ValueReference(fmu2, recordValues)
    fmi2SimulateCS(fmu2, dt, t_start, t_stop, vr, setup)
end

"""
Unload a fmu under the FMI-Standard 2.0.2

Free the allocated memory, close the DLLs and remove temporary zip and unziped fmu fmi2ModelDescription
"""
function fmi2Unload(fmu2::FMU2, cleanUp::Bool = true)
    fmi2FreeInstance!(fmu2)

    dlclose(fmu2.libHandle)
    dlclose(fmu2.cbLibHandle)

    if cleanUp
        try
            rm(fmu2.fmu2Path; recursive = true, force = true)
            rm(fmu2.zipPath; recursive = true, force = true)
        catch e
            display("[Warning]: Cannot delete unpacked data on disc.")
        end
    end
end


# Comfort functions for fmi2 functions


"""
Returns a string representing the header file used to compile the fmi2 functions.function

Returns "default" by default

For more information call ?fmi2GetTypesPlatform
"""
function fmi2GetTypesPlatform(fmu2::FMU2)
    fmi2GetTypesPlatform(fmu2.cGetTypesPlatform)
end

"""
Returns the version of the FMI Standard used in this FMU

For more information call ?fmi2GetVersion
"""
function fmi2GetVersion(fmu2::FMU2)
    fmi2GetVersion(fmu2.cGetVersion)
end

"""
Create a new instance of the given fmu2, adds a logger if logginOn == true

Returns the instance of the fmu2

For more information call ?fmi2Instantiate
"""
function fmi2Instantiate!(fmu2::FMU2; visible::Bool = false, loggingOn::Bool = false)
    fmu2.callbackFunctions = ccall(fmu2.cAllocateFmi2CallbackFunctions,
                    Ptr{Cvoid},
                    ())

    compAddr = fmi2Instantiate(fmu2.cInstantiate, fmu2.instanceName, fmu2.fmuType, fmu2.fmuGUID, fmu2.fmuResourceLocation, fmu2.callbackFunctions, fmi2Boolean(visible), fmi2Boolean(loggingOn))

    component = fmi2Component(compAddr, fmu2)
    push!(fmu2.components, component)
    component
end

"""
Free the allocated memory used for the looger and fmu2 instance and destroy the instance

For more information call ?fmi2FreeInstance
"""
function fmi2FreeInstance!(fmu2::FMU2)
    ccall(fmu2.cFreeFmi2CallbackFunctions, Cvoid, (Ptr{Cvoid},), fmu2.callbackFunctions)
    fmu2.callbackFunctions = C_NULL

    for component in fmu2.components
        fmi2FreeInstance(component)
    end

    fmu2.components = []
end

"""
Set the DebugLogger for the FMU

For more information call ?fmi2SetDebugLogging
"""
function fmi2SetDebugLogging(fmu2::FMU2)
    fmi2SetDebugLogging(fmu2.components[end], fmi2False, Unsigned(0), C_NULL)
end

"""
Set the start and end time for a simulation, can only be called after fmi2Instantiate and before fmi2EnterInitializationMode

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(fmu2::FMU2,
    toleranceDefined::Bool,
                tolerance::Real,
                startTime::Real,
                stopTimeDefined::Bool,
                stopTime::Real)
    fmu2.t = startTime
    fmi2SetupExperiment(fmu2.components[end], fmi2Boolean(toleranceDefined), fmi2Real(tolerance),
                            fmi2Real(startTime), fmi2Boolean(stopTimeDefined), fmi2Real(stopTime))
end

"""
Setup the simulation but without defining all of the parameters

For more information call ?fmi2SetupExperiment
"""
function fmi2SetupExperiment(fmu2::FMU2, startTime::Real = 0.0, stopTime::Real = startTime; tolerance::Real = 0.0)

    toleranceDefined = (tolerance > 0.0)
    stopTimeDefined = (stopTime > startTime)

    fmi2SetupExperiment(fmu2, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end

"""
FMU enters Initialization mode

For more information call ?fmi2EnterInitializationMode
"""
function fmi2EnterInitializationMode(fmu2::FMU2)
    fmi2EnterInitializationMode(fmu2.components[end])
end

"""
FMU exits Initialization mode

For more information call ?fmi2ExitInitializationMode
"""
function fmi2ExitInitializationMode(fmu2::FMU2)
    fmi2ExitInitializationMode(fmu2.components[end])
end

"""
Informs FMU that simulation run is terminated

For more information call ?fmi2Terminate
"""
function fmi2Terminate(fmu2::FMU2)
    fmi2Terminate(fmu2.components[end])
end

"""
Reset FMU

For more information call ?fmi2Reset
"""
function fmi2Reset(fmu2::FMU2)
    fmi2Reset(fmu2.components[end])
end

"""
Get the values of an array of fmi2Real variables

For more information call ?fmi2GetReal
"""
function fmi2GetReal(fmu2::FMU2, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    values = zeros(fmi2Real, nvr)
    fmi2GetReal!(fmu2.components[end], vr, nvr, values)
    values
end

"""
Get the value of a fmi2Real variable

For more information call ?fmi2GetReal
"""
function fmi2GetReal(fmu2::FMU2, vr::fmi2ValueReference)
    values = fmi2GetReal(fmu2, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Real variables by variable name

For more information call ?fmi2GetReal
"""
function fmi2GetReal(fmu2::FMU2, vr_string::Array{String})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetReal(fmu2, vr)
    end
end
"""
Get the value of a fmi2Real variable by variable name

For more information call ?fmi2GetReal
"""
function fmi2GetReal(fmu2::FMU2, vr_string::String)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetReal(fmu2, vr)
    end
end
"""
Set the values of an array of fmi2Real variables

For more information call ?fmi2SetReal
"""
function fmi2SetReal(fmu2::FMU2, vr::Array{fmi2ValueReference}, value::Array{<:Real})
    nvr = Csize_t(length(vr))
    fmi2SetReal(fmu2.components[end], vr, nvr, Array{fmi2Real}(value))
end

"""
Set the value of a fmi2Real variable

For more information call ?fmi2SetReal
"""
function fmi2SetReal(fmu2::FMU2, vr::fmi2ValueReference, value::Real)
    fmi2SetReal(fmu2, [vr], [value])
end
"""
Set the values of an array of fmi2Real variables by variable name

For more information call ?fmi2SetReal
"""
function fmi2SetReal(fmu2::FMU2, vr_string::Array{String}, value::Array{<:Real})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetReal(fmu2, vr, value)
    end
end
"""
Set the value of a fmi2Real variable by variable name

For more information call ?fmi2SetReal
"""
function fmi2SetReal(fmu2::FMU2, vr_string::String, value::Real)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetReal(fmu2, vr, value)
    end
end
"""
Get the values of an array of fmi2Integer variables

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(fmu2::FMU2, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    values = zeros(fmi2Integer, nvr)

    fmi2GetInteger!(fmu2.components[end], vr, nvr, values)
    values
end

"""
Get the value of a fmi2Integer variable

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(fmu2::FMU2, vr::fmi2ValueReference)
    values = fmi2GetInteger(fmu2, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Integer variables by variable name

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(fmu2::FMU2, vr_string::Array{String})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetInteger(fmu2, vr)
    end
end
"""
Get the value of a fmi2Integer variable by variable name

For more information call ?fmi2GetInteger
"""
function fmi2GetInteger(fmu2::FMU2, vr_string::String)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetInteger(fmu2, vr)
    end
end
"""
Set the values of an array of fmi2Integer variables

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(fmu2::FMU2, vr::Array{fmi2ValueReference},value::Array{<:Integer})
    nvr = Csize_t(length(vr))
    fmi2SetInteger(fmu2.components[end], vr, nvr, Array{fmi2Integer}(value))
end
"""
Get the value of a fmi2Integer variable

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(fmu2::FMU2, vr::fmi2ValueReference, value::Integer)
    fmi2SetInteger(fmu2,[vr], [value])
end
"""
Set the values of an array of fmi2Integer variables by variable name

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(fmu2::FMU2, vr_string::Array{String}, value::Array{<:Integer})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetInteger(fmu2, vr, value)
    end
end
"""
Set the value of a fmi2Integer variable by variable name

For more information call ?fmi2SetInteger
"""
function fmi2SetInteger(fmu2::FMU2, vr_string::String, value::Integer)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetInteger(fmu2, vr, value)
    end
end
"""
Get the values of an array of fmi2Boolean variables

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(fmu2::FMU2, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    value = zeros(fmi2Boolean, nvr)
    fmi2GetBoolean!(fmu2.components[end], vr, nvr, value)
end
"""
Get the value of a fmi2Boolean variable

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(fmu2::FMU2, vr::fmi2ValueReference)
    values = fmi2GetBoolean(fmu2, [vr])
    values[1]
end
"""
Get the values of an array of fmi2Boolean variables by variable name

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(fmu2::FMU2, vr_string::Array{String})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetBoolean(fmu2, vr)
    end
end
"""
Get the value of a fmi2Boolean variable by variable name

For more information call ?fmi2GetBoolean
"""
function fmi2GetBoolean(fmu2::FMU2, vr_string::String)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetBoolean(fmu2, vr)
    end
end
"""
Set the values of an array of fmi2Boolean variables

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(fmu2::FMU2, vr::Array{fmi2ValueReference}, value::Array{Bool})
    nvr = Csize_t(length(vr))
    fmi2SetBoolean(fmu2.components[end], vr, nvr, Array{fmi2Boolean}(value))
end
"""
Set the value of a fmi2Boolean variable

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(fmu2::FMU2, vr::fmi2ValueReference, value::Bool)
    fmi2SetBoolean(fmu2, [vr], [value])
end
"""
Set the values of an array of fmi2Boolean variables by variable name

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(fmu2::FMU2, vr_string::Array{String}, value::Array{Bool})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetBoolean(fmu2, vr, value)
    end
end
"""
Set the value of a fmi2Boolean variable by variable name

For more information call ?fmi2SetBoolean
"""
function fmi2SetBoolean(fmu2::FMU2, vr_string::String, value::Bool)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetBoolean(fmu2, vr, value)
    end
end
"""
Get the values of an array of fmi2String variables

For more information call ?fmi2GetString
"""
function fmi2GetString(fmu2::FMU2, vr::Array{fmi2ValueReference})
    nvr = Csize_t(length(vr))
    value = zeros(fmi2String, nvr)
    fmi2GetString!(fmu2.components[end], vr, nvr, value)
end
"""
Get the value of a fmi2String variable

For more information call ?fmi2GetString
"""
function fmi2GetString(fmu2::FMU2, vr::fmi2ValueReference)
    values = fmi2GetString(fmu2, [vr])
    values[1]
end
"""
Get the values of an array of fmi2String variables by variable name

For more information call ?fmi2GetString
"""
function fmi2GetString(fmu2::FMU2, vr_string::Array{String})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2GetString(fmu2, vr)
    end
end
"""
Get the value of a fmi2String variable by variable name

For more information call ?fmi2GetString
"""
function fmi2GetString(fmu2::FMU2, vr_string::String)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2GetString(fmu2, vr)
    end
end
"""
Set the values of an array of fmi2String variables

For more information call ?fmi2SetString
"""
function fmi2SetString(fmu2::FMU2, vr::Array{fmi2ValueReference}, value::Array{String})
    nvr = Csize_t(length(vr))
    fmi2SetString(fmu2.components[end], vr, nvr, Array{fmi2String}(value))
end
"""
Set the values of a fmi2String variable

For more information call ?fmi2SetString
"""
function fmi2SetString(fmu2::FMU2, vr::fmi2ValueReference, value::String)
    fmi2SetString(fmu2, [vr], [value])
end
"""
Set the values of an array of fmi2String variables by variable name

For more information call ?fmi2SetString
"""
function fmi2SetString(fmu2::FMU2, vr_string::Array{String}, value::Array{String})
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if length(vr) == 0
        display("[Error]: no valueReferences could be converted")
    else
        fmi2SetString(fmu2, vr, value)
    end
end
"""
Set the value of a fmi2String variable by variable name

For more information call ?fmi2SetString
"""
function fmi2SetString(fmu2::FMU2, vr_string::String, value::String)
    vr = fmi2String2ValueReference(fmu2, vr_string)
    if vr == nothing
        display("[ERROR]: valueReference not found")
    else
        fmi2SetString(fmu2, vr, value)
    end
end
"""
Get the pointer to the current FMU state

For more information call ?fmi2GetFMUstate
"""
function fmi2GetFMUstate(fmu2::FMU2)
    state = fmi2FMUstate()
    display(state)
    fmi2GetFMUstate(fmu2.components[end], state)
    display(state)
    state
end

"""
Set the FMU state to the given fmi2FMUstate

For more information call ?fmi2SetFMUstate
"""
function fmi2SetFMUstate(fmu2::FMU2, state::fmi2FMUstate)
    fmi2SetFMUstate(fmu2.components[end], state)
end

"""
Free the allocated memory for the FMU state

For more information call ?fmi2FreeFMUstate
"""
function fmi2FreeFMUstate(fmu2::FMU2)
    fmi2FreeFMUstate(fmu2.components[end], fmu2.fmi2FMUstate)
end

"""
Returns the size of a byte vector the FMU can be stored in

For more information call ?fmi2SerzializedFMUstateSize
"""
function fmi2SerializedFMUstateSize(fmu2::FMU2, size::Int64)
    fmi2SerializedFMUstateSize(fmu2.components[end], fmu2.fmi2FMUstate, Csize_t(size))
end

"""
Serialize the data in the FMU state pointer

For more information call ?fmi2SerzializeFMUstate
"""
function fmi2SerializeFMUstate(fmu2::FMU2, serializedState::fmi2Byte, size::Int64)
    fmi2SerializeFMUstate(fmu2.components[end], fmu2.fmi2FMUstate, serializedState, Csize_t(size))
end

"""
Deserialize the data in the serializedState fmi2Byte field

For more information call ?fmi2DeSerzializeFMUstate
"""
function fmi2DeSerializeFMUstate(fmu2::FMU2, serializedState::fmi2Byte, size::Int64)
    fmi2DeSerializeFMUstate(fmu2.components[end], serializedState, Csize_t(size), fmu2.fmi2FMUstate)
end

"""
Computes directional derivatives

For more information call ?fmi2GetDirectionalDerivatives
"""
function fmi2GetDirectionalDerivative(fmu2::FMU2,
                                      vUnknown_ref::Array{fmi2ValueReference},
                                      vKnown_ref::Array{fmi2ValueReference},
                                      dvKnown::Array{fmi2Real} = Array{fmi2Real}([]))

    nKnown = Csize_t(length(vKnown_ref))
    nUnknown = Csize_t(length(vUnknown_ref))

    if length(dvKnown) < nKnown
        dvKnown = ones(fmi2Real, nKnown)
    end

    dvUnknown = zeros(fmi2Real, nUnknown)

    fmi2GetDirectionalDerivative!(fmu2.components[end], vUnknown_ref, nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown)

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

# CoSimulation specific functions
"""
Sets the n-th time derivative of real input variables.

For more information call ?fmi2SetRealInputDerivatives
"""
function fmi2SetRealInputDerivatives(fmu2::FMU2, vr::fmi2ValueReference, nvr::Cint, order::Integer, value::Real)
    fmi2SetRealInputDerivatives(fmu2.components[end], vr, nvr, fmi2Integer(order), fmi2Real(value))
end

"""
Retrieves the n-th derivative of output values.

For more information call ?fmi2GetRealOutputDerivatives
"""
function fmi2GetRealOutputDerivatives(fmu2::FMU2, vr::fmi2ValueReference, nvr::Cint, order::Integer, value::Real)
    fmi2GetRealOutputDerivatives(fmu2.components[end], vr, nvr, fmi2Integer(order), fmi2Real(value))
end

"""
The computation of a time step is started.

For more information call ?fmi2DoStep
"""
function fmi2DoStep(fmu2::FMU2, currentCommunicationPoint::Real, communicationStepSize::Real, noSetFMUStatePriorToCurrentPoint::Bool = true)
    fmi2DoStep(fmu2.components[end], fmi2Real(currentCommunicationPoint), fmi2Real(communicationStepSize), fmi2Boolean(noSetFMUStatePriorToCurrentPoint))
end

function fmi2DoStep(fmu2::FMU2, communicationStepSize::Real)
    fmi2DoStep(fmu2.components[end], fmi2Real(fmu2.t), fmi2Real(communicationStepSize), fmi2True)
    fmu2.t += communicationStepSize
end

"""
Cancels a DoStep that didn't finish correctly

For more information call ?fmi2CancelStep
"""
function fmi2CancelStep(fmu2::FMU2)
    fmi2CancelStep(fmu2.components[end])
end

"""
Informs Master of fmi2Status

For more information call ?fmi2GetStatus
"""
function fmi2GetStatus(fmu2::FMU2, s::fmi2StatusKind, value::fmi2Status)
    fmi2GetStatus(fmu2.components[end], s, value)
end

"""
Informs Master of fmi2Status of fmi2Real

For more information call ?fmi2GetRealStatus
"""
function fmi2GetRealStatus(fmu2::FMU2, s::fmi2StatusKind, value::Real)
    fmi2GetRealStatus(fmu2.components[end], s, fmi2Real(value))
end

"""
Informs Master of fmi2Status of fmi2Integer

For more information call ?fmi2GetIntegerStatus
"""
function fmi2GetIntegerStatus(fmu2::FMU2, s::fmi2StatusKind, value::Integer)
    fmi2GetIntegerStatus(fmu2.components[end], s, fmi2Integer(value))
end

"""
Informs Master of fmi2Status of fmi2Boolean

For more information call ?fmi2GetBooleanStatus
"""
function fmi2GetBooleanStatus(fmu2::FMU2, s::fmi2StatusKind, value::Bool)
    fmi2GetBooleanStatus(fmu2.components[end], s, fmiBoolean(value))
end

"""
Informs Master of fmi2Status of fmi2String

For more information call ?fmi2GetStringStatus
"""
function fmi2GetStringStatus(fmu2::FMU2, s::fmi2StatusKind, value::String)
    fmi2GetStringStatus(fmu2.components[end], s, fmiString(value))
end
# Model Exchange specific functions
"""
Set a new time instant

For more information call ?fmi2SetTime
"""
function fmi2SetTime(fmu2::FMU2, time::Real)
    fmi2SetTime(fmu2.components[end], fmi2Real(time))
end

"""
Set a new (continuous) state vector

For more information call ?fmi2SetContinuousStates
"""
function fmi2SetContinuousStates(fmu2::FMU2, x::Union{Array{Float32}, Array{Float64}})
    nx = Csize_t(length(x))
    fmi2SetContinuousStates(fmu2.components[end], Array{fmi2Real}(x), nx)
end

"""
The model enters Event Mode

For more information call ?fmi2EnterEventMode
"""
function fmi2EnterEventMode(fmu2::FMU2)
    fmi2EnterEventMode(fmu2.components[end])
end
"""
Returns the next discrete states

For more information call ?fmi2NewDiscretestates
"""
function fmi2NewDiscreteStates(fmu2::FMU2)
    eventInfo = fmi2EventInfo()
    fmi2NewDiscreteStates(fmu2.components[end], eventInfo)
    eventInfo
end

"""
The model enters Continuous-Time Mode

For more information call ?fmi2EnterContinuousTimeMode
"""
function fmi2EnterContinuousTimeMode(fmu2::FMU2)
    fmi2EnterContinuousTimeMode(fmu2.components[end])
end

"""
This function must be called by the environment after every completed step

For more information call ?fmi2CompletedIntegratorStep
"""
function fmi2CompletedIntegratorStep(fmu2::FMU2,
                                     noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    enterEventMode = fmi2Boolean(false)
    terminateSimulation = fmi2Boolean(false)
    status = fmi2CompletedIntegratorStep!(fmu2.components[end],
                                         noSetFMUStatePriorToCurrentPoint,
                                         enterEventMode,
                                         terminateSimulation)
    (status, enterEventMode, terminateSimulation)
end

"""
Compute state derivatives at the current time instant and for the current states.

For more information call ?fmi2GetDerivatives
"""
function  fmi2GetDerivatives(fmu2::FMU2)
    nx = Csize_t(fmu2.modelDescription.numberOfContinuousStates)
    derivatives = zeros(fmi2Real, nx)
    fmi2GetDerivatives(fmu2.components[end], derivatives, nx)
    derivatives
end
"""
Returns the event indicators of the FMU

For more information call ?fmi2GetEventIndicators
"""
function fmi2GetEventIndicators(fmu2::FMU2)
    ni = Csize_t(fmu2.modelDescription.numberOfEventIndicators)
    eventIndicators = zeros(fmi2Real, ni)
    fmi2GetEventIndicators(fmu2.components[end], eventIndicators, ni)
    eventIndicators
end
"""
Return the new (continuous) state vector x

For more information call ?fmi2GetContinuousStates
"""
function fmi2GetContinuousStates(fmu2::FMU2)
    nx = Csize_t(fmu2.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetContinuousStates(fmu2.components[end], x, nx)
    x
end

"""
Return the new (continuous) state vector x

For more information call ?fmi2GetNominalsOfContinuousStates
"""
function fmi2GetNominalsOfContinuousStates(fmu2::FMU2)
    nx = Csize_t(fmu2.modelDescription.numberOfContinuousStates)
    x = zeros(fmi2Real, nx)
    fmi2GetNominalsOfContinuousStates(fmu2.components[end], x, nx)
    x
end
