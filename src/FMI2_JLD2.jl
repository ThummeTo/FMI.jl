#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMU2Solution

"""
Saves a FMU2Solution for later use.
"""
function fmiSaveSolution(solution::FMU2Solution, filepath::AbstractString; keyword="solution") 
    return JLD2.save(filepath, Dict(keyword=>solution))
end

"""
Loads a FMU2Solution. Returns a previously saved `FMU2Solution`.
"""
function fmiLoadSolution(filepath::AbstractString; keyword="solution")
    return JLD2.load(filepath, keyword)
end