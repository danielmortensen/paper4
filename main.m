nBus = 80; nCharger = 80; dt = 1*20; % one minute intervals
maxChargerPerBus = 16;
MIPGap = 0.99; ...nBus/(nCharger*maxChargerPerBus);
useGurobi = true; makePlots = false; computePrimary = true; computeSecondary = true;
useQuadraticLoss = false;

nGroup = 1;
lossType = "fiscal"; %"fiscal", "baseline", "consumption"
tic; 
if computePrimary
    clear('model');
    Sim1 = util.getSimParam(nBus, nCharger, dt);
    Var1 = util.getVarParam(Sim1);
    Sim1.u = Sim1.u*5;
    [A1, b1, nCon1, descr1, eq1] = con.getCon1(Sim1,Var1);
    [A2, b2, nCon2, descr2, eq2] = con.getCon2(Sim1,Var1);
    [A3, b3, nCon3, descr3, eq3] = con.getCon3(Sim1,Var1);
    [A4, b4, nCon4, descr4, eq4] = con.getCon4(Sim1,Var1);
    [A5, b5, nCon5, descr5, eq5] = con.getCon5(Sim1,Var1);
    [A6, b6, nCon6, descr6, eq6] = con.getCon6(Sim1,Var1);
    [A7, b7, nCon7, descr7, eq7] = con.getCon7(Sim1,Var1);
    [A8, b8, nCon8, descr8, eq8] = con.getCon8(Sim1,Var1);
    [A9, b9, nCon9, descr9, eq9] = con.getCon9(Sim1,Var1);
    [A10, b10, nCon10, descr10, eq10] = con.getCon10(Sim1,Var1);
    [A11, b11, nCon11, descr11, eq11] = con.getCon11(Sim1,Var1);
    [A12, b12, nCon12, descr12, eq12] = con.getCon12(Sim1,Var1);
   

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
        obj1 = con.getObj1(Sim1, Var1);
        obj2 = con.getObj2(Sim1, Var1);
        obj = obj2;
        model.obj = obj;
    elseif strcmp(lossType,"baseline")
        Q = con.getObjBaseline(Sim1, Var1);
        model.Q = Q;
    elseif strcmp(lossType,"consumption")
        obj = con.getObjConsumption(Sim1, Var1);
        model.obj = obj;
    else
        error("invalid loss type");
    end

    % form gurobi model
    model.vtype = repmat('C',[Var1.nVar,1]);
    model.A = A;
    model.rhs = b;
    model.sense = eq;

    % solve model
    Sol1 = gurobi(model, struct('OutputFlag',0));...,struct('DualReductions',0,'iisRequest',1));
        fprintf("Finished global uncontrained solution\n");

    if makePlots
        % extract charge schedules
        schedule = reshape(Sol1.x(Var1.b),[Sim1.nBus,Sim1.nTime]);
        figure; imagesc(schedule);

        for iBus = 1:Sim1.nBus
            subplot(Sim1.nBus,1,iBus); hold on;
            plot(Sol1.x(Var1.h(iBus,:)));
            plot(Sol1.x(Var1.b(iBus,:)));    legend('SOC','Power');
        end

        figure; plot(Sol1.x(Var1.p15)); hold on;
        plot(Sim1.u); plot(Sol1.x(Var1.pc));
        yline(Sol1.x(Var1.demand),'red'); yline(Sol1.x(Var1.facilities),'green');
        legend('total power','uncontrolled','charger','demand','facilities');
    end
    groups = computeGroups(Sim1, Var1, Sol1.x, nGroup, MIPGap);
    fprintf("Finished group separation problem\n");

end

