% Import ALL MAT tipping bucket data (precip & runoff)
[TIMESTAMP,RECORD,Precip_Tot,TR525_Up_Tot,TR525_Mid_Tot,TR525_Low_Tot] = import_MAT_PAS_TippingBucket('PrecipRunoff_Mature_Combined.csv',1, 31877);

% Multiply Tipping Bucket Runoff data by Conversion Factor adjusted for
% plot volume
conversionfactor=0.11875;

TR525_Up_Tot =TR525_Up_Tot*conversionfactor;
TR525_Mid_Tot = TR525_Mid_Tot*conversionfactor;
TR525_Low_Tot = TR525_Low_Tot*conversionfactor;

%% Import reference timestamps eg- tenminutetime_MAT
Convert_Rainfall_MAT_PAS_To_10min;

% Quick Plot of Precip and Tipping Bucket Runoff for MAT field site
% Tipping Buckets - rainfall and runoff
figure
plot(TIMESTAMP, Precip_Tot, TIMESTAMP, TR525_Up_Tot, TIMESTAMP, TR525_Mid_Tot, TIMESTAMP, TR525_Low_Tot);
hold on

% Import Celestino Tower Data
load('CelestinoClean.mat');

% Plot Celestino Tower (five min res), MAT Precip and MAT tipping bucket runoff
plot(celestino.dates, celestino.precip1); 
legend('PrecipMAT', 'Runoff UP', 'Runoff MID', 'Runoff LOW', 'Celestino');
title('MAT/Celestino Tower Precip vs. Adjusted Tipping Bucket Runoff');
