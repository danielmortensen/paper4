function Param = getSimParam(Sim, Var, Sol)
dt = Sim.deltaTSec;
nBus = Sim.nBus;
nCharger = Sim.nCharger;

% number of time intervals, where dt is given in seconds
Param.nTime = 3600*24/dt; 
Param.minEnergyPerSess = Sim.minEnergyPerSess;

% number of buses
Param.nBus = nBus;

% number of chargers
Param.nCharger = nCharger;

% maximum charge rate in kW
Param.pMaxKW = 350; 
Param.pMaxDelta = 20; % always leave a little room :)

% maximum battery capacity in kWh
Param.hMaxKWH = 450; 

% optimal values from prevous optimization
Param.demand = Sol.x(Var.demand);
Param.eOnPeak = Sol.x(Var.eOn);
Param.eOffPeak = Sol.x(Var.eOff);
Param.facilities = Sol.x(Var.facilities);

% change in time (seconds) between time indices
Param.deltaTSec = dt;

% initial state of charge of buses
Param.eta = ones([1,nBus])*0.8*Param.hMaxKWH; 

% minimum state of allowable state of charge
Param.hMin = ones([1,nBus])*0.2*Param.hMaxKWH;

% discharge over routes
[Param.delta, Param.alpha, Param.tArrive, Param.tDepart, Param.nRoute] = ...
    getRoutes(nBus, Param.nTime, Param.deltaTSec);

% On-Peak Energy Rate in dollars/kWh
Param.muEOn = 0.058282;

% Off-Peak Energy Rate in dollars/kWh
Param.muEOff = 0.029624;

% On-Peak demand rate in dollars/kW
Param.muPOn = 15.73;

% Total facilities rate in dollars/kW
Param.muPAll = 4.81;

% On-Peak time indices: 3pm - 10pm
Param.S = false([1,Param.nTime]);
iStart = floor(15*3600/dt);
iFinal = ceil(22*3600/dt) - 1;
Param.S(iStart:iFinal) = true;

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