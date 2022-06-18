#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMI.FMIImport.FMICore: fmi2Real

myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])
comp = fmiInstantiate!(myFMU; loggingOn=false)
@test comp != 0

# choose FMU or FMUComponent
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
@assert fmuStruct != nothing "Unknwon fmuStruct, environment variable `FMUSTRUCT` = `$envFMUSTRUCT`"

@test fmiSetupExperiment(fmuStruct) == 0
@test fmiEnterInitializationMode(fmuStruct) == 0
@test fmiExitInitializationMode(fmuStruct) == 0

targetValues = [[0.0, -10.0], [1.0, 0.0]]
dir_ders_buffer = zeros(fmi2Real, 2)
sample_ders_buffer = zeros(fmi2Real, 2, 1)
for i in 1:fmiGetNumberOfStates(myFMU)

    if fmiProvidesDirectionalDerivative(myFMU)
        # multi derivatives calls
        sample_ders = fmiSampleDirectionalDerivative(fmuStruct, myFMU.modelDescription.derivativeValueReferences, [myFMU.modelDescription.stateValueReferences[i]])
        fmiSampleDirectionalDerivative!(fmuStruct, myFMU.modelDescription.derivativeValueReferences, [myFMU.modelDescription.stateValueReferences[i]], sample_ders_buffer)

        @test sum(abs.(sample_ders[:,1] - targetValues[i])) < 1e-3
        @test sum(abs.(sample_ders_buffer[:,1] - targetValues[i])) < 1e-3

        dir_ders = fmiGetDirectionalDerivative(fmuStruct, myFMU.modelDescription.derivativeValueReferences, [myFMU.modelDescription.stateValueReferences[i]])
        @test fmiGetDirectionalDerivative!(fmuStruct, myFMU.modelDescription.derivativeValueReferences, [myFMU.modelDescription.stateValueReferences[i]], dir_ders_buffer) == 0
    
        @test sum(abs.(dir_ders - targetValues[i])) < 1e-3
        @test sum(abs.(dir_ders_buffer - targetValues[i])) < 1e-3
        
        # single derivative call 
        dir_der = fmiGetDirectionalDerivative(fmuStruct, myFMU.modelDescription.derivativeValueReferences[1], myFMU.modelDescription.stateValueReferences[1])
        @test dir_der == targetValues[1][1]

    else 
        @warn "Skipping directional derivative testing, FMU from $(ENV["EXPORTINGTOOL"]) doesn't support directional derivatives."
    end
    
end

fmiUnload(myFMU)
