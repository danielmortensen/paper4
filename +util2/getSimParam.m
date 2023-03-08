function Param = getSimParam(Sim, Var, x)
% need arrival and departure times for each session (in seconds)
iArrive = ceil(Sim.tArrive/Sim.deltaTSec) + 1;
iDepart = floor(Sim.tDepart/Sim.deltaTSec);
tStart = nan([Sim.nBus,max(Sim.nRoute)]);
tFinal = nan([Sim.nBus,max(Sim.nRoute)]);
mWidth = nan([Sim.nBus,max(Sim.nRoute)]);
for iBus = 1:Sim.nBus
    counter = 1;    
    busId = Sim.busId(iBus);
    for iRoute = 1:Sim.nRoute(iBus)
        charge = x(Var.b(busId,iArrive(iBus,iRoute):iDepart(iBus,iRoute)));
        iCharge = charge ~= 0;
        iStart = find(iCharge, 1, 'first') + iArrive(iBus,iRoute) - 1;
        iFinal = find(iCharge, 1, 'last') + iArrive(iBus,iRoute) - 1;
        if ~isempty(iStart)
            energy = sum(charge)*Sim.deltaTSec/3600;
            tStart(iBus,counter) = (iStart - 1)*Sim.deltaTSec;
            tFinal(iBus,counter) = (iFinal - 1)*Sim.deltaTSec;
            mWidth(iBus,counter) = energy/Sim.pMaxKW*3600;
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

