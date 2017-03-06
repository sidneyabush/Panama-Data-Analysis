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
    cmap = colormap(lines); % Store so we can match point and line colors. 
    
    % For each repeated file pair
    for j = 1:length(repeatedMeasuredFiles)
        % Perform the calibration.
        cutoffBeginning = 6; % 1 = no cutuff.
        cutoffInLiters = 4;
        slopeSplit = cutoffInLiters * 2; % Two data points per liter.
        measuredFilename = [rawMeasuredDataDir folderName '/' repeatedMeasuredFiles(j).name];
        truthFilename = [rawTruthDataDir folderName '/' repeatedMeasuredFiles(j).name];
        [lineFit1, lineFit2, selectedMeasurementMM, truthVol] = FindBestFit(truthFilename,...
            measuredFilename, cutoffBeginning, cutoffInLiters, false);
        
        % Add the mmVsVolume data points for this repetition to the plot. 
        plot(selectedMeasurementMM, truthVol, 'o', 'Color', cmap(j,:));
        
         % Plot all the different lines of best fit on one graph for comparison
        linearSamples1 = selectedMeasurementMM(cutoffBeginning):0.1:selectedMeasurementMM(slopeSplit);
        linearSamples2 = selectedMeasurementMM(slopeSplit):10:selectedMeasurementMM(end);
        calculatedLinearVolumes1 = polyval(lineFit1, linearSamples1);
        calculatedLinearVolumes2 = polyval(lineFit2, linearSamples2);
        plot(linearSamples1, calculatedLinearVolumes1, 'Color', cmap(j,:));
        plot(linearSamples2, calculatedLinearVolumes2, 'Color', cmap(j,:));
        
        % Store the results of this trial
        allLinearCoefs1{j} = lineFit1;
        allLinearCoefs2{j} = lineFit2;
        disp(['Linear1 Coefs for: ' repeatedMeasuredFiles(j).name 'is: ' num2str(lineFit1)]);
        disp(['Linear2 Coefs for: ' repeatedMeasuredFiles(j).name 'is: ' num2str(lineFit2)]);
    end
    hold off;  
end