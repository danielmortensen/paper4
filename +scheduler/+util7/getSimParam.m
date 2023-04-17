function Param = getSimParam(Sim4, Var4, Sol4)
nBus = Sim4.nBus;
nRoute = Sim4.nRoute;
nCharger = Sim4.nCharger;
x = Sol4.x;
busId = Sim4.busId;
routeAssignment = cell([nCharger,sum(nRoute)]);
chargeIdx = ones([1,nCharger]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        iCharge = find(round(x(Var4.sigma(iBus,iRoute,:))));
        tStart = x(Var4.b(iBus,iRoute));
        tFinish = x(Var4.f(iBus,iRoute));
        tArrive = Sim4.tStart(iBus,iRoute);
        tDepart = Sim4.tFinal(iBus,iRoute);
        energy = Sim4.energy(iBus,iRoute);
        mWidth = Sim4.mWidth(iBus,iRoute);
        data = struct('iBus',iBus,'tStart',tStart,'tFinish',tFinish,...
            'tArrive',tArrive,'tDepart',tDepart,'energy',energy,'iCharger',iCharge,'mWidth',mWidth,'iRoute',iRoute, 'busIdx',busId(iBus));
        routeAssignment{iCharge,chargeIdx(iCharge)} = data;
        chargeIdx(iCharge) = chargeIdx(iCharge) + 1;
    end
end
routeAssignment = routeAssignment(:,1:max(chargeIdx) - 1);

% sort each row
for iRow = 1:size(routeAssignment,1)
    row = routeAssignment(iRow,1:chargeIdx(iRow) - 1);
    tStart = nan([1,chargeIdx(iRow) - 1]);
    for iVal = 1:chargeIdx(iRow) - 1
        tStart(iVal) = row{iVal}.tStart;
    end
    [~, idx] = sort(tStart);
    routeAssignment(iRow,1:chargeIdx(iRow) - 1) = routeAssignment(iRow,idx);
end
Param.chargeSession = routeAssignment;
Param.nSession = chargeIdx - 1;
Param.nCharger = nCharger;
end