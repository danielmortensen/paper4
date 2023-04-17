function [A, b, nConst, descr, eq] = getCon7(Sim, Var)
% unpack relevent values
nGroup = Sim.nGroup;
nConst = nGroup*2;
nConstVal = sum(Sim.nBus)*nGroup*2;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iSigma = Var.sigma;

% loop variables
iConst = 1;
iConstVal = 1;
for iGroup = 1:Sim.nGroup
    for iBus = 1:sum(Sim.nBus)
        A(iConstVal + 0,:) = [iConst + 0, iSigma(iBus, iGroup),   1];
        A(iConstVal + 1,:) = [iConst + 1, iSigma(iBus, iGroup),  -1];
        b(iConst) = Sim.nMaxBus;
        b(iConst + 1) = -Sim.nMinBus;

        iConstVal = iConstVal + 2;
    end
    iConst = iConst + 2;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "set bounds on number of allowable buses in a group";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end