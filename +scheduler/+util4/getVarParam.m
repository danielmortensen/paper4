function Var = getVarParam(Sim)
nTime = Sim.nTime; 
nBus = Sim.nBus;
sVar = 1;

% variables for power at each time for each bus
fVar = sVar + nTime*nBus - 1;
Var.schedule = reshape(sVar:fVar,[nBus,nTime]);
Var.nSchedule = nBus*nTime;
Var.scheduletype = repmat('C',[nBus*nTime,1]);
sVar = fVar + 1;

% variables for the total power for all buses and uncontrolled loads
fVar = sVar + nTime - 1;
Var.allpower = sVar:fVar;
Var.nAllpower = nTime;
Var.allpowertype = repmat('C',[nTime,1]);
sVar = fVar + 1;

% variables for 15-minute average power
fVar = sVar + nTime - 1;
Var.p15 = sVar:fVar;
Var.nP15 = nTime;
Var.p15type = repmat('C',[nTime,1]);
sVar = fVar + 1;

% variables for calculating cost
Var.demand = sVar + 0;
Var.facilities = sVar + 1;
Var.onPeakEnergy = sVar + 2;
Var.offPeakEnergy = sVar + 3;
Var.nCostVar = 4;
Var.costVarType = repmat('C',[Var.nCostVar,1]);
sVar = sVar + 4;

Var.nVar = Var.nSchedule + Var.nAllpower + Var.nP15 + Var.nCostVar;
end