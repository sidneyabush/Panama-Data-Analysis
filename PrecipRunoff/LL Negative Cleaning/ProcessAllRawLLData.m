% Script Purpose: For each LL file, convert the multiple date formats into
% a single unified format. Then, convert 5 minute increments to 10. Then,
% use the conversion formulas we have established from LL calibrations to
% correct the reported volume.

clear all;

% Check that we're in the right directory to start in.
shouldBeDir = '/Users/sidneybush/Documents/Graduate School/Panama/2016 Summer Field Season Data/MATLAB Analysis/PrecipRunoff/LL Negative Cleaning';
if ~strcmp(pwd, shouldBeDir)
    warning(['Change to the directory: ' shouldBeDir ' in order to run.']);
    return;
end

rawDataDir = 'RawData/';
cleanedDataDir = '/CleanedData/';
repCorrectionFactorPath = '../LL Calibration/CleanedData/LLRepEquations.mat';
correctionFactorPath = '../LL Calibration/CleanedData/LLequations.mat';

% Load the height correction factors (single and repeated) - used later. 
load(fullfile(pwd, repCorrectionFactorPath));
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
    % The conversion is handled by two different linear equations.
    
    % We may or may not have the full repeated calibration equations
    % available. If not, fall back on the single calibration. 
    if isfield(repEquations, siteName)
        bestEquation = repEquations; 
    else
        disp(['Falling back on single calibration for: ' siteName]);
        bestEquation = equations;
    end
    
    % To replicate the old way of doing things (only using a linear
    % equation) just set the convertWithLog to be all zeros, and the
    % convertWithLinear to be all ones.
    
    justOneLinear = false;
    if ~justOneLinear
        convertWithLinear1 = rawHeightMM < bestEquation.(siteName).cutoffInMM;
    else
        convertWithLinear1 = zeros(length(rawHeightMM), 1);
    end
    convertWithLinear2 = ~convertWithLinear1;
    correctedVol = zeros(length(rawHeightMM), 1);
    
    % Convert rawHeightMM to a calibrated volume in L (from LL calibration).
    slope = bestEquation.(siteName).linearFit2(1);
    intercept = bestEquation.(siteName).linearFit2(2);
    correctedVol(convertWithLinear2) = rawHeightMM(convertWithLinear2) * slope + intercept;
    
    if ~justOneLinear
        % Correct the first section of data using a different line. 
        slope = bestEquation.(siteName).linearFit1(1);
        intercept = bestEquation.(siteName).linearFit1(2);
        correctedVol(convertWithLinear1) = rawHeightMM(convertWithLinear1) * slope + intercept;
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
    minimumvalidchangeheight = 0.5;
    heightMM(heightMM < minimumvalidchangeheight) = 0;
    % Clean data by removing any values where there was not enough water in
    % the bucket to accurately read a value.
    numPointsBefore = sum(heightMM > 0);
    heightMM(rawHeightMM < bestEquation.(siteName).minRawWaterLevel) = 0;
    numPointsAfter = sum(heightMM > 0);
    disp([siteName ' has: ' num2str(numPointsAfter) ' nonzero difference points.']);
    disp(['Min value: ' num2str(min(rawHeightMM)) '. Min water level: ' num2str(bestEquation.(siteName).minRawWaterLevel)]);
    disp(['Eliminated: ' num2str(numPointsBefore - numPointsAfter) ' points less than 3']);
%     figure;
%     edges = 40:5:400;
%     histogram(rawHeightMM, edges);
%     title([siteName num2str(bestEquation.(siteName).minRawWaterLevel)]);
    % Save the results to a structure that we can use later
    % Create a new field in the structure whose value is a structure
    % itself. That sub-structure contains the timestamp and heightmm
    allLL.(siteName) = struct('timeStamp',timeStamp, 'heightMM', heightMM, 'correctedHeightMM', correctedHeightMM);
    
end

% Save our structure to a .mat file so we can load it elsewhere
saveDir = [shouldBeDir cleanedDataDir 'allLL'];
save(saveDir, 'allLL');

