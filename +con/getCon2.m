function [A, b, nCon, descr, eq] = getCon2(Sim, Var)
% unpack variables
iH = Var.h;
iBp = Var.b;
SECOND_TO_HOURS = 1/3600;
deltaT = Sim.deltaTSec*SECOND_TO_HOURS;
delta = Sim.delta;
eta = Sim.eta;

% preallocate loop variables
nConVar = 3*Sim.nBus*Sim.nTime +Sim.nBus;
nCon = Sim.nBus*(Sim.nTime + 1);
A = nan([nConVar,3]);
b = nan([nCon,1]);
iConVar = 1;
iCon = 1;
for iBus = 1:Sim.nBus
    for iTime = 1:(Sim.nTime + 1)
        if iTime == 1
            A(iConVar,:) = [iCon, iH(iBus,iTime), 1];
            b(iCon) = eta(iBus);
            iConVar = iConVar + 1;
            iCon = iCon + 1;
        else
            A(iConVar + 0,:) = [iCon, iH(iBus, iTime - 0) ,  1     ];
            A(iConVar + 1,:) = [iCon, iH(iBus, iTime - 1) , -1     ];
            A(iConVar + 2,:) = [iCon, iBp(iBus, iTime - 1), -deltaT];
            b(iCon) = delta(iBus, iTime - 1);
            iCon = iCon + 1;
            iConVar = iConVar + 3;
        end
    end
end

% double check all constraints were used as anticipated
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constraint to propagate soc values from one time to another";
eq = repmat('=',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);
