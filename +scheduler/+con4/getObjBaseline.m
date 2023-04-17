function Q = getObjBaseline(Sim, Var)
    a = squeeze(sum(Sim.routeIdx,2,'omitnan'));
    nBus = Sim.nBus;
    nTime = Sim.nTime;
    Q = zeros([sum(a,'all'),3]);
    counter = 1;
    for iBus = 1:nBus
        for iTime = 1:nTime
            if a(iBus,iTime) > 0
                Q(counter,:) = [Var.schedule(iBus,iTime), Var.schedule(iBus,iTime), 1];
                counter = counter + 1;
            end
        end
    end
    
    Q = sparse(Q(:,1), Q(:,2) , Q(:,3), Var.nVar, Var.nVar);

 

end