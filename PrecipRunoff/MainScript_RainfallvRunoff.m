clear all;
close all;
%% Import Level Logger Data
% Forest Upper, Middle LL Data
cleanedLLDataFile = 'LL Negative Cleaning/CleanedData/allLL.mat';
% This will load the allLL structure here so we can use it
load(cleanedLLDataFile);
% SOMETHING BROKEN? Maybe uncomment this...
% ForLow_LL_Runoff;

%% Import Precip Rain Gauge Data
% Forest and Pasture
Convert_Rainfall_MAT_PAS_To_10min;

%% Plot Forest Whole Summer
% Forest Rainfall vs. Forest Upper Runoff, Middle Runoff Totals
% Rain Gauge
plot(tenminutetime_MAT, tenminutetotal_MAT);
hold on 
% Runoff
% Upper
plot(allLL.forUpLL.timeStamp, allLL.forUpLL.heightMM)
% Middle 
plot(allLL.forMidLL.timeStamp, allLL.forMidLL.heightMM)
% Lower
plot(allLL.forLowLL.timeStamp, allLL.forLowLL.heightMM);
legend('Rainfall Total','Runoff Upper', 'Runoff Middle','Runoff Lower')
title('Rainfall & Runoff for Mature Forest')
ylabel('Rainfall/Runoff (mm)')
xlabel('Time')

%% Double Plot of Precip and Runoff for Forest Summer 2016
width= 0.92;
height= 0.4;
leftcorner=0.05;
bottomcorner1=0.5;
bottomcorner2=bottomcorner1-height;
linewidth = 3;
titleFontSize = 20;
axisFontSize = 15;

figure('units','normalized','outerposition',[0 0 1 1])
clf

%This is the first part of the subplot - precip
ax(1)= axes('position',[leftcorner bottomcorner1 width height]);
plot(tenminutetime_MAT, tenminutetotal_MAT, 'LineWidth', linewidth);
currentYTicks = get(gca, 'YTick');
% Remove the last tick that would overlap with the bottom graph tick
set(gca, 'YTick', currentYTicks(1:end-1));
set(gca,'ydir','reverse');
linkaxes(ax,'x');
%xlim([736470 736540]);
xlim(datetime(2016,[5 7],[22 28]))
%beginTime='22/05/2016 00:00:00';
%endTime= '28/07/2016 00:00:00';
%set(gca, 'XLim', [22/05/2016 00:00:00 28/07/2016 00:00:00]);
ylabel('Rainfall (mm)')
title('Rainfall & Runoff for Mature Forest', 'FontSize', titleFontSize)
set(gca,'xtick',[])
set(gca, 'xticklabel',[])
set(gca,'FontSize',axisFontSize)

% This is the second part of the subplot - runoff
ax(2)= axes('position',[leftcorner bottomcorner2 width height]);
% Upper
plot(allLL.forUpLL.timeStamp, allLL.forUpLL.heightMM, 'LineWidth', linewidth)
hold on
% Middle 
plot(allLL.forMidLL.timeStamp, allLL.forMidLL.heightMM, 'LineWidth', linewidth)
% Lower
plot(allLL.forLowLL.timeStamp, allLL.forLowLL.heightMM, 'LineWidth', linewidth);
linkaxes(ax,'x');
%xlim([736470 736540]);
xlim(datetime(2016,[5 7],[22 28]))
currentYTicks = get(gca, 'YTick');
% Remove the last tick that would overlap with the top graph tick
set(gca, 'YTick', currentYTicks(1:end-1));
set(gca,'FontSize',axisFontSize)

%set(gca, 'XLim', [22/05/2016 00:00:00 28/07/2016 00:00:00]);
legend('Runoff Upper', 'Runoff Middle','Runoff Lower')
ylabel('Runoff (mm)')
xlabel('Time')

