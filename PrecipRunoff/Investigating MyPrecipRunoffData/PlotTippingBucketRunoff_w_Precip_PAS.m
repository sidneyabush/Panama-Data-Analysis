% Import ALL PAS tipping bucket data (precip & runoff)
[TIMESTAMP,RECORD,Precip_Tot,TR525_Up_Tot,TR525_Mid_Tot,TR525_Low_Tot] = import_PAS_TippingBucket('PrecipRunoff_Pasture_Combined.csv',5, 36884);

% Quick Plot of Precip and Tipping Bucket Runoff for PAS field site
% Tipping Buckets - rainfall and runoff

% Adjust for plot size by multiplying tipping bucket data by conversion factor
conversionfactor=0.11875;
TR525_Up_Tot = TR525_Up_Tot * conversionfactor; 
TR525_Mid_Tot =TR525_Mid_Tot * conversionfactor;
TR525_Low_Tot = TR525_Low_Tot * conversionfactor;

figure
plot(TIMESTAMP, Precip_Tot, TIMESTAMP, TR525_Up_Tot, TIMESTAMP, TR525_Mid_Tot, TIMESTAMP, TR525_Low_Tot);
hold on

%% Import reference timestamps
Convert_Rainfall_MAT_PAS_To_10min;

%% Import Guabo Camp
[GC_Timestamp,GC_tips] = importGC('GuaboCampPrecip_5_12_16 to 8_10_16.csv',3, 2654);
[ synchronizedmm ] = SyncGuaboCamptoMyPrecipData( tenminutetime_PAS, GC_Timestamp); 

% convert to mm
synchronizedmm = synchronizedmm.*0.254;

% Guabo Camp Time stamps are consistently 5 hours ahead of my timestamps- 
% adjust so they're the same
GCtimestamps = (tenminutetime_PAS - hours(5)); 


% Plot Guabo Camp (ten min res), PAS Precip and PAS tipping bucket runoff
plot(GCtimestamps, synchronizedmm); 
legend('PrecipPAS', 'Runoff UP', 'Runoff MID', 'Runoff LOW', 'Guabo Camp');
title('PAS/Guabo Camp Precip vs. Adjusted Tipping Bucket Runoff');
