function [A, b, nCon, descr, eq] = getCon4(Sim, Var)
% unpack relevent variables
iH = Var.h;
nBus = Sim.nBus;

% preallocate loop variables
nCon = nBus;
nConVar = nBus*2;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iBus = 1:Sim.nBus
    A(iConVar + 0,:) = [iCon + 0, iH(iBus,1), -1];
    A(iConVar + 1,:) = [iCon + 0, iH(iBus, end), 1];
    b(iCon + 0) = 0;
    iConVar = iConVar + 2;
    iCon = iCon + 1;
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constrain h_0 == h_end";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
