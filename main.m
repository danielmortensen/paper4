
nBus = 4; nCharger = 2; dt = 1*20; % one minute intervals
maxChargerPerBus = 16;
MIPGap = 0.99; ...nBus/(nCharger*maxChargerPerBus);
useGurobi = true; makePlots = false; computePrimary = true; computeSecondary = true;
useQuadraticLoss = false;
nGroup = 2;
lossType = "fiscal"; %"fiscal", "baseline", "consumption"
tic; 
if computePrimary
    [Sim1, Var1, Sol1] = computeIdeal(nBus,nCharger,dt, lossType);
    [Sim2, Var2, Sol2] = computeSmooth(Sim1, Var1, Sol1);
    groups = computeGroups(Sim2,Var2,Sol2.x,nGroup,MIPGap);   
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
    [A9, b9, nCon9, descr9, eq9] = con5.getCon9(Sim2,Var2);
    [A10, b10, nCon10, descr10, eq10] = con5.getCon10(Sim2,Var2);
    obj = con5.getObj(Sim2,Var2);

    vtype = [Var2.bType; ...
        Var2.isUsedAndFragmentedType; ...
        Var2.ptType; ...
        Var2.p15Type; ...
        Var2.routeEnergyType; ...
        Var2.demandType; ...
        Var2.facilitiesType; ...
        Var2.eOnType; ...
        Var2.eOffType; ...
        Var2.hType;];
    A = [A1; A2; A3; A4; A5; A6; A7; A8; A9; A10];
    b = [b1; b2; b3; b4; b5; b6; b7; b8; b9; b10];
    eq = [eq1; eq2; eq3; eq4; eq5; eq6; eq7; eq8; eq9; eq10];
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
Var4 = util4.getVarParam(Sim4);
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
figure; plot(plan.avgPower); hold on; plot(opt.avgPower); legend('plan','optimal');
xline(15*3600/Sim1.deltaTSec);
xline(22*3500/Sim1.deltaTSec);

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
