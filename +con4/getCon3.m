function [A, b, nConst, descr, eq] = getCon3(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nTime = Sim.nTime;
iAllPower = Var.allpower;
iSchedule = Var.schedule;
nConst = nTime;
nConstVal = nTime*(Sim.nBus + 1);
b = nan([nConst,1]);
A = nan([nConstVal,3]);

iConst = 1;
iConstVal = 1;
for iTime = 1:nTime
    A(iConstVal + 0,:) = [iConst + 0, iAllPower(iTime), -1];
    iConstVal = iConstVal + 1;
    for  iBus = 1:nBus
        A(iConstVal + 0,:) = [iConst + 0, iSchedule(iBus,iTime), 1];
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


descr = "compute total power for all buses";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end