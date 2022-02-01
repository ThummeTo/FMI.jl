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
            "Usage" =>[
                "Overview" => "usage/usage_overview.md"
                "Tutorials" => [
                    "Overview" => "tutorials/tutorial_overview.md"
                    "Get Started" => "tutorials/get_started.md"
                    "Load/Unload a FMU" => "tutorials/load_unload.md"
                    "Simulate a FMU" => "tutorials/simulate.md"
                ]
                "Examples" => [
                    "examples/overview_examples.md"
                    "examples/CS_simulation.md"
                    "examples/simulateME.md"
                    "examples/parameterize.md"
                    "examples/multipleInstance.md"
                ]
            ]
            "Library Functions" => Any[
                "Overview" => "library/overview_library.md",
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



#using Documenter, FMI
#
 #        makedocs(sitename="FMI.jl",
  #                format = Documenter.HTML(
   #                  collapselevel = 1,
   #                  sidebar_sitename = false
   #               ),
   #               pages= Any[
   #                  "Introduction" => "index.md"
   #                  "Tutorials" => [
   #                      "tutorials/overview.md"
   #                      "Get Started" => "tutorials/get_started.md"
   #                      "Load/Unload a FMU" => "tutorials/load_unload.md"
   #                      "Simulate a FMU" => "tutorials/simulate.md"
   #                  ]
   #                  "Examples" => [
   #                      "examples/overview_examples.md"
   #                      "examples/CS_simulation.md"
   #                      "examples/simulateME.md"
   #                      "examples/parameterize.md"
   #                      "examples/multipleInstance.md"
   #                  ]
   #                  "Library Functions" => Any[
   #                      "Overview" => "library/overview_library.md",
   #                      "FMI 2 library functions" => "library/library.md",
   #                      "FMI version independent functions" => "library/library_ind.md",
   #                      "FMU 2 functions" => "library/fmu2.md",
   #                      "FMU version independent functions" => "library/fmu.md"
   #                  ]
   #                  "related.md"
   #                  "Contents" => "contents.md"
   #                  "Library Index" => "indices.md"
   #                  ]
   #               )

#deploydocs(repo = "https://github.com/adribrune/FMI.jl.git", devbranch = "main")
#github.com/ThummeTo/FMI.jl.git