% COMPARE Celestino Tower Precip Data to MyPrecipData from MAT Forest

%% Import MAT Forest Data
Convert_Rainfall_MAT_PAS_To_10min;

% Import Celestino Tower Data
load('CelestinoClean.mat');

% Plot  
% Rain Gauge (MyPrecip)
figure
plot(tenminutetime_MAT, tenminutetotal_MAT, celestino.dates, celestino.precip1);
legend('MyPrecipMAT', 'Celestino');