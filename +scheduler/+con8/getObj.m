function Q = getObj(Sim, Var)
nBus = Sim.nBus;
nTime = Sim.nTime;
nWindow = 10;
availability = squeeze(sum(Sim.routeIdx,2,'omitnan'));
nVal = (sum(Sim.nSession) + sum(availability,'all'))*4*nWindow*2;
Q = nan([nVal,3]);
iVal = 1;
isOnBreak = false;
nRoute = 0;
for iBus = 1:nBus
    for iTime = 1:nTime + 1
        if availability(iBus,mod(iTime,nTime) + 1) == 1 || isOnBreak
            if availability(iBus,mod(iTime,nTime) + 1) == 1
                isOnBreak = true;
            else
                isOnBreak = false;
                nRoute = nRoute + 1;
            end
            for iWindow = -nWindow:-1
                ai = Var.schedule(iBus,mod(iTime,nTime) + 1);
                bi = Var.schedule(iBus,mod(iTime - iWindow,nTime) + 1);
                Q(iVal + 0,:) = [ai, ai,  1];
                Q(iVal + 1,:) = [bi, bi,  1];
                Q(iVal + 2,:) = [ai, bi, -1];
                Q(iVal + 3,:) = [bi, ai, -1];
                iVal = iVal + 4;
            end
        end
    end
end
Q = Q(1:iVal - 1,:);

Q = sparse(Q(:,1), Q(:,2), Q(:,3), Var.nVar, Var.nVar);
end