nSim = groups.nGroup;
Sims2 = util5.getAllSimParam(Sim1, Var1, Sol1.x, groups);
Sols2 = cell([nSim,1]);
Vars2 = cell([nSim,1]);
Sims3 = cell([nSim,1]);
Sols3 = cell([nSim,1]);
Vars3 = cell([nSim,1]);
u = Sim1.u;
for iSim = 1:numel(Sims2)
    clear('model');
    Sim2 = Sims2{iSim};
    Var2 = util5.getVarParam(Sim2);
    Sim2.u = u;

    [A1, b1, nCon1, descr1, eq1] = con5.getCon1(Sim2,Var2);
    [A2, b2, nCon2, descr2, eq2] = con5.getCon2(Sim2,Var2);
    [A3, b3, nCon3, descr3, eq3] = con5.getCon3(Sim2,Var2);
    [A4, b4, nCon4, descr4, eq4] = con5.getCon4(Sim2,Var2);
    [A5, b5, nCon5, descr5, eq5] = con5.getCon5(Sim2,Var2);
    [A6, b6, nCon6, descr6, eq6] = con5.getCon6(Sim2,Var2);
    [A7, b7, nCon7, descr7, eq7] = con5.getCon7(Sim2,Var2);
    [A8, b8, nCon8, descr8, eq8] = con5.getCon8(Sim2,Var2);
    obj = con5.getObj(Sim2,Var2);


    vtype = [Var2.bType; ...
        Var2.isUsedAndFragmentedType; ...
        Var2.ptType; ...
        Var2.p15Type; ...
        Var2.routeEnergyType; ...
        Var2.demandType; ...
        Var2.facilitiesType; ...
        Var2.eOnType; ...
        Var2.eOffType;];
    A = [A1; A2; A3; A4; A5; A6; A7; A8];
    b = [b1; b2; b3; b4; b5; b6; b7; b8];
    eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7; eq8];
    model.vtype = vtype;
    model.obj = obj;
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    fprintf("starting: de-fragmenting sub-problem %i of %i\n",iSim,nSim);
    Sols2{iSim} = gurobi(model,struct('OutputFlag',0));
    Vars2{iSim} = Var2;
    fprintf("finished: de-fragmenting sub-problem %i of %i\n",iSim,nSim);

    if Sols2{iSim}.status == "INFEASIBLE"
        error("Model infeasible: Line 126");
    end

    % update uncontrolled loads to reflect new solution
    u = u + Sols2{iSim}.x(Var2.pt);

    % assign buses to chargers
    clear('model');

    Sim3 = util2.getSimParam(Sims2{iSim}, Vars2{iSim}, Sols2{iSim}.x);
    Sims3{iSim} = Sim3;
    Var3 = util2.getVarParam(Sim3);
    Vars3{iSim} = Var3;

    [A1, b1, nCon1, descr1, eq1] = con2.getCon1(Sim3,Var3);
    [A2, b2, nCon2, descr2, eq2] = con2.getCon2(Sim3,Var3);
    [A3, b3, nCon3, descr3, eq3] = con2.getCon3(Sim3,Var3);
    [A4, b4, nCon4, descr4, eq4] = con2.getCon4(Sim3,Var3);
    [A5, b5, nCon5, descr5, eq5] = con2.getCon5(Sim3,Var3);

    A = [A1; A2; A3; A4; A5];
    b = [b1; b2; b3; b4; b5];
    eq = [eq1; eq2; eq3; eq4; eq5];
    vtype = [Var3.bType; Var3.fType; Var3.lType; Var3.sigmaType; Var3.maxtype];
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    model.vtype = vtype;
    if useQuadraticLoss
        [Q, obj] = con2.getObj(Sim3,Var3);
        model.obj = obj;
        model.Q = Q;
    else
        obj = con2.getObj2(Sim3,Var3);
        model.obj = obj;
    end
    fprintf('started: scheduling routes for sub-set %i of %i\n',iSim,numel(Sims2));
    Sols3{iSim} = gurobi(model,struct('MIPGap',MIPGap,'OutputFlag',0,'DualReductions',0)); ...,'DualReductions',0));
        Vars2{iSim} = Var2;
    if Sols3{iSim}.status == "INFEASIBLE"
        fprintf("MODEL WAS INFEASIBLE, DO NOT PASS GO, DO NOT COLLECT 200 DOLLARS\n");
        return;
    end
    fprintf("finished: scheduling routes for sub-set %i of %i\n",iSim,numel(Sims2));
