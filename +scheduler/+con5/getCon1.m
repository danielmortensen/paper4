function [A, b, nConst, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nRoute = Sim.nRoute;
canCharge = Sim.canCharge;
nTime = Sim.nTime;
deltaTHour = Sim.deltaTSec/3600;
iSchedule = Var.b;
iEnergyPerRoute = Var.routeEnergy;

% determine the number of constaints/values
nConst = sum(nRoute);
nConstVal = sum(canCharge,'all','omitnan') + nConst;
iConst = 1;
iConstVal = 1;
idx = 1:nTime;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        routeSchedule = logical(squeeze(canCharge(iBus,iRoute,:)));
        availIdx = idx(routeSchedule);
        nAvail = numel(availIdx);
        for iIdx = 1:nAvail
            iTime = iSchedule(iBus,availIdx(iIdx));
            A(iConstVal + 0,:) = [iConst + 0, iTime, deltaTHour];
            iConstVal = iConstVal + 1;
        end
        A(iConstVal + 0,:) = [iConst + 0, iEnergyPerRoute(iBus,iRoute), -1];
        b(iConst) = 0;
        iConstVal = iConstVal + 1;
        iConst = iConst + 1;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute energy per bus route";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end