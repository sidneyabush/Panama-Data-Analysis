% Calculates line of best fit for multiple calibration runs of a LL.

% Check to make sure we're in the right folder.
pathParts = strsplit(pwd, '/');
currentFolder = pathParts{end};
shouldBeInFolder = 'LL Calibration';
if ~strcmpi(currentFolder, shouldBeInFolder)
    warning(['Change to the directory: ' shouldBeInFolder ' in order to run.']);
    return;
end

%% Find all the folders that contain repeated measurements.
rawMeasuredDataDir = 'RawData/Measured/';
rawTruthDataDir = 'RawData/Truth/';
cleanedDataDir = 'CleanedData/';

allRawMeasuredDirs = dir(rawMeasuredDataDir);
% Remove anything that's not a folder
isMeasuredDir = [allRawMeasuredDirs(:).isdir]; % returns logical vector
allRawMeasuredDirNames = {allRawMeasuredDirs(isMeasuredDir).name}';
% Remove . and ..
allRawMeasuredDirNames(ismember(allRawMeasuredDirNames,{'.','..'})) = [];

allRawTruthDirs = dir(rawMeasuredDataDir);
% Remove anything that's not a folder
isTruthDir = [allRawTruthDirs(:).isdir]; %# returns logical vector
allRawTruthDirNames = {allRawTruthDirs(isTruthDir).name}';
% Remove . and ..
allRawTruthDirNames(ismember(allRawTruthDirNames,{'.','..'})) = [];

% Make sure that each truth folder has a matching measured folder
if ~all(strcmpi(allRawTruthDirNames, allRawMeasuredDirNames))
    warning('Not all measured and truth filenames are matching.');
    return;
end


% Check to make sure all pairs of truth-measured files are present.
%% For each site, find best fit of each repeated calibrations
for i = 1:length(allRawTruthDirNames)
    folderName = allRawTruthDirNames{i};
    % Check that there are the proper amount of csv files in the folder.
    repeatedMeasuredFiles = dir([rawMeasuredDataDir folderName '/' '*.CSV']);
    repeatedTruthFiles = dir([rawTruthDataDir folderName '/' '*.CSV']);
    expectedNumTestRuns = 5;
    if isempty(repeatedMeasuredFiles)
        warning(['No files in' folderName ' yet - skipping it.']);
        continue; % Skip this loop and go directly to next one.
    elseif any(diff([expectedNumTestRuns length(repeatedMeasuredFiles) ...
            length(repeatedTruthFiles)]))
        warning(['Number of repeated test runs is wrong, or does not match in ' folderName]);
        return;
    end
    
    % We'll store the coefficients for each repeated run in these.
    allLogCoefs = {};
    allLinearCoefs = {};
    
    % TODO: figure out a way to pass out this function from the FindBestFit
    % function
    logFunc = @(B,x) B(1).*log(x + B(2)) + B(3);
    
    % Prepare a figure to contain all lines of best fit from each
    % repetition. 
    figure;
    hold on;
    title(folderName);
    
    % For each repeated file pair
    for j = 1:length(repeatedMeasuredFiles)
        % Perform the calibration.
        cutoffBeginning = 1; % 1 = no cutuff.
        cutoffInLiters = 5;
        linearOrLogCutoff = cutoffInLiters * 2; % Two data points per liter.
        measuredFilename = [rawMeasuredDataDir folderName '/' repeatedMeasuredFiles(j).name];
        truthFilename = [rawTruthDataDir folderName '/' repeatedMeasuredFiles(j).name];
        
        %         fullfile(repeatedMeasuredFiles(i).folder, repeatedMeasuredFiles(i).name);
        %         truthFilename = fullfile(repeatedMeasuredFiles(i).folder, repeatedMeasuredFiles(i).name);
        %
        [logCoefs, lineFit, selectedMeasurementMM, truthVol] = FindBestFit(truthFilename,...
            measuredFilename, cutoffBeginning, cutoffInLiters, false);
        
        % Add the mmVsVolume data points for this repetition to the plot. 
        plot(selectedMeasurementMM, truthVol, 'o');
        
         % Plot all the different lines of best fit on one graph for comparison
        logSamples = selectedMeasurementMM(cutoffBeginning):0.1:selectedMeasurementMM(linearOrLogCutoff);
        linearSamples = selectedMeasurementMM(linearOrLogCutoff):10:selectedMeasurementMM(end);
        calculatedLogVolumes = logFunc(logCoefs, logSamples);
        calculatedLinearVolumes = polyval(lineFit, linearSamples);
        plot(linearSamples, calculatedLinearVolumes);
        plot(logSamples, calculatedLogVolumes);
        
        % Store the results of this trial
        allLogCoefs{j} = logCoefs;
        allLinearCoefs{j} = lineFit;
        disp(['Log Coefs for: ' repeatedMeasuredFiles(j).name 'is: ' num2str(logCoefs)]);
        disp(['Linear Coefs for: ' repeatedMeasuredFiles(j).name 'is: ' num2str(lineFit)]);
        
    end
    hold off;
    
end
% Store the result.
% Plot all those results.