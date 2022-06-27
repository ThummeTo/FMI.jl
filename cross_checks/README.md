# FMI Cross-Checks

---

:construction: **This feature is currently work in process**

---

This folder contains everything related to the FMI Cross-Check process for https://fmi-standard.org/tools/ 

More information: https://github.com/modelica/fmi-cross-check

## Instruction

To run the cross-checks, excecute `cross_checks.jl`

## Latest results
```

ME:
        List of successfull Cross checks
                1:      me - win64 - CATIA - R2015x - ControlledTemperature.fmu
                2:      me - win64 - CATIA - R2015x - Rectifier.fmu
                3:      me - win64 - CATIA - R2016x - ControlledTemperature.fmu
                4:      me - win64 - CATIA - R2016x - MixtureGases.fmu
                5:      me - win64 - CATIA - R2016x - Rectifier.fmu
                6:      me - win64 - Dymola - 2015FD01 - ControlledTemperature.fmu
                7:      me - win64 - Dymola - 2015FD01 - Rectifier.fmu
                8:      me - win64 - Dymola - 2016 - ControlledTemperature.fmu
                9:      me - win64 - Dymola - 2016 - Rectifier.fmu
                10:     me - win64 - Dymola - 2016FD01 - ControlledTemperature.fmu
                11:     me - win64 - Dymola - 2016FD01 - Rectifier.fmu
                12:     me - win64 - Dymola - 2017 - ControlledTemperature.fmu
                13:     me - win64 - Dymola - 2017 - MixtureGases.fmu
                14:     me - win64 - Dymola - 2017 - Rectifier.fmu
                15:     me - win64 - Dymola - 2019FD01 - ControlledTemperature.fmu
                16:     me - win64 - Dymola - 2019FD01 - Engine1b.fmu
                17:     me - win64 - Dymola - 2019FD01 - MixtureGases.fmu
                18:     me - win64 - Dymola - 2019FD01 - Rectifier.fmu
                19:     me - win64 - Dymola - 2019FD01 - fullRobot.fmu
                20:     me - win64 - FMIToolbox_MATLAB - 2.3 - Continuous.fmu
                21:     me - win64 - FMUSDK - 2.0.3 - bouncingBall.fmu
                22:     me - win64 - FMUSDK - 2.0.3 - dq.fmu
                23:     me - win64 - FMUSDK - 2.0.3 - vanDerPol.fmu
                24:     me - win64 - FMUSDK - 2.0.4 - bouncingBall.fmu
                25:     me - win64 - FMUSDK - 2.0.4 - dq.fmu
                26:     me - win64 - FMUSDK - 2.0.4 - vanDerPol.fmu
                27:     me - win64 - MWorks - 2021 - BouncingBall.fmu
                28:     me - win64 - MWorks - 2021 - ControlledTemperature.fmu
                29:     me - win64 - MWorks - 2021 - MixtureGases.fmu
                30:     me - win64 - MWorks - 2021 - Rectifier.fmu
                31:     me - win64 - MWorks - 2021 - fullRobot.fmu
                32:     me - win64 - MapleSim - 2016.2 - ControlledTemperature.fmu
                33:     me - win64 - MapleSim - 2018 - ControlledTemperature.fmu
                34:     me - win64 - MapleSim - 2018 - Rectifier.fmu
                35:     me - win64 - MapleSim - 2019 - ControlledTemperature.fmu
                36:     me - win64 - MapleSim - 2019 - Rectifier.fmu
                37:     me - win64 - MapleSim - 2021.1 - ControlledTemperature.fmu
                38:     me - win64 - MapleSim - 2021.1 - Rectifier.fmu
                39:     me - win64 - MapleSim - 2021.2 - ControlledTemperature.fmu
                40:     me - win64 - MapleSim - 2021.2 - Rectifier.fmu
                41:     me - win64 - solidThinking_Activate - 2020 - Arenstorf.fmu
                42:     me - win64 - solidThinking_Activate - 2020 - Boocwen.fmu
                43:     me - win64 - solidThinking_Activate - 2020 - CVloop.fmu
                44:     me - win64 - solidThinking_Activate - 2020 - Pendulum.fmu
        List of failed Cross checks
                1:      me - win64 - CATIA - R2016x - DFFREG.fmu: BoundsError(Float64[], (1,))
                2:      me - win64 - DS_FMU_Export_from_Simulink - 2.1 - TriggeredSubsystems_sf.fmu: BoundsError(Float64[], (1,))
                3:      me - win64 - DS_FMU_Export_from_Simulink - 2.1.1 - TriggeredSubsystems_sf.fmu: BoundsError(Float64[], (1,))
                4:      me - win64 - DS_FMU_Export_from_Simulink - 2.1.2 - TriggeredSubsystems_sf.fmu: BoundsError(Float64[], (1,))
                5:      me - win64 - DS_FMU_Export_from_Simulink - 2.2.0 - TriggeredSubsystems_sf.fmu: BoundsError(Float64[], (1,))
                6:      me - win64 - DS_FMU_Export_from_Simulink - 2.3.0 - TriggeredSubsystems_sf.fmu: BoundsError(Float64[], (1,))
                7:      me - win64 - Dymola - 2016 - DFFREG.fmu: BoundsError(Float64[], (1,))
                8:      me - win64 - Dymola - 2016FD01 - DFFREG.fmu: BoundsError(Float64[], (1,))
                9:      me - win64 - Dymola - 2017 - DFFREG.fmu: BoundsError(Float64[], (1,))
                10:     me - win64 - Dymola - 2019FD01 - DFFREG.fmu: BoundsError(Float64[], (1,))
                11:     me - win64 - FMIToolbox_MATLAB - 2.3 - Discontinuities.fmu: BoundsError(Float64[], (1,))
                12:     me - win64 - FMIToolbox_MATLAB - 2.3 - EmbeddedCode.fmu: BoundsError(Float64[], (1,))
                13:     me - win64 - FMUSDK - 2.0.3 - inc.fmu: BoundsError(Float64[], (1,))
                14:     me - win64 - FMUSDK - 2.0.4 - inc.fmu: BoundsError(Float64[], (1,))
                15:     me - win64 - MWorks - 2021 - DFFREG.fmu: BoundsError(Float64[], (1,))
                16:     me - win64 - Test-FMUs - 0.0.1 - Dahlquist.fmu: MethodError(FMI.var"#fmi2SimulateCS##kw"(), ((reltol = 1.0e-5, recordValues = ["x"]), FMI.fmi2SimulateCS, Model name:        Dahlquist
Type:              1, nothing, 0.0, 10.0), 0xffffffffffffffff)
                17:     me - win64 - Test-FMUs - 0.0.1 - Feedthrough.fmu: AssertionError("fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                18:     me - win64 - Test-FMUs - 0.0.1 - Stair.fmu: MethodError(FMI.var"#fmi2SimulateCS##kw"(), ((reltol = 1.0e-5, recordValues = ["counter"]), FMI.fmi2SimulateCS, Model name:        Stair
Type:              1, nothing, 0.0, 10.0), 0xffffffffffffffff)
                19:     me - win64 - Test-FMUs - 0.0.1 - VanDerPol.fmu: AssertionError("fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                20:     me - win64 - Test-FMUs - 0.0.2 - Dahlquist.fmu: MethodError(FMI.var"#fmi2SimulateCS##kw"(), ((reltol = 1.0e-5, recordValues = ["x"]), FMI.fmi2SimulateCS, Model name:        Dahlquist
Type:              1, nothing, 0.0, 10.0), 0xffffffffffffffff)
                21:     me - win64 - Test-FMUs - 0.0.2 - Feedthrough.fmu: AssertionError("fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                22:     me - win64 - Test-FMUs - 0.0.2 - Stair.fmu: MethodError(FMI.var"#fmi2SimulateCS##kw"(), ((reltol = 1.0e-5, recordValues = ["counter"]), FMI.fmi2SimulateCS, Model name:        Stair
Type:              1, nothing, 0.0, 10.0), 0xffffffffffffffff)
                23:     me - win64 - Test-FMUs - 0.0.2 - VanDerPol.fmu: AssertionError("fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                24:     me - win64 - solidThinking_Activate - 2020 - ActivateRC.fmu: ArgumentError("input string is empty or only contains whitespace")
                25:     me - win64 - solidThinking_Activate - 2020 - DiscreteController.fmu: ArgumentError("input string is empty or only contains whitespace")


CS:

        List of successfull Cross checks
                1:      FmuCrossCheck("2.0", "cs", "win64", "20sim", "4.6.4.8004", "TorsionBar", false, 3.160808872239127e-15, true, false, nothing)
                2:      FmuCrossCheck("2.0", "cs", "win64", "ASim", "2019FD01", "Counter", false, 0.5802298395176403, true, false, nothing)
                3:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2015x", "ControlledTemperature", true, 0.07570808166416204, true, false, nothing)
                4:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2015x", "DFFREG", false, 0.06039512945437038, true, false, nothing)
                5:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2015x", "Rectifier", true, 0.003927098453968272, true, false, nothing)
                6:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2016x", "ControlledTemperature", true, 0.07570808166416204, true, false, nothing)
                7:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2016x", "DFFREG", true, 0.06039512945437038, true, false, nothing)
                8:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2016x", "MixtureGases", true, 2.6618299956209707e-5, true, false, nothing)
                9:      FmuCrossCheck("2.0", "cs", "win64", "CATIA", "R2016x", "Rectifier", true, 0.003927052339344745, true, false, nothing)
                10:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1", "BouncingBalls_sf", false, 6.875495670247979e-6, true, false, nothing)
                11:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1", "TestModel1_sf", false, 3.248538332959761e-6, true, false, nothing)
                12:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1", "TriggeredSubsystems_sf", true, 0.013704190076450821, true, false, nothing)
                13:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.1", "BouncingBalls_sf", false, 6.875495670247979e-6, true, false, nothing)
                14:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.1", "TestModel1_sf", false, 3.248538333224738e-6, true, false, nothing)
                15:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.1", "TriggeredSubsystems_sf", true, 1.4220143699110263e-6, true, false, nothing)
                16:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.2", "BouncingBalls_sf", false, 6.875495670247979e-6, true, false, nothing)
                17:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.2", "TestModel1_sf", false, 3.248538333224738e-6, true, false, nothing)
                18:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.1.2", "TriggeredSubsystems_sf", true, 1.4220143699110263e-6, true, false, nothing)
                19:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.2.0", "BouncingBalls_sf", false, 6.875495670247979e-6, true, false, nothing)
                20:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.2.0", "TestModel1_sf", false, 3.248538333224738e-6, true, false, nothing)
                21:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.2.0", "TriggeredSubsystems_sf", true, 1.4220143699110263e-6, true, false, nothing)
                22:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.3.0", "BouncingBalls_sf", false, 6.875495670247979e-6, true, false, nothing)
                23:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.3.0", "TestModel1_sf", false, 3.248538333224738e-6, true, false, nothing)
                24:     FmuCrossCheck("2.0", "cs", "win64", "DS_FMU_Export_from_Simulink", "2.3.0", "TriggeredSubsystems_sf", true, 1.4220143699110263e-6, true, false, nothing)
                25:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2015FD01", "ControlledTemperature", true, 0.07570809961800998, true, false, nothing)
                26:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2015FD01", "DFFREG", false, 0.06039512945437038, true, false, nothing)
                27:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2015FD01", "Rectifier", true, 0.004074207621172055, true, false, nothing)
                28:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016", "ControlledTemperature", true, 0.07570809961800998, true, false, nothing)
                29:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016", "DFFREG", true, 0.06039512945437038, true, false, nothing)
                30:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016", "Rectifier", true, 0.004457224555206615, true, false, nothing)
                31:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016FD01", "ControlledTemperature", true, 0.07570809961800998, true, false, nothing)
                32:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016FD01", "DFFREG", true, 0.06039512945437038, true, false, nothing)
                33:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2016FD01", "Rectifier", true, 0.0035775314787378325, true, false, nothing)
                34:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2017", "ControlledTemperature", true, 0.07570809961800998, true, false, nothing)
                35:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2017", "DFFREG", true, 0.06039512945437038, true, false, nothing)
                36:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2017", "MixtureGases", true, 2.654370172786322e-5, true, false, nothing)
                37:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2017", "Rectifier", true, 0.004105003192467737, true, false, nothing)
                38:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "ControlledTemperature", true, 0.02453530689071217, true, false, nothing)
                39:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "DFFREG", true, 0.22190587516881363, true, false, nothing)
                40:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "Engine1b", true, 0.04180967193218527, true, false, nothing)
                41:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "MixtureGases", true, 2.654370172786322e-5, true, false, nothing)
                42:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "Rectifier", true, 0.0029981062039611092, true, false, nothing)
                43:     FmuCrossCheck("2.0", "cs", "win64", "Dymola", "2019FD01", "fullRobot", true, 3.8244589178049036e-6, true, false, nothing)
                44:     FmuCrossCheck("2.0", "cs", "win64", "Easy5", "2017.1", "VanDerPol", false, 0.004787782342006612, true, false, nothing)
                45:     FmuCrossCheck("2.0", "cs", "win64", "EcosimPro", "6.0.2", "aircraftgear", false, 5.276317615969063e-7, true, false, nothing)
                46:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.1", "Continuous", true, 0.0012894349434615755, true, false, nothing)
                47:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.1", "Discontinuities", true, 0.23649549959858368, true, false, nothing)
                48:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.1", "EmbeddedCode", true, 0.0012784999310599188, true, false, nothing)
                49:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.1", "Signal_Attributes", true, 1.3376629688023611, true, false, nothing)
                50:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.3", "Continuous", true, 7.947379769902836e-18, true, false, nothing)
                51:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.3", "Discontinuities", true, 0.23246547042389193, true, false, nothing)
                52:     FmuCrossCheck("2.0", "cs", "win64", "FMIToolbox_MATLAB", "2.3", "EmbeddedCode", true, 7.937971672476238e-18, true, false, nothing)
                53:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.3", "BouncingBall", true, 4.5513541687626e-16, true, false, nothing)
                54:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.3", "dq", true, 0.0, true, false, nothing)
                55:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.3", "inc", true, 0.6690727929036248, true, false, nothing)
                56:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.3", "vanDerPol", true, 3.958903432099801e-16, true, false, nothing)
                57:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.4", "BouncingBall", true, 4.5513541687626e-16, true, false, nothing)
                58:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.4", "dq", true, 0.0, true, false, nothing)
                59:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.4", "inc", true, 0.6690727929036248, true, false, nothing)
                60:     FmuCrossCheck("2.0", "cs", "win64", "FMUSDK", "2.0.4", "vanDerPol", true, 3.958903432099801e-16, true, false, nothing)
                61:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "DFFREG", false, 1.0746562421593873, true, false, nothing)
                62:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "BouncingBall", true, 0.2649998033726261, true, false, nothing)
                63:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "ControlledTemperature", true, 0.35249334675391286, true, false, nothing)
                64:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "DFFREG", true, 1.075424930079953, true, false, nothing)
                65:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "MixtureGases", true, 0.0, true, false, nothing)
                66:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "Rectifier", true, 9.025725675138174e-6, true, false, nothing)
                67:     FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2021", "fullRobot", true, 0.0, true, false, nothing)
                68:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2015.1", "ControlledTemperature", false, 3.3733230140616486e-14, true, false, nothing)
                69:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2015.1", "Rectifier", false, 0.0008062708525785004, true, false, nothing)
                70:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2015.2", "ControlledTemperature", false, 3.3733230140616486e-14, true, false, nothing)
                71:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2015.2", "Rectifier", false, 0.0008062708525785004, true, false, nothing)
                72:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2016.1", "ControlledTemperature", false, 3.3733230140616486e-14, true, false, nothing)
                73:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2016.1", "Rectifier", false, 0.0008062708525785004, true, false, nothing)
                74:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2016.2", "ControlledTemperature", true, 3.3733230140616486e-14, true, false, nothing)
                75:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2016.2", "Rectifier", false, 0.0008062708525785004, true, false, nothing)
                76:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2018", "ControlledTemperature", true, 3.3733230140616486e-14, true, false, nothing)
                77:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2018", "Rectifier", true, 0.0008062708525785193, true, false, nothing)
                78:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2019", "ControlledTemperature", true, 3.3733230140616486e-14, true, false, nothing)
                79:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2019", "Rectifier", true, 0.0008062708525785004, true, false, nothing)
                80:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2021.1", "ControlledTemperature", true, 3.3733230140616486e-14, true, false, nothing)
                81:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2021.1", "Rectifier", true, 0.0008062708525785004, true, false, nothing)
                82:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2021.2", "ControlledTemperature", true, 3.3733230140616486e-14, true, false, nothing)
                83:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "2021.2", "Rectifier", true, 0.0008062708525784265, true, false, nothing)
                84:     FmuCrossCheck("2.0", "cs", "win64", "MapleSim", "7.01", "ControlledTemperature", false, 0.000723410977660853, true, false, nothing)
                85:     FmuCrossCheck("2.0", "cs", "win64", "PROOSIS", "6.0.2", "aircraftgear", false, 5.276317615969063e-7, true, false, nothing)
                86:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "3.7.41138", "DoublePendulum", false, 0.00028423139947640977, true, false, nothing)
                87:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "3.7.41138", "Engine1b", false, 0.001256675841946218, true, false, nothing)
                88:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "3.7.41138", "Rectifier", false, 1.235793337994467e-5, true, false, nothing)
                89:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "4.0.4", "DoublePendulum", false, 0.0, true, false, nothing)
                90:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "4.0.4", "Engine1b", false, 0.0015028773148524793, true, false, nothing)
                91:     FmuCrossCheck("2.0", "cs", "win64", "SimulationX", "4.0.4", "Rectifier", false, 0.0, true, false, nothing)
                92:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "BouncingBall", false, 0.09118609008915496, true, false, nothing)
                93:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "Dahlquist", true, 0.01666045592217551, true, false, nothing)
                94:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "Resource", false, 0.0, true, false, nothing)
                95:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "Stair", true, 0.6435817981144258, true, false, nothing)
                96:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "BouncingBall", false, 0.028199575504621648, true, false, nothing)
                97:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "Dahlquist", true, 0.008053762859317333, true, false, nothing)
                98:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "Resource", false, 0.0, true, false, nothing)
                99:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "Stair", true, 0.6435817981144258, true, false, nothing)
                100:    FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "Arenstorf", true, 0.0002154562303943618, true, false, nothing)
                101:    FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "Boocwen", true, 0.0, true, false, nothing)
                102:    FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "CVloop", true, 8.182753972060446e-8, true, false, nothing)
                103:    FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "Pendulum", true, 0.0, true, false, nothing)
        List of failed Cross checks
        List of Cross checks with errors
                1:      FmuCrossCheck("2.0", "cs", "win64", "ASim", "2019FD01", "Circle_SWC", false, nothing, false, false, "BoundsError: attempt to access 40-element Vector{Float64} at index [41]")
                2:      FmuCrossCheck("2.0", "cs", "win64", "ASim", "2019FD01", "Speed_SWC", false, nothing, false, false, "BoundsError: attempt to access 40-element Vector{Float64} at index [41]")
                3:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "BouncingBall", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                4:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "ControlledTemperature", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                5:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "CoupledClutches", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                6:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "MixtureGases", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                7:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "Rectifier", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                8:      FmuCrossCheck("2.0", "cs", "win64", "MWorks", "2016", "fullRobot", false, nothing, false, false, "ArgumentError: invalid index: nothing of type Nothing")
                9:      FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "Feedthrough", true, nothing, false, false, "AssertionError: fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                10:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.1", "VanDerPol", true, nothing, false, false, "AssertionError: fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                11:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "Feedthrough", true, nothing, false, false, "AssertionError: fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                12:     FmuCrossCheck("2.0", "cs", "win64", "Test-FMUs", "0.0.2", "VanDerPol", true, nothing, false, false, "AssertionError: fmi2StringToDependencyKind(constant): Unknown dependency kind.")
                13:     FmuCrossCheck("2.0", "cs", "win64", "YAKINDU_Statechart_Tools", "4.0.4", "BouncingBall", false, nothing, false, false, "could not load library \"C:\\Users\\Christof\\AppData\\Local\\Temp\\fmijl_Zw5oBv\\BouncingBall\\binaries\\win64\\BouncingBall.dll\"\nThe specified module could not be found. ")
                14:     FmuCrossCheck("2.0", "cs", "win64", "YAKINDU_Statechart_Tools", "4.0.4", "Feedthrough", false, nothing, false, false, "could not load library \"C:\\Users\\Christof\\AppData\\Local\\Temp\\fmijl_DyKgY8\\Feedthrough\\binaries\\win64\\Feedthrough.dll\"\nThe specified module could not be found. ")
                15:     FmuCrossCheck("2.0", "cs", "win64", "YAKINDU_Statechart_Tools", "4.0.4", "Stairs", true, nothing, false, false, "could not load library \"C:\\Users\\Christof\\AppData\\Local\\Temp\\fmijl_2a01NA\\Stairs\\binaries\\win64\\Stairs.dll\"\nThe specified module could not be found. 
")
                16:     FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "ActivateRC", true, nothing, false, false, "ArgumentError: input string is empty or only contains whitespace")
                17:     FmuCrossCheck("2.0", "cs", "win64", "solidThinking_Activate", "2020", "DiscreteController", true, nothing, false, false, "ArgumentError: input string is empty or only contains whitespace")
 ```