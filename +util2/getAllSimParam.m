function Params = getAllSimParam(Sim, Var, x, nBusPerBatch, nChargePerBatch)
% determine number of buses in each group
nMinBus = floor(nBusPerBatch/2);
div = Sim.nBus/nBusPerBatch;
nGroup = ceil(div);
nBusPerGroup = repmat(nBusPerBatch,nGroup);
nChargePerGroup = repmat(nChargePerBatch,nGroup);
r = (div - floor(div))*nBusPerBatch;
if r < nMinBus
    nBusPerGroup(end) = r + nMinBus;    
    nBusPerGroup(end-1) = nBusPerGroup(end-1) - nMinBus;

    nChargeRemain = Sim.nCharger - sum(nChargePerGroup(1:end-2));
    nChargePerGroup(end-1) = floor(nChargeRemain/2);
    nChargePerGroup(end) = Sim.nCharger - sum(nChargePerGroup(1:end-1));
else
    nBusPerGroup(end) = r;
    nChargePerGroup(end) = Sim.nCharger - sum(nChargePerGroup(1:end-1));
end
busCounter = 1;
allParam = cell([nGroup,1]);

end