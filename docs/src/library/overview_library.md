# [Librar Functions](@id Lib)

## [Overview](@id overview_Lib)
The [Library Functions](@ref Lib) sections contains all the documentation to the functions provided by this library. A distinction is made between the functions already defined by the FMI standard and the functions developed internally. The individual functions are available in version-specific as well as version-independent form. In order to maintain a clear structure, the version-dependent commands are followed by a chapter for the respective version-independent commands.

- [FMI 2 library function](@ref library)
- [FMI version independent functions](@ref library_ind)
- [FMU 2 functions](@ref FMU_f)
- [FMU version independent function](@ref FMU2_ind)

## [Archtiecture] (@id architecture)
The FMI-standard has a version-specific command set, which has already been transferred to Jula code for more convenient use. To make the distinction of the version within the command usage clear, the respective FMI version will appear as a representative within the related command name.

```julia
FMI.fmi2COMMAND NAME
```

Here __*fmi2*__ stands for the second FMI standard version with the following __*COMMAND NAME*__. In general terms, the version number "__*?*__" will change within the command name to indicate the respective command version.
```julia
FMI.fmi?COMMAND NAME
```

To avoid the user having to distinguish between the different versions, we provide, in addition to the respective translations, a version-independent command form. Accordingly, the version number within the command is removed.
```julia
FMI.fmiCOMMAND NAME
```
For further clarification of the architecture, a graphical summary is shown below.  

![ ](https://github.com/adribrune/FMI.jl/blob/main/docs/src/assets/logo.png)

