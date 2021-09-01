#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Documenter, FMI

makedocs(sitename="FMI.jl",
         format = Documenter.HTML(
            collapselevel = 1,
            sidebar_sitename = false
         ),
         pages= Any[
            "Introduction" => "index.md"
            "Tutorials" => [
                "tutorials/overview.md"
                "Load/Unload a FMU" => "tutorials/load_unload.md"
                "Simulate a FMU" => "tutorials/simulateCS.md"
            ]
            "Examples" => [
                "examples/examples.md"
                "Simulate CS" => "examples/CS_simulation.md"
            ]
            "Library Functions" => Any[
                "FMI library functions" => "library/library.md",
                "FMU2 functions" => "library/fmu2.md"
            ]
            "Contents" => "contents.md"
            "Index" => "indices.md"
            ]
         )

deploydocs(repo = "github.com/ThummeTo/FMI.jl.git", devbranch = "main")
