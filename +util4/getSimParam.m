function Param = getSimParam(Sim1, Var1, Sol1, Sims2, Vars2, Sols2, groups)
nTime = Sim1.nTime;
nBus = Sim1.nBus;
nGroup = groups.nGroup;
pMaxKW = Sim1.pMaxKW;
deltaTSec = Sim1.deltaTSec;

schedule = reshape(Sol1.x(Var1.b),[nBus,nTime]);

% put second simulation variables back together
nMaxRoute = 0;
nAllRoute = 0;
for iSim = 1:nGroup
    nAllRoute = nAllRoute + sum(Sims2{iSim}.nRoute);
    nMaxRoute = max([nMaxRoute; Sims2{iSim}.nRoute(:)]);
end

routeIdx = nan([nBus,nMaxRoute,nTime]);
energy = nan([nBus,nMaxRoute]);
nRoute = nan([1,nBus]);
chargerIdx = nan([nBus,nMaxRoute]);
nPrevCharger = 0;
for iSim = 1:nGroup
    Sim = Sims2{iSim};
    Var = Vars2{iSim};
    Sol = Sols2{iSim}.x;    
    for iBus = 1:Sim.nBus
        busIdx = Sim.busId(iBus);
        nBusRoute = Sim.nRoute(iBus);
        for iRoute = 1:nBusRoute
            tStart = Sol(Var.b(iBus,iRoute));
            tFinal = Sol(Var.f(iBus,iRoute));
            tStart = max(tStart,Sims2{iSim}.tStart(iBus,iRoute));
            tFinal = min(tFinal,Sims2{iSim}.tFinal(iBus,iRoute));
            iArrive = floor(tStart/deltaTSec) + 1;
            iDepart = min(ceil(tFinal/deltaTSec),Sim1.nTime);           
            routeIdx(busIdx,iRoute,:) = 0;
            routeIdx(busIdx,iRoute,iArrive:iDepart) = 1;
            energy(busIdx, iRoute) = Sim.mWidth(iBus,iRoute)*pMaxKW/3600;
            chargerIdx(busIdx,iRoute) = nPrevCharger + find(round(Sol(Var.sigma(iBus,iRoute,:))));            
        end
        nRoute(busIdx) = nBusRoute;
    end
    nPrevCharger = nPrevCharger + groups.nCharger(iSim);
end

Param.isOnPeak = Sim1.S;
Param.deltaTSec = Sim1.deltaTSec;
Param.muEOn = Sim1.muEOn;
Param.muEOff = Sim1.muEOff;
Param.muPOn = Sim1.muPOn;
Param.muPAll = Sim1.muPAll;
Param.optProfile = sum(schedule,1);
Param.chargerIdx = chargerIdx;
Param.routeIdx = routeIdx;
Param.energy = energy;
Param.nSession = nRoute;
Param.nTime = nTime;
Param.nBus = nBus;
Param.pMaxKW = pMaxKW;
Param.deltaTSec = deltaTSec;
Param.u = Sim1.u;
Param.optSol = Sol1.x;
Param.optVar = Var1;
Param.optAvail = Sim1.alpha;
end