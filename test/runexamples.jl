#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Test
using Plots

examples = ["CS_simulate", "manipulation", "ME_simulate", "modelica_conference_2021", "multiple_instances", "parameterize"]

@testset "FMI.jl Examples" begin
    for example in examples
        @testset "$(example).jl" begin
            path = joinpath(dirname(@__FILE__), "..", "example", example * ".jl")
            include(path)
        end
    end
end
