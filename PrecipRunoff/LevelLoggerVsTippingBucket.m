% Plot mm as determined by level logger vs mm as determined by
% tipping bucket. This will help determine whether one or the other
% functioned more reliably. 
close all;
clear all;

% Calculate what 0.2mm of precip as measured by the rain gauge equates to
% in terms of mm precip that fell on the runoff plot
areaRunoff = 156850; 
diameterRainGauge = 153.924;
areaRainGauge = pi*(diameterRainGauge/2)^2;
mmRunoff = 0.2 * areaRainGauge/areaRunoff;

% Determine a conversion factor between the mm reported by the level logger
% and the volume that actually corresponds to. For now, assuming that the
% conversion factor is the same for all level loggers in all locations. 
[slope, intercept] = AnalyzeLLCal;

% Import the level logger data for the forest
[llUpForScans,llUpForDatetime,llUpForDate,llUpForTime,llUpForRaw,llUpForMM] = importLLForUp('LL_FORESTUPPER_Combined.csv',5, 9602);

% Convert level logger mm to volumes
llVolume = slope.*llUpForMM + intercept;

% Convert level logger volume(in L) to mm of precip that fell on the runoff plot
llMMRunoff = llVolume.*1000/areaRunoff;

% Import the tipping bucket data for the forest 
[forestTIMESTAMP,forestRECORD,forestPrecip_Tot,forest_Up_Tot,forest_Mid_Tot,forest_Low_Tot] = import_MAT_PAS_TippingBucket('PrecipRunoff_Mature_Combined.csv',1, 31877);

% convert mm rainguage to mm of precip that fell on the runoff plot
conversionfactor = 0.11875;
forest_Up_Tot = forest_Up_Tot * conversionfactor;

plot(llUpForDatetime, llMMRunoff,forestTIMESTAMP, forest_Up_Tot);
legend('Level Logger', 'Tipping Bucket');
title('Forest Upper Runoff');
