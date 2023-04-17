function obj = getObj2(Sim, Var)
% unpack variables
iEon = Var.eOn;
iEoff = Var.eOff;
iFac = Var.facilities;
iDem = Var.demand;
DAYS_PER_MONTH = 30;

obj = zeros([Var.nVar,1]);
obj(iEon) = Sim.muEOn*DAYS_PER_MONTH;
obj(iEoff) = Sim.muEOff*DAYS_PER_MONTH;
obj(iFac) = Sim.muPAll;
obj(iDem) = Sim.muPOn;
end