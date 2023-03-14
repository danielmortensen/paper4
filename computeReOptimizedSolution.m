function [Sol5, Var5] = computeReOptimizedSolution(Sim5)
Var5 = util4.getVarParam(Sim5);
[A1, b1, nConst1, descr1, eq1] = con4.getCon1(Sim5, Var5);
[A2, b2, nConst2, descr2, eq2] = con4.getCon2(Sim5, Var5);
[A3, b3, nConst3, descr3, eq3] = con4.getCon3(Sim5, Var5);
[A4, b4, nConst4, descr4, eq4] = con4.getCon4(Sim5, Var5);
[A5, b5, nConst5, descr5, eq5] = con4.getCon5(Sim5, Var5);
[A6, b6, nConst6, descr6, eq6] = con4.getCon6(Sim5, Var5);
obj5 = con4.getObj(Sim5, Var5);

feasSol = zeros([Var5.nVar,1]);
feasSol(Var5.schedule) = Sim5.optSol(Sim5.optVar.b);
feasSol(Var5.allpower) = Sim5.optSol(Sim5.optVar.pt);
feasSol(Var5.p15) = Sim5.optSol(Sim5.optVar.p15);
feasSol(Var5.onPeakEnergy) = Sim5.optSol(Sim5.optVar.eOn);
feasSol(Var5.offPeakEnergy) = Sim5.optSol(Sim5.optVar.eOff);
feasSol(Var5.demand) = Sim5.optSol(Sim5.optVar.demand);
feasSol(Var5.facilities) = Sim5.optSol(Sim5.optVar.facilities);


A = [A1;A2;A3;A4; A5; A6];
b = [b1;b2;b3;b4; b5; b6];
eq = [eq1;eq2;eq3;eq4; eq5; eq6];
vtype = [Var5.scheduletype; Var5.allpowertype; Var5.p15type; Var5.costVarType];
model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.obj = obj5;
Sol5 = gurobi(model,struct('MIPGap',0.002,'OutputFlag',0));...,'OutputFlag',0,'DualReductions',0));    
end