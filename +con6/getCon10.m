function [A, b, nCon, descr, eq] = getCon10(Sim, Var)
% unpack variables
iG = Var.g;
iBp = Var.b;

% preallocate loop variables
nConVar = 3*(Sim.nTime - 1)*Sim.nBus*2;
nCon = 2*(Sim.nTime - 1)*Sim.nBus;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iConVar = 1;
iCon = 1;
for iBus = 1:Sim.nBus
    for iTime = 1:Sim.nTime - 1
        A(iConVar + 0,:) = [iCon + 0, iG(iBus,iTime  + 0), -1];
        A(iConVar + 1,:) = [iCon + 0, iBp(iBus,iTime + 0),  1];
        A(iConVar + 2,:) = [iCon + 0, iBp(iBus,iTime + 1), -1];
        A(iConVar + 3,:) = [iCon + 1, iG(iBus,iTime  + 0), -1];
        A(iConVar + 4,:) = [iCon + 1, iBp(iBus,iTime + 0), -1];
        A(iConVar + 5,:) = [iCon + 1, iBp(iBus,iTime + 1),  1];        
        b(iCon + 0) = 0;
        b(iCon + 1) = 0;
        iCon = iCon + 2;
        iConVar = iConVar + 6;
    end
end

% double check all constraints were used as anticipated
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "compute absolute value of difference between adjacent charge values";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);
