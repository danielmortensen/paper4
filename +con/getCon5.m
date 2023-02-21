function [A, b, nCon, descr, eq] = getCon5(Sim, Var)
% unpack relevent variables
iPc = Var.pc;
iBp = Var.b;
nBus = Sim.nBus;
nTime = Sim.nTime;

% preallocate loop variables
nCon = nTime;
nConVar = (nBus + 1)*nTime;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iTime = 1:nTime
    A(iConVar + 0,:) = [iCon + 0, iPc(iTime),  1];
    for iBus = 1:nBus
        A(iConVar + iBus,:) = [iCon + 0, iBp(iBus, iTime), -1];
    end
    b(iCon + 0) = 0;
    iConVar = iConVar + 1 + nBus;
    iCon = iCon + 1;
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constrain pc to be the sum of charger consumption";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
