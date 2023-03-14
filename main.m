
nBus = 120; nCharger = 4; dt = 1*20; % one minute intervals
MIPGap = 0.99;
useGurobi = true; makePlots = false; computePrimary = true; computeSecondary = true; computePresmoothing = true;
nGroup = 2;
lossType = "fiscal"; %"fiscal", "baseline", "consumption"
tic; 
if computePrimary
    % compute unconstrained solution
    fprintf("Starting: Unconstrained Solution\n");
    [Sim1, Var1, Sol1] = computeIdeal(nBus,nCharger,dt, lossType);
    fprintf("Finished: Unconstrained Solution\n");
    
    % smooth preliminary results
    if computePresmoothing
        % compute smoothed version of unconstrained solution
        fprintf("Starting: Pre-Smoothing\n");
        [Sim2, Var2, Sol2] = computeSmooth(Sim1, Var1, Sol1);
        fprintf("Finished: Pre-Smoothing\n");
    else
        Sim2 = Sim1;
        Var2 = Var1;
        Sol2 = Sol1;
    end
    
    % separate into groups
    if nGroup == 1
        groups.groupId = ones([nBus,1]);
        groups.nBus = nBus;
        groups.nCharger = nCharger;
        groups.nGroup = 1;
        groups.schedule = Sol2.x(Var2.b);
    else
        fprintf("Started: Group Separation\n");
        groups = computeGroups(Sim2,Var2,Sol2.x,nGroup,MIPGap);
        fprintf("Finished: Group Separation\n");
    end
end

% prepare loop variables
nSim = groups.nGroup;
Sims3 = util5.getAllSimParam(Sim2, Var2, Sol2.x, groups);
Sols3 = cell([nSim,1]);
Vars3 = cell([nSim,1]);
Sims4 = cell([nSim,1]);
Sols4 = cell([nSim,1]);
Vars4 = cell([nSim,1]);
Sims5 = cell([nSim,1]);
Sols5 = cell([nSim,1]);
Vars5 = cell([nSim,1]);
u = Sim1.u;
for iSim = 1:numel(Sims3)

    % Defragment charge schedule
    Sim3 = Sims3{iSim}; Sim3.u = u;
    fprintf("Starting: de-fragmenting sub-problem %i of %i\n",iSim,nSim);
    [Sols3{iSim}, Vars3{iSim}] = computeDefragmentedSolution(Sim3);
    fprintf("Finished: de-fragmenting sub-problem %i of %i\n",iSim,nSim);

    % update uncontrolled loads to reflect new solution
    u = u + sum(Sols3{iSim}.x(Vars3{iSim}.b),1);

    % assign buses to chargers
    Sim4 = util2.getSimParam(Sims3{iSim}, Vars3{iSim}, Sols3{iSim}.x);
    Sims4{iSim} = Sim4;
    fprintf("Starting: Charger Scheduling for sub-set %i of %i\n",iSim,numel(Sims3));
    [Sols4{iSim}, Vars4{iSim}] = computeBusAssignments(Sim4);
    fprintf("Finished: Charger Scheduling for sub-set %i of %i\n",iSim,numel(Sims3));

    % compute charge intervals
    fprintf("Starting: Optimizing Schedule Window...\n");
    Sims5{iSim} = util7.getSimParam(Sims4{iSim}, Vars4{iSim}, Sols4{iSim});
    [Sols5{iSim}, Vars5{iSim}] = computeChargeIntervals(Sims5{iSim});
    fprintf("Finished: Optimizing Schedule Window\n")

  

    % apply optimized start/stop times to schedule from solution 4
    Sols4{iSim} = applyScheduleTimes(Sols4{iSim}, Vars4{iSim}, Sims4{iSim}, ...
        Sols5{iSim}, Vars5{iSim}, Sims5{iSim});
end

% fine tune step-by-step power use
fprintf('Starting: Variable Charge Rates\n');
Sim5 = util4.getSimParam(Sim2,Var2,Sol2, Sims4,Vars4,Sols4,groups);
[Sol5, Var5] = computeReOptimizedSolution(Sim5);
fprintf('Finished: Variable Charge Rates\n');

% add smoothing for hardware ;)
fprintf('Starting: Post-Smoothing\n');
Sim6 = util8.getSimParam(Sim5, Var5, Sol5); 
[Sol6, Var6] = computeSmoothReOptimization(Sim6);
fprintf('Finished: Post-Smoothing.\n');

% compute results
time = toc;
plan.schedule = reshape(Sol6.x(Var6.schedule),[Sim6.nBus,Sim6.nTime]);
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
figure; imagesc(opt.schedule); title('preliminary schedule');
figure; imagesc(plan.schedule); title('planned schedule');

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
    s = 0;
    for iWindow = -nPerWindow + 1:0
        idx = mod(iWindow + iTime, nTime) + 1;
        s = s + power(idx);
    end
    avgPower(iTime) = s/nPerWindow;    
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

