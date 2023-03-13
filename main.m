
nBus = 5; nCharger = 5; dt = 1*20; % one minute intervals
maxChargerPerBus = 16;
MIPGap = nBus/(nCharger*maxChargerPerBus);
useGurobi = true; makePlots = false; computePrimary = true; computeSecondary = true;
useQuadraticLoss = false;
nGroup = 1;
lossType = "fiscal"; %"fiscal", "baseline", "consumption"
tic; 
if computePrimary
    [Sim1, Var1, Sol1] = computeIdeal(nBus,nCharger,dt, lossType);
    [Sim2, Var2, Sol2] = computeSmooth(Sim1, Var1, Sol1);
    groups = computeGroups(Sim2,Var2,Sol2.x,nGroup,MIPGap);   
end

nSim = groups.nGroup;
Sims3 = util5.getAllSimParam(Sim2, Var2, Sol2.x, groups);
Sols3 = cell([nSim,1]);
Vars3 = cell([nSim,1]);
Sims4 = cell([nSim,1]);
Sols4 = cell([nSim,1]);
Vars4 = cell([nSim,1]);
u = Sim1.u;
for iSim = 1:numel(Sims3)
    clear('model');
    Sim3 = Sims3{iSim};
    Var3 = util5.getVarParam(Sim3);
    Sim3.u = u;

    [A1, b1, nCon1, descr1, eq1] = con5.getCon1(Sim3,Var3);
    [A2, b2, nCon2, descr2, eq2] = con5.getCon2(Sim3,Var3);
    [A3, b3, nCon3, descr3, eq3] = con5.getCon3(Sim3,Var3);
    [A4, b4, nCon4, descr4, eq4] = con5.getCon4(Sim3,Var3);
    [A5, b5, nCon5, descr5, eq5] = con5.getCon5(Sim3,Var3);
    [A6, b6, nCon6, descr6, eq6] = con5.getCon6(Sim3,Var3);
    [A7, b7, nCon7, descr7, eq7] = con5.getCon7(Sim3,Var3);
    [A8, b8, nCon8, descr8, eq8] = con5.getCon8(Sim3,Var3);
    [A9, b9, nCon9, descr9, eq9] = con5.getCon9(Sim3,Var3);
    [A10, b10, nCon10, descr10, eq10] = con5.getCon10(Sim3,Var3);
    obj = con5.getObj(Sim3,Var3);

    vtype = [Var3.bType; ...
        Var3.isUsedAndFragmentedType; ...
        Var3.ptType; ...
        Var3.p15Type; ...
        Var3.routeEnergyType; ...
        Var3.demandType; ...
        Var3.facilitiesType; ...
        Var3.eOnType; ...
        Var3.eOffType; ...
        Var3.hType;];
    A = [A1; A2; A3; A4; A5; A6; A7; A8; A9; A10];
    b = [b1; b2; b3; b4; b5; b6; b7; b8; b9; b10];
    eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7; eq8; eq9; eq10];
    model.vtype = vtype;
    model.obj = obj;
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    fprintf("starting: de-fragmenting sub-problem %i of %i\n",iSim,nSim);
    Sols3{iSim} = gurobi(model,struct('MIPGap',0.99,'OutputFlag',0));
    Vars3{iSim} = Var3;
    fprintf("finished: de-fragmenting sub-problem %i of %i\n",iSim,nSim);

    if Sols3{iSim}.status == "INFEASIBLE"
        error("Model infeasible: Line 126");
    end

    % update uncontrolled loads to reflect new solution
    u = u + sum(Sols3{iSim}.x(Var3.b),1);

    % assign buses to chargers
    clear('model');

    Sim4 = util2.getSimParam(Sims3{iSim}, Vars3{iSim}, Sols3{iSim}.x);
    Sims4{iSim} = Sim4;
    Var4 = util2.getVarParam(Sim4);
    Vars4{iSim} = Var4;

    [A1, b1, nCon1, descr1, eq1] = con2.getCon1(Sim4,Var4);
    [A2, b2, nCon2, descr2, eq2] = con2.getCon2(Sim4,Var4);
    [A3, b3, nCon3, descr3, eq3] = con2.getCon3(Sim4,Var4);
    [A4, b4, nCon4, descr4, eq4] = con2.getCon4(Sim4,Var4);
    [A5, b5, nCon5, descr5, eq5] = con2.getCon5(Sim4,Var4);

    A = [A1; A2; A3; A4; A5];
    b = [b1; b2; b3; b4; b5];
    eq = [eq1; eq2; eq3; eq4; eq5];
    vtype = [Var4.bType; Var4.fType; Var4.lType; Var4.sigmaType; Var4.maxtype];
    model.A = A;
    model.rhs = b;
    model.sense = eq;
    model.vtype = vtype;
    if useQuadraticLoss
        [Q, obj] = con2.getObj(Sim4,Var4);
        model.obj = obj;
        model.Q = Q;
    else
        obj = con2.getObj2(Sim4,Var4);
        model.obj = obj;
    end
    fprintf('started: scheduling routes for sub-set %i of %i\n',iSim,numel(Sims4));
    Sols4{iSim} = gurobi(model,struct('OutputFlag',1,'MIPGap',0.002,'DualReductions',0)); ...,'DualReductions',0));
        Vars3{iSim} = Var3;
    if Sols4{iSim}.status == "INFEASIBLE"
        fprintf("MODEL WAS INFEASIBLE, DO NOT PASS GO, DO NOT COLLECT 200 DOLLARS\n");
        return;
    end
    fprintf("finished: scheduling routes for sub-set %i of %i\n",iSim,numel(Sims3));
