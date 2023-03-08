function [A, b, nConst, descr, eq] = getCon6(Sim, Var)
% unpack relevent values
nTime = size(Sim.schedule,2);
nGroup = Sim.nGroup;
nConst = nTime*nGroup;
nConstVal = nTime*nGroup*2;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iP = Var.group;
iNCharger = Var.charger;
M = Sim.pMaxKW;

% loop variables
iConst = 1;
iConstVal = 1;
for iGroup = 1:Sim.nGroup
    for iTime = 1:nTime
        A(iConstVal + 0,:) = [iConst + 0, iP(iGroup,iTime),   1];
        A(iConstVal + 1,:) = [iConst + 0, iNCharger(iGroup), -M];
        b(iConst) = 0;

        iConstVal = iConstVal + 2;
        iConst = iConst + 1;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "cannot have more charge than the number of chargers can handle";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end