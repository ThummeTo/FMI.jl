#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

"""
    fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution") 

Save a `solution` of an FMU simulation under `keyword` in a jld2 file at `filepath`. 
(requires Package JLD2 in Julia Environment)

See also [`fmiSaveSolutionCSV`](@ref), [`fmiSaveSolutionMAT`](@ref), [`fmiLoadSolutionJLD2`](@ref).
"""
function fmiSaveSolutionJLD2(solution::FMUSolution, filepath::AbstractString; keyword="solution") 
    return JLD2.save(filepath, Dict(keyword=>solution))
end
export fmiSaveSolutionJLD2

"""
    fmiLoadSolutionJLD2(filepath::AbstractString; keyword="solution")

Load a [`FMUSolution`](@ref) from jld2 file at `filepath` using `keyword` as jld2 keyword. 
(requires Package JLD2 in Julia Environment)

See also [`fmiSaveSolutionCSV`](@ref), [`fmiSaveSolutionMAT`](@ref), [`fmiSaveSolutionJLD2`](@ref).
"""
function fmiLoadSolutionJLD2(filepath::AbstractString; keyword="solution")
    return JLD2.load(filepath, keyword)
end
export fmiLoadSolutionJLD2