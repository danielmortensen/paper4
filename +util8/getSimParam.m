function Param = getSimParam(Sim1, Var1, Sol1)
Param = Sim1;
Param.demand = Sol1.x(Var1.demand);
Param.facilities = Sol1.x(Var1.facilities);
Param.onPeakEnergy = Sol1.x(Var1.onPeakEnergy);
Param.offPeakEnergy = Sol1.x(Var1.offPeakEnergy);
end