nBus = 1; nCharger = 1;
Var = util.getVarParam(nBus);
Sim = util.getSimParam(nBus, nCharger);
[A1, b1, nCon1, descr1, eq1] = con.getCon1(Sim,Var);
[A2, b2, nCon2, descr2, eq2] = con.getCon2(Sim,Var);
[A3, b3, nCon3, descr3, eq3] = con.getCon3(Sim,Var);
[A4, b4, nCon4, descr4, eq4] = con.getCon4(Sim,Var);
[A5, b5, nCon5, descr5, eq5] = con.getCon5(Sim,Var);
[A6, b6, nCon6, descr6, eq6] = con.getCon6(Sim,Var);
[A7, b7, nCon7, descr7, eq7] = con.getCon7(Sim,Var);
[A8, b8, nCon8, descr8, eq8] = con.getCon8(Sim,Var);
[A9, b9, nCon9, descr9, eq9] = con.getCon9(Sim,Var);
[A10, b10, nCon10, descr10, eq10] = con.getCon10(Sim,Var);
obj1 = con.getObj1(Sim, Var);
obj2 = con.getObj2(Sim, Var);

% concatenate each constraint
A = [A1; A2; A3; A4; A5; A6; A7; A8; A9; A10];
b = [b1; b2; b3; b4; b5; b6; b7; b8; b9; b10];
nCon = nCon1 + nCon2 + nCon3 + nCon4 + nCon5 + nCon6 + nCon7 + nCon8 + nCon9 + nCon10;
eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7; eq8; eq9; eq10];

% double check dimensions
assert(size(A,1) == nCon);
assert(numel(b) == nCon);
assert(size(A,2) == Var.nVar);

% form gurobi model
model.vtype = repmat('C',[Var.nVar,1]);
model.A = A;
model.rhs = b;
model.sense = eq;
model.obj = obj1 + obj2;

% solve model
sol = gurobi(model,struct('DualReductions',0,'iisRequest',1));



