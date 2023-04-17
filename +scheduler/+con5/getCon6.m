function [A, b, nConst, descr, eq] = getCon6(Sim, Var)
% unpack relevent values
nPerWindow = (15*60)/Sim.deltaTSec;
nTime = Sim.nTime;
iPt = Var.pt;
iP15 = Var.p15;

% determine the number of constaints/values
nConst = nTime; 
nConstVal = nTime*nPerWindow;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iTime = 1:nTime
    for iWindow = -(nPerWindow - 2):1
        idx = mod(iTime - iWindow,nTime) + 1;
        A(iConstVal + 0,:) = [iConst + 0, iPt(idx), -1/nPerWindow];
        iConstVal = iConstVal + 1;
    end
    A(iConstVal + 0,:) = [iConst + 0, iP15(iTime), 1];
    b(iConst + 0) = 0;
    iConst = iConst + 1;
    iConstVal = iConstVal + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute 15-minute average power";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end