function Param = getVarParam(nBus)

% The number of 15-minute time periods in a day.
nTime = 3600*24/(15*60);
sVar = 1;

% the number of variables for average power
fVar = sVar + nBus*nTime - 1;
Param.b = reshape(sVar:fVar,[nBus,nTime]);
sVar = fVar + 1;

% the number of variables for state of charge
fVar = sVar + nBus*(nTime + 1) - 1;
Param.h = reshape(sVar:fVar,[nBus,nTime + 1]);
sVar = fVar + 1;

% the number of variables for total charger power use
fVar = sVar + nTime - 1;
Param.pc = sVar:fVar;
sVar = fVar + 1;

% variables for slack 'g' term to be used for absolute value expression
fVar = sVar +  (nTime - 1)*nBus - 1;
Param.g = reshape(sVar:fVar,[nBus, nTime - 1]);
sVar = fVar + 1;

% index for facilities power (max over all power)
Param.facilities = sVar;
sVar = sVar + 1;

% index for on-peak power (max over all on-peak intervals)
Param.demand = sVar;
sVar = sVar + 1;

% index for total off-peak energy
Param.eOff = sVar;
sVar = sVar + 1;

% index for total on-peak energy
Param.eOn = sVar;
sVar = sVar + 1;

% indices for total power (both uncontrolled loads and bus charger)
fVar = sVar + nTime - 1;
Param.pt = sVar:fVar;

Param.nVar = fVar;
end