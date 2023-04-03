

nBuses = [10]; ...ones([1,1])*8; ..., 20, 40, 60]; ... 18 18]; ...[20:20:80 9:18:80]; ...[10:10:80 10:10:80 10:10:80];...[120, 120, 10:10:80, 10:10:80, 9:9:81, ones([1,7])*12, 10:10:80];
nChargers = [7];...[7 7 7 7 7 7 7 7 7 7 7]; ... [ones(1,24)*20];...[7, 7, repmat(12,[1,32]) 10:10:80];
nGroups =  [ones(size(nBuses))]; ...[ones(1,4)*3, ones(1,8)*2, ones(1,8)*3]; ...1, 1, 1, 1, 1, 1, 1, 1];...[2, 3, ones([1,8])*1, ones([1,8])*2, ones([1,9])*3, ones([1,7]), ones([1,8])];
minEnergyPerSessions = [0 0 0 0 0 0 0 0 0 0 0]; ...45:5:80 45:5:80 45:5:80 45:5:80 45:5:80 45:5:80]; ...zeros([1,24]); ...[0,0,0,0,0,0,0,0]; ...[0, 0, 0, zeros([1,25]), 5:5:35, zeros([1,8])];
nRun = numel(nBuses);
tags = ["proCost","proCost","proCost","proCost","proCost","proCost","proCost","proCost","proCost","proCost","proCost"];...repmat("proCost",[numel(nBuses)/2,1]) repmat("proTime",[numel(nBuses)/2,1])];...,"proTime","proTime"];
lossTypes = ["fiscal","fiscal","fiscal","fiscal","fiscal","fiscal","fiscal","fiscal","fiscal","fiscal","fiscal"];
proCostGaps = [0.001]; ...repmat([0.0009]); , 0.0004 0.00035 0.0003 0.00025],[1,1]);
for iRun = 1:nRun
    tag = tags(iRun);
    nBus = nBuses(iRun);
    nCharger = nChargers(iRun);
    nGroup = nGroups(iRun);
    minEnergyPerSession = minEnergyPerSessions(iRun);
    dt = 1*20; % in seconds
    MIPGap = 0.99;
    proCostGap = proCostGaps(iRun);
    makePlots = false;
    computePrimary = false;
    computeSecondary = true;
    computePresmoothing = true;
    exportData = false;
    saveResults = true;
    lossType = lossTypes(iRun); ..."baseline"; %"fiscal", "baseline", "consumption"
    tic;
    if computePrimary
        % compute unconstrained solution
        fprintf("Starting: Unconstrained Solution\n");
        [Sim1, Var1, Sol1] = computeIdeal(nBus,nCharger,dt, lossType, minEnergyPerSession);
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
        timeUncontested = toc;
        % separate into groups
        if false; ...nGroup == 1
            groups.groupId = ones([nBus,1]);
            groups.nBus = nBus;
            groups.nCharger = nCharger;
            groups.nGroup = 1;
            groups.schedule = Sol2.x(Var2.b);
            Simg = struct();
            Varg = struct();
            Solg = struct();
        else
            fprintf("Started: Group Separation\n");
            [groups, Simg, Varg, Solg] = computeGroups(Sim2,Var2,Sol2.x,nGroup,MIPGap);
            fprintf("Finished: Group Separation\n");
        end
    end

    if computeSecondary
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
            if strcmp(tag,"proCost")
                [Sols4{iSim}, Vars4{iSim}] = computeBusAssignments(Sim4,'quadratic',proCostGap);
            else
                [Sols4{iSim}, Vars4{iSim}] = computeBusAssignments(Sim4);
            end
            fprintf("Finished: Charger Scheduling for sub-set %i of %i\n",iSim,numel(Sims3));
            
