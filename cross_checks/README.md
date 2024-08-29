# FMI Cross-Checks

This folder contains the scripts for the FMI Cross-Check process (https://fmi-standard.org/tools/)

More information: https://github.com/modelica/fmi-cross-check

## Instruction

### Automated run using github actions

The `..\.github\workflow` folder contains a `CrossChecks.yml` file that configures the execution of the FMI cross checks using a github action.

This action pulls the FMI cross checks from a repository, executes them and pushes the result files back to the repository. These specified repository needs to be forked before from https://github.com/modelica/fmi-cross-check. After forking the fmi-cross-check repository, a access token with repo rights needs to be generated (https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

In order to use the action you need to be set the following information about your fmi-cross-check repository the FMI.jl repository as secrets and variables.

* (Variable) `CROSS_CHECK_REPO_URL`: The url (without protocol) to your fmi-cross-check repository. (Example: `github.com/johndoe/fmi-cross-check`)
* (Variable) `CROSS_CHECK_REPO_USER`: The user that has write access to the fmi-cross-check repository and for which the token was created. (Example: `johndoe`)
* (Secret) `CROSS_CHECK_REPO_TOKEN`: The github token that was created for the fmi-cross-check repository (Example: `ghp_IqHJF673SD...`)

Not setting these values correctly will prevent the results to be pushed to your fmi-cross-check repository. However you will still be able to see the result summary of your run in the github action logs.

### Manual run

To run the cross-checks locally, excecute `cross_checks.jl` with the respective arguments

```
Arguments used for cross check:
usage: cross_check.jl [--os OS] [--ccrepo CCREPO]
                      [--ccbranch CCBRANCH] [--tempdir TEMPDIR]
                      [--fmiversion FMIVERSION] [--includefatals]
                      [--skipnotcompliant] [--commitrejected]
                      [--commitfailed] [-h]

optional arguments:
  --os OS               The operating system for which the cross
                        checks should be excecuted (default:
                        "windows-latest")
  --ccrepo CCREPO       The URL to the git repository that contains
                        the cross checks. (default:
                        "https://github.com/modelica/fmi-cross-check")
  --ccbranch CCBRANCH   The name of the branch in which the results
                        will be pushed (default: "master")
  --tempdir TEMPDIR     temporary directive that is used for cross
                        checks and results
  --fmiversion FMIVERSION
                        FMI version that should be used for the cross
                        checks (default: "2.0")
  --includefatals       Include FMUs that have caused the cross check
                        runner to fail and exit
  --skipnotcompliant    Reject officially not compliant FMUs and don't
                        execute them
  --commitrejected      Also commit the result file for FMUs that
                        hasn't been executed (e.g. officially not
                        compliant FMUs if they are not skipped)
  --commitfailed        Also commit the result file for failed FMUs
  --plotfailed          Plot result for failed FMUs (e.g. debugging)
  -h, --help            show this help message and exit

```

## Further configuration

More parameters can be found under `.\cross_check_config.jl`.

* TOOL_ID: Used for the results folder name in the fmi-cross-checks
* TOOL_VERSION: Used for the results folder name in the fmi-cross-checks
* FMI_CROSS_CHECK_REPO_NAME: Used to identify the fmi-cross-checks folder
* NRMSE_THRESHHOLD: Used to identify successful FMUs
* EXCLUDED_SYSTEMS: These fmi cross check systems are excluded from the fmi cross check run, because the have been unstable and caused the script to crash
* CROSS_CHECK_README_CONTENT: File content that is written in the readme in the results folder of the fmi-cross-checks