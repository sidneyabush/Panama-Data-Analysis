% This script generates a table of summary information after reading output files from HYDRUS.
% It is intended to run on a directory with folders called "MAT_10" "PAS_20" etc.

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
    [times, ~, cumulativeRunoff] = importOutFile(tLevelFilename);

    % Find peaks and append to arrays
    % runoff = runoff * 60; % Convert mm/min to mm/hr
    % [peakRunoffRate_MMperHr, peakIdx] = max(runoff);
    % peakRunoffRates_MMperHr = [peakRunoffRates_MMperHr, peakRunoffRate_MMperHr];
    % peakRunoffRateTimes = [peakRunoffRateTimes, times(peakIdx)];
    % runoffTotals_MM = [runoffTotals_MM, cumulativeRunoff(end)];
    % evtNames = [evtNames string(thisDir.name)];


    % Append a 0 to the beginning of all the vectors.
    times = [10; times];
    cumulativeRunoff = [0; cumulativeRunoff];

    % Set up array to store amount of runoff (mm) accumulated in 10 minutes.
    runoff10Min_mm = [];

    % Find the indices of every time that is an even multiple of 10 minutes.
    tenMinIdxs = find(mod(times, 10) == 0);
    % For each pair of indeces in that vector,
    for idx = 2:length(tenMinIdxs)
        startIdx = tenMinIdxs(idx - 1);
        endIdx = tenMinIdxs(idx);

        % Find the difference in cumulative runoff, store in a vector
        runoffInLast10Min_mm = cumulativeRunoff(endIdx) - cumulativeRunoff(startIdx);
        runoff10Min_mm = [runoff10Min_mm runoffInLast10Min_mm];
    end
    % Sanity check: does the sum of 10 minute runoff vector = the raw cumulative Runoff?
    if sum(runoff10Min_mm) ~= cumulativeRunoff(end)
        warning("Sum issue.");
    end

    % Find the max runoff rate from that vector.
    [peakRunoffIn10Min_mm, peakIdx] = max(runoff10Min_mm);
    timeOfPeak10MinRunoff = times(tenMinIdxs(peakIdx+1));
    % Multiply the amount of runoff that occurred in the last 10 minutes by 6 to get the runoff rate in mm/hr averaged over the last 10 minutes.
    peakRunoffRates_MMperHr = [peakRunoffRates_MMperHr peakRunoffIn10Min_mm * 6];
    peakRunoffRateTimes = [peakRunoffRateTimes timeOfPeak10MinRunoff];
    runoffTotals_MM = [runoffTotals_MM, cumulativeRunoff(end)];
    evtNames = [evtNames string(thisDir.name)];

    % Dirty hack to display 10-minute averaged hydrus data
    disp(['Hydrus event ' string(thisDir.name)]);
    disp('mm of runoff in the last 10 min:');
    runoff10Min_mm'
end

% Combine arrays into table
columnNames = ["Event_Index", "Peak_Runoff_Rate_Time", "Peak_Runoff_Rate_mm_per_hr", "Runoff_Total_mm"];
summTable = table(evtNames', peakRunoffRateTimes', peakRunoffRates_MMperHr', runoffTotals_MM', 'VariableNames', columnNames);
summTable
