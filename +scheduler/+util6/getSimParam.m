function Param = getSimParam(Sim, Var, Sol)
% dt = Sim.deltaTSec;
% nBus = Sim.nBus;
% nCharger = Sim.nCharger;
% 
% % number of time intervals, where dt is given in seconds
% Param.nTime = Sim.nTime;
% 
% % number of buses
% Param.nBus = nBus;
% 
% % number of chargers
% Param.nCharger = nCharger;
% 
% % maximum charge rate in kW
% Param.pMaxKW = Sim.pMaxKW; 
% Param.pMaxDelta = Sim.pMaxDelta; % always leave a little room :)
% 
% % maximum battery capacity in kWh
% Param.hMaxKWH = Sim.hMaxKWH; 

Param = Sim;
% optimal values from prevous optimization
Param.demand = Sol.x(Var.demand);
Param.eOnPeak = Sol.x(Var.eOn);
Param.eOffPeak = Sol.x(Var.eOff);
Param.facilities = Sol.x(Var.facilities);

% % change in time (seconds) between time indices
% Param.deltaTSec = dt;
% 
% % initial state of charge of buses
% Param.eta = Sim.eta; 
% 
% % minimum state of allowable state of charge
% Param.hMin = Sim.hMin;
% 
% % discharge over routes
% Param.delta = Sim.delta;
% Param.alpha = Sim.alpha;
% Param.tArrive = Sim.tArrive;
% Param.tDepart = Sim.tDepart;
% Param.nRoute = Sim.nRoute;
% 
% % On-Peak Energy Rate in dollars/kWh
% Param.muEOn = Sim.muEOn;
% 
% % Off-Peak Energy Rate in dollars/kWh
% Param.muEOff = Sim.muEOff;
% 
% % On-Peak demand rate in dollars/kW
% Param.muPOn = Sim.muPOn;
% 
% % Total facilities rate in dollars/kW
% Param.muPAll = Sim.muPAll;
% 
% % On-Peak time indices: 3pm - 10pm
% Param.S = Sim.S;
% 
% % Average power for uncontrolled loads
% Param.u = Sim.u;
end

