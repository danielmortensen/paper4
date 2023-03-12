function Q = getObj1(Sim, Var)
nVal = 4*(sum(Sim.alpha,'all') - sum(Sim.nRoute));
iB = Var.b;
A = nan([nVal,3]);
iConstVal = 1;
for iBus = 1:Sim.nBus
    isFirst = true;
    routeFinished = true;
    for iTime = 1:Sim.nTime
        if Sim.alpha(iBus,iTime) == 1
            if routeFinished && ~isFirst
                iRoute = iRoute + 1;
                routeFinished = false;
            elseif routeFinished && isFirst
                routeFinished = false;
            else
                b1 = iB(iBus,iTime - 1);
                b2 = iB(iBus,iTime - 0);
                A(iConstVal + 0,:) = [b1, b1,  1];
                A(iConstVal + 1,:) = [b1, b2, -1];
                A(iConstVal + 2,:) = [b2, b1, -1];
                A(iConstVal + 3,:) = [b2, b2,  1];
                iConstVal = iConstVal + 4;
            end
        else
            routeFinished = true;
        end
    end
end

Q = sparse(A(:,1), A(:,2), A(:,3), Var.nVar,Var.nVar);
end