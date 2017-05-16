% This file imports the celestino data starting 02/20/2015 and analyzes the rainfall during the two summer seasons.

% Import the csv
% celestinoDataDir = 'DataAndImport/Celestino/';
rawDataDir = 'RawData/';
cleanedDataDir = 'CleanedData/';
[TIMESTAMP,RainTB3_mm,RainNlynx_mm] = importCelestino([rawDataDir 'celestino_20150220_20160729.csv'],5);

% Define start and end dates
startdate1 = datetime({'15/05/01'},'InputFormat','yy/MM/dd');
enddate1 = datetime({'15/08/01'},'InputFormat','yy/MM/dd');
startdate2 = datetime({'16/05/01'},'InputFormat','yy/MM/dd');
enddate2 = datetime({'16/08/01'},'InputFormat','yy/MM/dd');

% Subset times and precip
subsetindex = ((TIMESTAMP>startdate1) & (TIMESTAMP<enddate1)) | ((TIMESTAMP>startdate2) & (TIMESTAMP<enddate2));
selecttimestamps = TIMESTAMP(subsetindex);
selectprecips1 = RainTB3_mm(subsetindex);
selectprecips2 = RainNlynx_mm(subsetindex);

% Save output.
field1 = 'dates';
field2 = 'precip1';
field3 = 'precip2';
cel2yr = struct(field1,selecttimestamps,field2,selectprecips1,field3,selectprecips2);

save([cleanedDataDir 'Cel2YR.mat'],'cel2yr');
