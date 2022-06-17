# FMI Cross-Checks

---

:construction: **This feature is currently work in process**

---

This folder contains everything related to the FMI Cross-Check process for https://fmi-standard.org/tools/ 

More information: https://github.com/modelica/fmi-cross-check

## Instruction

To run the cross-checks, excecute `cross_checks.jl`

## Currently failing
```
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\Test-FMUs\\0.0.1\\Feedthrough\\Feedthrough.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\Test-FMUs\\0.0.1\\VanDerPol\\VanDerPol.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\Test-FMUs\\0.0.2\\Feedthrough\\Feedthrough.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\Test-FMUs\\0.0.2\\VanDerPol\\VanDerPol.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\solidThinking_Activate\\2020\\ActivateRC\\ActivateRC.fmu: ArgumentError(\"input string is empty or only contains whitespace\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\me\\win64\\solidThinking_Activate\\2020\\DiscreteController\\DiscreteController.fmu: ArgumentError(\"input string is empty or only contains whitespace\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\Test-FMUs\\0.0.1\\Feedthrough\\Feedthrough.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\Test-FMUs\\0.0.1\\VanDerPol\\VanDerPol.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\Test-FMUs\\0.0.2\\Feedthrough\\Feedthrough.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\Test-FMUs\\0.0.2\\VanDerPol\\VanDerPol.fmu: AssertionError(\"fmi2StringToDependencyKind(constant): Unknown dependency kind.\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\YAKINDU_Statechart_Tools\\4.0.4\\Stairs\\Stairs.fmu: ErrorException(\"could not load library \\\"C:\\\\Users\\\\Christof\\\\AppData\\\\Local\\\\Temp\\\\fmijl_MeE91B\\\\Stairs\\\\binaries\\\\win64\\\\Stairs.dll\\\"\\nThe specified module could not be found. \")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\solidThinking_Activate\\2020\\ActivateRC\\ActivateRC.fmu: ArgumentError(\"input string is empty or only contains whitespace\")"
 "C:\\Users\\Christof\\AppData\\Local\\Temp\\fmicrosschecks_aypnem\\fmi-cross-check\\fmus\\2.0\\cs\\win64\\solidThinking_Activate\\2020\\DiscreteController\\DiscreteController.fmu: ArgumentError(\"input string is empty or only contains whitespace\")"
 ```