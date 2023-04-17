function [A, b, nConst, descr, eq] = getCon3(Sim, Var)
% unpack relevent values
[nAllBus, nTime] = size(Sim.schedule);
nGroup = Sim.nGroup;
nConst = nTime*nGroup;
nConstVal = nTime*nGroup*nAllBus;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iSigma = Var.sigma;
iP = Var.group;
schedule = Sim.schedule;

% loop variables
iConst = 1;
iConstVal = 1;
for iGroup = 1:Sim.nGroup
    for iTime = 1:nTime
        A(iConstVal,:) = [iConst + 0, iP(iGroup,iTime), 1];
        iConstVal = iConstVal + 1;
        for iBus = 1:nAllBus
            A(iConstVal,:) = [iConst + 0, iSigma(iBus,iGroup), -schedule(iBus,iTime)];
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


descr = "computes the sum of all charge for each group per time step";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end