function Param = getSimParam(nBus, nCharger)
% number of time intervals
Param.nTime = 3600*24/(15*60); 

% number of buses
Param.nBus = nBus;

% number of chargers
Param.nCharger = nCharger;

% maximum charge rate in kW
Param.pMaxKW = 350; 

% maximum battery capacity in kWh
Param.hMaxKWH = 450; 

% change in time (seconds) between time indices
Param.deltaTSec = 15*60; % fifteen minutes in seconds.

% initial state of charge of buses
Param.eta = ones([1,nBus])*0.8*Param.hMaxKWH; 

% minimum state of allowable state of charge
Param.hMin = ones([1,nBus])*0.2*Param.hMaxKWH;

% discharge over routes
[Param.delta, Param.alpha, Param.tArrive, Param.tDepart] = ...
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
iStart = 15*3600/(15*60);
iFinal = 22*3600/(15*60) - 1;
Param.S(iStart:iFinal) = true;

% Average power for uncontrolled loads
Param.u = getUncontrolledLoad();
end

function uncontrolled = getUncontrolledLoad()
    path = "\\wsl.localhost\Ubuntu\home\dmortensen\paper4\data\TPSS_Cov15.mat";
    data = load(path);
    uncontrolled = data.mu;
end

function [discharge, alpha, tArrive, tDepart] = getRoutes(nBus, nTime, deltaT)
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
iArrival = tArrive/deltaT;
rArrival = iArrival - floor(iArrival);
iArrival = floor(iArrival);

% convert departure times to indices + remainders
iDepart = tDepart/deltaT;
rDepart = iDepart - floor(iDepart);
iDepart = floor(iDepart);

%preallocate alpha values
alpha = ones([nBus,nTime]);
discharge = zeros([nBus,nTime]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus) - 1

        % define indices and remainders
        ai = iArrival(iBus,iRoute + 1);
        ar = rArrival(iBus,iRoute + 1);
        di = iDepart(iBus,iRoute);
        dr = rDepart(iBus,iRoute);
        if any(isnan([ai,ar,di,dr]))
            break;
        end

        % compute percentage the bus is available for each index
        dis = dSoc(iBus, iRoute);
        rLen = (ai + ar) - (di + dr);
        disPerIndex = dis/rLen;
        if di == ai
            alpha(iBus,ai) = 1 - (ar - dr);
            discharge(iBus,ai) = (ar - dr)*disPerIndex;
        else
            alpha(iBus,ai) = (1 - ar);
            discharge(iBus,ai) = ar*disPerIndex;
            alpha(iBus,di) = dr;
            discharge(iBus,di) = (1 - dr)*disPerIndex;
            if ai - di > 2
                alpha(iBus,di+1:ai-1) = 0;
                discharge(iBus,di + 1:ai - 1) = disPerIndex;
            end
        end        
    end
end
end