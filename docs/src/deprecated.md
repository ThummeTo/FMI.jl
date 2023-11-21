# deprecated Functions

this doc page is necessary as all exported functions must be documented in the manual with documenter configred to check for missing documentation, therefor this hidden page exists

### internal funtions: remove export?
```@docs
fmi2CallbackLogger
fmi2CallbackAllocateMemory
fmi2CallbackFreeMemory
fmi3CallbackLogger
fmi2CallbackFunctions
fmi2CallbackStepFinished
```

### deprecated
Mostly wrappers that are not supposed to be used (call specific wrapped functions instead)

```@docs
fmiSetReal
fmiReset
fmiGetGenerationTool
fmiEnterContinuousTimeMode
fmiGetEventIndicators
fmiSetBoolean
fmiFreeInstance!
fmiInstantiate!
fmiTerminate
fmiDoStep
fmiSetInteger
fmiCompletedIntegratorStep
fmiExitInitializationMode
fmiSetupExperiment
fmiSetDebugLogging
fmiSerializedFMUstateSize
fmiSerializeFMUstate
fmiDeSerializeFMUstate
fmiEnterInitializationMode
fmiGetDirectionalDerivative!
fmiNewDiscreteStates
fmiGetDirectionalDerivative
fmiSetRealInputDerivatives
fmiGetGenerationDateAndTime
fmiGetContinuousStates
fmiSetContinuousStates
fmiGetNominalsOfContinuousStates
fmiSetTime
fmiSetString
fmiGetString
fmiGetString!
fmiGetInteger
fmiGetInteger!
fmiGetReal
fmiGetReal!
fmiGetBoolean
fmiGetBoolean!
```
