function obj = getObj1(Sim, Var)
nTime = Sim.nTime;
nBus = Sim.nBus;
iBp = Var.b;

% preallocate
nConVal = (nTime - 1)*4*nBus;
obj = nan([nConVal,3]);
iConVal = 1;
for iBus = 1:nBus
    for iTime = 2:nTime
        ib1 = iBp(iBus,iTime - 1);
        ib2 = iBp(iBus,iTime);
        obj(iConVal + 0,:) = [ib1, ib1, 1];
        obj(iConVal + 1,:) = [ib1, ib2, -1];
        obj(iConVal + 2,:) = [ib2, ib1, -1];
        obj(iConVal + 3,:) = [ib2, ib2, 1];
        iConVal = iConVal + 4;
    end
end

assert(~any(isnan(obj(:))));
obj = sparse(obj(:,1), obj(:,2), obj(:,3), Var.nVar, Var.nVar);
end