function Q = getObj1(Sim, Var)
nVal = 4*(sum(Sim.alpha,'all') + sum(Sim.nRoute));
iB = Var.b;
A = nan([nVal,3]);
iConstVal = 1;
nTime = Sim.nTime;
for iBus = 1:Sim.nBus
    inStation = true;
    for iTime = 1:nTime + 1
        if Sim.alpha(iBus,mod(iTime, nTime) + 1) == 1 || inStation
            if Sim.alpha(iBus,mod(iTime,nTime) + 1) == 0
                inStation = false;
            else
                inStation = true;
            end
            b1 = iB(iBus,mod(iTime - 1,nTime) + 1);
            b2 = iB(iBus,mod(iTime - 0,nTime) + 1);
            A(iConstVal + 0,:) = [b1, b1,  1];
            A(iConstVal + 1,:) = [b1, b2, -1];
            A(iConstVal + 2,:) = [b2, b1, -1];
            A(iConstVal + 3,:) = [b2, b2,  1];
            iConstVal = iConstVal + 4;
        end
    end
end

Q = sparse(A(:,1), A(:,2), A(:,3), Var.nVar,Var.nVar);
end