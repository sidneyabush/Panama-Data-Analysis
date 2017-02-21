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
    cutoffBeginning = 1;
    cutoffInLiters = 5;
    linearOrLogCutoff = cutoffInLiters * 2; % Two data points per liter.
    
    [logCoefs, lineFit, selectedMeasurementMM] = FindBestFit(truthFilename,...
         measuredFilename, cutoffBeginning, cutoffInLiters, true);
    
    %     % Import the truth file
    %     [truthTime,truthVol] = importLLTruthData([rawTruthDataDir filename],2);
    %     % Import the measured file
    %     [measuredTime, Raw, measuredMM] = importLLMeasuredData([rawMeasuredDataDir filename], 7);
    %
    %     % Clear out variables so they are not mistakenly carried over from
    %     % previous loop.
    %     firstGreater = 0;
    %     selectedMeasurementMM = 0;
    %     selectedMeasurementTime = 0;
    %
    %     % For each truth timestamp, find the first ll data point that was collected
    %     % after that truth time - this corresponds to the height measured
    %     % immediately after the volume was changed.
    %     for j = 1:length(truthTime)
    %         firstGreater(j) = find(measuredTime > truthTime(j),1);
    %     end
    %     firstGreater = firstGreater';
    %
    %     % Pull out the height measurements.
    %     selectedMeasurementMM = measuredMM(firstGreater);
    %     selectedMeasurementTime = measuredTime(firstGreater);
    % % Uncomment to re enable these plots.
    % %     % Plot the selected measurements to allow visual inspection.
    % %     figure;
    % %     hold on;
    % %     plot(measuredTime, measuredMM);
    % %     plot(selectedMeasurementTime, selectedMeasurementMM,'o');
    % %     hold off;
    %
    %     % Find lines of best fit between selectedMeasurementMM and truthVol.
    %     % The larger volumes follow a linear relationship. The smaller ones
    %     % follow a logarithmic one.
    %     cutoffBeginning = 1;
    %     cutoffInLiters = 5;
    %     linearOrLogCutoff = cutoffInLiters * 2; % Two data points per liter.
    %     logFunc = @(B,x) B(1).*log(x + B(2)) + B(3);
    %     logCoefs = nlinfit(selectedMeasurementMM(cutoffBeginning:linearOrLogCutoff), ...
    %                        truthVol(cutoffBeginning:linearOrLogCutoff), logFunc, [0.1, 0, 0]);
    %
    %     %
    %     % !!!DANGER!!!
    %     %
    %     % The log coefficients turn out to be complex numbers. I'm discarding
    %     % the imaginary parts, because they cause issues with plotting later
    %     % on. And, plotting just the real parts seems to have a very good fit.
    %     % But I'm not 100% sure if this is mathematically valid to do...
    %     logCoefs = real(logCoefs);
    %     lineFit = polyfit(selectedMeasurementMM(linearOrLogCutoff:end), ...
    %                       truthVol(linearOrLogCutoff:end), 1);
    % Plot the estimations we've just fitted to make sure they look right.
    
    % TODO: figure out a way to pass this function out of the FindBestFit
    % function. 
%     logFunc = @(B,x) B(1).*log(x + B(2)) + B(3);

    
%     logSamples = selectedMeasurementMM(cutoffBeginning):0.1:selectedMeasurementMM(linearOrLogCutoff);
%     calculatedLogVolumes = logFunc(logCoefs, logSamples);
%     
%     linearSamples = selectedMeasurementMM(linearOrLogCutoff):10:selectedMeasurementMM(end);
%     calculatedLinearVolumes = polyval(lineFit, linearSamples);
%     
%     figure;
%     plot(selectedMeasurementMM, truthVol, 'o', linearSamples, calculatedLinearVolumes);
%     hold on;
%     plot(logSamples, calculatedLogVolumes);
%     hold off;
    slope = lineFit(1);
    intercept = lineFit(2);
    
    % Separate out just the filename, we'll use that below
    [~,name,~] = fileparts(filename);
    equations.(name).linearFit = lineFit;
    equations.(name).logFit = logCoefs;
    equations.(name).cutoffInMM = selectedMeasurementMM(linearOrLogCutoff);
end

% Save our structure to a .mat file so we can load it elsewhere
saveDir = [shouldBeDir '/CleanedData/LLequations'];
save(saveDir, 'equations');