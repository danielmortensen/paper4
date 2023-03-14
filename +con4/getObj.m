function obj = getObj(Sim, Var)
obj = zeros([Var.nVar,1]);
obj(Var.demand) = Sim.muPOn;
obj(Var.facilities) = Sim.muPAll;
obj(Var.onPeakEnergy) = Sim.muEOn;
obj(Var.offPeakEnergy) = Sim.muEOff;
end