function Param = getVarParam(P)

% The number time intervals in a day
nTime = P.nTime;
nBus = P.nBus;
sVar = 1;

% the number of variables for average power
fVar = sVar + nBus*nTime - 1;
Param.b = reshape(sVar:fVar,[nBus,nTime]);
Param.nB = nBus*nTime;
Param.btype = repmat('C',[Param.nB,1]);
sVar = fVar + 1;

% the number of variables for state of charge
fVar = sVar + nBus*(nTime + 1) - 1;
Param.h = reshape(sVar:fVar,[nBus,nTime + 1]);
Param.nH = nBus*(nTime + 1);
Param.hType = repmat('C',[Param.nH,1]);
sVar = fVar + 1;

% the number of variables for total charger power use
fVar = sVar + nTime - 1;
Param.pc = sVar:fVar;
Param.nPc = nTime;
Param.pcType = repmat('C',[nTime,1]);
sVar = fVar + 1;

% variable indices for 15-minute average power values
fVar = sVar + nTime - 1;
Param.p15 = sVar:fVar;
Param.nP15 = nTime;
Param.p15Type = repmat('C',[Param.nP15,1]);
sVar = fVar + 1;

% variables for slack 'g' term to be used for absolute value expression
fVar = sVar +  (nTime - 1)*nBus - 1;
Param.g = reshape(sVar:fVar,[nBus, nTime - 1]);
Param.nG = (nTime - 1)*nBus;
Param.gType = repmat('C',[Param.nG,1]);
sVar = fVar + 1;

% index for facilities power (max over all power)
Param.facilities = sVar;
Param.nFacilities = 1;
Param.facilitiesType = 'C';
sVar = sVar + 1;

% index for on-peak power (max over all on-peak intervals)
Param.demand = sVar;
Param.nDemand = 1;
Param.demandType = 'C';
sVar = sVar + 1;

% index for total off-peak energy
Param.eOff = sVar;
Param.nEOff = 1;
Param.eOffType = 'C';
sVar = sVar + 1;

% index for total on-peak energy
Param.eOn = sVar;
Param.NEon = 1;
Param.eOnType = 'C';
sVar = sVar + 1;

% indices for total power (both uncontrolled loads and bus charger)
fVar = sVar + nTime - 1;
Param.pt = sVar:fVar;
Param.nPt = nTime;
Param.ptType = repmat('C',[nTime,1]);

% indices for selector variables which give route selection
sVar = fVar + 1;
Param.sessionSelect = nan([nBus,max(P.nRoute)]);
for iBus =1:nBus
    for iRoute = 1:P.nRoute(iBus)
        Param.sessionSelect(iBus,iRoute) = sVar;
        sVar = sVar + 1;
    end
end
Param.nSessionSelect = sum(P.nRoute);
Param.sessionSelectType = repmat('B',[Param.nSessionSelect,1]);
Param.nVar = sVar - 1;
end