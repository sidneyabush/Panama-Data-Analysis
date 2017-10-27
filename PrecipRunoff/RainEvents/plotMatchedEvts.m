% Searches the good folder for matching MAT/PAS events, then calculates statistics and generates plots.

matFolder = 'RainEventFigures/All_Runoff/';
mergeFolder = 'Merge/';
eventFolder = 'Good/';

% Load the .mat file containing our edited event data (doesn't contain SM data).
oldEvts = load([matFolder 'allEvents.mat']);
Old_MAT_Events = oldEvts.MAT_Events;
Old_PAS_Events = oldEvts.PAS_Events;

% Generate new events (which contain added data like SM).
% Creates MAT_Events and PAS_Events variables.
Create_RainEvents;

% Load the .mat file containing our merged RR data.
load([matFolder mergeFolder '/mergeRR.mat']);

% evts struct will store the information we extract from the filenames.
evts.idx = [];
evts.site = [];
evts.type = [];
evts.merged = [];
eventFiles = dir([matFolder eventFolder '*.fig']);
pattern = '([A-T]{3})_event_(\d+)_([L-T][B-L]).fig';

% NOTE: Sort the data? Actually don't need to, unless we start doing scatter plots.

% For each figure, extract the site, event number and LL/TB and store into an array.
for fileNum = 1:length(eventFiles)
    fnTokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
    switch fnTokens{1}{1}{1}
        case 'MAT'
            thisEvt = MAT_Events(str2double(fnTokens{1}{1}{2}));
        case 'PAS'
            thisEvt = PAS_Events(str2double(fnTokens{1}{1}{2}));
        otherwise
            warning('Unexpected site.')
    end
    % It's possible that the minimum valid precip threshold has rendered
    % this event invalid. Don't use it if so.
    if any(isnan(thisEvt.site))
        % evts.idx(evtIdx) = [];
        % evts.site(evtIdx) = [];
        % evts.type(evtIdx) = [];
        continue
    end
    evts.site = [evts.site; fnTokens{1}{1}{1}];
    evts.idx = [evts.idx; str2double(fnTokens{1}{1}{2})];
    evts.type = [evts.type; fnTokens{1}{1}{3}];
end

numEdited = 0;
% Logical vector noting which events are merged.
isMerged = zeros(length(evts.idx), 1);
% For each event in the good folder:
for evtIdx = 1:length(evts.idx)
    % Make sure we apply the edits made in the old .mat file.
    switch evts.site(evtIdx)
        case 'M'
            thisEvt = MAT_Events(evts.idx(evtIdx));
            thisEvt_Old = Old_MAT_Events(evts.idx(evtIdx));
        case 'P'
            thisEvt = PAS_Events(evts.idx(evtIdx));
            thisEvt_Old = Old_PAS_Events(evts.idx(evtIdx));
        otherwise
            warning('Unexpected site.')
    end
    evtEdited = thisEvt.applyEdits(thisEvt_Old);
    numEdited = numEdited + double(evtEdited);
    thisEvt.calcAllStatistics();
    thisEvt.id = evts.idx(evtIdx);

    % Take into account the merged RR for certain events.
    includeMerge = false;
    fieldName = ['evt' num2str(evts.idx(evtIdx))];
    if isfield(mergeRR.(evts.site(evtIdx, :)), fieldName) && includeMerge
        evts.merged(evtIdx) = 1;
        thisEvt.avgRR = thisEvt.stats.mod.RR.both.precip;
        % Merged events use both LL and TB for exportPrecipRunoff
        evts.type(evtIdx, :) = 'BO';
    else
        evts.merged(evtIdx) = 0;
        thisEvt.avgRR = thisEvt.stats.mod.RR.(evts.type(evtIdx,:)).precip;
    end
end

% Select from all possible events just the events that were in our "good" folder.
matEvtIdx = evts.idx(all(evts.site == 'MAT', 2));
matEvtRunTypes = evts.type(all(evts.site == 'MAT', 2), :);
pasEvtIdx = evts.idx(all(evts.site == 'PAS', 2));
pasEvtRunTypes = evts.type(all(evts.site == 'PAS', 2), :);
matEvts = MAT_Events(matEvtIdx);
pasEvts = PAS_Events(pasEvtIdx);





%% Find events with matches.
% This keeps track of which events have matches.
matchedMATEvts = false(length(matEvts), 1);
matchedPASEvts = false(length(pasEvts), 1);
matchedEvtIdxs = struct('MAT', [], 'PAS', []);
matchedEvtTypes = struct('MAT', [], 'PAS', []);
pasTimes = [pasEvts.startTime]';
% For each event in MAT
for evtIdx = 1:length(matEvts)
    st = matEvts(evtIdx).startTime;
    % Build a vector that shows PAS event start times within an hour.
    hrsBtwnEvts = 1;
    try
        withinOne = (pasTimes - st < hours(hrsBtwnEvts)) & (pasTimes - st > hours(-1 * hrsBtwnEvts));
    catch
        disp('oops');
    end
    % Check to see if there exists a PAS event with start time within an hour.
    matchingPasIdx = find(withinOne);
    if length(matchingPasIdx) == 1
        % Record these matching events.
        matchedMATEvts(evtIdx) = true;
        matchedPASEvts(matchingPasIdx) = true;
        % DEBUGGING: Print the matching event start times to verify.
        disp(['MAT: ' datestr(st) ' PAS: ' datestr(pasEvts(matchingPasIdx).startTime)]);
    elseif length(matchingPasIdx) > 1
        % Would be surprising if there were more than one match, make a note of that.
        warning(['Found more than one matching event for MAT event with starttime: ' datestr(st)]);
    end
end
disp(['The total number of matched events is: ' num2str(sum(matchedMATEvts))]);





%% Gather different measurements into arrays.
data.MAT.id = [matEvts(matchedMATEvts).id];
data.PAS.id = [pasEvts(matchedPASEvts).id];
data.MAT.RR = [matEvts(matchedMATEvts).avgRR];
data.PAS.RR = [pasEvts(matchedPASEvts).avgRR];
data.MAT.StartTime = [matEvts(matchedMATEvts).startTime];
data.PAS.StartTime = [pasEvts(matchedPASEvts).startTime];
data.MAT.EndTime = [matEvts(matchedMATEvts).endTime];
data.PAS.EndTime = [pasEvts(matchedPASEvts).endTime];
data.MAT.PreTot = [matEvts(matchedMATEvts).precipTotal];
data.PAS.PreTot = [pasEvts(matchedPASEvts).precipTotal];
data.MAT.PI = [];
data.MAT.AvgI = [];
data.MAT.RT = [];
data.PAS.PI = [];
data.PAS.AvgI = [];
data.PAS.RT = [];
% Can't create an array automatically with structure deeper than one level.
matIdxs = find(matchedMATEvts);
for idx = 1:length(matIdxs)
    % Convert Precips to mm/hr from mm/10min
    data.MAT.PI = [data.MAT.PI matEvts(matIdxs(idx)).stats.mod.int.peak.precip * 6];
    data.MAT.AvgI = [data.MAT.AvgI matEvts(matIdxs(idx)).stats.mod.int.avg.precip * 6];
    data.MAT.RT = [data.MAT.RT minutes(matEvts(matIdxs(idx)).stats.orig.SM.RT)];
end

pasIdxs = find(matchedPASEvts);
for idx = 1:length(pasIdxs)
    % Convert Precips to mm/hr from mm/10min
    data.PAS.PI = [data.PAS.PI pasEvts(pasIdxs(idx)).stats.mod.int.peak.precip * 6];
    data.PAS.AvgI = [data.PAS.AvgI pasEvts(pasIdxs(idx)).stats.mod.int.avg.precip * 6];
    data.PAS.RT = [data.PAS.RT minutes(pasEvts(pasIdxs(idx)).stats.orig.SM.RT)];
end

data.MAT.duration = minutes([data.MAT.EndTime - data.MAT.StartTime]);
data.PAS.duration = minutes([data.PAS.EndTime - data.PAS.StartTime]);

% Sanity check the data.
if any([isnan(data.MAT.RT) isnan(data.PAS.RT)])
    warning('Response Time contained NaN values, something is wrong!');
end





%% Statistical tests comparing MAT and PAS for different measurements (RR, duration, etc.).
% Do a quick print out of the mean RRs for MAT and PAS.
avgMATRR = mean(data.MAT.RR);
avgPASRR = mean(data.PAS.RR);
disp(['Mean RR for good events in MAT is: ' num2str(avgMATRR)]);
disp(['Mean RR for good events in PAS is: ' num2str(avgPASRR)]);
disp(['PAS RR is: ' num2str((avgPASRR - avgMATRR) / avgMATRR * 100) '% higher than MAT.']);


% TODO: Fix RT in cases of NaNs, so that it stays a double and not a duration and can be ttested.
measurements = {'RR', 'duration', 'PI', 'AvgI', 'RT', 'PreTot'};
% measurements = {'RR', 'duration', 'PI', 'AvgI', 'PreTot'};
sites = {'MAT', 'PAS'};
for whichMeas = 1:length(measurements)
    [h,p] = ttest2(data.(sites{1}).(measurements{whichMeas}), data.(sites{2}).(measurements{whichMeas}));
    disp([measurements{whichMeas} ': TTest: The null hypothesis (that MAT and PAS share the same mean) was rejected?  (T/F): ' num2str(h) ' and p = ' num2str(p)]);

    combinedData = [data.(sites{1}).(measurements{whichMeas})'; data.(sites{2}).(measurements{whichMeas})'];
    numMAT = length(data.(sites{1}).(measurements{whichMeas}));
    numPAS = length(data.(sites{2}).(measurements{whichMeas}));
    groups(1:numMAT) = {'MAT'};
    groups(numMAT + 1:numMAT + numPAS) = {'PAS'};
    p = kruskalwallis(combinedData, groups, 'off');
    disp([measurements{whichMeas} ': Kruskal Wallis: The probability that MAT and PAS come from the same distribution: ' num2str(p)]);

    [h,p] = kstest2(data.(sites{1}).(measurements{whichMeas}), data.(sites{2}).(measurements{whichMeas}));
    disp([measurements{whichMeas} ': KSTest2: The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);

    % Perform the KSTest2 on each pair of bins from the MAT and PAS.
    % Need the same bin edges for both MAT and PAS, so use whichever is larger as
    % the reference.
    % if (max(data.PAS.(measurements{whichMeas})) > max(data.MAT.(measurements{whichMeas})))
    %     [NPAS, edgesPAS, bins.PAS] = histcounts(data.PAS.(measurements{whichMeas}));
    %     [NMAT, edgesMAT, bins.MAT] = histcounts(data.MAT.(measurements{whichMeas}), edgesPAS);
    % else
    %     [NMAT, edgesMAT, bins.MAT] = histcounts(data.MAT.(measurements{whichMeas}));
    %     [NPAS, edgesPAS, bins.PAS] = histcounts(data.PAS.(measurements{whichMeas}), edgesMAT);
    % end
    % for idx = 1:length(unique(edgesPAS))
    %     MATSample = data.MAT.(measurements{whichMeas})(bins.MAT == idx);
    %     PASSample = data.PAS.(measurements{whichMeas})(bins.PAS == idx);
    %     if ~isempty(MATSample) && ~isempty(PASSample)
    %         [h,p] = kstest2(MATSample, PASSample);
    %         disp([measurements{whichMeas} '- Bin starting with:' num2str(edgesPAS(idx)) ': KSTest2: The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);
    %     else
    %         disp([measurements{whichMeas} '- Bin starting with:' num2str(edgesPAS(idx)) ' did not contain samples for both MAT and PAS, so it could not be tested.']);
    %     end
    %
    % end

end

% Calculate the RR Uncertainty for each event and take an average.
uncerts = [];
matIdxs = find(matchedMATEvts);
for idx = 1:length(matIdxs)
    uncerts(end+1) = CalcRRUncertainty(matEvts(matIdxs(idx)), []);
end

pasIdxs = find(matchedPASEvts);
for idx = 1:length(pasIdxs)
    uncerts(end+1) = CalcRRUncertainty(pasEvts(pasIdxs(idx)), []);
end
avgRRUc = mean(uncerts);
disp(['The average uncertainty in the RR calculation for matched events is:' ...
      num2str(avgRRUc * 100) '%']);





%% Generate Plots.
genPlots = true;
if genPlots
    % Plot Average Intensity Vs RR.
    details.xlab = 'Mean Rainfall Intensity (mm hr^{-1})';
    details.ylab = 'Runoff Ratio';
    details.title = 'Average Rainfall Intensity vs RR';
    details.filename = 'Matched_AvgI';
    details.printEvtBins = true;
    details.expBarData = true;
    % 3 mm threshold cutoff, 5 quantiles:
    % edges = [ 0    4.0861    9.0401   13.7391   23.5329   67.4914];
    edges = [0    3.9744    7.3152   11.3707   25]; % Guabo Camp Multi Year
    % edges = linspace(0, 37, 6);
    plotErrorBars('AvgI', 'RR', data, details, edges);

    % Plot Peak Intensity Vs RR.
    details.xlab = 'Maximum Rainfall Intensity (mm hr^{-1})';
    details.ylab = 'Runoff Ratio';
    details.title = 'Maximum Rainfall Intensity vs RR';
    details.filename = 'Matched_PeakI';
    details.printEvtBins = true;
    details.expBarData = true;
    % 3mm, 5 quant
    % edges = [0   21.3360   42.6720   76.2000  120.3960  249.9360];
    edges = [ 0   21.3360   30.4800   41.9100  250]; % Guabo Camp Multi Year
    % edges = linspace(0, 125, 6);
    plotErrorBars('PI', 'RR', data, details, edges);

    % Plot Duration Vs RR.
    details.xlab = 'Duration (minutes)';
    details.ylab = 'Runoff Ratio';
    details.title = 'Duration vs RR';
    details.filename = 'Matched_Dur';
    details.printEvtBins = true;
    details.expBarData = true;
    details.xtickfmt = '%.f';
    % 3mm, 5 quantiles
    % edges = [ 0    55   100   165   270   580];
    edges = [0   60   110   180   410]; % Guabo Camp Multi Year
    % edges = linspace(0, 680, 6);
    plotErrorBars('duration', 'RR', data, details, edges);

    % Plot Precip Total vs RR.
    % details.xlab = 'Rainfall Total (mm)';
    % details.ylab = 'Runoff Ratio';
    % details.title = 'Precip Total vs RR';
    % details.filename = 'Matched_PreTot';
    % details.printEvtBins = false;
    % details.expBarData = false;
    % % 3mm, 5 quant
    % edges =[3    5.0800    8.5090   14.3510   27.0510   91.6940];
    % % edges = linspace(0, 60, 6);
    % plotErrorBars('PreTot', 'RR', data, details, edges);
end % genPlots





%% Export data for plotting with SigmaPlot
matIdxs = find(matchedMATEvts);
for evt = 1:length(matIdxs)
    type = matEvtRunTypes(matIdxs(evt), :);
    if strcmp(type, 'BO')
        type = 'BOTH';
    end
    whichEvt = matEvtIdx(matIdxs(evt));
    matEvts(matIdxs(evt)).exportPrecipRunoff('mod', type, whichEvt);
end

pasIdxs = find(matchedPASEvts);
for evt = 1:length(pasIdxs)
    type = pasEvtRunTypes(pasIdxs(evt), :);
    if strcmp(type, 'BO')
        type = 'BOTH';
    end
    whichEvt = pasEvtIdx(pasIdxs(evt));
    pasEvts(pasIdxs(evt)).exportPrecipRunoff('mod', type, whichEvt);
end

% Create summary statistics and save to .csvs
measurements = {'RR', 'duration', 'PI', 'AvgI','PreTot'};
sites = {'MAT', 'PAS'};
% For each site:
for whichSite = 1:length(sites)
    allMeas = struct('name', {}, 'vals', {});
    % Create a struct for each measurement and append
    for whichMeas = 1:length(measurements)
        thisMeas.vals = data.(sites{whichSite}).(measurements{whichMeas});
        thisMeas.name = measurements{whichMeas};
        allMeas(end+1) = thisMeas;
    end % For each measurement.
    details.fileName = ['Matched_' sites{whichSite} '.csv'];
    ExpSummStats(allMeas, details);
end % For each site.





%% Import modeled runoff from Hydrus and compare it to our observed runoff.
% TODO: This should be moved to a separate script eventually, but it exists
% here for the moment because this script already takes care of loading events
% and applying edits to them.
compareHydrus = true;
if compareHydrus == true
    % Storeage for values to be compared between modeled and observed data
    runStart = cell2table(cell(0,4));
    runStart.Properties.VariableNames = {'Site', 'Num', 'obsRunStart', 'hydRunStart'};
    runTot = cell2table(cell(0,4));
    runTot.Properties.VariableNames = {'Site', 'Num', 'obsRunTot', 'hydRunTot'};
    runRateMax = cell2table(cell(0,4));
    runRateMax.Properties.VariableNames = {'Site', 'Num', 'obsRunRateMax', 'hydRunRateMax'};
    runRateMaxTime = cell2table(cell(0,4));
    runRateMaxTime.Properties.VariableNames = {'Site', 'Num', 'obsRunRateMaxTime', 'hydRunRateMaxTime'};
    % Storage for time differences
    runStartError = [];

    hydDir = '../DataAndImport/HydrusOutputs';
    hydFldrs = dir(hydDir);
    pattern = '(MAT|PAS) *_*(\d+)'; % eg. 'MAT_40' or 'PAS 8'
    % For each hydrus file in the hydrus directory:
    for fldrIdx = 1:length(hydFldrs)
        % Determine which event it is based on folder name, eg. MAT_40.
        % hydFldrs(fldrIdx).name
        fldrTkn = regexp(hydFldrs(fldrIdx).name, pattern, 'tokens');
        if ~isempty(fldrTkn)
            hydSite = fldrTkn{1}{1};
            hydNum = str2double(fldrTkn{1}{2});
        else
            continue
        end

        % Check to make sure this hydrus event corresponds to an observed,
        % matched runoff event
        switch hydSite
        case 'MAT'
            % Get a list of index values for matched MAT events.
            matchedMATIdxs = matEvtIdx(find(matchedMATEvts));
            if ~any(hydNum == matchedMATIdxs)
                disp(['No matching event found for hydrus event: MAT' num2str(hydNum)]);
                continue
            end
            evtArrayIdx = find((matEvtIdx == hydNum) & matchedMATEvts);
            thisObsEvt = matEvts(evtArrayIdx);
            thisObsEvtType = matEvtRunTypes(evtArrayIdx, :);

        case 'PAS'
            % Get a list of index values for matched PAS events.
            matchedPASIdxs = pasEvtIdx(find(matchedPASEvts));
            if ~any(hydNum == matchedPASIdxs)
                disp(['No matching event found for hydrus event: PAS' num2str(hydNum)]);
                continue
            end
            evtArrayIdx = find((pasEvtIdx == hydNum) & matchedPASEvts);
            thisObsEvt = pasEvts(evtArrayIdx);
            thisObsEvtType = pasEvtRunTypes(evtArrayIdx, :);

        otherwise
            disp('Incorrect hydSite value.');
        end

        % Display which Hydrus file we're operating on
        disp([hydSite ' ' num2str(hydNum) ' -----------------------------']);

        % Import the hydrus data
        outFilePath = fullfile(hydDir, hydFldrs(fldrIdx).name, 'T_Level.out');
        if ~(exist(outFilePath, 'file') == 2)
            disp(['Out file for ' hydSite num2str(hydNum) ' might have different name than T_Level.out. Skipping this one.']);
            continue
        end
        [hydTime, hydRunoff, hydCumulativeRun] = importOutFile(outFilePath);
        % Raw runoff values are in MM/Min, convert to MM/10Min
        runoffTenMin = hydRunoff * 10;

        % Find runoff start times for hydrus and observed
        [hydStartTime, obsStartTime] = diffBtwnFirstRuns(runoffTenMin, hydTime, thisObsEvt, thisObsEvtType);
        % Append to a table for export.
        runStart = [runStart; {hydSite, hydNum, minutes(obsStartTime), minutes(hydStartTime)}];
        % Store the difference between the two (could be NaN if one or both are NaN).
        runStartError(end+1) = minutes(obsStartTime - hydStartTime);

        % Find total runoff amounts for modeled (hydrus) and observed.
        [hydRunTot, obsRunTot] = findRunoffTotals(hydCumulativeRun, thisObsEvt, thisObsEvtType);
        % Append to a table for export.
         runTot = [runTot; {hydSite, hydNum, obsRunTot, hydRunTot}];

        % Find peak runoff rates (and the minutes after precip start at which
        % they occurred) for modeled (hydrus) and observed.
        [hydPeakRunRate, obsPeakRunRate, hydPeakTime, obsPeakTime] = ...
          findRunoffMaxRates(hydRunoff, hydTime, thisObsEvt, thisObsEvtType);
        % DEBUGGING: Display the peak runoff rate times.
        disp(['Hydrus Peak time after start: ' num2str(hydPeakTime) ' Observed: ' num2str(obsPeakTime)]);

        % Append to a table for export.
         runRateMax = [runRateMax; {hydSite, hydNum, obsPeakRunRate, hydPeakRunRate}];
         runRateMaxTime = [runRateMaxTime; {hydSite, hydNum, obsPeakTime, hydPeakTime}];
    end
    % Compute an average difference in start time (maybe abs value?) and max runoff.
    disp(['The mean difference between observed and modeled start times is: '...
          num2str(nanmean(runStartError)) '. Negative means modeled occurs later.']);

    % Export the tables (runStart, runTot, runRateMax, etc.) to csv files.
    tableNames = {'runStart', 'runTot', 'runRateMax', 'runRateMaxTime'};
    tables = {runStart, runTot, runRateMax, runRateMaxTime};
    for tableIdx = 1:length(tables)
        fn = ['Export/ObsModComp/' tableNames{tableIdx} '.csv'];
        writetable(tables{tableIdx}, fn);
    end
end


function [hydStartTime, obsStartTime] = diffBtwnFirstRuns(hydRunoff, hydTime, thisObsEvt, thisObsEvtType)
    % Calculate the difference in time between when the first substantial runoff
    % ocurred in the hydrus data, and in the observed data.

    % Find the time of beginning of runoff for Hydrus data.
    % Tipping bucket has minimum resolution of 0.2mm, so use that.
    runThresh = 0.2;
    firstRunIdx = find(hydRunoff >= runThresh, 1);
    % TODO: Consider also setting a time threshold eg. must have runoff of
    % more than runThresh amount for longer than timeThresh amount of time.
    if isempty(firstRunIdx)
        disp('No substantial runoff found in modeled data.');
        hydStartTime = minutes(nan);
    else
      hydStartTime = minutes(hydTime(firstRunIdx) - hydTime(1));
    end
    % Find difference between that and the start of runoff for observed data.
    obsStartTime = thisObsEvt.timeToFirstRunoff(thisObsEvtType);
    if isnan(obsStartTime)
        disp('No substantial runoff found in observed data.');
    end
end

function [hydRunTot, obsRunTot] = findRunoffTotals(hydCumulativeRun, thisObsEvt, thisObsEvtType)
    % Find total runoff amounts for modeled (hydrus) and observed data

    % TODO: Consider whether 0 should be at beginning or end of duration.
    % duration = [0; diff(hydTimeVals)];
    % hydRunAmtMM = duration .* hydRunoffVals;
    % hydRunTot = sum(hydRunAmtMM);
    hydRunTot = hydCumulativeRun(end);
    obsRunTot = thisObsEvt.stats.mod.RunAmt.(thisObsEvtType);
end

function [hydRunMax, obsRunMax, hydMaxTime, obsMaxTime] = findRunoffMaxRates(hydRunoff, hydTime, thisObsEvt, thisObsEvtType)
    % Find maximum runoff rates (mm/hr) and times (mins after precip start) for modeled (hydrus) and observed data.
    [unqHydTime, unqIdx, ~] = unique(hydTime);
    unqHydRunoff = hydRunoff(unqIdx);
    hydRunSmoothed = movmean(unqHydRunoff, 5, 'omitnan', 'EndPoints', 'shrink', 'SamplePoints', unqHydTime);
    % Find max runoff rate, and convert from mm/min to mm/hr.
    [hydRunMax, maxIdx] = max(hydRunSmoothed);
    hydRunMax = hydRunMax * 60;
    hydMaxTime = unqHydTime(maxIdx) - unqHydTime(1);

    % obsRunMax = nan;
    [obsRunMax, obsMaxTime] = thisObsEvt.findMaxRunoffRate(thisObsEvtType);
    % Convert obsMaxTime from duration to double of minutes
    obsMaxTime = minutes(obsMaxTime);

    debugHydRunMax = false;
    if debugHydRunMax == true && (hydRunMax > 100 || hydRunMax < 0.1)
        % Debugging: Visualize smoothed and original data for sanity check.
        plot(hydTime, hydRunoff, unqHydTime, hydRunSmoothed);
        disp(['hydRunMax: ' num2str(hydRunMax) ' obsRunMax: ' num2str(obsRunMax)]);
    end
end
