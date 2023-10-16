#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

"""
    fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution") 

Saves a FMUSolution for later use. `keyword` is the used keyword for the jld data structure
"""
function fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution") 
    return JLD2.save(filepath, Dict(keyword=>solution))
end

"""
    fmiLoadSolutionJLD2(filepath::AbstractString; keyword="solution")

Loads a FMUSolution. Returns a previously saved `FMUSolution`. `keyword` is the used keyword for the jld data structure
"""
function fmiLoadSolutionJLD2(filepath::AbstractString; keyword="solution")
    return JLD2.load(filepath, keyword)
end