#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function warnDeprecated(oldStr, newStr, additional = "")
    @warn "`$(oldStr)` is deprecated, use `$(newStr)` instead. $(additional)\n(this message is printed 3 times)." maxlog =
        3
end

function fmi2Simulate(args...; kwargs...)
    warnDeprecated("fmi2Simulate", "simulate", "FMI version is determined automatically.")
    simulate(args...; kwargs...)
end
export fmi2Simulate

function fmiSimulate(args...; kwargs...)
    warnDeprecated("fmiSimulate", "simulate")
    simulate(args...; kwargs...)
end
export fmiSimulate

function fmi2SimulateME(args...; kwargs...)
    warnDeprecated(
        "fmi2SimulateME",
        "simulateME",
        "FMI version is determined automatically.",
    )
    simulateME(args...; kwargs...)
end
export fmi2SimulateME

function fmiSimulateME(args...; kwargs...)
    warnDeprecated("fmiSimulateME", "simulateME")
    simulateME(args...; kwargs...)
end
export fmiSimulateME

function fmi2SimulateCS(args...; kwargs...)
    warnDeprecated(
        "fmi2SimulateCS",
        "simulateCS",
        "FMI version is determined automatically.",
    )
    simulateCS(args...; kwargs...)
end
export fmi2SimulateCS

function fmiSimulateCS(args...; kwargs...)
    warnDeprecated("fmiSimulateCS", "simulateCS")
    simulateCS(args...; kwargs...)
end
export fmiSimulateCS

function fmiLoad(args...; kwargs...)
    warnDeprecated("fmiLoad", "loadFMU")
    loadFMU(args...; kwargs...)
end
export fmiLoad

function fmi2Load(args...; kwargs...)
    warnDeprecated("fmi2Load", "loadFMU", "FMI version is determined automatically.")
    loadFMU(args...; kwargs...)
end
export fmi2Load

function fmi3Load(args...; kwargs...)
    warnDeprecated("fmi3Load", "loadFMU", "FMI version is determined automatically.")
    loadFMU(args...; kwargs...)
end
export fmi3Load

function fmiUnload(args...; kwargs...)
    warnDeprecated("fmiUnload", "unloadFMU")
    unloadFMU(args...; kwargs...)
end
export fmiUnload

function fmi2Unload(args...; kwargs...)
    warnDeprecated("fmi2Unload", "unloadFMU", "FMI version is determined automatically.")
    unloadFMU(args...; kwargs...)
end
export fmi2Unload

function fmi3Unload(args...; kwargs...)
    warnDeprecated("fmi3Unload", "unloadFMU", "FMI version is determined automatically.")
    unloadFMU(args...; kwargs...)
end
export fmi3Unload

function fmiInfo(args...; kwargs...)
    warnDeprecated("fmiInfo", "info")
    info(args...; kwargs...)
end
export fmiInfo

function fmi2Info(args...; kwargs...)
    warnDeprecated("fmi2Info", "info", "FMI version is determined automatically.")
    info(args...; kwargs...)
end
export fmi2Info

function fmi3Info(args...; kwargs...)
    warnDeprecated("fmi3Info", "info", "FMI version is determined automatically.")
    info(args...; kwargs...)
end
export fmi3Info
