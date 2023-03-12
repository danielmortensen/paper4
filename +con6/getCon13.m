function [A, b, nCon, descr, eq] = getCon13(Sim, Var)
% unpack relevent variables
iDemand = Var.demand;
iEOn = Var.eOn;
iEOff = Var.eOff;
iFacilities = Var.facilities;

demand = Sim.demand;
facilities = Sim.facilities;
eOn = Sim.eOnPeak;
eOff = Sim.eOffPeak;

nCon = 4;
nConVar = 4;

A = nan([nConVar,3]);
b = nan([nCon,1]);

A(1,:) = [1, iDemand, 1];
A(2,:) = [2, iFacilities, 1];
A(3,:) = [3, iEOn, 1];
A(4,:) = [4, iEOff, 1];

b(1) = demand;
b(2) = facilities;
b(3) = eOn;
b(4) = eOff;

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constrain optimal values from previous solution";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
