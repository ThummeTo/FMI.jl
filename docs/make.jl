#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Documenter, FMI
using Documenter: GitHubActions

makedocs(sitename="FMI.jl",
         format = Documenter.HTML(
            collapselevel = 1,
            sidebar_sitename = false,
            edit_link = nothing
         ),
         pages= Any[
            "Introduction" => "index.md"
            "Features" => "features.md"
            "FAQ" => "faq.md"
            "Examples" => [
                "examples/overview.md"
                "examples/simulate.md"
                "examples/parameterize.md"
                "examples/multiple_instances.md"
                "examples/modelica_conference_2021.md"
                "examples/manipulation.md"
                "examples/multithreading.md"
                "examples/multiprocessing.md"
            ]
            "Library Functions" => Any[
                "FMI version independent library functions" => "library/library.md",
                "FMU version independent functions" => "library/fmu.md"
            ]
            "Related Publication" => "related.md"
            "Contents" => "contents.md"
            ]
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

deploydocs(repo = "github.com/ThummeTo/FMI.jl.git", devbranch = "main", deploy_config = deployConfig())
