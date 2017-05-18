% This creates rain events and calculates quantiles from auxiliary precip sources including: the two year celestino data, the multi-year Arnulfo data...

arnMYData.name = 'Arnulfo Multi Year';
arnMYData.path = '../DataAndImport/ArnulfoMultiYear/CleanedData/ArnMY.mat';


cel2yrData.name = 'Celestino 2 Year';
cel2yrData.path = '../DataAndImport/Celestino/CleanedData/Cel2YR.mat';

allPrecipSrc = [arnMYData, cel2yrData];
% allPrecipSrc = [cel2yrData];

for idx = 1:length(allPrecipSrc)
    CalcQuantiles(allPrecipSrc(idx));
end


function [] = CalcQuantiles(precipSrc)
    % Load the Celestino 2 Year .mat file.
    % CelFile = '../DataAndImport/Celestino/CleanedData/Cel2YR.mat';
    precipMatData = load(precipSrc.path);
    fns = fieldnames(precipMatData);
    precipStructName = fns{1};
    auxPrecip.dates = precipMatData.(precipStructName).dates;
    auxPrecip.precip = precipMatData.(precipStructName).precip;


    [startTimes, endTimes] = FindRainEvents(auxPrecip.dates, auxPrecip.precip);

    % For each rain event:
    for idx = 1:length(startTimes)
        thisEvent=C_RainEvent('AUX');

        % Add the start and end times.
        thisEvent.startTime=auxPrecip.dates(startTimes(idx));
        thisEvent.endTime=auxPrecip.dates(endTimes(idx));

        % Add the precip timestamps and values
        thisEvent.precipTimes=auxPrecip.dates(startTimes(idx):endTimes(idx));
        thisEvent.precipVals=auxPrecip.precip(startTimes(idx):endTimes(idx));


        % Perform just the updates and statistics that we have the data for.
        thisEvent.initModifiedVals();
        thisEvent.calcPeakIntensity();
        thisEvent.calcAvgIntensity();
        thisEvent.getTotal();

        AuxEvts(idx)=thisEvent;
    end

    %% Process to determine optimal bin sizes.
    data.PreTot = [AuxEvts.precipTotal];
    data.StartTimes = [AuxEvts.startTime];
    data.EndTimes = [AuxEvts.endTime];
    data.Duration = minutes(data.EndTimes - data.StartTimes);
    data.PI = [];
    data.AvgI = [];


    % Can't create an array automatically with structure deeper than one level.
    for idx = 1:length(AuxEvts)
        % Convert Precips to mm/hr from mm/10min
        data.PI = [data.PI AuxEvts(idx).stats.mod.int.peak.precip * 12];
        data.AvgI = [data.AvgI AuxEvts(idx).stats.mod.int.avg.precip * 12];
    end


    measurements = {'Duration', 'PI', 'AvgI', 'PreTot'};
    disp([precipSrc.name '-----------------------------']);
    for idx = 1:length(measurements)
        qt = quantile(data.(measurements{idx}), 3);
        % TODO: 0 is not always the proper bin edge. If there's no data between 0 and qt(1) then don't prepend 0 at all. 
        edges = [ 0 qt max(data.(measurements{idx}))];
        disp(['Bins and counts for meaurement: ' measurements{idx}]);
        histogram(data.(measurements{idx}), edges);
        [numInBin, ~] = histcounts(data.(measurements{idx}), edges);
        disp(numInBin);
        disp(edges);
    end

end
