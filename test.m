if ~exist('dataOpt','var')
optimalPath = "\\wsl.localhost\ubuntu\home\dmortensen\paper4\results\LossType_fiscal_nBus_18_nCharger_6_nGroup_1_dt_20_minEnergy_0.00_proCost.mat";
disoptimalPath = "\\wsl.localhost\ubuntu\home\dmortensen\paper4\results\LossType_fiscal_nBus_18_nCharger_6_nGroup_1_dt_20_minEnergy_0.00_proTime.mat";
dataOpt = load(optimalPath);
dataDis = load(disoptimalPath);
end

pointOpt = getPoint(dataOpt);
pointDis = getPoint(dataDis);
figure; scatter(pointOpt(:,1),pointOpt(:,2),'blue');
hold on; scatter(pointDis(:,1), pointDis(:,2),'red'); 
xlabel('average charge rate'); ylabel('duration');
legend('optimal','disoptimal'); shg
set(gca,'xscale','log'); set(gca,'yscale','log');
tabOpt = array2table(pointOpt,'VariableNames',{'avgPower','duration'});
tabDis = array2table(pointDis,'VariableNames',{'avgPower','duration'});
writetable(tabOpt,'\\wsl.localhost\ubuntu\home\dmortensen\paper4\documentation\media\11_results\avgPowerVsDurationOpt.csv');
writetable(tabDis,'\\wsl.localhost\ubuntu\home\dmortensen\paper4\documentation\media\11_results\avgPowerVsDurationDis.csv');
% isScheduledOpt = optimalData.Sim7.routeIdx;
% scheduleOpt = optimalData.Sol7(optimalData.Var7.schedule);
% nSessionOpt = optimalData.Sim7.nSession;
% nBusOpt = optimalData.Sim7.nBus;
% pointsOpt = zeros([sum(nSessionOpt),2]);
% startOpt = optimalData.Sols5{1}.x(optimalData.Vars5{1}.sessStart);
% finalOpt = optimalData.Sols5{1}.x(optimalData.Vars5{1}.sessFinal);
% deltaTSec = optimalData.Sim1.deltaTSec;
% iPoint = 1;
% for iBus = 1:nBusOpt
%     busSchedule = squeeze(scheduleOpt(iBus,:));
%     for iSession = 1:nSessionOpt(iBus)
%         timeIdx = isScheduledOpt(iBus,iSession);
%         nTime = sum(timeIdx);
%         mu = (timeIdx*busSchedule')/nTime;
%         dt = nTime*deltaTSec;
%         pointsOpt(iPoint,:) = [mu, dt];
%     end
% end




function point = getPoint(data)
isScheduled = data.Sim7.routeIdx;
schedule = data.Sol7.x(data.Var7.schedule);
nSession = data.Sim7.nSession;
nBus = data.Sim7.nBus;
point = zeros([sum(nSession),2]);
deltaTSec = data.Sim1.deltaTSec;
iPoint = 1;
for iBus = 1:nBus
    busSchedule = squeeze(schedule(iBus,:));
    for iSession = 1:nSession(iBus)
        timeIdx = logical(squeeze(isScheduled(iBus,iSession,:)));
        val = busSchedule(timeIdx);
        nTime = sum(val > 0);
        mu = sum(val)/nTime;
        dt = nTime*deltaTSec;
        energy = mu*dt/3600;
        
        if energy > 1
            point(iPoint,:) = [mu, dt];
            iPoint = iPoint + 1;
        end
    end
end
point = point(1:iPoint - 1,:);
end