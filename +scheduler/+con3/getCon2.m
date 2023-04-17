function [A, b, nConst, descr, eq] = getCon2(Sim, Var)
% unpack relevent values
nAllBus = sum(Sim.nBus);
nGroup = Sim.nGroup;
nConst = nAllBus;
nConstVal = nGroup*nAllBus;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iSigma = Var.sigma;

% loop variables
iConst = 1;
iConstVal = 1;
for  iBus = 1:nAllBus
        for iGroup = 1:Sim.nGroup
            A(iConstVal + 0,:) = [iConst + 0, iSigma(iBus,iGroup), 1];
            iConstVal = iConstVal + 1;
        end
        b(iConst) = 1;
        iConst = iConst + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "each bus must be placed in only one group";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end