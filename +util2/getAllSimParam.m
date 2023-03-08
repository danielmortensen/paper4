function Params = getAllSimParam(Sim, Var, x, groups)
% determine number of buses and chargers in each group

% compute parameters for each group
Params = cell([groups.nGroup,1]);
for iGroup = 1:groups.nGroup
    subsim.busId = find(groups.groupId == iGroup); ...busId(counter:counter + nBus(iGroup) - 1);
    subsim.nBus = numel(subsim.busId);
    subsim.nCharger = groups.nCharger(iGroup);
    subsim.deltaTSec = Sim.deltaTSec;
    subsim.nRoute = Sim.nRoute(subsim.busId);
    subsim.tDepart = Sim.tDepart(subsim.busId,:);
    subsim.tArrive = Sim.tArrive(subsim.busId,:);
    subsim.pMaxKW = Sim.pMaxKW;
    Params{iGroup} = util2.getSimParam(subsim,Var,x);
    Params{iGroup}.busId = subsim.busId;
end
end