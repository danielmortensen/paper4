function [A, b, nConst, descr, eq] = getCon7(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
iP15 = Var.p15;
iDemand = Var.demand;
iFacilities = Var.facilities;
isOnPeak = Sim.S;

% determine the number of constaints/values
nConst = Var.nP15 + sum(Sim.S); 
nConstVal = nConst*2;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iTime = 1:nTime    
    A(iConstVal + 0,:) = [iConst + 0, iFacilities, -1];
    A(iConstVal + 1,:) = [iConst + 0, iP15(iTime),  1];    
    b(iConst + 0) = 0;
    iConstVal = iConstVal + 2;
    iConst = iConst + 1;
    if isOnPeak(iTime)
        A(iConstVal + 0,:) = [iConst + 0, iDemand, -1];
        A(iConstVal + 1,:) = [iConst + 0, iP15(iTime) 1];
        b(iConst) = 0;
        iConst = iConst + 1;
        iConstVal = iConstVal + 2;
    end   
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute demand and facilities power";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end