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

    % Take into account the merged RR for certain events.
    includeMerge = true;
    fieldName = ['evt' num2str(evts.idx(evtIdx))];
    if isfield(mergeRR.(evts.site(evtIdx, :)), fieldName) && includeMerge
        evts.merged(evtIdx) = 1;
        thisEvt.avgRR = thisEvt.stats.mod.RR.both.precip;
    else
        evts.merged(evtIdx) = 0;
        thisEvt.avgRR = thisEvt.stats.mod.RR.(evts.type(evtIdx,:)).precip;
    end
end

% Select from all possible events just the events that were in our "good" folder.
matEvtIdx = evts.idx(all(evts.site == 'MAT', 2));
pasEvtIdx = evts.idx(all(evts.site == 'PAS', 2));
matEvts = MAT_Events(matEvtIdx);
pasEvts = PAS_Events(pasEvtIdx);

%% Find events with matches.
% This keeps track of which events have matches.
matchedMATEvts = false(length(matEvts), 1);
matchedPASEvts = false(length(pasEvts), 1);
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
disp(['The total number of matched events is: ' num2str(length(matchedMATEvts))]);





%% Gather different measurements into arrays.
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
    data.MAT.PI = [data.MAT.PI matEvts(idx).stats.mod.int.peak.precip * 6];
    data.MAT.AvgI = [data.MAT.AvgI matEvts(idx).stats.mod.int.avg.precip * 6];
    data.MAT.RT = [data.MAT.RT minutes(matEvts(idx).stats.orig.SM.RT)];
end

pasIdxs = find(matchedPASEvts);
for idx = 1:length(pasIdxs)
    % Convert Precips to mm/hr from mm/10min
    data.PAS.PI = [data.PAS.PI pasEvts(idx).stats.mod.int.peak.precip * 6];
    data.PAS.AvgI = [data.PAS.AvgI pasEvts(idx).stats.mod.int.avg.precip * 6];
    data.PAS.RT = [data.PAS.RT minutes(pasEvts(idx).stats.orig.SM.RT)];
end

data.MAT.duration = minutes([data.MAT.EndTime - data.MAT.StartTime]);
data.PAS.duration = minutes([data.PAS.EndTime - data.PAS.StartTime]);

% Sanity check the data.
if any([isnan(data.MAT.RT) isnan(data.PAS.RT)])
    warning('Respnse Time contained NaN values, something is wrong!');
end





%% Statistical tests comparing MAT and PAS for different measurements (RR, duration, etc.).
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






%% Generate Plots.
% Plot Average Intensity Vs RR.
details.xlab = 'Average Precip Intensity (mm/hr)';
details.ylab = 'Runoff Ratio';
details.title = 'Average Precip Intensity vs RR';
% 3 mm threshold cutoff, 5 quantiles:
edges = [ 0    4.0861    9.0401   13.7391   23.5329   67.4914];
% edges = linspace(0, 37, 6);
plotErrorBars('AvgI', 'RR', data, details, edges);

% Plot Peak Intensity Vs RR.
details.xlab = 'Peak Precip Intensity (mm/hr)';
details.ylab = 'Runoff Ratio';
details.title = 'Peak Precip Intensity vs RR';
% 3mm, 5 quant
edges = [0   21.3360   42.6720   76.2000  120.3960  249.9360];
% edges = linspace(0, 125, 6);
plotErrorBars('PI', 'RR', data, details, edges);

% Plot Duration Vs RR.
details.xlab = 'Duration (min)';
details.ylab = 'Runoff Ratio';
details.title = 'Duration vs RR';
% 3mm, 5 quantiles
edges = [ 0    55   100   165   270   580];
% edges = linspace(0, 680, 6);
plotErrorBars('duration', 'RR', data, details, edges);

% Plot Precip Total vs RR.
details.xlab = 'Precip Total (mm)';
details.ylab = 'Runoff Ratio';
details.title = 'Precip Total vs RR';
% 3mm, 5 quant
edges =[3    5.0800    8.5090   14.3510   27.0510   91.6940];
% edges = linspace(0, 60, 6);
plotErrorBars('PreTot', 'RR', data, details, edges);
