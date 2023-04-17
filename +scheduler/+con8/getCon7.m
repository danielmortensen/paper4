function [A, b, nConst, descr, eq] = getCon7(Sim, Var)
% unpack relevent values
iDemand = Var.demand;
iFacilities = Var.facilities;
iOnPeakEnergy = Var.onPeakEnergy;
iOffPeakEnergy = Var.offPeakEnergy;
nConst = 4;
A = nan([4,3]);
b = nan([4,1]);

A(1,:) = [1, iDemand, 1];
A(2,:) = [2, iFacilities, 1];
A(3,:) = [3, iOnPeakEnergy, 1];
A(4,:) = [4, iOffPeakEnergy, 1];
b(1) = Sim.demand;
b(2) = Sim.facilities;
b(3) = Sim.onPeakEnergy;
b(4) = Sim.offPeakEnergy;



% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "constrain optimal values from previous problem";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end