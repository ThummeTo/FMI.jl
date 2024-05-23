#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMI

@debug "Debugging messages enabled for FMI.jl ..."

using FMIImport.FMIBase.Reexport
@reexport using FMIImport
@reexport using FMIExport

include("sim.jl")
include("deprecated.jl")

end # module FMI
