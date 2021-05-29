#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Documenter, FMI

makedocs(sitename="FMI.jl",
          pages= Any[
                "Home" => "index.md"
                "Examples" => "examples.md"
                "Library" => Any[
                    "c-wrapper functions" => "library.md",
                    "FMU2 functions" => "fmu2.md"
                ]
         ]
         )

deploydocs(repo = "github.com/ThummeTo/FMI.jl.git", devbranch = "main")
