#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `FMI2_comp_wraps.jl` (FMU component wrappers)?
# - wrappers to call fmi2ComponentFunctions from FMUs (FMI-functions,        last instantiated component is used) [exported]
# - wrappers to call fmi2ComponentFunctions from FMUs (additional functions, last instantiated component is used) [exported]

# FMI-spec
"""
    fmi2Simulate(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2Simulate() in FMI/FMI2_sim.jl
"""
function fmi2Simulate(fmu::FMU2, args...; kwargs...)
    return fmi2Simulate(fmu, nothing, args...; kwargs...)
end

"""
    fmi2SimulateCS(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SimulateCS() in FMI/FMI2_sim.jl
"""
function fmi2SimulateCS(fmu::FMU2, args...; kwargs...)
    return fmi2SimulateCS(fmu, nothing, args...; kwargs...)
end

"""
    fmi2SimulateME(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SimulateME() in FMI/FMI2_sim.jl
"""
function fmi2SimulateME(fmu::FMU2, args...; kwargs...)
    return fmi2SimulateME(fmu, nothing, args...; kwargs...)
end

"""
    fmi2FreeInstance!(fmu::FMU2)

Wrapper for fmi2FreeInstance!() in FMIImport/FMI2_c.jl
"""
function fmi2FreeInstance!(fmu::FMU2)
    fmi2FreeInstance!(getCurrentComponent(fmu)) # this command also removes the component from the array
end

"""
    fmi2SetDebugLogging(fmu::FMU2)

Wrapper for fmi2SetDebugLogging() in FMIImport/FMI2_int.jl
"""
function fmi2SetDebugLogging(fmu::FMU2)
    fmi2SetDebugLogging(getCurrentComponent(fmu))
end

