#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# test different unpacking path options for FMUs

pathToFMU =
    get_model_filename("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

# load FMU in temporary directory
fmuStruct, myFMU = getFMUStruct(pathToFMU)
@test isfile(myFMU.zipPath) == true
@test isdir(splitext(myFMU.zipPath)[1]) == true
fmiUnload(myFMU)

# load FMU in source directory 
fmuDir = joinpath(splitpath(pathToFMU)[1:end-1]...)
fmuStruct, myFMU = getFMUStruct(pathToFMU; unpackPath = fmuDir)
@test isfile(splitext(pathToFMU)[1] * ".zip") == true
@test isdir(splitext(pathToFMU)[1]) == true
