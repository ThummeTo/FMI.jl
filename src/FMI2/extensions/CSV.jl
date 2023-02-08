#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMU2Solution

"""
Saves a FMU2Solution for later use.
"""
function fmiSaveSolutionCSV(solution::FMU2Solution, filepath::AbstractString) 
    df = DataFrame(time = solution.values.t)
    for i in 1:length(solution.values.saveval[1])
    df[!, Symbol(fmi2ValueReferenceToString(solution.component.fmu, solution.valueReferences[i]))] = [val[i] for val in solution.values.saveval]
    end
    CSV.write(filepath, df)
end

"""
Loads a FMU2Solution. Returns a previously saved `FMU2Solution`.
"""
function fmiLoadSolution(filepath::AbstractString; keyword="solution")
    return JLD2.load(filepath, keyword)
end