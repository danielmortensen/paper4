function Sims = getAllSimParam(Sim1, Var1, x, groups, minEnergyPerSess)
    
nTime = size(groups.schedule,2);
idx = 1:Sim1.nBus;
Sims = cell([groups.nGroup,1]);
for iGroup = 1:groups.nGroup
    isInGroup = groups.groupId == iGroup;
    schedule = reshape(x(Var1.b(isInGroup,:)),[groups.nBus(iGroup), nTime]);
   
    busIds = idx(isInGroup);
    nMaxRoute = max(Sim1.nRoute(isInGroup));
   
    nBusInGroup = numel(busIds);
    iSessArr = nan([nBusInGroup,nMaxRoute]);
    iSessDep = nan([nBusInGroup,max(Sim1.nRoute(isInGroup))]);
    sessE = nan([nBusInGroup,max(Sim1.nRoute(isInGroup))]);
    canCharge = zeros([nBusInGroup, nMaxRoute, Sim1.nTime]);
    totalBusEnergy = zeros([1,nBusInGroup]);
    sessStatus = repmat("NaN",[nBusInGroup,max(Sim1.nRoute(isInGroup))]);
    nRoute = Sim1.nRoute(busIds);
    for iBus = 1:nBusInGroup
        for iRoute = 1:nRoute(iBus)
            tArrive = Sim1.tArrive(busIds(iBus),iRoute);
            tDepart = Sim1.tDepart(busIds(iBus),iRoute);
            iArrive = floor(tArrive/Sim1.deltaTSec) + 1;
            iDepart = ceil(tDepart/Sim1.deltaTSec);

            % store indices for arrival and departure
            iSessArr(iBus,iRoute) = iArrive;
            iSessDep(iBus,iRoute) = iDepart;

            % binary vector indicating when a bus can charge
            canCharge(iBus,iRoute,iArrive:iDepart) = 1;

            % get energy for this session
            energy = sum(schedule(iBus,iArrive:iDepart))*Sim1.deltaTSec/3600;
            totalBusEnergy(iBus) = totalBusEnergy(iBus) + energy;

            if energy >= minEnergyPerSess
                sessE(iBus,iRoute) = energy;
                sessStatus(iBus,iRoute) = "USED";
            elseif energy > 0
                sessStatus(iBus,iRoute) = "FRAGMENTED";
                sessE(iBus,iRoute) = energy;
            else
                sessE(iBus,iRoute) = 0;
                sessStatus(iBus,iRoute) = "UNUSED";
            end
        end
    end
    Sims{iGroup}.iArrive = iSessArr;
    Sims{iGroup}.iDepart = iSessDep;
    Sims{iGroup}.canCharge = canCharge;
    Sims{iGroup}.totalBusEnergy = totalBusEnergy;
    Sims{iGroup}.sessStatus = sessStatus;
    Sims{iGroup}.energyInSession = sessE;
    Sims{iGroup}.minEnergyPerSess = minEnergyPerSess;
    Sims{iGroup}.nTime = Sim1.nTime;
    Sims{iGroup}.nBus = nBusInGroup;
    Sims{iGroup}.busId = busIds;
    Sims{iGroup}.nRoute = nRoute;
    Sims{iGroup}.u = Sim1.u;
    Sims{iGroup}.muPOn = Sim1.muPOn;
    Sims{iGroup}.muPAll = Sim1.muPAll;
    Sims{iGroup}.muEOn = Sim1.muEOn;
    Sims{iGroup}.muEOff = Sim1.muEOff;   
    Sims{iGroup}.deltaTSec = Sim1.deltaTSec;
    Sims{iGroup}.schedule = groups.schedule(busIds,:);
    Sims{iGroup}.hMax = Sim1.hMaxKWH;
    Sims{iGroup}.pMax = Sim1.pMaxKW;
    Sims{iGroup}.pMaxDelta = Sim1.pMaxDelta;
    Sims{iGroup}.S = Sim1.S;
    Sims{iGroup}.nCharger = groups.nCharger(iGroup);
    Sims{iGroup}.delta = Sim1.delta(busIds,:);
    Sims{iGroup}.hMin = Sim1.hMin;
    Sims{iGroup}.h0 = Sim1.eta;
end
end