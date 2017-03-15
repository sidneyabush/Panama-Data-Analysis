% Match up the exact values of time-volume to the time-height measurements
% collected by the level loggers, then create a height-volume conversion
% factor.

clear all;
close all;

% Check that we're running this from the correct directory, near all the
% data.
shouldBeDir = '/Users/sidneybush/Documents/Graduate School/Panama/2016 Summer Field Season Data/MATLAB Analysis/PrecipRunoff/LL Calibration';
if ~strcmp(pwd, shouldBeDir)
    warning(['Change to the directory: ' shouldBeDir ' in order to run.']);
    return;
end

rawMeasuredDataDir = 'RawData/Measured/';
rawTruthDataDir = 'RawData/Truth/';
cleanedDataDir = 'CleanedData/';

% Make sure that every truth file has a matching measured file of the same
% name.
allRawMeasuredFiles = dir([rawMeasuredDataDir '*.csv']);
allRawMeasuredFileNames = {allRawMeasuredFiles.name};
allRawTruthFiles = dir([rawTruthDataDir '*.csv']);
allRawTruthFileNames = {allRawTruthFiles.name};
if ~all(strcmpi(allRawTruthFileNames, allRawMeasuredFileNames))
    warning('Not all measured and truth filenames are matching.');
    return;
end

% Create structure to store linear equations for each level logger
equations= struct;

% For each pair of measured and truth files
for i = 1:length(allRawMeasuredFileNames)
    filename = allRawMeasuredFileNames{i};
    truthFilename = [rawTruthDataDir filename];
    measuredFilename = [rawMeasuredDataDir filename];
    cutoffBeginning = 8;  % How many points to ignore at the beginning of cal.  5 = 2.5L 
    cutoffInLiters = 4;
    linearSplit = cutoffInLiters * 2; % Two data points per liter.
    
    [lineFit1, lineFit2, selectedMeasurementMM, truthVol] = FindBestFit(truthFilename,...
         measuredFilename, cutoffBeginning, cutoffInLiters, true);
    
    % Separate out just the filename, we'll use that below
    [~,name,~] = fileparts(filename);
    equations.(name).linearFit1 = lineFit1;
    equations.(name).linearFit2 = lineFit2;
    equations.(name).cutoffInMM = selectedMeasurementMM(linearSplit);
    equations.(name).minRawWaterLevel = selectedMeasurementMM(cutoffBeginning);
end

% Save our structure to a .mat file so we can load it elsewhere
saveDir = [shouldBeDir '/CleanedData/LLequations'];
save(saveDir, 'equations');