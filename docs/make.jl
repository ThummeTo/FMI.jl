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
            "Home" => "index.md"
            "Examples" => [
                "Parameterize" => "parameterize.md"
                "Simulate CoSimulation" => "simulateCS.md"
                "Simulate ModelExchange" => "simulateME.md"
            ]
            "Library Functions" => Any[
                "FMI library functions" => "library.md",
                "FMU2 functions" => "fmu2.md"
            ]
         ]
         )

deploydocs(repo = "github.com/ThummeTo/FMI.jl.git", devbranch = "main")