end


Sim5 = util4.getSimParam(Sim2,Var2,Sol2, Sims4,Vars4,Sols4,groups);
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
fprintf('begin variable charge problem\n');
Sol5 = gurobi(model,struct('MIPGap',0.002,'OutputFlag',0));...,'OutputFlag',0,'DualReductions',0)); 
fprintf('Finished variable charge problem\n');
time = toc;

% compute results
plan.schedule = reshape(Sol5.x(Var5.schedule),[Sim5.nBus,Sim5.nTime]);
plan.uncontrolled = Sim2.u;
opt.schedule = reshape(Sol2.x(Var2.b),[Sim2.nBus,Sim2.nTime]);
opt.uncontrolled = Sim2.u;
plan = computeResults(plan, Sim2);
opt = computeResults(opt, Sim2);
percentIncrease = (plan.cost - opt.cost)/opt.cost*100;
fprintf("Time: %0.2f, plan cost: %0.2f, opt cost: %0.2f, percent increase: %0.2f\n",time,plan.cost,opt.cost,percentIncrease);

% make plots
figure; plot(plan.avgPower); hold on; plot(opt.avgPower); legend('plan','optimal');
xline(15*3600/Sim2.deltaTSec);
xline(22*3500/Sim2.deltaTSec);

figure; imagesc(plan.schedule); title('planned schedule');
figure; imagesc(opt.schedule); title('optimal schedule');

function plan = computeResults(plan, Sim)

% compute total power
busPower = squeeze(sum(plan.schedule,1));
power = busPower + Sim.u;

% compute on and off-peak energy
eOn = sum(power(Sim.S)*Sim.deltaTSec/3600);
eOff = sum(power(~Sim.S)*Sim.deltaTSec/3600);

% compute 15-minute average
nPerWindow = (60*15)/Sim.deltaTSec;
nTime = size(plan.schedule,2);
avgPower = nan([nTime,1]);
for iTime = 1:nTime
    iStart = max(1,iTime - nPerWindow + 2);
    iFinal = iTime;
    avgPower(iTime) = mean(power(iStart:iFinal)); 
end

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
