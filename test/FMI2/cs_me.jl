###############
# Prepare FMU #
###############

t_start = 0.0
t_stop = 1.0

###

fmuStruct, myFMU = getFMUStruct("SpringPendulum1D")

sol = fmiSimulateCS(fmuStruct, (t_start, t_stop))
@test sol.success 
sol = fmiSimulateME(fmuStruct, (t_start, t_stop); solver=FBDF(autodiff=false))
@test sol.success 

fmiUnload(myFMU)

###

fmuStruct, myFMU = getFMUStruct("SpringPendulum1D"; type=:ME)

sol = fmiSimulate(fmuStruct, (t_start, t_stop); solver=FBDF(autodiff=false))
@test sol.success
fmiUnload(myFMU)

###

fmuStruct, myFMU = getFMUStruct("SpringPendulum1D"; type=:CS)

sol = fmiSimulate(fmuStruct, (t_start, t_stop))
@test sol.success
fmiUnload(myFMU)