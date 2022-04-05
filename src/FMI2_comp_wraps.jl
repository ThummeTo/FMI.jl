#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI2_comp_wraps.jl` (FMU component wrappers)?
# - wrappers to call fmi2ComponentFunctions from FMUs (FMI-functions,        last instantiated component is used) [exported]
# - wrappers to call fmi2ComponentFunctions from FMUs (additional functions, last instantiated component is used) [exported]

# FMI-spec

function fmi2Simulate(fmu::FMU2, args...; instantiate::Bool=false, kwargs...)

    if instantiate
        c = fmi2Instantiate!(fmu)
        ret = fmi2Simulate(c, args...; kwargs...)
        fmi2FreeInstance!(c)
        return ret
    else 
        @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate? Use keyword `instantiate=true` to allocate an instance automatically."]
        c = fmu.components[end]
        return fmi2Simulate(c, args...; kwargs...)
    end
end

function fmi2SimulateCS(fmu::FMU2, args...; instantiate::Bool=false, kwargs...)
  
    if instantiate
        c = fmi2Instantiate!(fmu)
        ret = fmi2SimulateCS(c, args...; kwargs...)
        fmi2FreeInstance!(c)
        return ret
    else 
        @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate? Use keyword `instantiate=true` to allocate an instance automatically."]
        c = fmu.components[end]
        return fmi2SimulateCS(c, args...; kwargs...)
    end
end

function fmi2SimulateME(fmu::FMU2, args...; instantiate::Bool=false, kwargs...)

    if instantiate
        c = fmi2Instantiate!(fmu)
        ret = fmi2SimulateME(c, args...; kwargs...)
        fmi2FreeInstance!(c)
        return ret
    else 
        @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate? Use keyword `instantiate=true` to allocate an instance automatically."]
        c = fmu.components[end]
        return fmi2SimulateME(c, args...; kwargs...)
    end
end

function fmi2FreeInstance!(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2FreeInstance!(fmu.components[end]) # this command also removes the component from the array
end

function fmi2SetDebugLogging(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetDebugLogging(fmu.components[end])
end

function fmi2SetupExperiment(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetupExperiment(fmu.components[end], args...; kwargs...)
end

function fmi2EnterInitializationMode(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2EnterInitializationMode(fmu.components[end])
end

function fmi2ExitInitializationMode(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2ExitInitializationMode(fmu.components[end])
end

function fmi2Terminate(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2Terminate(fmu.components[end])
end

function fmi2Reset(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2Reset(fmu.components[end])
end

function fmi2GetReal(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetReal(fmu.components[end], args...; kwargs...)
end

function fmi2GetReal!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetReal!(fmu.components[end], args...; kwargs...)
end

function fmiGet(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2Get(fmu.components[end], args...; kwargs...)
end

function fmiGet!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2Get!(fmu.components[end], args...; kwargs...)
end

function fmiSet(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2Set(fmu.components[end], args...; kwargs...)
end

function fmi2GetRealOutputDerivatives(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetRealOutputDerivatives(fmu.components[end], args...; kwargs...)
end

function fmi2SetReal(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetReal(fmu.components[end], args...; kwargs...)
end

function fmi2SetRealInputDerivatives(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetRealInputDerivatives(fmu.components[end], args...; kwargs...)
end

function fmi2GetInteger(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetInteger(fmu.components[end], args...; kwargs...)
end

function fmi2GetInteger!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetInteger!(fmu.components[end], args...; kwargs...)
end

function fmi2SetInteger(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetInteger(fmu.components[end], args...; kwargs...)
end

function fmi2GetBoolean(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetBoolean(fmu.components[end], args...; kwargs...)
end

function fmi2GetBoolean!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetBoolean!(fmu.components[end], args...; kwargs...)
end

function fmi2SetBoolean(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetBoolean(fmu.components[end], args...; kwargs...)
end

function fmi2GetString(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetString(fmu.components[end], args...; kwargs...)
end

function fmi2GetString!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetString!(fmu.components[end], args...; kwargs...)
end

function fmi2SetString(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetString(fmu.components[end], args...; kwargs...)
end

function fmi2GetFMUstate(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetFMUstate(fmu.components[end], args...; kwargs...)
end

function fmi2SetFMUstate(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetFMUstate(fmu.components[end], args...; kwargs...)
end

function fmi2FreeFMUstate!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2FreeFMUstate!(fmu.components[end], args...; kwargs...)
end

function fmi2SerializedFMUstateSize(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SerializedFMUstateSize(fmu.components[end], args...; kwargs...)
end

function fmi2SerializeFMUstate(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SerializeFMUstate(fmu.components[end], args...; kwargs...)
end

function fmi2DeSerializeFMUstate(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2DeSerializeFMUstate(fmu.components[end], args...; kwargs...)
end

function fmi2GetDirectionalDerivative!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetDirectionalDerivative!(fmu.components[end], args...; kwargs...)
end

function fmi2GetDirectionalDerivative(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetDirectionalDerivative(fmu.components[end], args...; kwargs...)
end

function fmi2SampleDirectionalDerivative!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SampleDirectionalDerivative!(fmu.components[end], args...; kwargs...)
end

function fmi2SampleDirectionalDerivative(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SampleDirectionalDerivative(fmu.components[end], args...; kwargs...)
end

function fmi2GetJacobian!(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetJacobian!(fmu.components[end], args...; kwargs...)
end

function fmi2GetJacobian(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetJacobian(fmu.components[end], args...; kwargs...)
end

function fmi2DoStep(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2DoStep(fmu.components[end], args...; kwargs...)
end

function fmi2CancelStep(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2CancelStep(fmu.components[end])
end

function fmi2GetStatus(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetStatus(fmu.components[end], args...; kwargs...)
end

function fmi2GetRealStatus(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetRealStatus(fmu.components[end], args...; kwargs...)
end

function fmi2GetIntegerStatus(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetIntegerStatus(fmu.components[end], args...; kwargs...)
end

function fmi2GetBooleanStatus(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetBooleanStatus(fmu.components[end], args...; kwargs...)
end

function fmi2GetStringStatus(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetStringStatus(fmu.components[end], args...; kwargs...)
end

function fmi2SetTime(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetTime(fmu.components[end], args...; kwargs...)
end

function fmi2SetContinuousStates(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2SetContinuousStates(fmu.components[end], args...; kwargs...)
end

function fmi2EnterEventMode(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2EnterEventMode(fmu.components[end])
end

function fmi2NewDiscreteStates(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2NewDiscreteStates(fmu.components[end], args...; kwargs...)
end

function fmi2EnterContinuousTimeMode(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2EnterContinuousTimeMode(fmu.components[end])
end

function fmi2CompletedIntegratorStep(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2CompletedIntegratorStep(fmu.components[end], args...; kwargs...)
end

function  fmi2GetDerivatives(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetDerivatives(fmu.components[end])
end

function fmi2GetEventIndicators(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetEventIndicators(fmu.components[end])
end

function fmi2GetContinuousStates(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetContinuousStates(fmu.components[end])
end

function fmi2GetNominalsOfContinuousStates(fmu::FMU2)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetNominalsOfContinuousStates(fmu.components[end])
end

# additionals

function fmi2GetStartValue(fmu::FMU2, args...; kwargs...)
    @assert length(fmu.components) > 0 ["No FMU instance allocated, have you already called fmiInstantiate?"]
    fmi2GetStartValue(fmu.components[end], args...; kwargs...)
end