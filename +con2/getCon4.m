function [A, b, nConst, descr, eq] = getCon4(Sim, Var)
% unpack relevent values
iF = Var.f;
iB = Var.b; 
iSigma = Var.sigma;
M = 3600*24; % number of seconds in a day
iL = Var.l;
nMayConflict = Sim.nMayConflict;
nCharger = Sim.nCharger;
nBus = Sim.nBus;

% preallocate loop variables
nConstVal = 2*nMayConflict*nCharger*5;
nConst = 2*nMayConflict*nCharger;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iConst = 1;
iConstVal = 1;
for  iBus1 = 1:Sim.nBus
    for iRoute1 = 1:Sim.nRoute(iBus1)   
        for iBus2 = iBus1 + 1:nBus
            for iRoute2 = 1:Sim.nRoute(iBus2)
                if Sim.mayConflict(iBus1,iRoute1,iBus2,iRoute2)
                    for iCharger = 1:nCharger
                        A(iConstVal + 0,:) = [iConst + 0, iF(iBus1,iRoute1),  1];
                        A(iConstVal + 1,:) = [iConst + 0, iB(iBus2,iRoute2), -1];
                        A(iConstVal + 2,:) = [iConst + 0, iSigma(iBus1,iRoute1,iCharger),  M];
                        A(iConstVal + 3,:) = [iConst + 0, iSigma(iBus2,iRoute2,iCharger),  M];
                        A(iConstVal + 4,:) = [iConst + 0, iL(iBus1,iRoute1,iBus2,iRoute2), M];
                        b(iConst + 0) = 3*M;

                        A(iConstVal + 5,:) = [iConst + 1, iF(iBus2,iRoute2),  1];
                        A(iConstVal + 6,:) = [iConst + 1, iB(iBus1,iRoute1), -1];
                        A(iConstVal + 7,:) = [iConst + 1, iSigma(iBus1,iRoute1,iCharger),   M];
                        A(iConstVal + 8,:) = [iConst + 1, iSigma(iBus2,iRoute2,iCharger),   M];
                        A(iConstVal + 9,:) = [iConst + 1, iL(iBus1,iRoute1,iBus2,iRoute2), -M];
                        b(iConst + 1) = 2*M;

                        iConst = iConst + 2;
                        iConstVal = iConstVal + 10;
                    end
                end
            end
        end
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "resolve conflict";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end