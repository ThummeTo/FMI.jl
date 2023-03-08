#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport.EzXML
using FMIImport.ZipFile

function fmiCheckVersion(pathToFMU::String; unpackPath=nothing)
    # Unzip MD

    # Download FMU if necessary
    if startswith(pathToFMU, "http")
        @info "Downloading FMU for Version extraction from `$(pathToFMU)`."
        pathToFMU = download(pathToFMU)
    end

    pathToFMU = normpath(pathToFMU)

    fileNameExt = basename(pathToFMU)
    (fileName, fileExt) = splitext(fileNameExt)
        
    if unpackPath === nothing
        # cleanup=true leads to issues with automatic testing on linux server.
        unpackPath = mktempdir(; prefix="fmijl_", cleanup=false)
    end

    zipPath = joinpath(unpackPath, fileName * ".zip")
    unzippedPath = joinpath(unpackPath, fileName)

    # only copy ZIP if not already there
    if !isfile(zipPath)
        cp(pathToFMU, zipPath; force=true)
    end

    @assert isfile(zipPath) ["fmiCheckVersion(...): ZIP-Archive couldn't be copied to `$zipPath`."]

    zipAbsPath = isabspath(zipPath) ?  zipPath : joinpath(pwd(), zipPath)
    unzippedAbsPath = isabspath(unzippedPath) ? unzippedPath : joinpath(pwd(), unzippedPath)

    @assert isfile(zipAbsPath) ["fmiCheckVersion(...): Can't deploy ZIP-Archive at `$(zipAbsPath)`."]

    # only unzip if not already done
    if !isdir(unzippedAbsPath)
        mkpath(unzippedAbsPath)

        zarchive = ZipFile.Reader(zipAbsPath)
        for f in zarchive.files
            if f.name == "modelDescription.xml"
                fileAbsPath = normpath(joinpath(unzippedAbsPath, f.name))

                # create directory if not forced by zip file folder
                mkpath(dirname(fileAbsPath))

                numBytes = write(fileAbsPath, read(f))

                @assert numBytes > 0 "fmiCheckVersion(...): Can't unzip file `$(f.name)` at `$(fileAbsPath)`, file is empty."
                @assert isfile(fileAbsPath) "fmiCheckVersion(...): Can't unzip file `$(f.name)` at `$(fileAbsPath)`, file does not exist in target directory."
            end
            
        end
        close(zarchive)
    end

    @assert isdir(unzippedAbsPath) ["fmiCheckVersion(...): ZIP-Archive couldn't be unzipped at `$(unzippedPath)`."]
    # @info "fmiUnzipVersion(...): Successfully unzipped modelDescription.xml at `$unzippedAbsPath`."

    # read version tag

    doc = readxml(normpath(joinpath(unzippedAbsPath, "modelDescription.xml")))

    root = doc.root
    version = root["fmiVersion"]

    # cleanup unzipped modelDescription
    try
        rm(unzippedAbsPath; recursive = true, force = true)
        rm(zipAbsPath; recursive = true, force = true)
    catch e
        @warn "Cannot delete unpacked data on disc. Maybe some files are opened in another application."
    end

    # return version
    return version
end