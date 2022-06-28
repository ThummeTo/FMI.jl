###############
# Prepare FMU #
###############

t_start = 0.0
t_stop = 1.0

myFMU = fmiLoad("BouncingBall", "ModelicaReferenceFMUs", "0.0.16", "3.0")
# @test fmiIsCoSimulation(myFMU)
# @test fmiIsModelExchange(myFMU)
# inst = fmiInstantiate!(myFMU; loggingOn=false)
# @test inst != 0
# # choose FMU or FMUComponent
# fmuStruct = nothing
# envFMUSTRUCT = ENV["FMUSTRUCT"]
# if envFMUSTRUCT == "FMU"
#     fmuStruct = myFMU
# elseif envFMUSTRUCT == "FMUCOMPONENT"
#     fmuStruct = inst
# end
# sol = fmiSimulateCS(fmuStruct, t_start, t_stop)
# @test sol.success 
# sol = fmiSimulateME(fmuStruct, t_start, t_stop)
# @test sol.success 
# fmiUnload(myFMU)



# myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]; type=:ME)
@test myFMU.type == FMI.fmi3TypeModelExchange
inst = fmi3InstantiateModelExchange!(myFMU; loggingOn=false)
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = inst
end
sol = fmiSimulate(fmuStruct, t_start, t_stop)
@test sol.success
fmiUnload(myFMU)



# myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]; type=:CS)
@test myFMU.type == FMI.fmi3TypeCoSimulation
inst = fmi3InstantiateCoSimulation!(myFMU; loggingOn=false)
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = inst
end
sol = fmiSimulate(fmuStruct, t_start, t_stop)
@test sol.success
fmiUnload(myFMU)