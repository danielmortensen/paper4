function [A, b, nConst, descr, eq] = getCon2(Sim, Var)
% unpack relevent values
nBus = Sim.nBus;
nRoute = Sim.nRoute;
iSigma = Var.isUsedAndFragmented;
iEnergyPerRoute = Var.routeEnergy;
nFragment = sum(strcmp(Sim.sessStatus,"FRAGMENTED"),'all');
nUsed = sum(strcmp(Sim.sessStatus,"USED"),'all');
nUnused = sum(strcmp(Sim.sessStatus,"UNUSED"),'all');
nConst = 2*nFragment + nUsed + nUnused;
nConstVal = 4*nFragment + nUsed + nUnused;
eMin = Sim.minEnergyPerSess;
M = Sim.hMax;

% determine the number of constaints/values
iConst = 1;
iConstVal = 1;
A = nan([nConstVal,3]);
b = nan([nConst,1]);
for iBus = 1:nBus
    for iRoute = 1:nRoute(iBus)
        if strcmp(Sim.sessStatus(iBus,iRoute),"FRAGMENTED")
            A(iConstVal + 0,:) = [iConst + 0, iEnergyPerRoute(iBus,iRoute), -1];
            A(iConstVal + 1,:) = [iConst + 0, iSigma(iBus,iRoute), eMin];
            b(iConst + 0) = 0;
            A(iConstVal + 2,:) = [iConst + 1, iEnergyPerRoute(iBus,iRoute), 1];
            A(iConstVal + 3,:) = [iConst + 1, iSigma(iBus,iRoute), -M];
            b(iConst + 1) = 0;
            iConstVal = iConstVal + 4;
            iConst = iConst + 2;            
        elseif strcmp(Sim.sessStatus(iBus,iRoute),"UNUSED")
            A(iConstVal + 0,:) = [iConst + 0, iEnergyPerRoute(iBus,iRoute), 1];
            b(iConst + 0) = 0;
            iConstVal = iConstVal + 1;
            iConst = iConst + 1;
        elseif strcmp(Sim.sessStatus(iBus,iRoute),"USED")
            A(iConstVal + 0,:) = [iConst + 0, iEnergyPerRoute(iBus,iRoute), -1];
            b(iConst + 0) = -Sim.energyInSession(iBus,iRoute);
            iConstVal = iConstVal + 1;
            iConst = iConst + 1;
        else
            error("incorrect type of route")
        end      
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "constrain route energy appropriately";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end