%         for iBus = 1:nBus
%             for iRoute = 1:Sims4{iSim}.nRoute(iBus)
%                 tArriveOpt = Sims4{1}.tStart(iBus,iRoute);
%                 tDepartOpt = Sims4{1}.tFinal(iBus,iRoute);
%                 tArrive = Sols4{1}.x(Vars4{1}.b(iBus,iRoute));
%                 tDepart = Sols4{1}.x(Vars4{1}.f(iBus,iRoute));
%                 fprintf('Diff tArrive: %0.2f Diff tDepart: %0.2f\n',tArriveOpt - tArrive, tDepartOpt - tDepart);            
%             end
%         end

            % compute charge intervals
            fprintf("Starting: Optimizing Schedule Window...\n");
            Sims5{iSim} = util7.getSimParam(Sims4{iSim}, Vars4{iSim}, Sols4{iSim});
            [Sols5{iSim}, Vars5{iSim}] = computeChargeIntervals(Sims5{iSim});
            fprintf("Finished: Optimizing Schedule Window\n")

            % apply optimized start/stop times to schedule from solution 4
            Sols4{iSim} = applyScheduleTimes(Sols4{iSim}, Vars4{iSim}, Sims4{iSim}, ...
                Sols5{iSim}, Vars5{iSim}, Sims5{iSim});

%             for iBus = 1:nBus
%                 for iRoute = 1:Sims4{iSim}.nRoute(iBus)
%                     tArriveOpt = Sims4{1}.tStart(iBus,iRoute);
%                     tDepartOpt = Sims4{1}.tFinal(iBus,iRoute);
%                     tArrive = Sols4{1}.x(Vars4{1}.b(iBus,iRoute));
%                     tDepart = Sols4{1}.x(Vars4{1}.f(iBus,iRoute));
%                     fprintf('Diff tArrive: %0.2f Diff tDepart: %0.2f\n',tArriveOpt - tArrive, tDepartOpt - tDepart);
%                 end
%             end
        end

        % fine tune step-by-step power use
        fprintf('Starting: Variable Charge Rates\n');
        Sim6 = util4.getSimParam(Sim2,Var2,Sol2, Sims4,Vars4,Sols4,groups);        
        Sim6.optSim = Sim2; % for debugging
        [Sol6, Var6] = computeReOptimizedSolution(Sim6, lossType);
        fprintf('Finished: Variable Charge Rates\n');

        % add smoothing for hardware 
        fprintf('Starting: Post-Smoothing\n');
        Sim7 = util8.getSimParam(Sim6, Var6, Sol6);
        [Sol7, Var7] = computeSmoothReOptimization(Sim7);
        fprintf('Finished: Post-Smoothing.\n');

