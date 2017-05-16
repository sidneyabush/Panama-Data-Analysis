% Scans the "Merge" folder to pick events, then performs bootstrapping on all 3 LL and all 3 TB to get a better idea of what the RR might be.

%% Determine which events to bootstrap.
matFolder = 'RainEventFigures/All_Runoff/';
eventFolder = 'Merge/';

% Load the mat file containing our event data.
load([matFolder 'allEvents.mat']);

% Get all the figures in the desired folder.
eventFiles = dir([matFolder eventFolder '*.fig']);

% Create a structure to save the bootstrapped RR data.
mergeRR = struct();
mergeRR.MAT = struct();
mergeRR.PAS = struct();

% Debugging structure to capture the difference between the mean of all and the mean of the bootstrapped data.
diffFromMean = struct();
diffFromMean.MAT = [];
diffFromMean.PAS = [];
% Debugging structure to capture variances.
variances = struct();
variances.MAT = [];
variances.PAS = [];

% Extract, using parentheses in the regex, the event number and TB or LL.
pattern = '([A-T]{3})_event_(\d+)_([L-T][B-L]).fig';

% For each event in the merge folder, bootstrap the average runoff ratio.
for fileNum = 1:length(eventFiles)
    tokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
    site = tokens{1}{1}{1};
    evtIdx = str2double(tokens{1}{1}{2});
    type = tokens{1}{1}{3};

    % Are we looking at an event from the MAT or the PAS?
    switch site
    case 'MAT'
        evtArray = MAT_Events;
    case 'PAS'
        evtArray = PAS_Events;
    end

    % Store all 6 runoff totals in one vector so we can sample from it.
    runoffTotals = [];
    numRunoffSources = 6; % Don't include the celestino data for MAT.
    for runNum = 1:numRunoffSources
        runoffTotals = [runoffTotals; evtArray(evtIdx).allRunoff(runNum).getTotal('mod')];
    end

    % Precip is also needed for the RR calculation.
    totalPrecip = evtArray(evtIdx).getTotal();

    % Perform the bootstrapping.
    % calcRR = @(runoff) (sum(runoff) / (totalPrecip * length(runoff));
    calcRR = @(runoff) (mean(runoff) / totalPrecip);
    [bootstat, bootsam] = bootstrp(1000, calcRR, runoffTotals);
    % Perform a visual inspection of the average RR distribution.
%     histogram(bootstat);

    % Test to see whether the variance is greater than the measurement uncertainty.
    % Uncertainty for each device (scale from 0->1).
    % Calculate the LL percent uncertainty. This assumes an optimal calibration.
    % TODO: Determine how close we actually are to the optimal calibration. Actually this might not matter since the LL is apparently so much more accurate than the other measurements.
    LLAccuracyMM = 0.5/2;
    LLRangeMM = 35*10;
    UCLLRunoff = LLAccuracyMM / LLRangeMM;
    UCTBRunoff = 0.01;
    UCTBPrecip = 0.01;
    % Compound measurement uncertainty.
    % TODO: double check how to deal with dividing by an uncertainty.
    measUncert = ((3 * UCTBRunoff + 3 * UCLLRunoff) / 6) + UCTBPrecip;
    % We want the variance of the boostrapped data to be smaller than the measUncert.
    % Matrix has 6 columns: lower bound, mean, upper bound, lower bound, mean, upper bound.
    stdev = std(bootstat);
    meanRR = evtArray(evtIdx).stats.mod.RR.both.precip;
    thisUC = [(mean(bootstat) - 2 * stdev) (mean(bootstat)) (mean(bootstat) + 2 * stdev) ...
              (meanRR * (1 - measUncert)) (meanRR) (meanRR * (1 + measUncert))];
    variances.(site) = [ variances.(site); thisUC];


    % Debugging
    thisDiff = mean(bootstat) - evtArray(evtIdx).stats.mod.RR.both.precip;
    diffFromMean.(site) = [ diffFromMean.(site) thisDiff];

    % Store the data in a struct for easy processing.
    fieldName = ['evt' num2str(evtIdx)];
    mergeRR.(site).(fieldName) = bootstat;
    % evtInfo = struct('num', evtIdx, 'RRs', bootstat);
    % data.(site) = [data.(site) evtInfo];

end

% Save bootstrapping data for use elsewhere.
saveDir = [matFolder eventFolder 'mergeRR'];
save(saveDir, 'mergeRR');
