function [A, b, nConst, descr, eq] = getCon8(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
iPt = Var.pt;
iEOn = Var.eOn;
iEOff = Var.eOff;
isOnPeak = Sim.S;
deltaTHour = Sim.deltaTSec/3600;

% determine the number of constaints/values
nConst = 2; 
nConstVal = nTime + 2;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iTime = 1:nTime
    if isOnPeak(iTime)
        A(iConstVal + 0,:) = [iConst + 0, iPt(iTime), -deltaTHour];
    else
        A(iConstVal + 0,:) = [iConst + 1, iPt(iTime), -deltaTHour];
    end
    iConstVal = iConstVal + 1;
end
A(iConstVal + 0,:) = [iConst + 0, iEOn, 1];
A(iConstVal + 1,:) = [iConst + 1, iEOff, 1];
b(iConst + 0) = 0;
b(iConst + 1) = 0;

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute on and off peak energy";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end