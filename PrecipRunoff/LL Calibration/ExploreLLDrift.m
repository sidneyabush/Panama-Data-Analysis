% Initial exploration of the drift of the level loggers.
% Import the LL Data from the drift file
% close all;
clear all;

rawDriftDataDir = 'RawData/Drift/';
cleanedDataDir = 'CleanedData/Drift/';

% Find all drift files
allRawDriftFiles = dir([rawDriftDataDir '*.csv']);
allRawDriftFileNames = {allRawDriftFiles.name};

% For each drift CSV file
for i = 1:length(allRawDriftFileNames)
    fileName =  allRawDriftFileNames{i};
    
    % Import the data
    % driftFile1 = 'RawData/Drift/FORESTUPPER_drift.CSV';
    [date, time, raw, mm] = importLLDriftFile([rawDriftDataDir fileName], 7);
    
    % In case there are samples taken at midnight in a format that Matlab can't
    % handle, replace with the time midnight in the proper format.
    midnightIdx = find(isnat(time));
    if ~isempty(midnightIdx)
        if(length(midnightIdx) > 8)
            warning('There are an awful lot of midnight timestamps - perhaps something else is causing NAT issues?');
        end
        midnight = datetime('00:00:00', 'InputFormat', 'HH:mm:ss');
        time(midnightIdx) = midnight;
        % Another fix for midnight - make sure it's midnight of the next day, not
        % the previous.
        date(midnightIdx) = date(midnightIdx + 1);
    end
    % Combine the date and time into one
    datetimes = date + timeofday(time);
    % Change the format so that it displays date and time both
    datetimes.Format = 'MM/dd/yyyy HH:mm:ss';
    
    % Display a sample to make sure everything worked well
    disp(datetimes(1:10));
    % Display the timestamps before and after a midnight to make sure it worked
    % disp(datetimes(midnightIdx(1) - 1 :midnightIdx(1) + 1));
    
    % Plot the data to inspect visually
    figure;
    plot(datetimes, mm);
    title(fileName);
end