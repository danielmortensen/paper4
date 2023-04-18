function Param = getSimParam(nBus, nCharger, dt, chargerCapacity, batteryCapacity, initialBatteryEnergy, minBatteryEnergy, muEOn, muEOff, muPOn, muPAll, onPeakInterval)
% number of time intervals, where dt is given in seconds
Param.nTime = 3600*24/dt; 

% number of buses
Param.nBus = nBus;

% number of chargers
Param.nCharger = nCharger;

% maximum charge rate in kW
Param.pMaxKW = chargerCapacity; 
Param.pMaxDelta = 20; % always leave a little room :)

% maximum battery capacity in kWh
Param.hMaxKWH = batteryCapacity; 

% change in time (seconds) between time indices
Param.deltaTSec = dt;

% initial state of charge of buses
if numel(initialBatteryEnergy) == 1
    Param.eta = ones([1,nBus])*initialBatteryEnergy;
elseif numel(initialBatteryEnergy) == nBus
    Param.eta = initialBatteryEnergy;
else
    error("number of initialBatteryEnergy values must be 1 or nBus");
end

% minimum state of allowable state of charge
if numel(minBatteryEnergy) == 1
    Param.hMin = ones([1,nBus])*minBatteryEnergy;
elseif numel(minBatteryEnergy) == nBus
    Param.hMin = minBatteryEnergy;
else
    error("number of minBatteryEnergy values must be 1 or nBus");
end

% discharge over routes
[Param.delta, Param.alpha, Param.tArrive, Param.tDepart, Param.nRoute] = ...
    getRoutes(nBus, Param.nTime, Param.deltaTSec);

% On-Peak Energy Rate in dollars/kWh
Param.muEOn = muEOn;

% Off-Peak Energy Rate in dollars/kWh
Param.muEOff = muEOff;

% On-Peak demand rate in dollars/kW
Param.muPOn = muPOn;

% Total facilities rate in dollars/kW
Param.muPAll = muPAll;

% On-Peak time indices: 3pm - 10pm
Param.S = false([1,Param.nTime]);
nInterval = size(onPeakInterval,1);
for iInterval = 1:nInterval
iStart = floor(onPeakInterval(iInterval,1)/dt);
iFinal = ceil(onPeakInterval(iInterval, 2)/dt) - 1;
Param.S(iStart:iFinal) = true;
end

% Average power for uncontrolled loads
Param.u = getUncontrolledLoad(dt);
end

function uncontrolled = getUncontrolledLoad(dt)
    path = "\\wsl.localhost\Ubuntu\home\dmortensen\paper4\data\TPSS_Cov15.mat";
    data = load(path);
    uncontrolled = data.mu;

    % resample at new rate
    nInitial = numel(uncontrolled);
    nDesired = 3600*24/dt;
    uncontrolled = resample(uncontrolled,nDesired,nInitial);
    assert(numel(uncontrolled) == nDesired);
end

function [discharge, alpha, tArrive, tDepart, nRoute] = getRoutes(nBus, nTime, deltaT)
dirRoutes = "\\wsl.localhost\Ubuntu\home\dmortensen\paper4\data\routesTable.csv";
routes = readtable(dirRoutes);
routes = sortrows(routes,'nRoute','descend');

% get nBus worth of route data
simRoutes = routes(1:nBus,:);
nRoute = simRoutes(:,end-1);
simRoutes = simRoutes(:,1:end-3);
simRoutes = table2array(simRoutes);
nRoute = table2array(nRoute);
tArrive = simRoutes(:,1:3:end);
tDepart = simRoutes(:,2:3:end);
dSoc = -simRoutes(:,3:3:end);

% convert arrival times to indices + remainders
iArrival = ceil(tArrive/deltaT);

% convert departure times to indices + remainders
iDepart = floor(tDepart/deltaT);

%preallocate alpha values
alpha = ones([nBus,nTime]);
discharge = zeros([nBus,nTime]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus) - 1

        % define indices and remainders
        ai = iArrival(iBus,iRoute + 1);
        di = iDepart(iBus,iRoute);
        rLen = ai - di;
        if any(isnan([ai,di])) || rLen == 0
            break;
        end

        % compute percentage the bus is available for each index
        dis = dSoc(iBus, iRoute);
        disPerIndex = dis/rLen;
        alpha(iBus,di:ai) = 0;
        discharge(iBus,di:ai) = disPerIndex;
    end
end
end