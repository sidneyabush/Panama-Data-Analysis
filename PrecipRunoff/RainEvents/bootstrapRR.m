% Scans the "Merge" folder to pick events, then performs bootstrapping on all 3 LL and all 3 TB to get a better idea of what the RR might be.

%% Determine which events to bootstrap.
matFolder = 'RainEventFigures/All_Runoff/';
eventFolder = 'Merge';

% Load the mat file containing our event data.
load([matFolder 'allEvents.mat']);

% Get all the figures in the desired folder.
% matFigs = dir([matFolder eventFolder '/MAT*.fig']);
% pasFigs = dir([matFolder eventFolder '/PAS*.fig']);
eventFiles = dir([matFolder eventFolder '/*.fig']);
% allFigs = {matFigs, pasFigs};

% allEvents = {MAT_Events, PAS_Events};
% siteNames = {'MAT', 'PAS'};

% Create a structure to save the bootstrapped RR data.
data = struct();
data.MAT = [];
data.PAS = [];

% Extract, using parentheses in the regex, the event number and TB or LL.
pattern = '([A-T]{3})_event_(\d+)_([L-T][B-L]).fig';

% For each event in the merge folder, bootstrap the average runoff ratio.
for fileNum = 1:length(eventFiles)
    tokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
    % display(tokens);
    site = tokens{1}{1}{1};
    evtIdx = str2double(tokens{1}{1}{2});
    type = tokens{1}{1}{3};

    % Obtain all 6 types of runoff data.
    switch site
    case 'MAT'
        evtArray = MAT_Events;
    case 'PAS'
        evtArray = PAS_Events;
    end

    % allRunoff = [evtArray(evtIdx).allRunoff];
    % Store all the runoff totals in one vector so we can sample it.
    runoffTotals = [];
    numRunoffSources = 6; % Don't include the celestino data for MAT.
    for runNum = 1:numRunoffSources
        runoffTotals = [runoffTotals; evtArray(evtIdx).allRunoff(runNum).getTotal('mod')];
    end
    totalPrecip = evtArray(evtIdx).getTotal();
    % display(runoffTotals);
    % Perform the bootstrapping.
    % calcRR = @(runoff) (sum(runoff) / (totalPrecip * length(runoff));
    calcRR = @(runoff) (mean(runoff) / totalPrecip);
    [bootstat, bootsam] = bootstrp(100, calcRR, runoffTotals);
    % Perform a visual inspection of the average RR distribution.
    % histogram(bootstat);

    % Store the data in a struct for easy processing.
    evtInfo = struct('num', evtIdx, 'RRs', bootstat);
    data.(site) = [data.(site) evtInfo]; 

end



%% Bootstrap events.
