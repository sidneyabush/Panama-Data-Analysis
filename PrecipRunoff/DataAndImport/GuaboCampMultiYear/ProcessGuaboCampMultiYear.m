% This file imports the Arnulfo data from multiple years and analyzes the rainfall during the summer seasons.

% TODO: Change the hard coded start index to something that takes into account the first good sample after the "logged" statement. It's not the same for every file.


%% Import the data.
% Import the csvs
rawDataDir = 'RawData/';
cleanedDataDir = 'CleanedData/';

% Find all the filenames.
allRawFiles = dir([rawDataDir '*.csv']);
allRawFileNames = {allRawFiles.name};

% A struct to save the extracted data into.
GCMY = struct();
GCMY.rawDates = [];
GCMY.counts = [];

% For each CSV file
for idx = 1:length(allRawFileNames)
    fileName =  allRawFileNames{idx};
    [~,dates,counts] = importArnulfoMultiYear([rawDataDir fileName], 7);
    % The last four rows don't contain any useful data for us, so trim them off.
    dates(end-4:end) = [];
    counts(end-4:end) = [];

    % Find events in the months May, June and July
    subsetIdx = any((month(dates) == [5 6 7]), 2);
    selDates = dates(subsetIdx);
    selCounts = counts(subsetIdx);

    % Append data from this file to the master record.
    GCMY.rawDates = [GCMY.rawDates; selDates];
    GCMY.counts = [GCMY.counts; selCounts];
end

% Sort the dates and counts from earliest to latest.
[sortedDates, sortIdx] = sort(GCMY.rawDates);
GCMY.rawDates = sortedDates;
GCMY.counts = GCMY.counts(sortIdx);





%% Sanity check the data.
% Plot the sorted data to verify that we captured only the data we wanted.
plot(GCMY.rawDates, GCMY.counts);

if any(isnan(GCMY.counts))
    disp('Warning: There were nan values in the count data');
end

% Difference between counts should only ever be increasing by one, or be
% large negative values (between different files).
countdiffs = [0; diff(GCMY.counts)];
if(any(countdiffs > 1))
    display('Unexpected difference in count, possible data corruption. Diffs > 1: ')
    display(countdiffs(countdiffs > 1));
    plot(GCMY.rawDates, countdiffs);
end





%% Convert individual tips to precip rates per X minutes.
% Create our uniform time stamps: one every X minutes starting at the first tip
startTime = GCMY.rawDates(1);
endTime = GCMY.rawDates(end);
numMinsPerTS = 10;
ts = [startTime:minutes(numMinsPerTS):endTime]';
% But don't create any timestamps for months that we don't have any data for.
unusedTimes = ~any((month(ts) == [5 6 7]), 2);
ts(unusedTimes) = [];

% Count the number of tips that occured during each time stamp.
numtips = zeros(length(ts), 1);
numtips(1) = length(find(GCMY.rawDates <= ts(1)));
for tsIdx = 2:length(ts)
    numtips(tsIdx) = length(find(GCMY.rawDates > ts(tsIdx-1) & GCMY.rawDates <= ts(tsIdx)));
end

% Convert number of tips to a precip rate in mm/10mins.
% .254 mm per tip.
GCMY.precip = numtips * 0.254;
GCMY.dates = ts;





%% Save output.
save([cleanedDataDir 'GCMY.mat'],'GCMY');
