function Var = getVarParam(Sim)
nTime = Sim.nTime;
nBus = Sim.nBus;
sVal = 1;

% define variables for bus power
fVal = sVal + nTime*nBus - 1;
Var.b = reshape(sVal:fVal,[nBus,nTime]);
Var.nB = nTime*nBus;
Var.bType = repmat('C',[Var.nB,1]);
sVal = fVal + 1;

% define binary variables indicating which routes to be used
fVal = sVal + sum(Sim.sessStatus == "FRAGMENTED",'all') - 1;
idx = sVal:fVal;
counter = 1;
Var.isUsedAndFragmented = nan([nBus,max(Sim.nRoute)]);
for iBus = 1:nBus
    for iRoute = 1:Sim.nRoute(iBus)
        if strcmp(Sim.sessStatus(iBus,iRoute),"FRAGMENTED")
            Var.isUsedAndFragmented(iBus,iRoute) = idx(counter);
            counter = counter + 1;
        end
    end
end
Var.nIsUsedAndFragmented = sum(strcmp(Sim.sessStatus,"FRAGMENTED"),'all');
Var.isUsedAndFragmentedType = repmat('B',[Var.nIsUsedAndFragmented,1]);
sVal = fVal + 1;

% define variables for total power
fVal = sVal + nTime - 1;
Var.pt = sVal:fVal;
Var.nPt = nTime;
Var.ptType = repmat('C',[nTime,1]);
sVal = fVal + 1;

% define variables for 15-minute average power
fVal = sVal + nTime - 1;
Var.p15 = sVal:fVal;
Var.nP15 = nTime;
Var.p15Type = repmat('C',[Var.nP15,1]);
sVal = fVal + 1;

% define variables for power used by buses at each time step
nRoute = Sim.nRoute;
fVal = sVal + sum(nRoute) - 1;
temp = sVal:fVal;
counter = 1;
Var.routeEnergy = nan([nBus,max(nRoute)]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        Var.routeEnergy(iBus,iRoute) = temp(counter);
        counter = counter + 1;
    end
end
Var.nRouteEnergy = sum(nRoute);
Var.routeEnergyType = repmat('C',[Var.nRouteEnergy,1]);
sVal = fVal + 1;

% define variables for demand power
Var.demand = sVal;
Var.nDemand = 1;
Var.demandType = 'C';

% facilities power
Var.facilities = sVal + 1;
Var.nFacilities = 1;
Var.facilitiesType = 'C';

% on-peak energy
Var.eOn = sVal + 2;
Var.nEOn = 1;
Var.eOnType = 'C';

% off-peak energy
Var.eOff = sVal + 3;
Var.nEOff = 1;
Var.eOffType = 'C';

% update in case we need this later
sVal = sVal + 4;

% define state of charge variables
fVal = sVal + (nTime + 1)*nBus - 1;
Var.h = reshape(sVal:fVal,[nBus,nTime + 1]);
Var.nH = (nTime + 1)*nBus;
Var.hType = repmat('C',[Var.nH,1]);
sVal = fVal + 1;

% define number of total variables
Var.nVar = Var.nB + Var.nIsUsedAndFragmented + Var.nPt + Var.nP15 + Var.nRouteEnergy + Var.nDemand + Var.nFacilities + Var.nEOn + Var.nEOff + Var.nH;

end