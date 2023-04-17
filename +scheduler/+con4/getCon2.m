function [A, b, nConst, descr, eq] = getCon2(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nTime = Sim.nTime;
iSchedule = Var.schedule;
isCharging = Sim.routeIdx;
isCharging(isnan(isCharging)) = 0;
isCharging = logical(isCharging);
nSession = Sim.nSession;
energy = Sim.energy;
nConst = sum(nSession,'omitnan');
nConstVal = sum(isCharging,'all','omitnan');
b = nan([nConst,1]);
A = nan([nConstVal,3]);
deltaTHour = Sim.deltaTSec/3600;

iConst = 1;
iConstVal = 1;
for  iBus = 1:nBus
    for iSession = 1:nSession(iBus)
        for iTime = 1:nTime   
            if isCharging(iBus,iSession,iTime)
                A(iConstVal + 0,:) = [iConst + 0, iSchedule(iBus,iTime), deltaTHour];     
                iConstVal = iConstVal + 1;
            end            
        end
        b(iConst) = energy(iBus,iSession);
        iConst = iConst + 1;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "Energy must be delivered during each charge session";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end