using FMI, FMIZoo, FMIImport

myFMU = fmiLoad("Feedthrough", "ModelicaReferenceFMUs", "0.0.20", "2.0")
fmi2Instantiate!(myFMU)
solution = fmiSimulate(myFMU, (0.0, 1.0))
fmiUnload(myFMU)

fmi2GetVersion(myFMU)