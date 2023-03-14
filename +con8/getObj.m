function Q = getObj(Sim, Var)
nBus = Sim.nBus;
nTime = Sim.nTime;
availability = squeeze(sum(Sim.routeIdx,2,'omitnan'));
Q = nan([sum(availability,'all')*4,3]);
iVal = 1;
for iBus = 1:nBus
    for iTime = 1:nTime - 1
        if availability(iBus,iTime:iTime + 1) == 2
            ai = Var.schedule(iBus,iTime);
            bi = Var.schedule(iBus,iTime + 1);
            Q(iVal + 0,:) = [ai, ai,  1];
            Q(iVal + 1,:) = [bi, bi,  1];
            Q(iVal + 2,:) = [ai, bi, -1];
            Q(iVal + 3,:) = [bi, ai, -1];
            iVal = iVal + 4;
        end
    end
end
Q = Q(1:iVal - 1,:);

Q = sparse(Q(:,1), Q(:,2), Q(:,3), Var.nVar, Var.nVar);
end