function [A, b, nConst, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
iB = Var.b;
iF = Var.f;
a = Sim.tStart;
d = Sim.tFinal;

% preallocate loop variables
nConst = 3*sum(Sim.nRoute);
nConstVal = 4*sum(Sim.nRoute);
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iConst = 1;
iConstVal = 1;
for  iBus = 1:Sim.nBus
    for iRoute = 1:Sim.nRoute(iBus)
        A(iConstVal + 0,:) = [iConst + 0, iB(iBus,iRoute), -1];
        A(iConstVal + 1,:) = [iConst + 1, iB(iBus,iRoute),  1];
        A(iConstVal + 2,:) = [iConst + 1, iF(iBus,iRoute), -1];
        A(iConstVal + 3,:) = [iConst + 2, iF(iBus,iRoute),  1];        
        b(iConst + 0) = -a(iBus,iRoute);
        b(iConst + 1) = 0;
        b(iConst + 2) = d(iBus,iRoute);
        iConstVal = iConstVal + 4;        
        iConst = iConst + 3;
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "ordering for arrival, start, finish, and departure times";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end