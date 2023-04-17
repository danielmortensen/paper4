function [groups, Sim2, Var2, sol] = computeGroups(Sim, Var, x, nGroup, solverparam)
import scheduler.con3.*
import scheduler.util3.*

nBus = Sim.nBus;
nCharger = Sim.nCharger;
if nGroup == 1
 groups.groupId = ones([nBus,1]);
            groups.nBus = nBus;
            groups.nCharger = nCharger;
            groups.nGroup = 1;
            groups.schedule = x(Var.b);
            Sim2 = struct();
            Var2 = struct();
            sol = struct();
else
% compute simulation params/variable indices
Sim2 = getSimParam(Sim, Var, x, nGroup);
Var2 = getVarParam(Sim2);
nGroup = Sim2.nGroup;

% compute constraints
[A1, b1, nCon1, descr1, eq1] = getCon1(Sim2,Var2);
[A2, b2, nCon2, descr2, eq2] = getCon2(Sim2,Var2);
[A3, b3, nCon3, descr3, eq3] = getCon3(Sim2,Var2);
[A4, b4, nCon4, descr4, eq4] = getCon4(Sim2,Var2);
[A5, b5, nCon5, descr5, eq5] = getCon5(Sim2,Var2);
[A6, b6, nCon6, descr6, eq6] = getCon6(Sim2,Var2);
[A7, b7, nCon7, descr7, eq7] = getCon7(Sim2,Var2);
obj = getObj2(Sim2,Var2);

% formulate model
A = [...
     A1;...
     A2;...
     A3;...
     A4;...
     A5;...
     A6;...
     A7;...
     ];
b = [...
     b1;...
     b2;...
     b3;...
     b4;...
     b5;...
     b6;...
     b7;...
     ];
eq = [...
      eq1;...
      eq2;...
      eq3;...
      eq4;...
      eq5;...
      eq6;...
      eq7;...
      ];
vtype = [Var2.vtype; Var2.sigmatype; Var2.grouptype; Var2.chargertype; Var2.maxOverallType];

model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.obj = obj;

% solve problem
sol = gurobi(model,struct(solverparam{:})); ...struct('MIPGap',0.3));
if sol.status == "INFEASIBLE"
    error("unable to form groups.\n");
end

% compute group parameters
groupIdx = nan([Sim.nBus,1]);
for iBus = 1:Sim.nBus
    groupIdx(iBus) = find(round(sol.x(Var2.sigma(iBus,:))));
end
for iGroup = 1:nGroup
    Sim2.nBus(iGroup) = sum(groupIdx == iGroup);
end
nCharger = sol.x(Var2.charger);

% package for use
groups.nBus = Sim2.nBus;
groups.nCharger = nCharger;
groups.groupId = groupIdx;
groups.nGroup = nGroup;
groups.schedule = Sim2.schedule;
groups.sol = sol;
end
end
