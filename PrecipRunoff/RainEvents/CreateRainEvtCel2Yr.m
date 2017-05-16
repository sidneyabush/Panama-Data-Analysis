% This creates rain events from the two year celestino data.

% Load the Celestino 2 Year .mat file.
CelFile = '../DataAndImport/Celestino/CleanedData/Cel2YR.mat';
load(CelFile);

[startTimes, endTimes] = FindRainEvents(cel2yr.dates, cel2yr.precip1);

% For each rain event:
for idx = 1:length(startTimes)
    thisEvent=C_RainEvent('CEL');

    % Add the start and end times.
    thisEvent.startTime=cel2yr.dates(startTimes(idx));
    thisEvent.endTime=cel2yr.dates(endTimes(idx));

    % Add the precip timestamps and values
    thisEvent.precipTimes=cel2yr.dates(startTimes(idx):endTimes(idx));
    thisEvent.precipVals=cel2yr.precip1(startTimes(idx):endTimes(idx));


    % Perform just the updates and statistics that we have the data for.
    thisEvent.initModifiedVals();
    thisEvent.calcPeakIntensity();
    thisEvent.calcAvgIntensity();
    thisEvent.getTotal();

    CelEvts(idx)=thisEvent;
end

%% Process to determine optimal bin sizes.
data.PreTot = [CelEvts.precipTotal];
data.StartTimes = [CelEvts.startTime];
data.EndTimes = [CelEvts.endTime];
data.Duration = minutes(data.EndTimes - data.StartTimes);
data.PI = [];
data.AvgI = [];


% Can't create an array automatically with structure deeper than one level.
for idx = 1:length(CelEvts)
    % Convert Precips to mm/hr from mm/10min
    data.PI = [data.PI CelEvts(idx).stats.mod.int.peak.precip * 12];
    data.AvgI = [data.AvgI CelEvts(idx).stats.mod.int.avg.precip * 12];
end


measurements = {'Duration', 'PI', 'AvgI', 'PreTot'};
for idx = 1:length(measurements)
    qt = quantile(data.(measurements{idx}), 3);
    edges = [ 0 qt max(data.(measurements{idx}))];
    % [numInBin, edges, binLabels] = histcounts(data.(measurements{idx}));
    disp(['Bins and counts for meaurement: ' measurements{idx}]);
    % disp(numInBin);
    disp(edges);
end
