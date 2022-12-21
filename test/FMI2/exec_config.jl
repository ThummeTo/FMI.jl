#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport

t_start = 0.0
t_stop = 1.0

myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])

comp = fmiInstantiate!(myFMU; loggingOn=false, type=fmi2TypeCoSimulation)
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

for execConf in (FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET) # ToDo: Add `FMU2_EXECUTION_CONFIGURATION_NOTHING`
    for mode in (:CS, :ME) 
        global fmuStruct
        @info "\t$(mode) | $(execConf)"

        myFMU.executionConfig = execConf

        # sim test
        numInst = length(myFMU.components)

        if mode == :CS
            fmiSimulateCS(fmuStruct, (t_start, t_stop))
        elseif mode == :ME
            fmiSimulateME(fmuStruct, (t_start, t_stop))
        else 
            @assert false "Unknown mode `$(mode)`."
        end

        if execConf.instantiate
            numInst += 1
        end
        if execConf.freeInstance
            numInst -= 1
        end

        @test length(myFMU.components) == numInst

        # prepare next run start
        if envFMUSTRUCT == "FMU"
            if !execConf.freeInstance
                fmi2FreeInstance!(myFMU)
            end
            fmi2Instantiate!(myFMU; type=(mode==:CS ? fmi2TypeModelExchange : fmi2TypeCoSimulation))

        elseif envFMUSTRUCT == "FMUCOMPONENT"
            if !execConf.freeInstance
                fmi2FreeInstance!(fmuStruct)
            end
            fmuStruct = fmi2Instantiate!(myFMU; type=(mode==:CS ? fmi2TypeModelExchange : fmi2TypeCoSimulation))

        end
        
        # prepare next run end

    end
end

fmiUnload(myFMU)