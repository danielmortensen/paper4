function [A, b, nConst, descr, eq] = getCon4(Sim, Var)
% unpack relevent values
iP15 = Var.p15;
nTime = Sim.nTime;
iAllPower = Var.allpower;
nPerWindow = (15*60)/Sim.deltaTSec;
nConst = nTime;
nConstVal = nTime*nPerWindow;
b = nan([nConst,1]);
A = nan([nConstVal,3]);

iConst = 1;
iConstVal = 1;
for iTime = 1:nTime
    A(iConstVal + 0,:) = [iConst + 0, iP15(iTime), -1];
    iConstVal = iConstVal + 1;
    for  iWindow = -nPerWindow + 1:0
        idx = mod(iWindow + iTime,nTime) + 1;
        A(iConstVal + 0,:) = [iConst + 0, iAllPower(idx), 1/nPerWindow];
        iConstVal = iConstVal + 1;
    end
    b(iConst) = 0;
    iConst = iConst + 1;
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute 15-minute average power for each time step.";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end