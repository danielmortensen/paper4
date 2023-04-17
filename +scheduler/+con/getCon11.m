function [A, b, nCon, descr, eq] = getCon11(Sim, Var)
% unpack relevent variables
iPt = Var.pt;
iP15 = Var.p15;
nTime = Sim.nTime;
n15 = 15*60/Sim.deltaTSec; 

% preallocate loop variables
nCon = nTime;
nConVar = n15*(nTime - n15) + n15*(n15 - 1)/2 + nTime;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iTime = 1:nTime
    A(iConVar,:) = [iCon, iP15(iTime), 1];
    iConVar = iConVar + 1;
    for iLow = -n15 + 1:0
        idx = mod(iLow + iTime, nTime) + 1;
        A(iConVar,:) = [iCon, iPt(idx), -1/n15];
        iConVar = iConVar + 1;
    end
    b(iCon) = 0;
    iCon = iCon + 1;   
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "compute the 15-minute average power";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end