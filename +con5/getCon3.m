function [A, b, nConst, descr, eq] = getCon3(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
canCharge = squeeze(sum(Sim.canCharge,2));
nTime = Sim.nTime;
iSchedule = Var.b;
pMax = Sim.pMax - Sim.pMaxDelta;

% determine the number of constaints/values
nConst = 2*nBus*nTime; 
nConstVal = nConst;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iTime = 1:nTime
        A(iConstVal + 0,:) = [iConst + 0, iSchedule(iBus,iTime), 1];
        A(iConstVal + 1,:) = [iConst + 1, iSchedule(iBus,iTime), -1];
        b(iConst + 1) = 0;
        if canCharge(iBus,iTime)
            b(iConst + 0) = pMax;
        else
            b(iConst + 0) = 0;
        end
        iConst = iConst + 2;
        iConstVal = iConstVal + 2;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "constrain individual values for power";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end