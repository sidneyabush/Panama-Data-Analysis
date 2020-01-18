% This script generates a table of summary information after reading output files from HYDRUS.

% Gather the directories that we want to scrape information from.
dirContainingRelevantFolders = 'C:\Users\sidne\Google Drive\CU Boulder\Panama_publication\HP HYDRUS UPDATE';
allDirContents = dir(dirContainingRelevantFolders);
onlyDirs = allDirContents([allDirContents.isdir] == 1);
validDirs = onlyDirs(contains({onlyDirs.name}, ["MAT_", "PAS_"]));

% Variables to hold table data.
peakRunoffRates_MMperHr = [];
peakRunoffRateTimes = [];
runoffTotals_MM = [];
evtNames = [];

for dirIdx = 1:length(validDirs)
    thisDir = validDirs(dirIdx);

    % Extract runoff and time variables from T_Level.out file
    tLevelFilename = fullfile(dirContainingRelevantFolders, thisDir.name, 'T_Level.out');
    [times, runoff, cumulativeRunoff] = importOutFile(tLevelFilename);

    % Find peaks and append to arrays
    runoff = runoff * 60; % Convert mm/min to mm/hr
    [peakRunoffRate_MMperHr, peakIdx] = max(runoff);
    peakRunoffRates_MMperHr = [peakRunoffRates_MMperHr, peakRunoffRate_MMperHr];
    peakRunoffRateTimes = [peakRunoffRateTimes, times(peakIdx)];
    runoffTotals_MM = [runoffTotals_MM, cumulativeRunoff(end)];
    evtNames = [evtNames string(thisDir.name)];
end

% Combine arrays into table
columnNames = ["Event_Index", "Peak_Runoff_Rate_Time", "Peak_Runoff_Rate_mm_per_hr", "Runoff_Total_mm"];
summTable = table(evtNames', peakRunoffRateTimes', peakRunoffRates_MMperHr', runoffTotals_MM', 'VariableNames', columnNames);
summTable
