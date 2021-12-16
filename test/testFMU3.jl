using FMI

# xml = FMI.fmi3ReadModelDescription("model/fmi3/BouncingBall/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Dahlquist/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Feedthrough/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/LinearTransform/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Stair/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/VanDerPol/modelDescription.xml")

fmu = FMI.fmi3Load("model/fmi3/BouncingBall.fmu")
# instance1 = FMI.fmi3InstantiateModelExchange!(fmu; loggingOn=true)
instance2 = FMI.fmi3InstantiateCoSimulation!(fmu; loggingOn=true)
# fmu.components
# FMI.fmi3GetVersion(fmu)
# FMI.fmi3SetDebugLogging(fmu)
t_start = 0.0
t_stop = 3.0
dt = 0.01
saveat = t_start:dt:t_stop
success, data = FMI.fmi3SimulateCS(fmu, t_start, t_stop; recordValues=["h", "v"], saveat = saveat)
# success, data = FMI.fmi3SimulateME(fmu, 0.0, 20.0; recordValues=["h", "v"])
FMI.fmiPlot(fmu,["h", "v"], data)
# FMI.fmi3EnterInitializationMode(fmu, 0.0, 3.0)
# FMI.fmi3GetFloat64(fmu, "g")
# FMI.fmi3SetFloat64(fmu, ["g"], [0.5])
# FMI.fmi3GetFloat64(fmu, "g")
# FMI.fmi3ExitInitializationMode(fmu)
# dt = FMI.fmi3Float64(0.1)
# ts = 0.0:dt:3.0
# t = FMI.fmi3Float64(0.0)
# noSetFMUStatePriorToCurrentPoint = FMI.fmi3False
# eventEncountered = FMI.fmi3False
# terminateSimulation = FMI.fmi3False
# earlyReturn = FMI.fmi3False
# lastSuccessfulTime = FMI.fmi3Float64(0.0)
# result = []
# ccall(fmu.cDoStep, Cuint,
#           (Ptr{Nothing}, FMI.fmi3Float64, FMI.fmi3Float64, FMI.fmi3Boolean, Ptr{FMI.fmi3Boolean}, Ptr{FMI.fmi3Boolean}, Ptr{FMI.fmi3Boolean}, Ptr{FMI.fmi3Float64}),
#           fmu.components[end].compAddr, t, dt, noSetFMUStatePriorToCurrentPoint, Ref(eventEncountered), Ref(terminateSimulation), Ref(earlyReturn), Ref(lastSuccessfulTime))
# FMI.fmi3EnterStepMode(fmu.components[end])
# FMI.fmi3DoStep(fmu, 0.0, dt, false, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
# for t in ts
#     FMI.fmi3DoStep(fmu, t, dt, false, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
#     value = FMI.fmi3GetFloat64(fmu, "h")
    # println(result, value)
#     push!(result, value)
# end
# state = FMI.fmi3GetFMUState(fmu)
# FMI.fmi3SetFMUState(fmu, state)
# FMI.fmi3FreeFMUState(fmu, state)
# # test = FMI.fmi3GetNumberOfContinuousStates(fmu)
# test = FMI.fmi3GetNumberOfEventIndicators(fmu)
# FMI.fmi3GetContinuousStates(fmu)
# FMI.fmi3GetNominalsOfContinuousStates(fmu)
# FMI.fmi3EvaluateDiscreteStates(fmu)
# FMI.fmi3EnterContinuousTimeMode(fmu)
# dir_ders_buffer = zeros(FMI.fmi3Float64, 2)
# fmu.modelDescription.derivativeValueReferences
# dir_ders = FMI.fmi3GetDirectionalDerivative(fmu, fmu.modelDescription.derivativeValueReferences, [fmu.modelDescription.stateValueReferences[1]])
# FMI.fmi3GetDirectionalDerivative!(fmu, fmu.modelDescription.derivativeValueReferences, [fmu.modelDescription.stateValueReferences[1]], dir_ders_buffer)
# FMI.fmi3SerializedFMUStateSize(fmu, state)
# serialState = FMI.fmi3SerializeFMUState(fmu, state)
# FMI.fmi3DeSerializeFMUState(fmu, serialState)
# FMI.fmi3EnterConfigurationMode(fmu)
# FMI.fmi3ExitConfigurationMode(fmu)
# FMI.fmi3EnterStepMode(instance2)
# FMI.fmi3Terminate(fmu)
# FMI.fmi3Reset(fmu)
FMI.fmi3Unload(fmu)


