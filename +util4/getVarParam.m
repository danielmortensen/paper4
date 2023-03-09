function Var = getVarParam(Sim)
nTime = Sim.nTime; 
nBus = Sim.nBus;

Var.schedule = reshape(1:nBus*nTime,[nBus,nTime]);
Var.nSchedule = nBus*nTime;
Var.scheduletype = repmat('C',[nBus*nTime,1]);

Var.allpower = Var.nSchedule + 1:Var.nSchedule + nTime;
Var.nAllpower = nTime;
Var.allpowertype = repmat('C',[nTime,1]);

Var.nVar = Var.nSchedule + Var.nAllpower;
end