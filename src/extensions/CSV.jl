#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

"""
    fmiSaveSolutionCSV(solution::FMUSolution, filepath::AbstractString)

Saves a FMUSolution to a csv file.

# Arguments
- `solution::FMUSolution`: The simulation results that should be saved
- `filepath::AbstractString`: The path specifing where to save the results, also indicating the file format. Supports *.mat, *.csv, *.JLD2
"""
function fmiSaveSolutionCSV(solution::FMUSolution, filepath::AbstractString)
    CSV.write(filepath, solution)
end