# fmu = FMI.fmi3Load("model/fmi3/Clocks.fmu")
# instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
# instance2 = FMI.fmi3InstantiateCoSimulation!(fmu)
# FMI.fmi3EnterInitializationMode(fmu)
# FMI.fmi3GetClock(fmu, "inClock2")
# FMI.fmi3ExitInitializationMode(fmu)
# FMI.fmi3Terminate(fmu)
# FMI.fmi3Reset(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Dahlquist.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
# success, data = FMI.fmi3SimulateME(fmu, 0.0, 3.0)
# FMI.fmiPlot(fmu,["x"], data)
test1 = FMI.fmi3GetNumberOfContinuousStates(fmu)
test2 = FMI.fmi3GetNumberOfEventIndicators(fmu)
test3 = FMI.fmi3GetNumberOfContinuousStates(instance1)
test4 = FMI.fmi3GetNumberOfEventIndicators(instance1)
test1
test2
test3
test4
FMI.fmi3EnterInitializationMode(fmu, 0.0, 10.0)
x0 = FMI.fmi3GetContinuousStates(fmu)
x0_nom = FMI.fmi3GetNominalsOfContinuousStates(fmu)

# FMI.fmi3SetContinuousStates(instance1, x0)
FMI.fmi3ExitInitializationMode(fmu)
x0 = FMI.fmi3GetContinuousStates(fmu)
x0_nom = FMI.fmi3GetNominalsOfContinuousStates(fmu)
# FMI.fmi3SetContinuousStates(fmu, x0)
FMI.fmi3EnterContinuousTimeMode(fmu)
FMI.fmi3CompletedIntegratorStep(instance1, FMI.fmi3True)
FMI.fmi3SetContinuousStates(fmu, x0)
x0 = FMI.fmi3GetContinuousStates(fmu)
x0_nom = FMI.fmi3GetNominalsOfContinuousStates(fmu)
FMI.fmi3EnterEventMode(fmu, true, false, [FMI.fmi3Int32(2)], 0, false)
x0 = FMI.fmi3GetContinuousStates(fmu)
x0_nom = FMI.fmi3GetNominalsOfContinuousStates(fmu)
dx = FMI.fmi3GetContinuousStateDerivatives(fmu)

discreteStatesNeedUpdate = FMI.fmi3False
terminateSimulation = FMI.fmi3False
nominalsOfContinuousStatesChanged = FMI.fmi3False
valuesOfContinuousStatesChanged = FMI.fmi3False
nextEventTimeDefined = FMI.fmi3False
nextEventTime = FMI.fmi3Float64(0.0)

