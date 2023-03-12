function Q = getObjBaseline(Sim, Var)
    a = Sim.alpha;
    nBus = Sim.nBus;
    nTime = Sim.nTime;
    Q = zeros([sum(Sim.alpha(:) > 0),3]);
    counter = 1;
    obj = zeros([Var.nVar,1]);
    for iBus = 1:nBus
        for iTime = 1:nTime
            if a(iBus,iTime) > 0
                Q(counter,:) = [Var.b(iBus,iTime), Var.b(iBus,iTime), 1];
                counter = counter + 1;
            end
        end
    end
    
    Q = sparse(Q(:,1), Q(:,2) , Q(:,3), Var.nVar, Var.nVar);

end