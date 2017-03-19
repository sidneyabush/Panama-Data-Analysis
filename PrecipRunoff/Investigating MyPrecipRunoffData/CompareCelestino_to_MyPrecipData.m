% COMPARE Celestino Tower Precip Data to MyPrecipData from MAT Forest

%% Import MAT Forest Data
% Convert_Rainfall_MAT_PAS_To_10min;

%Load the mat file containing Precip and TB runoff
% Change this to Guabo
GCFile = 'DataAndImport/GuaboCamp/CleanedData/GCClean.mat';
load(GCFile);

% Import Celestino Tower Data
load('CelestinoClean.mat');

% Plot  
% Rain Gauge (MyPrecip)
figure
plot(gc.timeStamps, gc.precipMM, celestino.dates, celestino.precip1);
legend('GuaboCamp', 'Celestino');