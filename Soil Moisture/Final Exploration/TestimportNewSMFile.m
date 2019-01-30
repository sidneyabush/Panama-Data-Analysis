% Script to test import of new SM files
cleanedDataDir = 'CleanedData\';
newFileName = 'Pasture_15.minute.qaqc.VWC.csv';
% SMData = importNewSMFile(newFileName, 20000, inf);
PASStartRow = 22650; % Just a few rows before the old CSV starts: 3/21/2016.
PASEndRow = 34994; % Just a few rows after the old CSV starts: 7/27/2016
[TIME,~,T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4] = importNewSMFile(newFileName, PASStartRow, PASEndRow);

% Average T1, M1, B1. Average T2, M2, etc.
avg10  = mean([T1 M1 B1], 2, 'omitnan');
avg30  = mean([T2 M2 B2], 2, 'omitnan');
avg50  = mean([T3 M3 B3], 2, 'omitnan');
avg100 = mean([T4 M4 B4], 2, 'omitnan');

SMDataNew = struct();

SMDataNew.PAS = struct('TIME', TIME, 'T1', T1, 'T2', T2, 'T3', T3, 'T4', T4,...
                                     'M1', M1, 'M2', M2, 'M3', M3, 'M4', M4,...
                                     'B1', B1, 'B2', B2, 'B3', B3, 'B4', B4,...
                                     'avg10', avg10, 'avg30', avg30, 'avg50', avg50, 'avg100', avg100);


% Save the struct for use in other scripts
saveDir = [cleanedDataDir 'SMDataNew'];
save(saveDir, 'SMDataNew');
