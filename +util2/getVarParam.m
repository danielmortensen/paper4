function Param = getVarParam(P)

% preliminaries
nAllRoute = sum(P.nRoute);
nRoute = P.nRoute;
nBus = P.nBus;
nCharger = P.nCharger;
sVar = 1;


% the number of 'begin' variables or b
fVar = sVar + nAllRoute - 1;
iVars = sVar:fVar;
b = nan([nBus,max(nRoute)]);
counter = 1;
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        b(iBus,iRoute) = iVars(counter);
        counter = counter + 1;
    end
end
Param.b = b;
Param.bType = repmat('C',[nAllRoute,1]);
sVar = fVar + 1;

% the number of 'finish' variables, or f
fVar = sVar + nAllRoute - 1;
iVars = sVar:fVar;
f = nan([nBus,max(nRoute)]);
counter = 1;
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        f(iBus,iRoute) = iVars(counter);
        counter = counter + 1;
    end
end
Param.f = f;
Param.fType = repmat('C',[nAllRoute,1]);
sVar = fVar + 1;

% variables for ordering ('l')
fVar = sVar + P.nMayConflict - 1;
iVars = sVar:fVar;
l = nan(size(P.mayConflict));
counter = 1;
for iBus1 = 1:nBus
    for iRoute1 = 1:nRoute(iBus1)
        for iBus2 = iBus1 + 1:nBus
            for iRoute2 = 1:nRoute(iBus2)
                if P.mayConflict(iBus1,iRoute1,iBus2,iRoute2)
                    l(iBus1,iRoute1,iBus2,iRoute2) = iVars(counter);
                    l(iBus2,iRoute2,iBus1,iRoute1) = iVars(counter);
                    counter = counter + 1;
                end
            end
        end
    end
end
Param.l = l;
Param.lType = repmat('B',[P.nMayConflict,1]);
sVar = fVar + 1;

% variables for assigning routes to chargers 'sigma'
fVar = sVar + nAllRoute*nCharger - 1;
Param.sigma = nan([nBus,max(nRoute),nCharger]);
iVars = sVar:fVar;
counter = 1;
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        for iCharger = 1:nCharger
            Param.sigma(iBus,iRoute,iCharger) = iVars(counter);
            counter = counter + 1;
        end
    end
end
Param.sigmaType = repmat('B',[nAllRoute*nCharger,1]);
sVar = fVar + 1;

% assign total number of variables
Param.nVar = fVar;


end