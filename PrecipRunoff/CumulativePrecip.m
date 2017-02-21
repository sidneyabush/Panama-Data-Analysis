% Calculate cumulative rainfall for pasture and forest

clear all;
close all;

% Import forest
% [MatPrecip_Times,~,MatPrecip_Precip,~,~,~] = importForest('PrecipRunoff_Mature_CombinedOLD.csv',5, 31878);
load MAT_Precip.mat
cumulativeForestPrecip = cumsum(MatPrecip_Precip);
% figure;
% plot(MatPrecip_Times, cumulativeForestPrecip);

% Import pasture
%[PasPrecip_Times,~,PasPrecip_Precip,~,~,~] = importPasture('PrecipRunoff_Pasture_Combined.csv',5, 36884);
load PAS_Precip.mat
% Need to convert PasPrecip_Times from cell to datetime
PasPrecip_Times = datetime(PasPrecip_Times, 'InputFormat', '"yyyy-MM-dd HH:mm:ss"');
cumulativePasPrecip_Precip = cumsum(PasPrecip_Precip);
% hold on;
% plot(PasPrecip_Times, cumulativePasPrecip_Precip);
% hold off;
% legend('Forest', 'Pasture', 'Location', 'northwest');

% Plot cumulative precipitation for pasture and forest only after a certain
% date
startDate = {'22/05/2016'};
startDate = datetime(startDate, 'InputFormat', 'dd/MM/yyyy');
% Find the index of the first date in the pasture after our start date so
% we can plot just the times/sums after it
pastureStartDateIdx = find(PasPrecip_Times > startDate, 1);
forestStartDateIdx = find(MatPrecip_Times > startDate, 1);

figure;
plot(MatPrecip_Times(forestStartDateIdx:end), cumulativeForestPrecip(forestStartDateIdx:end),'LineWidth',2);
hold on;
plot(PasPrecip_Times(pastureStartDateIdx:end), cumulativePasPrecip_Precip(pastureStartDateIdx:end),'LineWidth',2);
hold off;

AX=legend('Forest', 'Pasture', 'Location', 'northwest');
set(AX,'FontSize',10);

ylabel('Precipitation (mm)');
xlabel('Time');
title('Cumulative Precipitation for Mature Forest and Pasture', 'fontsize',3);
set(gca,'FontSize',10);
xlhand = get(gca,'xlabel');
set(xlhand,'string','Time','fontsize',10);
yhand = get(gca,'ylabel');
set(yhand,'string','Precipitation (mm)','fontsize',10);
