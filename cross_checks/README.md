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
 ```