function [A, b, nConst, descr, eq] = getCon1(Sim, Var)
% unpack relevent values
nConst = 3*sum(Sim.nSession);
nConstVal = 4*sum(Sim.nSession);
nSession = Sim.nSession;
nCharger = Sim.nCharger;
iStart = Var.sessStart;
iFinal = Var.sessFinal;

%preallocate 
A = nan([nConstVal, 3]);
b = nan([nConst,1]);
iConst = 1;
iConstVal = 1;

% set constraint
for iCharger = 1:nCharger
    for iSession = 1:nSession(iCharger)
        session = Sim.chargeSession(iCharger,iSession);
        session = session{1};
        A(iConstVal + 0,:) = [iConst + 0, iStart(iCharger, iSession), -1];
        b(iConst + 0) = -(session.tArrive - 1e-3);

        A(iConstVal + 1,:) = [iConst + 1, iStart(iCharger, iSession),  1];
        A(iConstVal + 2,:) = [iConst + 1, iFinal(iCharger, iSession), -1];
        b(iConst + 1) = 0;

        A(iConstVal + 3,:) = [iConst + 2, iFinal(iCharger, iSession),  1];
        b(iConst + 2) = session.tDepart + 1e-3;

        iConstVal = iConstVal + 4;
        iConst = iConst + 3;
    end
end

% verify constraint with sanity check
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "charge sessions within bounds";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end