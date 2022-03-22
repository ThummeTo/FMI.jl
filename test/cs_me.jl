###############
# Prepare FMU #
###############

t_start = 0.0
t_stop = 1.0

myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"])
@test fmiIsCoSimulation(myFMU)
@test fmiIsModelExchange(myFMU)
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
success = fmiSimulateCS(fmuStruct, t_start, t_stop)
@test success
sol, _ = fmiSimulateME(fmuStruct, t_start, t_stop)
@test sol.retcode == :Success
fmiUnload(myFMU)



myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]; type=:ME)
@test myFMU.type == FMI.fmi2TypeModelExchange
comp = fmiInstantiate!(myFMU; loggingOn=false)
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
sol, _ = fmiSimulate(fmuStruct, t_start, t_stop)
@test sol.retcode == :Success
fmiUnload(myFMU)



myFMU = fmiLoad("SpringPendulum1D", ENV["EXPORTINGTOOL"], ENV["EXPORTINGVERSION"]; type=:CS)
@test myFMU.type == FMI.fmi2TypeCoSimulation
comp = fmiInstantiate!(myFMU; loggingOn=false)
fmuStruct = nothing
envFMUSTRUCT = ENV["FMUSTRUCT"]
if envFMUSTRUCT == "FMU"
    fmuStruct = myFMU
elseif envFMUSTRUCT == "FMUCOMPONENT"
    fmuStruct = comp
end
success = fmiSimulate(fmuStruct, t_start, t_stop)
@test success
fmiUnload(myFMU)