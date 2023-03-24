function [Sol, Var] = computeChargeIntervals(Sim)
Var = util7.getVarParam(Sim);
[A1, b1, nConst1, descr1, eq1] = con7.getCon1(Sim,Var);
[A2, b2, nConst2, descr2, eq2] = con7.getCon2(Sim,Var);
[A3, b3, nConst3, descr3, eq3] = con7.getCon3(Sim,Var);
Q = con7.getObj(Sim,Var);
A = [...
     A1;...
     A2;...
     A3;...
     ];
b = [...
     b1;...
     b2;...
     b3;...
     ];
eq = [...
     eq1;...
     eq2;...
     eq3;...
     ];
vtype = repmat('C',[Var.nVar,1]);
model.vtype = vtype;
model.Q = Q;
model.A = A;
model.rhs = b;
model.sense = eq;
Sol = gurobi(model,struct('OutputFlag',0));
end