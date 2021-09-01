## [Load a FMU](@id loading)

Loading a FMU in FMI.jl is fairly easy, you only have to call the ```fmiLoad``` function with the path to your FMU.

```
julia> myFMU = fmiLoad("path/to/myFMU.fmu")
julia> myFMU = fmiLoad("path/to/myFMU.fmu"; unpackPath = "path/to/unpacked/fmu/")
```

By default, the unpacked FMU is stored into a temporary directory. Optionally you can provide a path where the FMU should be unpacked. There you have access to the model description and resources of the FMU. Additionally the information of the model description is parsed into a Julia struct.

The most important function to access those informations are are:

```
julia> fmiGetModelName(myFMU)
julia> fmiGetGUID(myFMU)
julia> fmi2String2ValueReference(myFMU, "ModelVariable")
```

While ```fmiGetModelName``` and ```fmiGetGUID``` return the name and GUID of the FMU, ```fmi2String2ValueReference``` returns the corresponding value reference of a model variable.

Also a connection to the shared library is estabished and depending on the provided FMU, the necessary function pointers are loaded to access the need FMI functions.

## [Unload a FMU](@id unload)

Similiar to the ```fmiLoad``` function the ```fmiUnload``` unloads a FMU.

```
julia> fmiUnload(myFMU)
```

The connection to the shared library is closed all instances of the FMU are destroyed (read more about instances [here](@ref Instantiation)) and the temporary files are deleted.

<!--Vlt Doku zu der Stelle wo was erklärt wird-->
