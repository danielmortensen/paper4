function [A, b, nCon, descr, eq] = getCon12(Sim, Var)
% unpack relevent variables
iPc = Var.pc;
nTime = Sim.nTime;
nCharger = Sim.nCharger;
nBus = Sim.nBus;
maxTotalCharge = (Sim.pMaxKW - Sim.pMaxDelta)*nCharger;

% preallocate loop variables
nCon = nTime;
nConVar = nTime;
A = nan([nConVar,3]);
b = nan([nCon,1]);
iCon = 1;
iConVar = 1;
for iTime = 1:nTime
    A(iConVar + 0,:) = [iCon + 0, iPc(iTime),  1];   
    b(iCon + 0) = maxTotalCharge;
    iConVar = iConVar + 1;
    iCon = iCon + 1;
end

% double check for any red flags
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));
assert(max(A(:,1)) == nCon);
descr = "constrain pc to be less than the capacity of all chargers";
eq = repmat('<',[nCon,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nCon, Var.nVar);

end
