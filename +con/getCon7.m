function [A, b, nCon, descr, eq] = getCon7(Sim, Var)
% unpack relevent variables
iPt = Var.pt;
iFac = Var.facilities;
nTime = Sim.nTime;

% preallocate loop variables
nCon = nTime;
nConVar = 2*nTime;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iTime = 1:nTime
    A(iConVar + 0,:) = [iCon + 0, iPt(iTime),  1];
    A(iConVar + 1,:) = [iCon + 0, iFac,       -1];
    b(iCon + 0) = 0;
    iConVar = iConVar + 2;
    iCon = iCon + 1;
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "Constrain facilities power to be > all other total power values";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
