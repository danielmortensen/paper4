function Q = getObj(Sim,Var)
nSession = Sim.nSession;
nVal = sum(nSession)*4;
iStart = Var.sessStart;
iFinal = Var.sessFinal;
A = nan([nVal,3]);
iConstVal = 1;
for iCharger = 1:Sim.nCharger
    for iSession = 1:nSession(iCharger)        
        e = Sim.chargeSession(iCharger,iSession);
        e = e{1};
        e = e.energy;
        A(iConstVal + 0,:) = [iStart(iCharger,iSession), iStart(iCharger,iSession),  e];
        A(iConstVal + 1,:) = [iStart(iCharger,iSession), iFinal(iCharger,iSession), -e];
        A(iConstVal + 2,:) = [iFinal(iCharger,iSession), iStart(iCharger,iSession), -e];
        A(iConstVal + 3,:) = [iFinal(iCharger,iSession), iFinal(iCharger,iSession),  e];
        iConstVal = iConstVal + 4;
    end
end
Q = sparse(A(:,1), A(:,2), A(:,3), Var.nVar,Var.nVar);
end