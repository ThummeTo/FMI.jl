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
            "Features" => "features.md"
            "Tutorials" => [
                "tutorials/overview.md"
                "Load/Unload a FMU" => "tutorials/load_unload.md"
                "Simulate a FMU" => "tutorials/simulate.md"
            ]
            "Examples" => [
                "examples/examples.md"
                "examples/CS_simulation.md"
                "examples/simulateME.md"
                "examples/parameterize.md"
                "examples/multipleInstance.md"
            ]
            "Library Functions" => Any[
                "FMI 2 library functions" => "library/library.md",
                "FMI version independent functions" => "library/library_ind.md",
                "FMU 2 functions" => "library/fmu2.md",
                "FMU version independent functions" => "library/fmu.md"
            ]
            "related.md"
            "Contents" => "contents.md"
            "Library Index" => "indices.md"
            ]
         )

deploydocs(repo = "github.com/ThummeTo/FMI.jl.git", devbranch = "main")
