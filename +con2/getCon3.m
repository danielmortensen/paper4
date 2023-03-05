function [A, b, nConst, descr, eq] = getCon3(Sim, Var)
% unpack relevent values
iF = Var.f;
iB = Var.b; 
w = Sim.mWidth;

% preallocate loop variables
nConstVal = 2*sum(Sim.nRoute);
nConst = sum(Sim.nRoute);
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iConst = 1;
iConstVal = 1;
for  iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)        
        A(iConstVal + 0,:) = [iConst + 0, iF(iBus,iRoute), -1];
        A(iConstVal + 1,:) = [iConst + 0, iB(iBus,iRoute),  1];
        b(iConst) = -w(iBus,iRoute);
        iConstVal = iConstVal + 2;            
        iConst = iConst + 1;        
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "minimum charge window width";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end