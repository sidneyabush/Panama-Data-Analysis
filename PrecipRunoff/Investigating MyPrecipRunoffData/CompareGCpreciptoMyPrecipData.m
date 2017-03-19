% Compare GC precip data to MyPrecipData

%% Import reference timestamps, eg. allTB.PAS_TimeStamp_10min. 

%Load the mat file containing Precip and TB runoff. 
TBFile = 'TippingBucketCleaning/CleanedData/allTB.mat';
load(TBFile);

% Import Guabo Camp
GCFile = 'DataAndImport/GuaboCamp/CleanedData/GCClean.mat';
load(GCFile);

%% Plot Pasture Whole Summer
% Rain Gauge (Precip)
figure
plot(allTB.PAS_TimeStamp_10min, allTB.PAS_Precip_10min, gc.timeStamps, gc.precipMM);
legend('MyPrecip', 'GuaboCamp');
