function [A, b, nConst, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
nAllBus = sum(Sim.nBus);
nConst = 5*Var.nV;
nConstVal = 9*Var.nV;
b = nan([nConst,1]);
A = nan([nConstVal,3]);
iV = Var.v;
iSigma = Var.sigma;
M = Sim.M;

iConst = 1;
iConstVal = 1;
for  iBus = 1:nAllBus
    for jBus = iBus + 1:nAllBus
        for iGroup = 1:Sim.nGroup
            % first constraint
            A(iConstVal + 0,:) = [iConst + 0, iV(iBus,jBus,iGroup), 1];
            b(iConst) = Sim.A(iBus,jBus);

            % second constraint
            A(iConstVal + 1,:) = [iConst + 1, iV(iBus,jBus,iGroup), -1];
            A(iConstVal + 2,:) = [iConst + 1, iSigma(iBus, iGroup), M];
            A(iConstVal + 3,:) = [iConst + 1, iSigma(jBus, iGroup), M];
            b(iConst + 1) = 2*M - Sim.A(iBus,jBus);

            % third constraint
            A(iConstVal + 4,:) = [iConst + 2, iV(iBus,jBus,iGroup), 1];
            A(iConstVal + 5,:) = [iConst + 2, iSigma(iBus,iGroup), -M];
            b(iConst + 2) = 0;

            % fourth constraint
            A(iConstVal + 6,:) = [iConst + 3, iV(iBus,jBus,iGroup), 1];
            A(iConstVal + 7,:) = [iConst + 3, iSigma(jBus,iGroup), -M];
            b(iConst + 3) = 0;

            % fifth constraint
            A(iConstVal + 8,:) = [iConst + 4, iV(iBus,jBus,iGroup), -1];
            b(iConst + 4) = 0;

            % update loop variables
            iConstVal = iConstVal + 9;
            iConst = iConst + 5;
        end
    end
end

% double check that each constraint was set as expected
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
if nConst > 0
    assert(max(A(:,1)) == nConst);
    assert(numel(b) == nConst);
end

descr = "constrain loss variable 'v' ";
eq = repmat('<',[nConst,1]);

A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);

end