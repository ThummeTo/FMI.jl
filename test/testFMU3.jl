using FMI

xml = FMI.fmi3ReadModelDescription("model/fmi3/BouncingBall/modelDescription.xml")
xml = FMI.fmi3ReadModelDescription("model/fmi3/Dahlquist/modelDescription.xml")
xml = FMI.fmi3ReadModelDescription("model/fmi3/Feedthrough/modelDescription.xml")
xml = FMI.fmi3ReadModelDescription("model/fmi3/LinearTransform/modelDescription.xml")
xml = FMI.fmi3ReadModelDescription("model/fmi3/Stair/modelDescription.xml")
xml = FMI.fmi3ReadModelDescription("model/fmi3/VanDerPol/modelDescription.xml")