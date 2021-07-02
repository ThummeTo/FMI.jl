#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Test

examples = ["ME_simulate", "CS_simulate", "multiple_instances", "parameterize", "modelica_conference_2021"]

@testset "FMI.jl Examples" begin
    for example in examples
        @testset "$(example).jl" begin
            path = joinpath(dirname(@__FILE__), "..", "example", example * ".jl")
            @test include(path) == nothing
        end
    end
end
