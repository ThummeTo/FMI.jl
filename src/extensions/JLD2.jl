#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

"""
Saves a FMUSolution for later use.
"""
function fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution") 
    return JLD2.save(filepath, Dict(keyword=>solution))
end

"""
Loads a FMUSolution. Returns a previously saved `FMUSolution`.
"""
function fmiLoadSolutionJLD2(filepath::AbstractString; keyword="solution")
    return JLD2.load(filepath, keyword)
end