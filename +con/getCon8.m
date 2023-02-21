function [A, b, nCon, descr, eq] = getCon8(Sim, Var)
% unpack relevent variables
iPt = Var.pt;
iDem = Var.demand;
isOn = Sim.S;
nTime = Sim.nTime;

% preallocate loop variables
nCon = sum(isOn);
nConVar = 2*nCon;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iTime = 1:nTime
    if isOn(iTime)
        A(iConVar + 0,:) = [iCon + 0, iPt(iTime),  1];
        A(iConVar + 1,:) = [iCon + 0, iDem,       -1];       
        b(iCon + 0) = 0;
        iConVar = iConVar + 2;
        iCon = iCon + 1;
    end
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "Set demand charge >= all on-peak values in pt";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