%% Plot Pasture Whole Summer
% Rain Gauge (Precip)
figure
plot(tenminutetime_PAS, tenminutetotal_PAS);
hold on
% Upper
plot(allLL.pasUpLL.timeStamp, allLL.pasUpLL.heightMM)
% Middle 
plot(allLL.pasMidLL.timeStamp, allLL.pasMidLL.heightMM)
% Lower
plot(allLL.pasLowLL.timeStamp, allLL.pasLowLL.heightMM);

legend('Rainfall Total','Runoff Upper Pasture', 'Runoff Middle Pasture','Runoff Lower Pasture')
title('Rainfall & Runoff for Pasture')
ylabel('Rainfall/Runoff (mm)')
xlabel('Time')

%% Double Plot Pasture Whole Summer

width= 0.92;
height= 0.4;
leftcorner=0.05;
bottomcorner1=0.5;
bottomcorner2=bottomcorner1-height;
linewidth = 3;
titleFontSize = 20;
axisFontSize = 15;

figure('units','normalized','outerposition',[0 0 1 1])
clf

%This is the first part of the subplot - precip
ax(1)= axes('position',[leftcorner bottomcorner1 width height]);
plot(tenminutetime_PAS, tenminutetotal_PAS, 'LineWidth', linewidth);
currentYTicks = get(gca, 'YTick');
% Remove the last tick that would overlap with the bottom graph tick
set(gca, 'YTick', currentYTicks(1:end-1));
set(gca,'ydir','reverse');
linkaxes(ax,'x');
%xlim([736470 736540]);
xlim(datetime(2016,[5 7],[22 28]))
%beginTime='22/05/2016 00:00:00';
%endTime= '28/07/2016 00:00:00';
%set(gca, 'XLim', [22/05/2016 00:00:00 28/07/2016 00:00:00]);
ylabel('Rainfall (mm)')
title('Rainfall & Runoff for Pasture', 'FontSize', titleFontSize)
set(gca,'xtick',[])
set(gca, 'xticklabel',[])
set(gca,'FontSize',axisFontSize)


% This is the second part of the subplot - runoff
ax(2)= axes('position',[leftcorner bottomcorner2 width height]);
% Upper
plot(allLL.pasUpLL.timeStamp, allLL.pasUpLL.heightMM, 'LineWidth', linewidth)
hold on
% Middle 
plot(allLL.pasMidLL.timeStamp, allLL.pasMidLL.heightMM, 'LineWidth', linewidth)
% Lower
plot(allLL.pasLowLL.timeStamp, allLL.pasLowLL.heightMM, 'LineWidth', linewidth);

linkaxes(ax,'x');
%xlim([736470 736540]);
xlim(datetime(2016,[5 7],[22 28]))
currentYTicks = get(gca, 'YTick');
% Remove the last tick that would overlap with the top graph tick
set(gca, 'YTick', currentYTicks(1:end-1));
%set(gca, 'XLim', [22/05/2016 00:00:00 28/07/2016 00:00:00]);
set(gca,'FontSize',axisFontSize)
legend('Runoff Upper', 'Runoff Middle','Runoff Lower')
ylabel('Runoff (mm)')
xlabel('Time')
%% Plot single event on July 9, 2016 - Forest (GOOD)
testStart = datetime('9-Jul-2016 11:00:00');
testEnd= datetime('9-Jul-2016 14:45:00');
dates = [testStart testEnd];
legendStrings = {'Rainfall Total','Runoff Upper', 'Runoff Middle', 'Runoff Lower'};
plotTitle = 'Rainfall & Runoff for July 9th Event - Mature Forest';
timeValPairs = {{tenminutetime_MAT, tenminutetotal_MAT}, 
                {allLL.forUpLL.timeStamp, allLL.forUpLL.heightMM}, 
                {allLL.forMidLL.timeStamp, allLL.forMidLL.heightMM},
                {allLL.forLowLL.timeStamp, allLL.forLowLL.heightMM}};
