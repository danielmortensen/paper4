nBus = 55; nCharger = 5; dt = 1*60; % one minute intervals
useGurobi = true; makePlots = false; computePrimary = true;
tic; 
if computePrimary
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
    obj1 = con.getObj1(Sim, Var);
    obj2 = con.getObj2(Sim, Var);

    % concatenate each constraint
    Ain = [A1; A3; A7; A8; A10];
    bin = [b1; b3; b7; b8; b10];
    Aeq = [A2; A4; A5; A6; A9; A11];
    beq = [b2; b4; b5; b6; b9; b11];
    A = [Ain; Aeq];
    b = [bin; beq];
    nCon = nCon1 + nCon2 + nCon3 + nCon4 + nCon5 + nCon6 + nCon7 + nCon8 + nCon9 + nCon10 + nCon11;
    eq = [eq1; eq3; eq7; eq8; eq10; eq2; eq4; eq5; eq6; eq9; eq11];

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
        sol = gurobi(model);...,struct('DualReductions',0,'iisRequest',1));
    else
        sol = struct();
        tic;
        sol.x = linprog(obj,Ain,bin,Aeq,beq);
        t = toc
    end

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
end

Sim2 = util2.getSimParam(Sim, Var, sol.x);
Var2 = util2.getVarParam(Sim2);
[A1, b1, nCon1, descr1, eq1] = con2.getCon1(Sim2,Var2);
[A2, b2, nCon2, descr2, eq2] = con2.getCon2(Sim2,Var2);
[A3, b3, nCon3, descr3, eq3] = con2.getCon3(Sim2,Var2);
[A4, b4, nCon4, descr4, eq4] = con2.getCon4(Sim2,Var2);
obj = con2.getObj(Sim2,Var2);

A = [A1; A2; A3; A4];
b = [b1; b2; b3; b4];
eq = [eq1; eq2; eq3; eq4];
vtype = [Var2.bType; Var2.fType; Var2.lType; Var2.sigmaType];
model.A = A;
model.rhs = b;
model.sense = eq;
model.obj = obj;
model.vtype = vtype;
sol = gurobi(model);
time = toc

if 0
% extract to sessions
sessions = nan([sum(Sim.nRoute),6]);
iSession = 1;
ENERGY_IDX = 1;IARRIVE_IDX = 2;IDEPART_IDX = 3;IMIN_DEPART_IDX = 4;
MIN_WIDTH_IDX = 5; IMAX_START_IDX = 6; MAX_WIDTH_IDX = 7;
for iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        iArrive = ceil(Sim.tArrive(iBus,iRoute)/Sim.deltaTSec) + 1;
        iDepart = floor(Sim.tDepart(iBus,iRoute)/Sim.deltaTSec);
        ib = Var.b;
        chargeRates = sol.x(ib(iBus,iArrive:iDepart));
        if any(chargeRates ~= 0)
            sessions(iSession,ENERGY_IDX) = sum(chargeRates)*Sim.deltaTSec/3600;
            sessions(iSession,IARRIVE_IDX) = iArrive;
            sessions(iSession,IDEPART_IDX) = iDepart;
            minSessTimeSEC = (sessions(iSession,ENERGY_IDX)/Sim.pMaxKW)*3600;
            sessions(iSession,MIN_WIDTH_IDX) = ceil(minSessTimeSEC/Sim.deltaTSec);
            sessions(iSession,IMIN_DEPART_IDX) = iArrive + sessions(iSession,MIN_WIDTH_IDX); 
            sessions(iSession,IMAX_START_IDX) = iDepart - sessions(iSession,MIN_WIDTH_IDX) + 1;
            iSession = iSession + 1;
        end
    end
end
sessions = sessions(1:iSession - 1,:);
temp = sortrows(sessions,[IMAX_START_IDX, IMIN_DEPART_IDX]);

% initialize charger queues
START_IDX = 1; STOP_IDX = 2; POWER_IDX = 3;
chargerQueue = nan([sum(Sim.nRoute),Sim.nCharger,6]);
queuePosIdx = ones([1,Sim.nCharger]);

% assign sessions to chargers
for iSession = 1:size(sessions,1)
    session = sessions(iSession,:);
    overlap = inf;
    bestCharger = nan;
    for iCharger = 1:Sim.nCharger
        if hasNoEntries(chargerQueue, iCharger)
            curOverlap = 0;
        else
            % check if we can schedule on this charger
            prevSession = chargerQueue(queuePosIdx(iCharger) - 1,iCharger,:);
            prevSession = squeeze(prevSession);

            % we can schedule if the min. end time is less than or equal to
            % the maximum start time of this session
            minFinalTime = prevSession(IMIN_DEPART_IDX);
            maxStartTime = session(IMAX_START_IDX);
            if minFinalTime < maxStartTime
                startIdx1 = prevSession(IARRIVE_IDX);
                startIdx2 = session(IARRIVE_IDX);
                finalIdx1 = prevSession(IDEPART_IDX);
                finalIdx2 = session(IDEPART_IDX);
                diff1 = finalIdx1 - startIdx2;
                diff2 = finalIdx2 - startIdx1;
                curOverlap = min([diff1, diff2]);                
            else
                curOverlap = inf;
            end            
        end
        if overlap < 0 && curOverlap < 0 && curOverlap > overlap
            overlap = curOverlap;
            bestCharger = iCharger;
        elseif overlap > curOverlap
            overlap = curOverlap;
            bestCharger = iCharger;
        end       
    end

    % need to adjust the session so that it butts up against the previous
    % session
    if queuePosIdx(bestCharger) > 1
        prevDepart = chargerQueue(queuePosIdx(bestCharger) - 1,bestCharger,IDEPART_IDX);
        currArrive = session(IARRIVE_IDX);
        prevDepart = min(prevDepart, currArrive);
        chargerQueue(queuePosIdx(bestCharger) - 1, bestCharger, IDEPART_IDX) = prevDepart;
    end
    chargerQueue(queuePosIdx(bestCharger),bestCharger,:) = session;
    queuePosIdx(bestCharger) = queuePosIdx(bestCharger) + 1;    
end
end

% initialize charger queues
function value = hasNoEntries(chargerQueue, iCharger)
    value = all(isnan(chargerQueue(1,iCharger,:)));
end