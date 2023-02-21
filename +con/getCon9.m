function [A, b, nCon, descr, eq] = getCon9(Sim, Var)
% unpack relevent variables
iPt = Var.pt;
iEon = Var.eOn;
iEoff = Var.eOff;
isOn = Sim.S;
nTime = Sim.nTime;
SEC_TO_HOURS = 1/3600;
deltaT = Sim.deltaTSec*SEC_TO_HOURS;

% preallocate loop variables
nCon = 2;
nConVar = nTime + 2;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;

% add indices for on-peak and off-peak energy
A(iConVar + 0,:) = [iCon + 0, iEon, 1];
A(iConVar + 1,:) = [iCon + 1, iEoff,1];
b(iCon + 0) = 0;
b(iCon + 1) = 0;
iConVar = iConVar + 2;

% add indices for each time period
for iTime = 1:nTime
    if isOn(iTime)
        A(iConVar + 0,:) = [iCon + 0, iPt(iTime),  -deltaT];
        iConVar = iConVar + 1;
    else
        A(iConVar + 0,:) = [iCon + 1, iPt(iTime), -deltaT];
        iConVar = iConVar + 1;
    end
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "Compute on and off-peak energy for the day";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
