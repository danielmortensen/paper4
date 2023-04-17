function Param = getVarParam(Sim)
%get parameters for start times
nSession = Sim.nSession;
nCharger = Sim.nCharger;

% parameters for start times
sVar = 1;
fVar = sVar + sum(nSession) - 1;
Param.sessStart = nan([nCharger,max(nSession)]);
idx = sVar:fVar;
counter = 1;
for iCharger = 1:nCharger
    for iSession = 1:nSession(iCharger)
        Param.sessStart(iCharger,iSession) = idx(counter);
        counter = counter + 1;
    end
end


% parameters for 'finish' times
sVar = fVar + 1;
fVar = sVar + sum(nSession) - 1;
Param.sessFinal = nan([nCharger,max(nSession)]);
idx = sVar:fVar;
counter = 1;
for iCharger = 1:nCharger
    for iSession = 1:nSession(iCharger)
        Param.sessFinal(iCharger,iSession) = idx(counter);
        counter = counter + 1;
    end
end

Param.nVar = fVar;
end