using FMI

# xml = FMI.fmi3ReadModelDescription("model/fmi3/BouncingBall/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Dahlquist/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Feedthrough/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/LinearTransform/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/Stair/modelDescription.xml")
# xml = FMI.fmi3ReadModelDescription("model/fmi3/VanDerPol/modelDescription.xml")

fmu = FMI.fmi3Load("model/fmi3/BouncingBall.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
instance2 = FMI.fmi3InstantiateCoSimulation!(fmu)
fmu.components
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Dahlquist.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Feedthrough.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
FMI.fmi3Unload(fmu)

# fmu = FMI.fmi3Load("model/fmi3/LinearTransform.fmu")
# FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/Stair.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
FMI.fmi3Unload(fmu)

fmu = FMI.fmi3Load("model/fmi3/VanDerPol.fmu")
instance1 = FMI.fmi3InstantiateModelExchange!(fmu)
FMI.fmi3Unload(fmu)