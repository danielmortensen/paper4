function [A, b, nConst, descr, eq] = getCon4(Sim, Var)
% unpack relevent values
nGroup = Sim.nGroup;
nConst = 1;
iChargerIdx = Var.charger;
nCharger = sum(Sim.nCharger);
nConstVal = nGroup;
b = nan([nConst,1]);
A = nan([nConstVal,3]);

% loop variables
iConst = 1;
iConstVal = 1;

% constrain the sum of chargers to be equal to the total number of chargers
for iGroup = 1:nGroup
A(iConstVal + 0,:) = [iConst, iChargerIdx(iGroup), 1];
iConstVal = iConstVal + 1;
end
b(iConst) = nCharger;
iConst = iConst + 1;

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "number of chargers must be equal to the total number of chargers";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end