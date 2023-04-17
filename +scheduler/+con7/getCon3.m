function [A, b, nConst, descr, eq] = getCon3(Sim, Var)
% unpack relevent values
nConst = 2*sum(Sim.nSession);
nConstVal = 4*sum(Sim.nSession);
nSession = Sim.nSession;
nCharger = Sim.nCharger;
iStart = Var.sessStart;
iFinal = Var.sessFinal;
sessions = Sim.chargeSession;

%preallocate 
A = nan([nConstVal, 3]);
b = nan([nConst,1]);
iConst = 1;
iConstVal = 1;

% set constraint
for iCharger = 1:nCharger
    for iSession = 1:nSession(iCharger)
        if iSession == nSession(iCharger)
            session = sessions(iCharger,iSession);
            session = session{1};
            A(iConstVal + 0,:) = [iConst, iFinal(iCharger,iSession),1];
            b(iConst) = session.tDepart;
            iConst = iConst + 1;
            iConstVal = iConstVal + 1;
        else
            session1 = sessions(iCharger,iSession); 
            session1 = session1{1};
            session2 = sessions(iCharger,iSession + 1); 
            session2 = session2{1};
            if iSession == 1
                A(iConstVal + 0,:) = [iConst + 0, iStart(iCharger,iSession),1];
                b(iConst) = session1.tArrive;
                iConst = iConst + 1;
                iConstVal = iConstVal + 1;
            end       
            if session2.tArrive < session1.tDepart
                A(iConstVal + 0,:) = [iConst + 0, iStart(iCharger, iSession + 1),1];
                A(iConstVal + 1,:) = [iConst + 0, iFinal(iCharger, iSession),   -1];
                b(iConst + 0) = 0;
                iConstVal = iConstVal + 2;
                iConst = iConst + 1;
            else
                A(iConstVal + 0,:) = [iConst + 0, iStart(iCharger, iSession + 1) 1];
                b(iConst + 0) = session2.tArrive;
                A(iConstVal + 1,:) = [iConst + 1, iFinal(iCharger, iSession), 1];
                b(iConst + 1) = session1.tDepart;
                iConst = iConst + 2;
                iConstVal = iConstVal + 2;
            end
        end       
    end
end

A  = A(1:iConstVal - 1,:);
b = b(1:iConst - 1);
nConst = iConst - 1;

% verify constraint with sanity check
assert(~any(isnan(A(:))));
assert(~any(isnan(b)));  
assert(max(A(:,1)) == nConst);
assert(numel(b) == nConst);


descr = "expand to fill empty space on chargers";
eq = repmat('=',[nConst,1]);
A = sparse(A(:,1), A(:,2), A(:,3), nConst, Var.nVar);
end