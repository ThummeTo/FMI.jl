#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMU2Solution

"""
Saves a FMU2Solution to a csv file.
"""
function fmiSaveSolutionCSV(solution::FMU2Solution, filepath::AbstractString) 
    df = DataFrames.DataFrame(time = solution.values.t)
    for i in 1:length(solution.values.saveval[1])
        df[!, Symbol(fmi2ValueReferenceToString(solution.component.fmu, solution.valueReferences[i]))] = [val[i] for val in solution.values.saveval]
    end
    CSV.write(filepath, df)
end