FMI.fmi3UpdateDiscreteStates(instance1, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
discreteStatesNeedUpdate
terminateSimulation
nominalsOfContinuousStatesChanged
valuesOfContinuousStatesChanged
nextEventTimeDefined
nextEventTime
FMI.fmi3SetTime(instance1, 0.1)
indicators = FMI.fmi3GetEventIndicators(instance1)
# FMI.fmi3CompletedIntegratorStep(instance1, FMI.fmi3True)
# FMI.fmi3SetContinuousStates(fmu, x0)
# instance2 = FMI.fmi3InstantiateCoSimulation!(fmu)
# instance = FMI.fmi3InstantiateCoSimulation!(fmu; loggingOn=true)
# success, data = FMI.fmi3SimulateCS(fmu, 0.0, 3.0; recordValues=["x"])
# FMI.fmiPlot(fmu,["x"], data)
# FMI.fmi3EnterInitializationMode(fmu)
# FMI.fmi3ExitInitializationMode(fmu)
# FMI.fmi3GetFMUstate(fmu)
# FMI.fmi3Terminate(fmu)
# FMI.fmi3Reset(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Feedthrough.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
instance = FMI.fmi3InstantiateCoSimulation!(fmu; loggingOn=true)
success, data = FMI.fmi3SimulateCS(fmu, 0.0, 3.0; recordValues=["real_continuous_in", "real_continuous_out"])
success, data = FMI.fmi3SimulateME(fmu, 0.0, 3.0; recordValues=["real_continuous_in", "real_continuous_out"])
FMI.fmiPlot(fmu,["real_continuous_in", "real_continuous_out"], data)
FMI.fmi3EnterInitializationMode(fmu, 0.0, 3)
FMI.fmi3GetInt32(fmu, "int_in")
FMI.fmi3SetInt32(fmu, ["int_in"], [FMI.fmi3Int32(2)])
FMI.fmi3GetInt32(fmu, ["int_in"])
FMI.fmi3GetBoolean(fmu, "bool_in")
FMI.fmi3SetBoolean(fmu, ["bool_in"], [Bool(true)])
FMI.fmi3GetBoolean(fmu, ["bool_in"])
FMI.fmi3GetString(fmu, "string_param")
FMI.fmi3SetString(fmu, ["string_param"], ["Test!"])
FMI.fmi3GetString(fmu, ["string_param"])
binary = FMI.fmi3GetBinary(fmu, "binary_in")
FMI.fmi3SetBinary(fmu, ["binary_in"], [binary])
FMI.fmi3GetBinary(fmu, ["binary_in"])
FMI.fmi3ExitInitializationMode(fmu)
FMI.fmi3GetFMUState(fmu)
FMI.fmi3Terminate(fmu)
FMI.fmi3Reset(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/LinearTransform.fmu")
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Resource.fmu")
instance = FMI.fmi3InstantiateCoSimulation!(fmu)
instance = FMI.fmi3InstantiateModelExchange!(fmu)

success, data = FMI.fmi3SimulateME(fmu, 0.0, 3.0)
FMI.fmi3EnterInitializationMode(fmu, 0.0, 3.0)
# FMI.fmi3GetFloat64(fmu, "g")
# FMI.fmi3SetFloat64(fmu, ["g"], [0.5])
# FMI.fmi3GetFloat64(fmu, "g")
FMI.fmi3ExitInitializationMode(fmu)
dt = 0.001
ts = 0.0:dt:3.0
eventEncountered = false
terminateSimulation = false
earlyReturn = false
lastSuccessfulTime = 0.0
# FMI.fmi3EnterStepMode(fmu.components[end])
FMI.fmi3DoStep(fmu, 0.0, dt, true, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
FMI.fmi3

fmu = FMI.fmi3Load("model/fmi3/Stair.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
instance2 = FMI.fmi3InstantiateCoSimulation!(fmu)
success, data = FMI.fmi3SimulateCS(fmu, 0.0, 3.0; recordValues=["counter"])
success, data = FMI.fmi3SimulateME(fmu, 0.0, 3.0; recordValues=["counter"])

FMI.fmi3GetFMUstate(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/VanDerPol.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu; loggingOn = true)
instance = FMI.fmi3InstantiateCoSimulation!(fmu; loggingOn=true)
t_start = 0.0
t_stop = 10.0
dt = 0.01
saveat = t_start:dt:t_stop
success, data = FMI.fmi3SimulateCS(fmu, 0.0, 10.0; recordValues=["x0", "x1"], saveat=saveat)
success, data = FMI.fmi3SimulateME(fmu, 0.0, 3.0; recordValues=["x0", "x1"])
FMI.fmiPlot(fmu,["x0", "x1"], data)

FMI.fmi3GetFMUState(fmu)
FMI.fmi3Unload(fmu)

