nBus = 60; nCharger = 4; dt = 1*60; % one minute intervals
useGurobi = true; makePlots = false; computePrimary = false; computeSecondary = false;
useQuadraticLoss = true; nGroup = 2;
tic; 
if computePrimary
    clear('model');
    Sim = util.getSimParam(nBus, nCharger, dt);
    Var = util.getVarParam(Sim);
    Sim.u = Sim.u*5;
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
    [A11, b11, nCon11, descr11, eq11] = con.getCon11(Sim,Var);
    [A12, b12, nCon12, descr12, eq12] = con.getCon12(Sim,Var);
    obj1 = con.getObj1(Sim, Var);
    obj2 = con.getObj2(Sim, Var);

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
    assert(size(A,2) == Var.nVar);
    obj = obj1*5 + obj2;

    if useGurobi
        % form gurobi model
        model.vtype = repmat('C',[Var.nVar,1]);
        model.A = A;
        model.rhs = b;
        model.sense = eq;
        model.obj = obj;

        % solve model
        sol = gurobi(model, struct('OutputFlag',0));...,struct('DualReductions',0,'iisRequest',1));
        fprintf("Finished first problem\n");
    else
        sol = struct();
        tic;
        sol.x = linprog(obj,Ain,bin,Aeq,beq);
        t = toc
    end
    optimalCost = sol.x'*obj2;
    if makePlots
        % extract charge schedules
        schedule = reshape(sol.x(Var.b),[Sim.nBus,Sim.nTime]);
        figure; imagesc(schedule);

        for iBus = 1:Sim.nBus
            subplot(Sim.nBus,1,iBus); hold on;
            plot(sol.x(Var.h(iBus,:)));
            plot(sol.x(Var.b(iBus,:)));    legend('SOC','Power');
        end

        figure; plot(sol.x(Var.p15)); hold on;
        plot(Sim.u); plot(sol.x(Var.pc));
        yline(sol.x(Var.demand),'red'); yline(sol.x(Var.facilities),'green');
        legend('total power','uncontrolled','charger','demand','facilities');
    end
    groups = computeGroups(Sim, Var, sol.x, nGroup);
    fprintf("Finished second problem\n");

end

if computeSecondary
    clear('model');
    allSim = util2.getAllSimParam(Sim,Var,sol.x, groups);
    allSol = cell([numel(allSim),1]);
    allVar = cell([numel(allSim),1]);
    for iSim = 1:numel(allSim)
        Sim2 = allSim{iSim};
        Var2 = util2.getVarParam(Sim2);

        [A1, b1, nCon1, descr1, eq1] = con2.getCon1(Sim2,Var2);
        [A2, b2, nCon2, descr2, eq2] = con2.getCon2(Sim2,Var2);
        [A3, b3, nCon3, descr3, eq3] = con2.getCon3(Sim2,Var2);
        [A4, b4, nCon4, descr4, eq4] = con2.getCon4(Sim2,Var2);

        A = [A1; A2; A3; A4];
        b = [b1; b2; b3; b4];
        eq = [eq1; eq2; eq3; eq4];
        vtype = [Var2.bType; Var2.fType; Var2.lType; Var2.sigmaType];
        model.A = A;
        model.rhs = b;
        model.sense = eq;
        model.vtype = vtype;
        if useQuadraticLoss
            [Q, obj] = con2.getObj(Sim2,Var2);
            model.obj = obj;
            model.Q = Q;
        else
            obj = con2.getObj2(Sim2,Var2);
            model.obj = obj;
        end
        allSol{iSim} = gurobi(model,struct('MIPGap',0.2,'OutputFlag',0,'DualReductions',0)); ...,'DualReductions',0));
        allVar{iSim} = Var2;
        if allSol{iSim}.status == "INFEASIBLE"
            fprintf("MODEL WAS INFEASIBLE, DO NOT PASS GO, DO NOT COLLECT 200 DOLLARS\n");
            return;
        end
        fprintf("completed sub-problem %i of %i\n",iSim,numel(allSim));
    end
    time = toc
end

% compute power for all buses with uncontrolled loads
allBusPower = zeros([1,Sim.nTime]);
for iSol = 1:numel(allSol)
    p = computeBusPower(allSim{iSol},allVar{iSol}, allSol{iSol}.x, Sim);
    allBusPower = allBusPower + sum(p,1);
end
allPower = allBusPower + Sim.u;

