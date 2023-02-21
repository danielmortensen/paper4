function [A, b, nCon, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
iBp = Var.b;
alpha = Sim.alpha;
pMax = Sim.pMaxKW;
nCon = 2*Sim.nBus*Sim.nTime;

% preallocate loop variables
b = nan([nCon,1]);
A = nan([nCon,3]);
iConst = 1;
for  iBus = 1:Sim.nBus
    for iTime = 1:Sim.nTime
        A(iConst + 0,:) = [iConst + 0, iBp(iBus,iTime), -1];
        A(iConst + 1,:) = [iConst + 1, iBp(iBus,iTime),  1];
        b(iConst + 0) = 0;
        b(iConst + 1) = pMax*alpha(iBus,iTime);
        iConst = iConst + 2;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nCon);


descr = "limits bus average power to between zero and max power";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);
end