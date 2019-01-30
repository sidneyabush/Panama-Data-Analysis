% Purpose: Import Soil Moisture data from new CSVs and store it into a MAT file for use by other programs. Need to maintain format of previous script, ProcessRawSMData

% Struct containing information on Pasture CSV file
PastureDetails.fileName = 'Pasture_15.minute.qaqc.VWC.csv';
PastureDetails.structName = 'PAS';
PastureDetails.startRow = 22650; % Just a few rows before old CSV starts: 3/21/2016.
PastureDetails.endRow = 34994; % Just a few rows after the old CSV ends: 7/27/2016

% Struct containing information on Mature Forest CSV file
ForestDetails.fileName = 'SF80_15.minute.qaqc.VWC.csv';
ForestDetails.structName = 'MAT';
ForestDetails.startRow = 30041; % Just a few rows before old CSV starts: 5/23/2016.
ForestDetails.endRow = 36283; % Just a few rows after the old CSV ends: 7/27/2016

SMDataNew = struct();
SMDataNew.(PastureDetails.structName) = SM_CSV_to_Struct(PastureDetails);
SMDataNew.(ForestDetails.structName)  = SM_CSV_to_Struct(ForestDetails);

% Save the structure for use elsewhere
save('CleanedData/SMDataNew', 'SMDataNew');

% Imports data from a SM CSV, computes a few simple means, and stores them
% all in a struct to be returned.
function SMFields = SM_CSV_to_Struct(CSV)
  [TIME,~,T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4] = importNewSMFile(CSV.fileName,...
                                                      CSV.startRow, CSV.endRow);

  % Average T1, M1, B1. Average T2, M2, etc.
  avg1  = mean([T1 M1 B1], 2, 'omitnan');
  avg2  = mean([T2 M2 B2], 2, 'omitnan');
  avg3  = mean([T3 M3 B3], 2, 'omitnan');
  avg4 = mean([T4 M4 B4], 2, 'omitnan');

  SMFields = struct('TIME', TIME, 'T1', T1, 'T2', T2, 'T3', T3, 'T4', T4,...
                                       'M1', M1, 'M2', M2, 'M3', M3, 'M4', M4,...
                                       'B1', B1, 'B2', B2, 'B3', B3, 'B4', B4,...
                                       'avg1', avg1, 'avg2', avg2, 'avg3', avg3, 'avg4', avg4);
end
