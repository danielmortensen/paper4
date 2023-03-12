function [A, b, nConst, descr, eq] = getCon9(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
nBus = Sim.nBus;
iH = Var.h;
iB= Var.b;
delta = Sim.delta;

% determine the number of constaints/values
nConst = Sim.nBus*(Sim.nTime + 1); 
nConstVal = Sim.nBus*Sim.nTime*3 + Sim.nBus;
iConst = 1;
iConstVal = 1;

% preallocate for use
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iTime = 1:nTime + 1
        if iTime == 1
            A(iConstVal + 0,:) = [iConst + 0, iH(iTime), 1];
            b(iConst + 0) = Sim.h0(iBus);
            iConstVal = iConstVal + 1;
            iConst = iConst + 1;
        else
            A(iConstVal + 0,:) = [iConst + 0, iH(iBus,iTime), 1];
            A(iConstVal + 1,:) = [iConst + 0, iH(iBus,iTime - 1), -1];
            A(iConstVal + 2,:) = [iConst + 0, iB(iBus,iTime - 1), -1];
            b(iConst + 0) = -delta(iBus,iTime - 1);
            iConstVal = iConstVal + 3;
            iConst = iConst + 1;
        end
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute state of charge for each bus";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end