%         power2 = Sol2.x(Var2.b);
%         power7 = Sol7.x(Var7.schedule);
%         for iBus = 1:nBus
%             for iRoute = 1:Sim3.nRoute(iBus)
%                 c = squeeze(Sim3.canCharge(iBus,iRoute,:));
%                 energy2 = squeeze(power2(iBus,:))*c*dt/3600;
%                 energy3 = squeeze(power7(iBus,:))*c*dt/3600;
%                 fprintf('diff: %0.2f\n',energy2 - energy3);
%             end
%         end
    end

    % compute results
    time = toc;
    plan.schedule = reshape(Sol7.x(Var7.schedule),[Sim7.nBus,Sim7.nTime]);
    plan.uncontrolled = Sim2.u;
    opt.schedule = reshape(Sol2.x(Var2.b),[Sim2.nBus,Sim2.nTime]);
    opt.uncontrolled = Sim2.u;
    plan = computeResults(plan, Sim2);
    opt = computeResults(opt, Sim2);
    percentIncrease = (plan.cost - opt.cost)/opt.cost*100;
    dem = plan.charges.demand;
    fac = plan.charges.facilities;
    enr = plan.charges.consumptionOff + plan.charges.consumptionOn;
    gap = Sols4{1}.mipgap;
    fprintf("Time: %0.2f, plan cost: %0.2f, opt cost: %0.2f, percent increase: %0.2f plan demand: %0.2f plan facilities: %0.2f plan energy: %0.2f time uncontested: %0.2f sol4 gap: %0.2f\n",time,plan.cost,opt.cost,percentIncrease,dem,fac,enr, timeUncontested, gap*100);

    %% export for plots

    if exportData
        nResample = 96*2;
        decimateBy = Sim1.nTime/nResample;
        secInDay = 3600*24;

        % compute times
        datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
        times = datetime(2021,8,23);
        offset = seconds((0:nResample - 1)/nResample*3600*24);
        times = times + offset; times = times(:);

        % resample data
        secPerSample = secInDay/nResample;
        sStart = seconds(15*3600);
        sFinal = seconds(22*3600);
        isOnPeak = (offset >= sStart) & (offset <= sFinal);
        allPower = plan.avgPower(1:decimateBy:end)';
        allBus = plan.avgBusPower(1:decimateBy:end)';
        load = plan.avgLoadPower(1:decimateBy:end)';
        allOnPeak = allPower.*isOnPeak;
        [maxAllVal, maxAllIdx] = max(allPower);
        [onPeakVal, onPeakIdx] = max(allOnPeak);
        if maxAllIdx == onPeakIdx
            maxAllIdx = maxAllIdx - 1;
            onPeakIdx = onPeakIdx + 1;
        end

        % format power values
        data1 = zeros([numel(times),4]);
        data1(:,1) = allOnPeak;
        data1(:,2) = allPower;
        data1(maxAllIdx,3) = maxAllVal;
        data1(onPeakIdx,4) = onPeakVal;

        % format as table
        headers = {'onPeakOut','facilitiesOut','maxFacilitiesOut','maxOnPeakOut'};
        dataTable1 = array2table(data1);
        dataTable1.Properties.VariableNames = headers;
        dataTable1.time = string(times);

        % save table
        saveDir = "\\wsl.localhost\Ubuntu\home\dmortensen\paper4\documentation\media\11_results\";
        saveLoc1 = fullfile(saveDir,"totalPower" + lossType + "proTime.csv");
        writetable(dataTable1,saveLoc1);

        % format bus and uncontrolled load power
        data2 = zeros([numel(times),2]);
        data2(:,1) = allBus;
        data2(:,2) = load;

        % format as table
        headers  = {'meanBusPower','loadPower'};
        dataTable2 = array2table(data2);
        dataTable2.Properties.VariableNames = headers;
        dataTable2.time = times;

        % save table
        saveLoc2 = fullfile(saveDir,'powerPlot' + lossType + ".csv");
        writetable(dataTable2,saveLoc2);
    end

    if saveResults
        saveDir = '\\wsl.localhost\ubuntu\home\dmortensen\paper4\results';
        name = sprintf("LossType_%s_nBus_%i_nCharger_%i_nGroup_%i_dt_%i_minEnergy_%0.2f_%s_proCostGap_%f.mat",lossType,nBus,nCharger, nGroup, dt,minEnergyPerSession,tag,proCostGap);
        saveLoc = fullfile(saveDir,name);
        save(saveLoc,"Sim1","Var1","Sol1",...
            "Sim2","Var2","Sol2","groups","Simg","Varg","Solg",...
            "Sims3","Vars3","Sols3","Sims4","Vars4","Sols4",...
            "Sims5","Vars5","Sols5","Sim6","Var6","Sol6","Sim7","Var7","Sol7",...
            "time","plan","opt","timeUncontested");
    end
    fprintf("percent complete: %0.2f\n",iRun/nRun*100);
end



% format power plots with total load for 

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
avgBusPower = nan([nTime,1]);
avgLoadPower =nan([nTime,1]);
for iTime = 1:nTime
    s = 0;
    b = 0;
    l = 0;
    for iWindow = -nPerWindow + 1:0
        idx = mod(iWindow + iTime, nTime) + 1;
        s = s + power(idx);
        b = b + busPower(idx);
        l = l + Sim.u(idx);
    end
    avgPower(iTime) = s/nPerWindow;  
    avgBusPower(iTime) = b/nPerWindow;
    avgLoadPower(iTime) = l/nPerWindow;
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
plan.avgBusPower = avgBusPower;
plan.avgLoadPower = avgLoadPower;
end


