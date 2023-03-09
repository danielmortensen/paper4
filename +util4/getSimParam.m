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
    nMaxRoute = max(nMaxRoute,sum(Sims2{iSim}.nRoute));
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
            iArrive = floor(tStart/deltaTSec) + 1;
            iDepart = ceil(tFinal/deltaTSec);
            routeIdx(busIdx,iRoute,:) = 0;
            routeIdx(busIdx,iRoute,iArrive:iDepart) = 1;
            energy(busIdx, iRoute) = Sim.mWidth(iBus,iRoute)*pMaxKW/3600;
            chargerIdx(busIdx,iRoute) = nPrevCharger + find(Sol(Var.sigma(iBus,iRoute,:)));
            
        end
        nRoute(busIdx) = nBusRoute;
    end
    nPrevCharger = nPrevCharger + groups.nCharger(iSim);
end

Param.optSchedule = schedule;
Param.optProfile = sum(schedule,1);
Param.chargerIdx = chargerIdx;
Param.routeIdx = routeIdx;
Param.energy = energy;
Param.nSession = nRoute;
Param.nTime = nTime;
Param.nBus = nBus;
Param.pMaxKW = pMaxKW;
Param.deltaTSec = deltaTSec;
end