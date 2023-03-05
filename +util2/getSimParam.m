function Param = getSimParam(Sim, Var, x)
% need arrival and departure times for each session (in seconds)
iArrive = ceil(Sim.tArrive/Sim.deltaTSec) + 1;
iDepart = floor(Sim.tDepart/Sim.deltaTSec);
tStart = nan([Sim.nBus,max(Sim.nRoute)]);
tFinal = nan([Sim.nBus,max(Sim.nRoute)]);
mWidth = nan([Sim.nBus,max(Sim.nRoute)]);
for iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        charge = x(Var.b(iBus,iArrive:iDepart));
        iCharge = charge ~= 0;
        iStart = find(iCharge, 1, 'first');
        iFinal = find(iCharge, 1, 'last');
        energy = sum(charge)*Sim.deltaTSec/3600;
        tStart(iBus,iRoute) = (iStart - 1)*Sim.deltaTSec;
        tFinal(iBus,iRoute) = (iFinal - 1)*Sim.deltaTSec;
        mWidth(iBus,iRoute) = energy/Sim.pMaxKW*3600;
    end
end

% identify which routes may conflict
mayConflict = nan([Sim.nBus,max(Sim.nRoute),Sim.nBus,max(Sim.nRoute)]);
for iBus1 = 1:Sim.nBus
    mayConflict(iBus1,:,iBus1,:) = false;
    for iBus2 = iBus1 + 1:Sim.nBus        
        for iRoute1 = 1:Sim.nRoute(iBus1)   
            for iRoute2 = 1:Sim.nRoute(iBus2)
                iArrive1 = iArrive(iBus1,iRoute1);
                iArrive2 = iArrive(iBus2,iRoute2);
                iDepart1 = iDepart(iBus1,iRoute1);
                iDepart2 = iDepart(iBus2,iRoute2);
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
end

