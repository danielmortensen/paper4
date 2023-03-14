function [A, b, nConst, descr, eq] = getCon6(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
iP15 = Var.p15;
isOnPeak = Sim.isOnPeak;
iDemand = Var.demand;
iFacilities = Var.facilities;

nConst = nTime + sum(isOnPeak);
nConstVal = nConst*2;
b = nan([nConst,1]);
A = nan([nConstVal,3]);

iConst = 1;
iConstVal = 1;
for iTime = 1:nTime
    if isOnPeak(iTime)
        A(iConstVal + 0,:) = [iConst + 0, iP15(iTime), 1];
        A(iConstVal + 1,:) = [iConst + 0, iDemand, -1];
        b(iConst + 0) = 0;
        iConstVal = iConstVal + 2;
        iConst = iConst + 1;
    end
    A(iConstVal + 0,:) = [iConst + 0, iP15(iTime), 1];
    A(iConstVal + 1,:) = [iConst + 0, iFacilities, -1];
    b(iConst + 0) = 0;
   iConstVal = iConstVal + 2;
   iConst = iConst + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute demand and facilities charge.";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end