jul9ForestRR = PlotRainfallEvent(dates, legendStrings, plotTitle, timeValPairs)

%% Plot single event on July 9, 2016 - Pasture with PlotRainfallEvents
testStart = datetime('9-Jul-2016 11:15:00');
testEnd= datetime('9-Jul-2016 14:45:00');
dates = [testStart testEnd];
legendStrings = {'Rainfall Total','Runoff Upper', 'Runoff Middle', 'Runoff Lower'};
plotTitle = 'Rainfall & Runoff for July 9th Event - Pasture';
timeValPairs = {{tenminutetime_PAS, tenminutetotal_PAS}, 
                {allLL.pasUpLL.timeStamp, allLL.pasUpLL.heightMM}, 
                {allLL.pasMidLL.timeStamp, allLL.pasMidLL.heightMM},
                {allLL.pasLowLL.timeStamp, allLL.pasLowLL.heightMM}};

jul9PastureRR = PlotRainfallEvent(dates, legendStrings, plotTitle, timeValPairs)


%% Plot single event on June 19th - Forest
testStart = datetime('19-Jun-2016 9:00:00');
testEnd= datetime('19-Jun-2016 12:15:00');
dates = [testStart testEnd];
legendStrings = {'Rainfall Total','Runoff Upper', 'Runoff Middle', 'Runoff Lower'};
plotTitle = 'Rainfall & Runoff for June 19th Event - Mature Forest';
timeValPairs = {{tenminutetime_MAT, tenminutetotal_MAT}, 
                {allLL.forUpLL.timeStamp, allLL.forUpLL.heightMM}, 
                {allLL.forMidLL.timeStamp, allLL.forMidLL.heightMM},
                {allLL.forLowLL.timeStamp, allLL.forLowLL.heightMM}};

jun19ForestRR = PlotRainfallEvent(dates, legendStrings, plotTitle, timeValPairs)


%% Plot single event on Jun 19th - PAS
jun19Start = datetime('19-Jun-2016 9:00:00');
jun19End= datetime('19-Jun-2016 12:15:00');
dates = [jun19Start jun19End];
legendStrings = {'Rainfall Total','Runoff Upper', 'Runoff Middle', 'Runoff Lower'};
plotTitle = 'Rainfall & Runoff for June 19th Event - Pasture';
timeValPairs = {{tenminutetime_PAS, tenminutetotal_PAS}, 
                {allLL.pasUpLL.timeStamp, allLL.pasUpLL.heightMM}, 
                {allLL.pasMidLL.timeStamp, allLL.pasMidLL.heightMM},
                {allLL.pasLowLL.timeStamp, allLL.pasLowLL.heightMM}};
jun19PastureRR = PlotRainfallEvent(dates, legendStrings, plotTitle, timeValPairs)

%% Plot Hyetograph for Forest
figure
plot(tenminutetime_MAT, tenminutetotal_MAT, 'linewidth',4);
title('Mature Forest Hyetograph', 'fontsize', 20)
set(gca,'FontSize',15)
xlhand = get(gca,'xlabel')
set(xlhand,'string','Time','fontsize',20)
yhand = get(gca,'ylabel')
set(yhand,'string','Precipitation (mm)','fontsize',20)
ylim([0 20])

%% Plot Hyetograph for Pasture
figure
plot(tenminutetime_PAS, tenminutetotal_PAS, 'LineWidth', 4);
title('Pasture Hyetograph', 'FontSize',20)
set(gca,'FontSize',15)
xlhand = get(gca,'xlabel')
set(xlhand,'string','Time','fontsize',20)
yhand = get(gca,'ylabel')
set(yhand,'string','Precipitation (mm)','fontsize',20)
ylim([0 20])