end


Sim4 = util4.getSimParam(Sim1,Var1,Sol1, Sims3,Vars3,Sols3,groups);
Var4 = util4.getVarParam(Sim3);
[A1, b1, nConst1, descr1, eq1] = con4.getCon1(Sim4, Var4);
[A2, b2, nConst2, descr2, eq2] = con4.getCon2(Sim4, Var4);
[A3, b3, nConst3, descr3, eq3] = con4.getCon3(Sim4, Var4);
[Q4, obj4] = con4.getObj(Sim4, Var4);

A = [A1;A2;A3;];
b = [b1;b2;b3;];
eq = [eq1;eq2;eq3;];
vtype = [Var4.scheduletype; Var4.allpowertype];
model.A = A;
model.rhs = b;
model.sense = eq;
model.vtype = vtype;
model.obj = obj4;
model.Q = Q4;
fprintf('begin variable charge problem\n');
sol4 = gurobi(model,struct('MIPGap',0.02,'OutputFlag',0));...,'OutputFlag',0,'DualReductions',0)); 
fprintf('Finished variable charge problem\n');
time = toc;

% compute results
plan.schedule = reshape(sol4.x(Var4.schedule),[Sim4.nBus,Sim4.nTime]);
plan.uncontrolled = Sim1.u;
opt.schedule = reshape(Sol1.x(Var1.b),[Sim1.nBus,Sim1.nTime]);
opt.uncontrolled = Sim1.u;
plan = computeResults(plan, Sim1);
opt = computeResults(opt, Sim1);
percentIncrease = (plan.cost - opt.cost)/opt.cost*100;
fprintf("Time: %0.2f, plan cost: %0.2f, opt cost: %0.2f, percent increase: %0.2f\n",time,plan.cost,opt.cost,percentIncrease);

% make plots
time = (0:Sim1.nTime - 1)/Sim1.nTime*24;
figure; plot(time,plan.avgPower); hold on; plot(time,opt.avgPower); legend('plan','optimal');
% xline(15*3600/Sim1.deltaTSec);
% xline(22*3500/Sim1.deltaTSec);

function plan = computeResults(plan, Sim)

% compute total power
busPower = squeeze(sum(plan.schedule,1));
power = busPower + Sim.u;

% compute on and off-peak energy
eOn = sum(power(Sim.S)*Sim.deltaTSec/3600);
eOff = sum(power(~Sim.S)*Sim.deltaTSec/3600);

% compute 15-minute average
nPerWindow = (60*15)/Sim.deltaTSec;
window = ones([1,nPerWindow])/nPerWindow;
avgPower = conv(power,window,'same');

% compute demand and facilities charges
mOn = max(avgPower(Sim.S));
iMOn = find(avgPower == mOn);
[mAll, iMAll] = max(avgPower);

% compute charges for a 30-day month
demand = mOn*Sim.muPOn;
facilities = mAll*Sim.muPAll;
consumptionOn = eOn*Sim.muEOn*30;
consumptionOff = eOff*Sim.muEOff*30;

% total cost
cost = demand + facilities + consumptionOn + consumptionOff;

% package for use
plan.busPower = busPower;
plan.allPower = power;
plan.avgPower = avgPower;
plan.onPeakEnergy = eOn;
plan.offPeakEnergy = eOff;
plan.onPeakMax = mOn;
plan.onPeakMaxIdx = iMOn;
plan.allMax = mAll;
plan.allMaxIdx = iMAll;
plan.charges.demand = demand;
plan.charges.facilities = facilities;
plan.charges.consumptionOn = consumptionOn;
plan.charges.consumptionOff = consumptionOff;
plan.cost = cost;
end

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
function groups = computeGroups(Sim, Var, x, nGroup, MIPGap)

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
sol = gurobi(model,struct('OutputFlag',0,'MIPGap',MIPGap)); ...struct('MIPGap',0.3));
fprintf("finished group separation problem\n");
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
groups.sol = sol;
end
