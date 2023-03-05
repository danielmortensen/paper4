function [A, b, nConst, descr, eq] = getCon2(Sim, Var)
% unpack relevent values
iSigma = Var.sigma;
nCharger = Sim.nCharger;

% preallocate loop variables
nConstVal = nCharger*sum(Sim.nRoute);
nConst = sum(Sim.nRoute);
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iConst = 1;
iConstVal = 1;
for  iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        for iCharger = 1:nCharger
            A(iConstVal + 0,:) = [iConst + 0, iSigma(iBus,iRoute,iCharger),1];
            iConstVal = iConstVal + 1;            
        end
        b(iConst) = 0;
        iConst = iConst + 1;        
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "each route can only charge on one charger at a time";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end