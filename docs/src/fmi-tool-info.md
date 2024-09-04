# FMU Import Compatibility information (*FMIImport.jl*) 
This section contains information about how import and simulation of *FMI.jl* and *FMIInmport.jl* where tested.

## FMI-3.0
FMI3 is for now only beta supported and information will be deployed together with the full support release.

## FMI-2.0
*FMI.jl* and *FMIImport.jl* are validated by simulating **all valid** FMI2-FMUs from the official [FMI-Cross-Check](https://github.com/modelica/fmi-cross-check) in ME- as well as in CS-Mode, excluding the tools *AMESim*, *Test-FMUs*, *SimulationX* and *Silver*.
For more information see [our automated GitHub-Action](https://github.com/ThummeTo/FMI.jl/tree/main/cross_checks). The results files - as defined by the FMI Cross Check - can be found in [the forked repository](https://github.com/ThummeTo/fmi-cross-check/tree/master) inside of the corresponding sub folders. 
There are different branches for different OS-configurations available.

# FMU Export Compatibility information (*FMIExport.jl*) 
Detailed export information and automatically generated FMUs will be deployed soon in the repository.

## FMI-3.0
| **File name** | **x86_64-windows** |  **x86_64-linux** | 
| :--- | --- | --- |
| BouncingBall | coming soon | coming soon |
| Manipulation | coming soon | coming soon |
| NeuralFMU | coming soon | coming soon |

## FMI-2.0
| **File name** | **x86_64-windows** |  **x86_64-linux** | 
| :--- | --- | --- |
| BouncingBall | [ME](https://github.com/ThummeTo/FMIExport.jl/tree/main/examples/FMI2/BouncingBall) | coming soon |
| Manipulation | [ME](https://github.com/ThummeTo/FMIExport.jl/tree/main/examples/FMI2/Manipulation) | coming soon |
| NeuralFMU | [ME](https://github.com/ThummeTo/FMIExport.jl/tree/main/examples/FMI2/NeuralFMU) | coming soon |

## Validation tools
- [Dassault Dymola 2022X](https://www.3ds.com/products/catia/dymola)
- [FMU Check](https://fmu-check.herokuapp.com/)