#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMIImport: FMUSolution

"""
ToDo: DocString.

Saves a FMUSolution to a mat file.
"""
function fmiSaveSolutionMAT(solution::FMUSolution, filepath::AbstractString) 
    file = MAT.matopen(filepath, "w")
    x = collect.(solution.values.saveval)
    v = [tup[k] for tup in x, k in 1:length(x[1])]
    v = hcat(solution.values.t, v)
    MAT.write(file, "time", v[:,1])
    for i in 2:length(v[1,:])
        MAT.write(file, replace(fmi2ValueReferenceToString(solution.component.fmu, solution.valueReferences[i-1])[1], "." => "_"), v[:,i])
        # df[!, Symbol(fmi2ValueReferenceToString(solution.component.fmu, solution.valueReferences[i]))] = [val[i] for val in solution.values.saveval]
    end
    
    MAT.close(file)
end