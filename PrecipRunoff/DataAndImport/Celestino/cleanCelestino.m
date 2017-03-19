% Import, clean and save Celestino data into a .mat file. 

% Import Celestino Data from two CSV files
[TIMESTAMP3,RainTB3_mm_Tot3,RainNlynx_mm_Tot3] = importCelestino('celestino_tower_3.csv',5, 151122);
[TIMESTAMP4,RainTB3_mm_Tot4,RainNlynx_mm_Tot4] = importCelestino('celestino_tower_4.csv',5);

% Combine them. 
combinedtimestamps = [TIMESTAMP3; TIMESTAMP4];
combinedPrecip1 = [RainTB3_mm_Tot3; RainTB3_mm_Tot4];
combinedPrecip2 = [RainNlynx_mm_Tot3; RainNlynx_mm_Tot4];

% Define start and end dates
startdate = datetime({'16/05/20'},'InputFormat','yy/MM/dd');
enddate = datetime({'16/08/10'},'InputFormat','yy/MM/dd');

% Subset times and precip
subsetindex = (combinedtimestamps>startdate) & (combinedtimestamps<enddate);
selecttimestamps = combinedtimestamps(subsetindex);
selectprecips1 = combinedPrecip1(subsetindex);
selectprecips2 = combinedPrecip2(subsetindex);

% Save Output 
field1 = 'dates';
field2 = 'precip1';
field3 = 'precip2';
celestino = struct(field1,selecttimestamps,field2,selectprecips1,field3,selectprecips2);

save('CleanedData/CelestinoClean.mat','celestino');




