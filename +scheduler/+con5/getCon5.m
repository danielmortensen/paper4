function [A, b, nConst, descr, eq] = getCon5(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nTime = Sim.nTime;
iB = Var.b;
iPt = Var.pt;
uncontrolled = Sim.u;

% determine the number of constaints/values
nConst = nTime; 
nConstVal = (nBus + 1)*nTime;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iTime = 1:nTime
    for iBus = 1:nBus
        A(iConstVal + 0,:) = [iConst + 0, iB(iBus,iTime), -1];
        iConstVal = iConstVal + 1;
    end
    A(iConstVal + 0,:) = [iConst + 0, iPt(iTime), 1];
    b(iConst + 0) = uncontrolled(iConst);
    iConst = iConst + 1;
    iConstVal = iConstVal + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute total power";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end