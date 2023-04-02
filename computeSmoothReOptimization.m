function [Sol5, Var5] = computeSmoothReOptimizedSolution(Sim5)
Var5 = util8.getVarParam(Sim5);
[A1, b1, nConst1, descr1, eq1] = con8.getCon1(Sim5, Var5);
[A2, b2, nConst2, descr2, eq2] = con8.getCon2(Sim5, Var5);
[A3, b3, nConst3, descr3, eq3] = con8.getCon3(Sim5, Var5);
[A4, b4, nConst4, descr4, eq4] = con8.getCon4(Sim5, Var5);
[A5, b5, nConst5, descr5, eq5] = con8.getCon5(Sim5, Var5);
[A6, b6, nConst6, descr6, eq6] = con8.getCon6(Sim5, Var5);
[A7, b7, nConst7, descr7, eq7] = con8.getCon7(Sim5, Var5);
Q = con8.getObj(Sim5, Var5);

A = [A1;A2;A3;A4; A5; A6; A7];
b = [b1;b2;b3;b4; b5; b6; b7];
eq = [eq1;eq2;eq3;eq4; eq5; eq6; eq7];
vtype = [Var5.scheduletype; Var5.allpowertype; Var5.p15type; Var5.costVarType];
model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.Q = Q;
Sol5 = gurobi(model,struct('MIPGap',0.02,'OutputFlag',0));...,'OutputFlag',0,'DualReductions',0));    
end