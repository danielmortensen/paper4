function [A, b, nConst, descr, eq] = getCon5(Sim, Var)
% unpack relevent values
nTime = Sim.nTime;
iAllPower = Var.allpower;
isOnPeak = Sim.isOnPeak;
deltaTHour = Sim.deltaTSec/3600;
iOnPeakEnergy = Var.onPeakEnergy;
iOffPeakEnergy = Var.offPeakEnergy;

nConst = 2;
nConstVal = nTime + 2;
b = nan([nConst,1]);
A = nan([nConstVal,3]);

iConst = 1;
iConstVal = 1;
for iTime = 1:nTime
    if isOnPeak(iTime)
        A(iConstVal + 0,:) = [iConst + 0, iAllPower(iTime), deltaTHour];
    else
        A(iConstVal + 0,:) = [iConst + 1, iAllPower(iTime), deltaTHour];
    end
   iConstVal = iConstVal + 1;
end
A(iConstVal + 0,:) = [iConst + 0, iOnPeakEnergy, -1];
A(iConstVal + 1,:) = [iConst + 1, iOffPeakEnergy, -1];
b(iConst + 0) = 0;
b(iConst + 1) = 0;

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "compute on and off peak energy.";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end