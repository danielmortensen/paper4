function [Sim1, Var1, Sol1] = computeIdeal(nBus, nCharger, dt, lossType,  chargerCapacity, batteryCapacity, initialBatteryEnergy, loadMultiplyFactor, minBatteryEnergy, solveparams, muEOn, muEOff, muPOn, muPAll, onPeakInterval)
import scheduler.util.*;
import scheduler.con.*;
Sim1 = getSimParam(nBus, nCharger, dt, chargerCapacity, batteryCapacity, initialBatteryEnergy, minBatteryEnergy, muEOn, muEOff, muPOn, muPAll, onPeakInterval);
Var1 = getVarParam(Sim1);
Sim1.u = Sim1.u*loadMultiplyFactor;
[A1, b1, nCon1, descr1, eq1] = getCon1(Sim1,Var1);
[A2, b2, nCon2, descr2, eq2] = getCon2(Sim1,Var1);
[A3, b3, nCon3, descr3, eq3] = getCon3(Sim1,Var1);
[A4, b4, nCon4, descr4, eq4] = getCon4(Sim1,Var1);
[A5, b5, nCon5, descr5, eq5] = getCon5(Sim1,Var1);
[A6, b6, nCon6, descr6, eq6] = getCon6(Sim1,Var1);
[A7, b7, nCon7, descr7, eq7] = getCon7(Sim1,Var1);
[A8, b8, nCon8, descr8, eq8] = getCon8(Sim1,Var1);
[A9, b9, nCon9, descr9, eq9] = getCon9(Sim1,Var1);
[A10, b10, nCon10, descr10, eq10] = getCon10(Sim1,Var1);
[A11, b11, nCon11, descr11, eq11] = getCon11(Sim1,Var1);
[A12, b12, nCon12, descr12, eq12] = getCon12(Sim1,Var1);


% concatenate each constraint
Ain = [A1; A3; A7; A8; A10; A12];
bin = [b1; b3; b7; b8; b10; b12];
Aeq = [A2; A4; A5; A6; A9; A11];
beq = [b2; b4; b5; b6; b9; b11];
A = [Ain; Aeq];
b = [bin; beq];
nCon = nCon1 + nCon2 + nCon3 + nCon4 + nCon5 + nCon6 + nCon7 + nCon8 + nCon9 + nCon10 + nCon11 + nCon12;
eq = [eq1; eq3; eq7; eq8; eq10; eq12; eq2; eq4; eq5; eq6; eq9; eq11];

% double check dimensions
assert(size(A,1) == nCon);
assert(numel(b) == nCon);
assert(size(A,2) == Var1.nVar);

if strcmp(lossType,"fiscal")
    obj = getObj2(Sim1, Var1);
    model.obj = obj;
elseif strcmp(lossType,"baseline")
    Q = getObjBaseline(Sim1, Var1);
    model.Q = Q;
elseif strcmp(lossType,"consumption")
    obj = getObjConsumption(Sim1, Var1);
    model.obj = obj;
else
    error("invalid loss type");
end

% form gurobi model
vtype = repmat('C',[Var1.nVar,1]);
model.vtype = vtype;
model.A = A;
model.rhs = b;
model.sense = eq;

% solve model
Sol1 = gurobi(model, struct(solveparams{:}));...,struct('DualReductions',0,'iisRequest',1));
    fprintf("Finished global uncontrained solution\n");
end