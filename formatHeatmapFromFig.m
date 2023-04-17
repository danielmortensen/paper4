files = ["\\wsl.localhost\ubuntu\home\dmortensen\paper4\results\GapComparisons\disoptimalRoutes",...
         "\\wsl.localhost\ubuntu\home\dmortensen\paper4\results\GapComparisons\optimizedRoutes"];
addpath('\\wsl.localhost\Ubuntu\home\dmortensen\paper4\documentation\MatlabScripts');
dt = 20; % in seconds
nTime = 3600*24/dt;
decimateBy = 32;
for iFile = 1:numel(files)
    fig = openfig(files(iFile) + ".fig");
    matlab2tikz();
%     data = fig.Children.Children.CData;
%     
%     nBus = size(data,1);
%     datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');  
%     times = datetime(1993,08,23);
%     offset = seconds((0:1:nTime - 1)/nTime*3600*24);
%     times = times + offset;
% 
%     % preallocate
%     busId = nan([nBus,nTime]);
%     busTime = strings([nBus,nTime]);
%     for iBus = 1:nBus
%         busId(iBus,:) = iBus;
%         busTime(iBus,:) = string(times);
%     end
%     busTime = busTime(:,1:decimateBy:end);
%     busTime = busTime(:);
%     busId = busId(:,1:decimateBy:end);
%     busId = busId(:);
%     data = data(:,1:decimateBy:end);
%     data = data(:);
%     t = table(busId, busTime, data,'VariableNames',{'BusId','Time','Charge'});
%     writetable(t, files(iFile) + ".csv");
end