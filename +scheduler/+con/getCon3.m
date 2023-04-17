function [A, b, nCon, descr, eq] = getCon3(Sim, Var)
% unpack relevent variables
hMin = Sim.hMin;
hMax = Sim.hMaxKWH;
iH = Var.h;

% preallocate loop variables
nCon = 2*Sim.nBus*(Sim.nTime + 1);
nConVar = nCon;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iBus = 1:Sim.nBus
    for iTime = 1:Sim.nTime + 1
        A(iConVar + 0,:) = [iCon + 0, iH(iBus,iTime), -1];
        A(iConVar + 1,:) = [iCon + 1, iH(iBus, iTime), 1];
        b(iCon + 0) = -hMin(iBus);
        b(iCon + 1) = hMax;
        iConVar = iConVar + 2;
        iCon = iCon + 2;
    end
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constraints so that the SOC for a bus stays within proper bounds";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
