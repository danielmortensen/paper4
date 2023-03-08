function Param = getSimParam(Sim, Var, x, nGroup)
schedule = reshape(x(Var.b),[Sim.nBus,Sim.nTime]);
A = schedule*schedule';
M = max(A(:));

Param.nCharger = Sim.nCharger;
Param.nBus = Sim.nBus;
Param.nGroup = nGroup;
Param.M = M;
Param.A = A;
Param.schedule = schedule;
Param.pMaxKW = Sim.pMaxKW;
Param.pMaxDelta = Sim.pMaxDelta;
diff = Sim.nBus/nGroup;
if diff == floor(diff)
    Param.nMinBus = diff;
    Param.nMaxBus = diff;
else
    Param.nMinBus = diff;
    Param.nMaxBus = diff + 1;
end
end