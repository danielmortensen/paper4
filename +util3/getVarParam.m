function Var = getVarParam(Sim)
% unpack
nTime = size(Sim.schedule,2);
A = Sim.A;
nAllBus = sum(Sim.nBus);
nGroup = Sim.nGroup;

% compute variable indices
start = 1;
final = start + (numel(A) - nAllBus)*nGroup/2;
idx = start:final - 1;
counter = 1;
v = nan([size(A),nGroup]);
for iBus = 1:nAllBus
    for jBus = iBus + 1:nAllBus
        for iGroup = 1:nGroup
            v(iBus,jBus,iGroup) = idx(counter);
            v(jBus,iBus,iGroup) = idx(counter);
            counter = counter + 1;
        end
    end
end
start = final;
Var.v = v;
Var.vtype = repmat('C',[counter - 1,1]);
Var.nV = counter - 1;

% compute indicator indices
final = start + nAllBus*nGroup;
Var.sigma = reshape(start:final - 1,[nAllBus,nGroup]);
Var.sigmatype = repmat('B',[numel(Var.sigma),1]);
Var.nSigma = numel(Var.sigma);
start = final;

% variables for total power use in each group
final = start + nTime*nGroup - 1;
Var.group = reshape(start:final,[nGroup,nTime]);
Var.grouptype = repmat('C',[nGroup*nTime,1]);
Var.nGroup = nGroup*nTime;
start = final + 1;

% variables for number of chargers assigned to each group
final = start + nGroup - 1;
Var.charger = start:final;
Var.nCharger = nGroup;
Var.chargertype = repmat('I',[nGroup,1]);


Var.nVar = Var.nV + Var.nSigma + Var.nGroup + Var.nCharger;

end