% Scans the "Merge" folder to pick events, then performs bootstrapping on all 3 LL and all 3 TB to get a better idea of what the RR might be.

%% Determine which events to bootstrap.
matFolder = 'RainEventFigures/All_Runoff/';
eventFolder = 'Merge/';

% Load the mat file containing our event data.
load([matFolder 'allEvents.mat']);

% Get all the figures in the desired folder.
% matFigs = dir([matFolder eventFolder '/MAT*.fig']);
% pasFigs = dir([matFolder eventFolder '/PAS*.fig']);
eventFiles = dir([matFolder eventFolder '*.fig']);
% allFigs = {matFigs, pasFigs};

% allEvents = {MAT_Events, PAS_Events};
% siteNames = {'MAT', 'PAS'};

% Create a structure to save the bootstrapped RR data.
mergeRR = struct();
mergeRR.MAT = struct();
mergeRR.PAS = struct();

% Extract, using parentheses in the regex, the event number and TB or LL.
pattern = '([A-T]{3})_event_(\d+)_([L-T][B-L]).fig';

% For each event in the merge folder, bootstrap the average runoff ratio.
for fileNum = 1:length(eventFiles)
    tokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
    % display(tokens);
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
    [bootstat, bootsam] = bootstrp(100, calcRR, runoffTotals);
    % Perform a visual inspection of the average RR distribution.
    % histogram(bootstat);

    % Store the data in a struct for easy processing.
    fieldName = ['evt' num2str(evtIdx)];
    mergeRR.(site).(fieldName) = bootstat;
    % evtInfo = struct('num', evtIdx, 'RRs', bootstat);
    % data.(site) = [data.(site) evtInfo];

end

% Save bootstrapping data for use elsewhere.
saveDir = [matFolder eventFolder 'mergeRR'];
save(saveDir, 'mergeRR');
