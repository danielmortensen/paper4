function [A, b, nConst, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nTime = Sim.nTime;
nConst = 2*nBus*nTime;
nConstVal = nConst;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iSchedule = Var.schedule;
isCharging = squeeze(sum(Sim.routeIdx,2,'omitnan'));
pMaxKW = Sim.pMaxKW;

iConst = 1;
iConstVal = 1;
for  iBus = 1:nBus
    for iTime = 1:nTime
        A(iConstVal + 0,:) = [iConst + 0, iSchedule(iBus,iTime),  -1];
        A(iConstVal + 1,:) = [iConst + 1, iSchedule(iBus,iTime), 1];
        b(iConst + 0) = 0;
        if isCharging(iBus,iTime)
            b(iConst + 1) = pMaxKW;
        else
            b(iConst + 1) = 0;
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


descr = "set max and min charging rates ";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end