%% Plot Rainfall Rates for Forest
figure
plot(tenminutetime_MAT, tenminuterate_MAT, 'LineWidth', 4);
title('Mature Forest Rainfall Rates', 'FontSize', 20)
set(gca,'FontSize',15)
xlhand = get(gca,'xlabel');
set(xlhand,'string','Time','fontsize',20)
yhand = get(gca,'ylabel');
set(yhand,'string','Precipitation (mm/hr)','fontsize',20)
ylim([0 120])

%% Plot Rainfall Rates for Pasture
figure
plot(tenminutetime_PAS, tenminuterate_PAS,'LineWidth',4);
title('Pasture Rainfall Rates', 'FontSize', 20)
set(gca,'FontSize',15)
xlhand = get(gca,'xlabel')
set(xlhand,'string','Time','fontsize',20)
yhand = get(gca,'ylabel')
set(yhand,'string','Precipitation (mm/hr)','fontsize',20)
ylim([0 120])

%% Calculate Whole Summer Forest Runoff Ratios 
% Forest Upper - Whole Summer
totalforuprunoff= sum(allLL.forUpLL.heightMM);
totalforupprecip= sum(tenminutetotal_MAT);
foruprunoffcoeff= totalforuprunoff/totalforupprecip;
disp(['forest upper runoff coefficient - whole summer: ' num2str(foruprunoffcoeff)]);

% Forest Middle - Whole Summer
totalformidrunoff= sum(allLL.forMidLL.heightMM);
totalformidprecip= sum(tenminutetotal_MAT);
formidrunoffcoeff= totalformidrunoff/totalformidprecip;
disp(['forest middle runoff coefficient - whole summer: ' num2str(formidrunoffcoeff)]);

% Forest Lower - Whole Summer
totalforlowrunoff= sum(allLL.forLowLL.heightMM);
totalforlowprecip= sum(tenminutetotal_MAT);
forlowrunoffcoeff= totalforlowrunoff/totalforlowprecip;
disp(['forest middle runoff coefficient - whole summer: ' num2str(forlowrunoffcoeff)]);

% Forest Average Runoff Ratio- whole summer
forRunoffAverage = mean([totalforuprunoff, totalformidrunoff, totalforlowrunoff]);
allSummerForestRatio = forRunoffAverage/sum(tenminutetotal_MAT);
disp(['Forest runoff coefficient for whole summer (average of site runoffs): ' num2str(allSummerForestRatio)]);

%% Calculate Whole Summer Pasture Runoff Ratios 
% Pasture Upper - Whole Summer
totalpasuprunoff= sum(allLL.pasUpLL.heightMM);
totalpasupprecip= sum(tenminutetotal_PAS);
pasuprunoffcoeff= totalpasuprunoff/totalpasupprecip;
disp(['Pasture upper runoff coefficient - whole summer: ' num2str(pasuprunoffcoeff)]);

% Pasture Middle - Whole Summer
totalpasmidrunoff= sum(allLL.pasMidLL.heightMM);
totalpasmidprecip= sum(tenminutetotal_PAS);
pasmidrunoffcoeff= totalpasmidrunoff/totalpasmidprecip;
disp(['Pasture middle runoff coefficient - whole summer: ' num2str(pasmidrunoffcoeff)]);

% Pasture Lower - Whole Summer
totalpaslowrunoff= sum(allLL.pasLowLL.heightMM);
totalpaslowprecip= sum(tenminutetotal_PAS);
paslowrunoffcoeff= totalpaslowrunoff/totalpaslowprecip;
disp(['Pasture middle runoff coefficient - whole summer: ' num2str(paslowrunoffcoeff)]);

% Pasture Average Runoff Ratio- whole summer
pasRunoffAverage = mean([totalpasuprunoff, totalpasmidrunoff, totalpaslowrunoff]);
allSummerPastureRatio = pasRunoffAverage/sum(tenminutetotal_PAS);
disp(['Pasture runoff coefficient for whole summer (average of site runoffs): ' num2str(allSummerPastureRatio)]);
