#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport

t_start = 0.0
t_stop = 1.0

myFMU = fmiLoad("BouncingBall", "ModelicaReferenceFMUs", "0.0.16", "3.0")

comp = fmi3InstantiateCoSimulation!(myFMU; loggingOn=false)
@test comp != 0
# choose FMU or FMUComponent
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
@assert fmuStruct !== nothing "Unknown fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

for execConf in (FMU3_EXECUTION_CONFIGURATION_NO_FREEING, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET) # ToDo: Add `FMU3_EXECUTION_CONFIGURATION_NOTHING`
    for mode in ([:CS]) 
        global fmuStruct
        @info "\t$(mode) | $(execConf)"

        myFMU.executionConfig = execConf

        # sim test
        numInst = length(myFMU.instances)

        if mode == :CS
            fmiSimulateCS(fmuStruct, t_start, t_stop)
        elseif mode == :ME
            fmiSimulateME(fmuStruct, t_start, t_stop)
        else 
            @assert false "Unknown mode `$(mode)`."
        end

        if execConf.instantiate
            numInst += 1
        end
        if execConf.freeInstance
            numInst -= 1
        end

        @test length(myFMU.instances) == numInst

        # prepare next run start
        if envFMUSTRUCT == "FMU"
            if execConf.freeInstance
                fmi3FreeInstance!(myFMU)
            end

            if mode == :CS
                fmi3InstantiateCoSimulation!(myFMU)
            elseif mode == :ME
                fmi3InstantiateModelExchange!(myFMU)
            end

        elseif envFMUSTRUCT == "FMUCOMPONENT"
            if execConf.freeInstance
                fmi3FreeInstance!(fmuStruct)
            end
            if mode == :CS
                fmi3InstantiateCoSimulation!(myFMU)
            elseif mode == :ME
                fmi3InstantiateModelExchange!(myFMU)
            end

        end
        # prepare next run end

    end
end

fmiUnload(myFMU)