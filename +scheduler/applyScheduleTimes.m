function Sol4 = applyScheduleTimes(Sol4, Var4, Sim4, Sol5, Var5, Sim5)
nCharger = Sim5.nCharger;
nSession = Sim5.nSession;
for iCharger = 1:nCharger
    for iSession = 1:nSession(iCharger)
        session = Sim5.chargeSession(iCharger,iSession);
        session = session{1};
        tStart = Sol5.x(Var5.sessStart(iCharger,iSession));
        tFinal = Sol5.x(Var5.sessFinal(iCharger,iSession));
        iRoute = session.iRoute;
        iBus = session.iBus;
        Sol4.x(Var4.b(iBus,iRoute)) = tStart;
        Sol4.x(Var4.f(iBus,iRoute)) = tFinal;
    end
end
end