"""
    fmi2SetupExperiment(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetupExperiment() in FMIImport/FMI2_int.jl
"""
function fmi2SetupExperiment(fmu::FMU2, args...; kwargs...) 
    fmi2SetupExperiment(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2EnterInitializationMode(fmu::FMU2)

Wrapper for fmi2EnterInitializationMode() in FMIImport/FMI2_c.jl
"""
function fmi2EnterInitializationMode(fmu::FMU2)
    fmi2EnterInitializationMode(getCurrentComponent(fmu))
end

"""
    fmi2ExitInitializationMode(fmu::FMU2)

Wrapper for fmi2ExitInitializationMode() in FMIImport/FMI2_c.jl
"""
function fmi2ExitInitializationMode(fmu::FMU2)
    fmi2ExitInitializationMode(getCurrentComponent(fmu))
end

"""
    fmi2Terminate(fmu::FMU2)

Wrapper for fmi2Terminate() in FMIImport/FMI2_c.jl
"""
function fmi2Terminate(fmu::FMU2)
    fmi2Terminate(getCurrentComponent(fmu))
end

"""
    fmi2Reset(fmu::FMU2)

Wrapper for fmi2Reset() in FMIImport/FMI2_c.jl
"""
function fmi2Reset(fmu::FMU2)
    fmi2Reset(getCurrentComponent(fmu))
end

"""
    fmi2GetReal(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetReal() in FMIImport/FMI2_int.jl
"""
function fmi2GetReal(fmu::FMU2, args...; kwargs...)
    fmi2GetReal(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetReal!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetReal!() in FMIImport/FMI2_int.jl
"""
function fmi2GetReal!(fmu::FMU2, args...; kwargs...)
    fmi2GetReal!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmiGet(fmu::FMU2, args...; kwargs...)

Wrapper for fmiGet() in FMIImport/FMI2_ext.jl
"""
function fmi2Get(fmu::FMU2, args...; kwargs...)
    fmi2Get(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmiGet!(fmu::FMU2, args...; kwargs...)

Wrapper for fmiGet!() in FMIImport/FMI2_ext.jl
"""
function fmi2Get!(fmu::FMU2, args...; kwargs...)
    fmi2Get!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmiSet(fmu::FMU2, args...; kwargs...)

Wrapper for fmiSet() in FMIImport/FMI2_ext.jl
"""
function fmi2Set(fmu::FMU2, args...; kwargs...)
    fmi2Set(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetRealOutputDerivatives(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetRealOutputDerivatives() in FMIImport/FMI2_int.jl
"""
function fmi2GetRealOutputDerivatives(fmu::FMU2, args...; kwargs...)
    fmi2GetRealOutputDerivatives(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetReal(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetReal() in FMIImport/FMI2_int.jl
"""
function fmi2SetReal(fmu::FMU2, args...; kwargs...)
    fmi2SetReal(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetRealInputDerivatives(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetRealInputDerivatives() in FMIImport/FMI2_int.jl
"""
function fmi2SetRealInputDerivatives(fmu::FMU2, args...; kwargs...)
    fmi2SetRealInputDerivatives(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetInteger(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetInteger() in FMIImport/FMI2_int.jl
"""
function fmi2GetInteger(fmu::FMU2, args...; kwargs...)
    fmi2GetInteger(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetInteger!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetInteger!() in FMIImport/FMI2_int.jl
"""
function fmi2GetInteger!(fmu::FMU2, args...; kwargs...)
    
    fmi2GetInteger!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetInteger(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetInteger() in FMIImport/FMI2_int.jl
"""
function fmi2SetInteger(fmu::FMU2, args...; kwargs...)
    
    fmi2SetInteger(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetBoolean(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetBoolean() in FMIImport/FMI2_int.jl
"""
function fmi2GetBoolean(fmu::FMU2, args...; kwargs...)
    
    fmi2GetBoolean(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetBoolean!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetBoolean!() in FMIImport/FMI2_int.jl
"""
function fmi2GetBoolean!(fmu::FMU2, args...; kwargs...)
    
    fmi2GetBoolean!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetBoolean(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetBoolean() in FMIImport/FMI2_int.jl
"""
function fmi2SetBoolean(fmu::FMU2, args...; kwargs...)
    
    fmi2SetBoolean(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetString(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetString() in FMIImport/FMI2_int.jl
"""
function fmi2GetString(fmu::FMU2, args...; kwargs...)
    
    fmi2GetString(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetString!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetString!() in FMIImport/FMI2_int.jl
"""
function fmi2GetString!(fmu::FMU2, args...; kwargs...)
    
    fmi2GetString!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetString(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetString() in FMIImport/FMI2_int.jl
"""
function fmi2SetString(fmu::FMU2, args...; kwargs...)
    
    fmi2SetString(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetFMUstate(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetFMUstate() in FMIImport/FMI2_int.jl
"""
function fmi2GetFMUstate(fmu::FMU2, args...; kwargs...)
    
    fmi2GetFMUstate(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetFMUstate(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetFMUstate() in FMIImport/FMI2_c.jl
"""
function fmi2SetFMUstate(fmu::FMU2, args...; kwargs...)
    
    fmi2SetFMUstate(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2FreeFMUstate!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2FreeFMUstate!() in FMIImport/FMI2_int.jl
"""
function fmi2FreeFMUstate!(fmu::FMU2, args...; kwargs...)
    
    fmi2FreeFMUstate!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SerializedFMUstateSize(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SerializedFMUstateSize() in FMIImport/FMI2_int.jl
"""
function fmi2SerializedFMUstateSize(fmu::FMU2, args...; kwargs...)
    
    fmi2SerializedFMUstateSize(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SerializeFMUstate(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SerializeFMUstate() in FMIImport/FMI2_int.jl
"""
function fmi2SerializeFMUstate(fmu::FMU2, args...; kwargs...)
    
    fmi2SerializeFMUstate(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2DeSerializeFMUstate(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2DeSerializeFMUstate() in FMIImport/FMI2_int.jl
"""
function fmi2DeSerializeFMUstate(fmu::FMU2, args...; kwargs...)
    
    fmi2DeSerializeFMUstate(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetDirectionalDerivative!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetDirectionalDerivative!() in FMIImport/FMI2_int.jl
"""
function fmi2GetDirectionalDerivative!(fmu::FMU2, args...; kwargs...)
    
    fmi2GetDirectionalDerivative!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetDirectionalDerivative(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetDirectionalDerivative() in FMIImport/FMI2_int.jl
"""
function fmi2GetDirectionalDerivative(fmu::FMU2, args...; kwargs...)
    
    fmi2GetDirectionalDerivative(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SampleDirectionalDerivative!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SampleDirectionalDerivative!() in FMIImport/FMI2_ext.jl
"""
function fmi2SampleDirectionalDerivative!(fmu::FMU2, args...; kwargs...)
    
    fmi2SampleDirectionalDerivative!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SampleDirectionalDerivative(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SampleDirectionalDerivative() in FMIImport/FMI2_ext.jl
"""
function fmi2SampleDirectionalDerivative(fmu::FMU2, args...; kwargs...)
    
    fmi2SampleDirectionalDerivative(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetJacobian!(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetJacobian!() in FMIImport/FMI2_ext.jl
"""
function fmi2GetJacobian!(fmu::FMU2, args...; kwargs...)
    
    fmi2GetJacobian!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetJacobian(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetJacobian() in FMIImport/FMI2_ext.jl
"""
function fmi2GetJacobian(fmu::FMU2, args...; kwargs...)
    
    fmi2GetJacobian(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2DoStep(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2DoStep() in FMIImport/FMI2_c.jl
"""
function fmi2DoStep(fmu::FMU2, args...; kwargs...)
    
    fmi2DoStep(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2CancelStep(fmu::FMU2)

Wrapper for fmi2CancelStep() in FMIImport/FMI2_c.jl
"""
function fmi2CancelStep(fmu::FMU2)
    
    fmi2CancelStep(getCurrentComponent(fmu))
end

"""
    fmi2GetStatus(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetStatus!() in FMIImport/FMI2_c.jl
"""
function fmi2GetStatus(fmu::FMU2, args...; kwargs...)
    
    fmi2GetStatus!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetRealStatus(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetRealStatus!() in FMIImport/FMI2_c.jl
"""
function fmi2GetRealStatus(fmu::FMU2, args...; kwargs...)
    
    fmi2GetRealStatus!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetIntegerStatus(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetIntegerStatus!() in FMIImport/FMI2_c.jl
"""
function fmi2GetIntegerStatus(fmu::FMU2, args...; kwargs...)
    
    fmi2GetIntegerStatus!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetBooleanStatus(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetBooleanStatus!() in FMIImport/FMI2_c.jl
"""
function fmi2GetBooleanStatus(fmu::FMU2, args...; kwargs...)
    
    fmi2GetBooleanStatus!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetStringStatus(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2GetStringStatus!() in FMIImport/FMI2_c.jl
"""
function fmi2GetStringStatus(fmu::FMU2, args...; kwargs...)
    
    fmi2GetStringStatus!(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetTime(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetTime() in FMIImport/FMI2_c.jl
"""
function fmi2SetTime(fmu::FMU2, args...; kwargs...)
    
    fmi2SetTime(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2SetContinuousStates(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2SetContinuousStates() in FMIImport/FMI2_c.jl
"""
function fmi2SetContinuousStates(fmu::FMU2, args...; kwargs...)
    
    fmi2SetContinuousStates(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2EnterEventMode(fmu::FMU2)

Wrapper for fmi2EnterEventMode() in FMIImport/FMI2_c.jl
"""
function fmi2EnterEventMode(fmu::FMU2)
    
    fmi2EnterEventMode(getCurrentComponent(fmu))
end

"""
    fmi2NewDiscreteStates(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2NewDiscreteStates() in FMIImport/FMI2_c.jl
"""
function fmi2NewDiscreteStates(fmu::FMU2, args...; kwargs...)
    
    fmi2NewDiscreteStates(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2EnterContinuousTimeMode(fmu::FMU2)

Wrapper for fmi2EnterContinuousTimeMode() in FMIImport/FMI2_c.jl
"""
function fmi2EnterContinuousTimeMode(fmu::FMU2)
    
    fmi2EnterContinuousTimeMode(getCurrentComponent(fmu))
end

"""
    fmi2CompletedIntegratorStep(fmu::FMU2, args...; kwargs...)

Wrapper for fmi2CompletedIntegratorStep() in FMIImport/FMI2_c.jl
"""
function fmi2CompletedIntegratorStep(fmu::FMU2, args...; kwargs...)
    
    fmi2CompletedIntegratorStep(getCurrentComponent(fmu), args...; kwargs...)
end

"""
    fmi2GetDerivatives(fmu::FMU2)

Wrapper for fmi2GetDerivatives() in FMIImport/FMI2_c.jl
"""
function fmi2GetDerivatives(fmu::FMU2)
    
    fmi2GetDerivatives(getCurrentComponent(fmu))
end

"""
    fmi2GetEventIndicators(fmu::FMU2)

Wrapper for fmi2GetEventIndicators() in FMIImport/FMI2_c.jl
"""
function fmi2GetEventIndicators(fmu::FMU2)
    
    fmi2GetEventIndicators(getCurrentComponent(fmu))
end

"""
    fmi2GetContinuousStates(fmu::FMU2)fmi2ins

Wrapper for fmi2GetContinuousStates() in FMIImport/FMI2_c.jl
"""
function fmi2GetContinuousStates(fmu::FMU2)
    
    fmi2GetContinuousStates(getCurrentComponent(fmu))
end

"""
    fmi2GetNominalsOfContinuousStates(fmu::FMU2)

Wrapper for fmi2GetNominalsOfContinuousStates() in FMIImport/FMI2_c.jl
"""
function fmi2GetNominalsOfContinuousStates(fmu::FMU2)
    
    fmi2GetNominalsOfContinuousStates(getCurrentComponent(fmu))
end

# additionals
"""
    fmi2GetStartValue(fmu::FMU2, args...; kwargs...)
    
Wrapper for fmi2GetStartValue() in FMIImport/FMI2_c.jl
"""
function fmi2GetStartValue(fmu::FMU2, args...; kwargs...)
    
    fmi2GetStartValue(getCurrentComponent(fmu), args...; kwargs...)
end