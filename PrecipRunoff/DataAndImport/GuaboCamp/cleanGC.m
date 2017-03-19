% Imports, cleans and saves Guabo Camp data into a .mat file. 

%Load the mat file containing Precip and TB runoff. 
TBFile = 'TippingBucketCleaning/CleanedData/allTB.mat';
load(TBFile);

% Import Guabo Camp. 
[GC_Timestamp,GC_tips] = importGC('RawData/GuaboCampPrecip_5_12_16 to 8_10_16.csv',3, 2654);

% GC timestamps are about 5 hours delayed from our data. Shift to correct. 
GC_Timestamp = GC_Timestamp - hours(5); 

[ synchronizedmm ] = SyncGuaboCamptoMyPrecipData(allTB.PAS_TimeStamp_10min, GC_Timestamp); 

% convert to mm. 
synchronizedmm = synchronizedmm.*0.254;

% Save Output 
field1 = 'timeStamps';
field2 = 'precipMM';
gc = struct(field1, allTB.PAS_TimeStamp_10min, field2, synchronizedmm);

save('CleanedData/GCClean.mat','gc');