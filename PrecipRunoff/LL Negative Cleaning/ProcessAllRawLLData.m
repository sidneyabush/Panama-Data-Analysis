% Script Purpose: For each LL file, convert the multiple date formats into
% a single unified format. Then, convert 5 minute increments to 10

clear all;

% Check that we're in the right directory to start in.
shouldBeDir = '/Users/sidneybush/Documents/Graduate School/Panama/2016 Summer Field Season Data/MATLAB Analysis/PrecipRunoff/LL Negative Cleaning';
if ~strcmp(pwd, shouldBeDir)
    warning(['Change to the directory: ' shouldBeDir ' in order to run.']);
    return;
end

rawDataDir = 'RawData/';
cleanedDataDir = '/CleanedData/';
correctionFactorPath = '../LL Calibration/CleanedData/LLequations.mat';

% Load the height correction factors - used later.
load(fullfile(pwd, correctionFactorPath));

% Find only the CSV files in the data folder
allRawFiles = dir([rawDataDir '*.csv']);

% For each raw data file, do a couple of things
for i = 1:length(allRawFiles)
    fileName = allRawFiles(i).name;
    % Separate out just the filename, we'll use that below
    [~,siteName,~] = fileparts(fileName);
    % Process the individual file to correct date stamps
    [timeStamp, rawHeightMM] = processLLFile([rawDataDir fileName]);
    
    % LL rawHeightMM data is inaccurate due to shape of bucket and the
    % sensor's response. We correct this here.
    % The conversion is handled by two different equations - a linear one
    % for larger heights (volumes) and a logarithmic for smaller heights.
    % Note which heights are above and below the linear equation cutoff.
    
    % To replicate the old way of doing things (only using a linear
    % equation) just set the convertWithLog to be all zeros, and the
    % convertWithLinear to be all ones.
    
    justLinear = true;
    if ~justLinear
        convertWithLog = rawHeightMM < equations.(siteName).cutoffInMM;
    else
        convertWithLog = zeros(length(rawHeightMM), 1);
    end
    
    convertWithLinear = ~convertWithLog;
    
    correctedVol = zeros(length(rawHeightMM), 1);
    % Convert rawHeightMM to a calibrated volume in L (from LL calibration).
    slope = equations.(siteName).linearFit(1);
    intercept = equations.(siteName).linearFit(2);
    correctedVol(convertWithLinear) = rawHeightMM(convertWithLinear) * slope + intercept;
    
    if ~justLinear
        logCoefs = equations.(siteName).logFit;
        correctedVol(convertWithLog) = ...
            logCoefs(1).*log(rawHeightMM(convertWithLog) + logCoefs(2)) + logCoefs(3);
    end
    % Multiply volumes by 1000 to get cm^3 rather than L
    correctedVol = correctedVol * 1000;
    % Divide by area of plot to return a height in cm.
    plotAreaCM = 1568.5;
    correctedHeightCM = correctedVol / plotAreaCM;
    % Multiply by 10 to get height in mm.
    correctedHeightMM = correctedHeightCM * 10;
    
    % Determine how the height has changed in each sample - take difference
    % between consecutive samples.
    heightMM = [0; diff(correctedHeightMM)];
    
    % Clean data by removing any negative values and any too-small positive
    % values
    minimumvalidchangeheight = 0.2;
    heightMM(heightMM < minimumvalidchangeheight) = 0;
    
    % Save the results to a structure that we can use later
    % Create a new field in the structure whose value is a structure
    % itself. That sub-structure contains the timestamp and heightmm
    allLL.(siteName) = struct('timeStamp',timeStamp, 'heightMM', heightMM, 'correctedHeightMM', correctedHeightMM);
    
end

% Save our structure to a .mat file so we can load it elsewhere
saveDir = [shouldBeDir cleanedDataDir 'allLL'];
save(saveDir, 'allLL');

