function obj = getObj(Sim,Var)
    obj = zeros([Var.nVar,1]);
    obj(Var.demand) = Sim.muPOn;
    obj(Var.facilities) = Sim.muPAll;
    obj(Var.eOn) = Sim.muEOn;
    obj(Var.eOff) = Sim.muEOff;
end