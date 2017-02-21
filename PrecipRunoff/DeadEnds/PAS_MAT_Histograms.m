% Clean workspace
close all;
clear all;
% Import mature forest data
% [~,~,MAT_Precip,~, ~,~] = import_mature('PrecipRunoff_Mature_Combined.csv',1, 31877);
load('MAT_Precip.mat');
% Import pasture data
% [~,~,PAS_Precip,~,~,~] = import_pasture('PAS_PrecipRunoffOLD.csv',5, 36884);
load('PAS_Precip.mat');


% Generate histogram for pasture precipitation
pas_precip_hist = histogram(PasPrecip_Precip(PasPrecip_Precip ~= 0));
current_fig = gcf; 
current_fig.Name = 'Pasture Precipitation Histogram';
title('Pasture');
set(gca,'FontSize',10);
xlhand = get(gca,'xlabel');
set(xlhand,'string','Daily Rainfall (mm)','fontsize',10);
yhand = get(gca,'ylabel');
set(yhand,'string','Frequency','fontsize',10);
xlim([0 20]);
ylim([0 1000]);

% Generate histogram for mature forest precipitation
figure;
mat_precip_hist = histogram(MatPrecip_Precip(MatPrecip_Precip ~= 0));
current_fig = gcf; 
current_fig.Name = 'Mature Forest Precipitation Histogram';
title('Mature Forest');
set(gca,'FontSize',10);
xlhand = get(gca,'xlabel');
set(xlhand,'string','Daily Rainfall (mm)','fontsize',10);
yhand = get(gca,'ylabel');
set(yhand,'string','Frequency','fontsize',10);
xlim([0 20]);
ylim([0 1000]);

% Generate histogram for pasture lower runoff
% figure;
% pas_lower_hist = histogram(PAS_Lower(PAS_Lower ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Pasture Lower Runoff Histogram';

% Generate histogram for pasture middle runoff
% figure;
% pas_middle_hist = histogram(PAS_Middle(PAS_Middle ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Pasture Middle Runoff Histogram';

% Generate histogram for pasture upper runoff
% figure;
% pas_upper_hist = histogram(PAS_Upper(PAS_Upper ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Pasture Upper Runoff Histogram';




% Generate histogram for mature forest lower runoff
% figure;
% mat_lower_hist = histogram(MAT_Lower(MAT_Lower ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Mature Forest Lower Runoff Histogram';
% 
% % Generate histogram for mature forest middle runoff
% figure;
% mat_middle_hist = histogram(MAT_Middle(MAT_Middle ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Mature Forest Middle Runoff Histogram';
% 
% % Generate histogram for mature forest upper runoff
% figure;
% mat_upper_hist = histogram(MAT_Upper(MAT_Upper ~=0)); 
% current_fig = gcf; 
% current_fig.Name = 'Mature Forest Upper Runoff Histogram';
