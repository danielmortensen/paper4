function [A, b, nConst, descr, eq] = getCon4(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
iRouteEnergy = Var.routeEnergy;
energy = Sim.totalBusEnergy;
nRoute = Sim.nRoute; 

% determine the number of constaints/values
nConst = nBus; 
nConstVal = sum(Sim.nRoute);
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        A(iConstVal + 0,:) = [iConst + 0, iRouteEnergy(iBus,iRoute), 1];        
        iConstVal = iConstVal + 1;
    end
    b(iConst + 0) = energy(iBus);
    iConst = iConst + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "total energy has to equal given values";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end