% resample to 15-minute average power
nPerWindow = (60*15)/Sim.deltaTSec;
avgPower = conv(allPower, ones([1,nPerWindow])/nPerWindow,'same');
facilitiesMax = max(avgPower);
demandMax = max(avgPower(Sim.S));
offPeakEnergy = sum(allPower(~Sim.S))*Sim.deltaTSec/3600;
onPeakEnergy = sum(allPower(Sim.S))*Sim.deltaTSec/3600;
cost = facilitiesMax*Sim.muPAll + demandMax*Sim.muPOn + 30*(offPeakEnergy*Sim.muEOff + onPeakEnergy*Sim.muEOn);
percentIncrease = (cost - optimalCost)/optimalCost*100;



function busPower = computeBusPower(Sim, Var, x, Sim2)
busPower = zeros([Sim.nBus,Sim2.nTime]);
for iBus =1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        e = Sim.mWidth(iBus,iRoute)*Sim2.pMaxKW/3600;
        e = (e > 0.2)*e;
        tStart = x(Var.b(iBus,iRoute));
        tFinal = x(Var.f(iBus,iRoute));
        if tFinal - tStart > 30
            p = e/((tFinal - tStart)/3600);
            is = floor(tStart/Sim2.deltaTSec);
            rs = (tStart - is*Sim2.deltaTSec)/Sim2.deltaTSec;
            ifin = floor(tFinal/Sim2.deltaTSec);
            rfin = (tFinal - ifin*Sim2.deltaTSec)/Sim2.deltaTSec;
            if is == ifin
                busPower(iBus,is + 1) = busPower(iBus,is + 1) + (rfin - rs)*p;
            else
                busPower(iBus,is + 1) = busPower(iBus,is + 1) + (1 - rs)*p;
                busPower(iBus,ifin + 1) = busPower(iBus,ifin + 1) + rfin*p;
                busPower(iBus,is + 2:ifin) = busPower(iBus,is + 2:ifin) + p;
            end
        end       
    end
end
end
function groups = computeGroups(Sim, Var, x, nGroup)

fprintf("building constraints for group separation...\n");
% compute simulation params/variable indices
Sim2 = util3.getSimParam(Sim, Var, x, nGroup);
Var2 = util3.getVarParam(Sim2);
nGroup = Sim2.nGroup;

% compute constraints
[A1, b1, nCon1, descr1, eq1] = con3.getCon1(Sim2,Var2);
[A2, b2, nCon2, descr2, eq2] = con3.getCon2(Sim2,Var2);
[A3, b3, nCon3, descr3, eq3] = con3.getCon3(Sim2,Var2);
[A4, b4, nCon4, descr4, eq4] = con3.getCon4(Sim2,Var2);
[A5, b5, nCon5, descr5, eq5] = con3.getCon5(Sim2,Var2);
[A6, b6, nCon6, descr6, eq6] = con3.getCon6(Sim2,Var2);
[A7, b7, nCon7, descr7, eq7] = con3.getCon7(Sim2,Var2);
obj = con3.getObj(Sim2,Var2);

% formulate model
A = [A1; A2; A3; A4; A5; A6; A7];
b = [b1; b2; b3; b4; b5; b6; b7];
eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7];
vtype = [Var2.vtype; Var2.sigmatype; Var2.grouptype; Var2.chargertype];

model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.obj = obj;

% solve problem
fprintf("solving group separation problem\n");
sol = gurobi(model,struct('OutputFlag',0,'MIPGap',0.55)); ...struct('MIPGap',0.3));
fprintf("finished group separation problelm\n");
% % create feasiable solution
% feasSol = zeros([Var2.nVar,1]);
% 
% % there are two groups
% feasSol(Var2.group(1,:)) = sum(Sim2.schedule,1);
% ...feasSol(Var2.group(2,:)) = 0;
% feasSol(Var2.charger(1)) = 12;
% ...feasSol(Var2.charger(2)) = 0;
% feasSol(Var2.sigma(:,1)) = 1;


% for iGroup = 1:nGroup
%     
% end
% for iBus = 1:Sim2.nBus
%     for iRoute = 1:Sim2.nRoute(iBus)
%         feasSol(Var2.b(iBus,iRoute)) = Sim2.tStart(iBus,iRoute);
%         feasSol(Var2.f(iBus,iRoute)) = Sim2.tFinal(iBus,iRoute);
%         feasSol(Var2.sigma(iBus,iRoute,iBus)) = 1;
%     end
% end

% compute group parameters
groupIdx = nan([Sim.nBus,1]);
for iBus = 1:Sim.nBus
    groupIdx(iBus) = find(sol.x(Var2.sigma(iBus,:)));
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
end
