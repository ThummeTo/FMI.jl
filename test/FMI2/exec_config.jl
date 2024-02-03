#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport

t_start = 0.0
t_stop = 1.0

fmuStruct = Dict{Symbol, Union{FMU2, FMU2Component}}()
myFMU = Dict{Symbol, FMU2}()

fmuStruct[:ME], myFMU[:ME] = getFMUStruct("SpringPendulum1D"; type=:ME)
fmuStruct[:CS], myFMU[:CS] = getFMUStruct("SpringPendulum1D"; type=:CS)

for execConf in (FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET) # ToDo: Add `FMU2_EXECUTION_CONFIGURATION_NOTHING`
    for mode in (:CS, :ME) 
        global fmuStruct, myFMU

        @info "\t$(mode) | $(execConf)"

        myFMU[mode].executionConfig = execConf

        # sim test
        numInst = length(myFMU[mode].components)

        if mode == :CS
            fmiSimulateCS(fmuStruct[mode], (t_start, t_stop))
        elseif mode == :ME
            fmiSimulateME(fmuStruct[mode], (t_start, t_stop))
        else 
            @assert false "Unknown mode `$(mode)`."
        end

        if execConf.instantiate
            numInst += 1
        end
        if execConf.freeInstance
            numInst -= 1
        end

        @test length(myFMU[mode].components) == numInst

        othermode = (mode == :CS ? :ME : :CS)

        # prepare next run start
        if isa(fmuStruct[mode], FMU2)
            if !execConf.freeInstance
                fmi2FreeInstance!(myFMU[mode])
            end 
            
            fmi2Instantiate!(myFMU[othermode]; type=(othermode==:ME ? fmi2TypeModelExchange : fmi2TypeCoSimulation))

        elseif isa(fmuStruct[mode], FMU2Component)
            if !execConf.freeInstance
                fmi2FreeInstance!(fmuStruct[mode])
            end
            fmuStruct[othermode] = fmi2Instantiate!(myFMU[othermode]; type=(othermode==:ME ? fmi2TypeModelExchange : fmi2TypeCoSimulation))

        else
            @assert false "Unknwon fmuStruct type `$(typeof(fmuStruct[mode]))`"
        end
        
        # prepare next run end

    end
end

fmiUnload(myFMU[:ME])
fmiUnload(myFMU[:CS])