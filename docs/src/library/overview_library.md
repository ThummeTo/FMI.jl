# [Librar Functions](@id Lib)

## [Overview](@id overview_Lib)
The [Library Functions](@ref Lib) sections contains all the documentation to the functions provided by this library. A distinction is made between the functions already defined by the FMI standard and the functions developed internally. The individual functions are available in version-specific as well as version-independent form.


## [Archtiecture] (@id architecture)
Das FMI-Standart besitzt eine Versionenspezifische Befehlssatz, der zur angenehmeren Nutzung bereits in Jula-Code übertagen wurde. Damit die unterscheidung der Version inerhalb der Befehlsnutzung eindeutig ist, wird die jeweilige FMI-Version als repräsentant innerhalb des jeweiligen Befehlsnamen auftauchen.

```julia
FMI.fmi2COMMANDNAME
```

Hierbei steht __*fmi2*__ für die zweite FMI-Standart Version mit dem darauffolgenden __*BEFEHLSNAME*__. Verallgemeinert bertrachtet wird sich dementsprechen die Versionsnummer "__*?*__" innerhalb des Befehlsnamen ändern um die jeweilge Befehlsversion zu kennzeichnen.
```julia
FMI.fmi?COMMANDNAME
```

Damit der Entnutzer nicht unter den jeweiligen Version unterschieden muss, gewährleisten wir, zusäzlich zu den jeweiligen übersetzungen, eine Versionsunabhängig Befehlsform. Dementsprechend fällt die Versionskenzahl innerhalb des Berfehls weg.
```julia
FMI.fmiCOMMANDNAME
```
Zur weiteren Verdeutlichung der Architektur ist im Anschluss eine Graphische Zusammenfassung dargestellt.
[architecture-imag]: 