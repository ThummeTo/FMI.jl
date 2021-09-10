## [Load a FMU](@id loading)

Loading a FMU in FMI.jl is fairly easy, you only have to call the [`fmiLoad`](@ref) function with the path to your FMU.

```julia
julia> myFMU = fmiLoad("path/to/myFMU.fmu")
julia> myFMU = fmiLoad("path/to/myFMU.fmu"; unpackPath = "path/to/unpacked/fmu/")
```

By default, the unpacked FMU is stored into a temporary directory. Optionally you can provide a path where the FMU should be unpacked. There you have access to the model description and resources of the FMU. Additionally the information of the model description is parsed into a Julia struct.

The most important function to access those informations are are:

```julia
julia> fmiGetModelName(myFMU)
julia> fmiGetGUID(myFMU)
julia> fmiString2ValueReference(myFMU, "ModelVariable")
julia> fmiInfo(myFMU)
```

While [`fmiGetModelName`](@ref) and [`fmiGetGUID`](@ref) return the name and GUID of the FMU, [`fmi2String2ValueReference`](@ref) returns the corresponding value reference of a model variable. While [`fmiInfo`](@ref) prints the same information as the functions mentioned before and also additional ones.

Also a connection to the shared library is estabished and depending on the provided FMU, the necessary function pointers are loaded to access the need FMI functions.

## [Unload a FMU](@id unload)

Similiar to the [`fmiLoad`](@ref) function the [`fmiUnload`](@ref) unloads a FMU.

```julia
julia> fmiUnload(myFMU)
```

The connection to the shared library is closed all instances of the FMU are destroyed (read more about instances [here](@ref Instantiation)) and the temporary files are deleted.
