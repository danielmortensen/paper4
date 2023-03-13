function [Sol5, Var5] = computeReOptimizedSolution(Sim5)
Var5 = util4.getVarParam(Sim5);
[A1, b1, nConst1, descr1, eq1] = con4.getCon1(Sim5, Var5);
[A2, b2, nConst2, descr2, eq2] = con4.getCon2(Sim5, Var5);
[A3, b3, nConst3, descr3, eq3] = con4.getCon3(Sim5, Var5);
[Q5, obj5] = con4.getObj(Sim5, Var5);

A = [A1;A2;A3;];
b = [b1;b2;b3;];
eq = [eq1;eq2;eq3;];
vtype = [Var5.scheduletype; Var5.allpowertype];
model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.obj = obj5;
model.Q = Q5;
Sol5 = gurobi(model,struct('MIPGap',0.002,'OutputFlag',0));...,'OutputFlag',0,'DualReductions',0)); 
end