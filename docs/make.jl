#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import Pkg;
Pkg.develop(path = joinpath(@__DIR__, "../../FMI.jl"));
using Documenter, Plots, JLD2, DataFrames, CSV, MAT, FMI, FMIBase, FMIImport, FMICore
using Documenter: GitHubActions

example_pages = [
    "Overview" => "examples/overview.md",
    "Simulate" => "examples/simulate.md",
    "Parameterize" => "examples/parameterize.md",
    "Inputs" => "examples/inputs.md",
    "Multiple instances" => "examples/multiple_instances.md",
    "Modelica conference 2021" => "examples/modelica_conference_2021.md",
    "Manipulation" => "examples/manipulation.md",
    "Multithreading" => "examples/multithreading.md",
    "Multiprocessing" => "examples/multiprocessing.md",
    "Pluto Workshops" => "examples/workshops.md",
]

makedocs(
    sitename = "FMI.jl",
    format = Documenter.HTML(
        collapselevel = 1,
        sidebar_sitename = false,
        edit_link = nothing,
        size_threshold = 512000,
        size_threshold_ignore = [
            "deprecated.md",
            "fmi2_lowlevel_library_functions.md",
            "fmi3_lowlevel_library_functions.md",
        ],
    ),
    modules = [FMI, FMIImport, FMICore, FMIBase],
    checkdocs = :exports,
    linkcheck = true,
    warnonly = :linkcheck,
    pages = Any[
        "Introduction" => "index.md"
        "Features" => "features.md"
        "FAQ" => "faq.md"
        "Examples" => example_pages
        "User Level API - FMI.jl" => "library.md"
        "Developer Level API" => Any[
            "fmi version independent content"=>Any[
                "fmi_lowlevel_library_constants.md",
                "fmi_lowlevel_modeldescription_functions.md",
                "fmi_lowlevel_library_functions.md",
            ],
            "FMI2 specific content"=>Any[
                "fmi2_lowlevel_library_constants.md",
                "FMI2 Functions in FMI Import/Core .jl"=>Any[
                    "fmi2_lowlevel_modeldescription_functions.md",
                    "fmi2_lowlevel_library_functions.md",
                    "fmi2_lowlevel_ME_functions.md",
                    "fmi2_lowlevel_CS_functions.md",
                ],
            ],
            "FMI3 specific content"=>Any[
                "fmi3_lowlevel_library_constants.md",
                "FMI3 Functions in FMI Import/Core .jl"=>Any[
                    "fmi3_lowlevel_modeldescription_functions.md",
                    "fmi3_lowlevel_library_functions.md",
                    "fmi3_lowlevel_ME_functions.md",
                    "fmi3_lowlevel_CS_functions.md",
                    "fmi3_lowlevel_SE_functions.md",
                ],
            ],
        ]
        "API Index" => "index_library.md"
        "FMI Tool Information" => "fmi-tool-info.md"
        "Related Publication" => "related.md"
        "Contents" => "contents.md"
        hide("Deprecated" => "deprecated.md")
    ],
)

function deployConfig()
    github_repository = get(ENV, "GITHUB_REPOSITORY", "")
    github_event_name = get(ENV, "GITHUB_EVENT_NAME", "")
    if github_event_name == "workflow_run"
        github_event_name = "push"
    end
    github_ref = get(ENV, "GITHUB_REF", "")
    return GitHubActions(github_repository, github_event_name, github_ref)
end

deploydocs(
    repo = "github.com/ThummeTo/FMI.jl.git",
    devbranch = "main",
    deploy_config = deployConfig(),
)
