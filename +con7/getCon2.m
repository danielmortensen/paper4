function [A, b, nConst, descr, eq] = getCon2(Sim, Var)
% unpack relevent values
nConst = sum(Sim.nSession);
nConstVal = 2*sum(Sim.nSession);
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
        A(iConstVal + 0,:) = [iConst + 0, iStart(iCharger, iSession),  1];
        A(iConstVal + 1,:) = [iConst + 0, iFinal(iCharger, iSession), -1];
        b(iConst) = -(session.mWidth - 1e-3);       

        iConstVal = iConstVal + 2;
        iConst = iConst + 1;
    end
end

% verify constraint with sanity check
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "charge session within minimum width";
eq = repmat('<',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end