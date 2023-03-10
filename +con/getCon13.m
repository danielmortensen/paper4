function [A, b, nCon, descr, eq] = getCon13(Sim, Var)
% unpack relevent variables
canCharge = Sim.canCharge;
iB = Var.b; 
nTime = Sim.nTime;
nBus = Sim.nBus;
deltaTHour = Sim.deltaTSec/3600;
nRoute = Sim.nRoute;
minEnergy = Sim.minEnergyPerSession;
iSigma = Var.sessionSelect;
pMaxKW = Sim.pMaxKW;

% preallocate loop variables
nCon = 2*(sum(Sim.nRoute,'all','omitnan'));
nConVar = 2*(sum(canCharge,'all')) + 2*sum(Sim.nRoute,'all','omitnan');
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        for iTime = 1:nTime
            if canCharge(iBus,iRoute,iTime)
                A(iConVar + 0,:) = [iCon + 0, iB(iBus,iTime),  -deltaTHour];
                A(iConVar + 1,:) = [iCon + 1, iB(iBus,iTime),   deltaTHour];
                iConVar = iConVar + 2;
            end
        end

        % M is the maximum energy for this session.
        M = squeeze(sum(canCharge(iBus,iRoute,:),'all'))*deltaTHour*pMaxKW;
        A(iConVar + 0,:) = [iCon + 0, iSigma(iBus,iRoute),  M];
        A(iConVar + 1,:) = [iCon + 1, iSigma(iBus,iRoute), -M];
        b(iCon + 0) = M - minEnergy;
        b(iCon + 1) = 0;
        iConVar = iConVar + 2;
        iCon = iCon + 2;
    end
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "establish constriant for minimum energy delivered per session";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
