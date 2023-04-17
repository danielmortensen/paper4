function [A, b, nConst, descr, eq] = getCon10(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
nBus = Sim.nBus;
iH = Var.h;

% determine the number of constaints/values
nConst = Sim.nBus*(Sim.nTime + 1); 
nConstVal = nConst;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iTime = 1:nTime + 1
        A(iConstVal + 0,:) = [iConst, iH(iBus,iTime), -1];
        b(iConst + 0) = -Sim.hMin(iBus);
        iConstVal = iConstVal + 1;
        iConst = iConst + 1;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "state of charge must be greater than minimum";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end