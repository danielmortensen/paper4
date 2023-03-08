function [A, b, nConst, descr, eq] = getCon5(Sim, Var)
% unpack relevent values
iChargerIdx = Var.charger;
nCharger = sum(Sim.nCharger);
nConstVal = Sim.nGroup;
nConst = Sim.nGroup;
b = nan([nConst,1]);
A = nan([nConstVal,3]);

% loop variables
iConst = 1;
iConstVal = 1;

% constrain each nCharger to be greater than zero
for iGroup = 1:Sim.nGroup
A(iConstVal + 0,:) = [iConst + 0, iChargerIdx(iGroup), -1];
b(iConst) = 0;
iConstVal = iConstVal + 1;
iConst = iConst + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "all nCharger values are > 0";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end