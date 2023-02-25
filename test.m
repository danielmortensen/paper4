% 2 bus 1 charger scenario
nBus = 1; nCharger = 1;
Var = util.getVarParam(nBus);
Sim = util.getSimParam(nBus, nCharger);

sol = nan([Var.nVar,1]);
Sim.delta = zeros(size(Sim.delta));
Sim(1,91) = 10;
% no charging necessary
for iBus = 1:Sim.nBus
    for iTime = 1:Sim.nTime
        sol(Var.b(iBus,iTime)) = 0;
    end
end

% initial state of charge
for iBus = 1:Sim.nBus
    sol(Var.h(iBus,1)) = Sim.eta(iBus);
end

% no change in state of charge
for iBus = 1:Sim.nBus
    for iTime = 2:Sim.nTime + 1
        sol(Var.h(iBus,iTime)) = sol(Var.h(iBus,iTime - 1)) + Sim.delta(iBus,iTime - 1) +  sol(Var.pc(iBus,iTime));
    end
end

% no charger use
for iTime = 1:Sim.nTime
    sol(Var.pc(iTime)) = 0;
end

% absolute valeu of g is still zero
for iBus = 1:nBus
    for iTime = 1:Sim.nTime - 1
        sol(Var.g(iBus,iTime)) = 0;
    end
end

% compute facilities power
f = max(Sim.u);

% demand power
d = max(Sim.u(Sim.S));
sol(Var.facilities) = f;
sol(Var.demand) = d;

% on-peak energy
eon = sum(Sim.u(Sim.S));
eof = sum(Sim.u(~Sim.S));
sol(Var.eOff) = eof;
sol(Var.eOn) = eon;

% calculate total power
sol(Var.pt) = Sim.u;

% set up constraints
...Sim.delta = zeros(size(Sim.delta));
...Sim.u = zeros(size(Sim.u));
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

% plot first constraint
b1sol = A1*sol;
plotComparison(b1sol, b1);
assertIn(b1sol, b1);

% plot second constraint
b2sol = A2*sol;
plotComparison(b2sol,b2);
assertEq(b2sol,b2);

% plot third constraint
b3sol = A3*sol;
plotComparison(b3sol, b3);
assertIn(b3sol,b3);

% verify fourth constraint
b4sol = A4*sol; 
plotComparison(b4sol, b4);
assertEq(b4sol,b4);

% verify fifth constraint
b5sol = A5*sol;
plotComparison(b5sol, b5);
assertEq(b5sol,b5);

% verify sixth constraint
b6sol = A6*sol;
plotComparison(b6sol, b6);
assertEq(b6sol, b6);


function assertIn(d1, d2)
    assert(sum(d1 > d2) == 0);
end
function assertEq(d1, d2)
    assert(sum(d1 ~= d2) == 0);
end
function plotComparison(d1, d2)
    figure; plot(d1); hold on; plot(d2); legend('given','expected');
end