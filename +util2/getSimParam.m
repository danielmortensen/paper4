function Param = getSimParam(Sim, Var, x)
% need arrival and departure times for each session (in seconds)
iArrive = Sim.iArrive;
iDepart = Sim.iDepart;
tArrive = (iArrive - 1)*Sim.deltaTSec;
tDepart = iDepart*Sim.deltaTSec;
tStart = nan([Sim.nBus,max(Sim.nRoute)]);
tFinal = nan([Sim.nBus,max(Sim.nRoute)]);
mWidth = nan([Sim.nBus,max(Sim.nRoute)]);
minTimePerSession = 0;
for iBus = 1:Sim.nBus
    counter = 1;
    for iRoute = 1:Sim.nRoute(iBus)
        charge = sum(x(Var.b(iBus,iArrive(iBus,iRoute):iDepart(iBus,iRoute))),'all');
        if ~(charge == 0)
            energy = sum(charge)*Sim.deltaTSec/3600;
            tStart(iBus,counter) = tArrive(iBus,iRoute);
            tFinal(iBus,counter) = tDepart(iBus,iRoute);
            mWidth(iBus,counter) = max(minTimePerSession,energy/Sim.pMax*3600);
            iArrive(iBus,counter) = iArrive(iBus,iRoute);
            iDepart(iBus,counter) = iDepart(iBus,iRoute);
            counter = counter + 1;
        end
    end
    Sim.nRoute(iBus) = counter - 1;
    iArrive(iBus,counter:end) = nan;
    iDepart(iBus,counter:end) = nan;
end

% identify which routes may conflict
mayConflict = nan([Sim.nBus,max(Sim.nRoute),Sim.nBus,max(Sim.nRoute)]);
for iBus1 = 1:Sim.nBus
    mayConflict(iBus1,:,iBus1,:) = false;
    for iBus2 = iBus1 + 1:Sim.nBus        
        for iRoute1 = 1:Sim.nRoute(iBus1)   
            for iRoute2 = 1:Sim.nRoute(iBus2)
                iArrive1 = tStart(iBus1,iRoute1);
                iArrive2 = tStart(iBus2,iRoute2);
                iDepart1 = tFinal(iBus1,iRoute1);
                iDepart2 = tFinal(iBus2,iRoute2);
                if iArrive1 < iArrive2
                    if iArrive2 <= iDepart1
                        mayConflict(iBus1,iRoute1,iBus2,iRoute2) = true;
                        mayConflict(iBus2,iRoute2,iBus1,iRoute1) = true;
                    else
                        mayConflict(iBus1,iRoute1,iBus2,iRoute2) = false;
                        mayConflict(iBus2,iRoute2,iBus1,iRoute1) = false;
                    end
                elseif iArrive1 > iArrive2
                    if iArrive1 <= iDepart2
                        mayConflict(iBus1,iRoute1,iBus2,iRoute2) = true;
                        mayConflict(iBus2,iRoute2,iBus1,iRoute1) = true;
                    else
                        mayConflict(iBus1,iRoute1,iBus2,iRoute2) = false;
                        mayConflict(iBus2,iRoute2,iBus1,iRoute1) = false;
                    end
                else
                    mayConflict(iBus1,iRoute1,iBus2,iRoute2) = true;
                    mayConflict(iBus2,iRoute2,iBus1,iRoute1) = true;
                end
            end
        end
    end
end
Param.tStart = tStart;
Param.tFinal = tFinal;
Param.mWidth = mWidth;
Param.nCharger = Sim.nCharger;
Param.nRoute = Sim.nRoute;
Param.mayConflict = mayConflict;
Param.nMayConflict = sum(mayConflict(:),'omitnan')/2;
Param.nBus = Sim.nBus;
Param.minBusChargeTime = Sim.minEnergyPerSess/Sim.pMax*3600;
Param.busId = Sim.busId;
Param.nTime = Sim.nTime;
end

