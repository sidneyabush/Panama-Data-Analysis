% Generates several plots (e.g. RR v. Intensity) from the "good" folder.

matFolder = 'RainEventFigures/All_Runoff/';
eventFolder = 'Good';
mergeFolder = 'Merge';

% Load the .mat file containing our edited event data (doesn't contain SM data).
oldEvts = load([matFolder 'allEvents.mat']);
Old_MAT_Events = oldEvts.MAT_Events;
Old_PAS_Events = oldEvts.PAS_Events;
allOldEvents = {Old_MAT_Events, Old_PAS_Events};

% Generate new events (which contain added data like SM).
Create_RainEvents;
allEvents = {MAT_Events, PAS_Events};

% Load the .mat file containing our merged RR data.
load([matFolder mergeFolder '/mergeRR.mat']);

% Get all the figures in the desired folder.
matFigs = dir([matFolder eventFolder '/MAT*.fig']);
pasFigs = dir([matFolder eventFolder '/PAS*.fig']);
allFigs = {matFigs, pasFigs};
sites = {'MAT', 'PAS'};

% Create a structure to store the RR data, Intensity data, etc.
data = struct();
data.(sites{1}) = struct();
data.(sites{2}) = struct();
data.numEdited = 0;

% Extract, using parentheses in the regex, the event number and TB or LL.
pattern = 'event_(\d+)_([L-T][B-L]).fig';
% For both the MAT and PAS field sites.
for j = 1:length(sites)
    tokens = regexp({allFigs{j}.name}, pattern, 'tokens');

    % Store the event number and type (TB or LL).
    data.(sites{j}).RR = [];
    data.(sites{j}).celestinoRR = [];
    data.(sites{j}).startTimes = [];
    data.(sites{j}).endTimes = [];
    data.(sites{j}).PI = [];
    data.(sites{j}).AvgI = [];
    data.(sites{j}).celestinoAvgI = [];
    data.(sites{j}).celestinoPI = [];
    data.(sites{j}).RT = [];

    cells = [tokens{:}];
    % Sort the events based on the event number. TODO: vectorize this.
    evtNums = [];
    for idx = 1:length(cells)
        % Extract the event number
        evtNums = [evtNums str2double(cells{idx}{1})];
    end
    % Create the sorting indices.
    [~, sortIdx] = sort(evtNums);
    % Resort the cells.
    cells = cells(sortIdx');

    % For every event in the "good" folder, for the current site.
    for i = 1:length(cells)
        evtIdx = str2double(cells{i}{1});
        thisEvt = allEvents{j}(evtIdx);
        thisEvt_Old = allOldEvents{j}(evtIdx);
        % DEBUGGING: Make some noise if we found an event with edits.
        % if any(thisEvt_Old.precipZeroed)
        %     display([sites{j} num2str(evtIdx) 'contains the following zeroing: ' thisEvt_Old.precipZeroed]);
        % end
        % Copy over the edits from the old version of the event to the new.
        evtEdited = thisEvt.applyEdits(thisEvt_Old);
        data.numEdited = data.numEdited + double(evtEdited);
        % Make sure to calc all statistics after copying edits.
        thisEvt.calcAllStatistics();

        % Concatenate details about this event including RR, start and end times, Peak Intensity etc.
        % Check if there's a "merged" version of the RR. If so, use that instead of the original one.
        fieldName = ['evt' num2str(evtIdx)];
        includeBootMerge = true;
        if isfield(mergeRR.(sites{j}), fieldName) && includeBootMerge
            thisEvtRR = mean(mergeRR.(sites{j}).(fieldName));
        else
            thisEvtRR = thisEvt.stats.mod.RR.(cells{i}{2}).precip;
        end
        data.(sites{j}).RR = [data.(sites{j}).RR thisEvtRR];
        % Notify if we just found an event with a RR > 1.
        if data.(sites{j}).RR(end) >= 1
            warning(['RR >= 1 for: ' sites{j} ' ' num2str(evtIdx)]);
        end

        data.(sites{j}).startTimes = [data.(sites{j}).startTimes thisEvt.startTime];
        data.(sites{j}).endTimes = [data.(sites{j}).endTimes thisEvt.endTime];
        data.(sites{j}).PI = [data.(sites{j}).PI thisEvt.stats.mod.int.peak.precip];
        data.(sites{j}).AvgI = [data.(sites{j}).AvgI thisEvt.stats.mod.int.avg.precip];
        % There are four response times, one for each depth. Store in 2D array.
        avgs = [thisEvt.SM.avg1.RT.dur;
            thisEvt.SM.avg2.RT.dur;
            thisEvt.SM.avg3.RT.dur;
            thisEvt.SM.avg4.RT.dur];
        data.(sites{j}).RT = [data.(sites{j}).RT avgs];


        % Add additional RR data for the MAT site using Celestino.
        % NOTE: This does not take into account the possible presence of a merged RR for celestino.
        if strcmpi(sites{j}, 'MAT')
            data.(sites{j}).celestinoRR = [data.(sites{j}).celestinoRR thisEvt.stats.mod.RR.(cells{i}{2}).addl];
            if data.(sites{j}).celestinoRR(end) >= 1
                warning(['celestinoRR >= 1 for: ' sites{j} ' ' num2str(evtIdx)]);
            end
            data.(sites{j}).celestinoPI = [data.(sites{j}).celestinoPI thisEvt.stats.mod.int.peak.celestino];
            data.(sites{j}).celestinoAvgI = [data.(sites{j}).celestinoAvgI thisEvt.stats.mod.int.avg.celestino];
        end
    end

    % Calculate duration
    data.(sites{j}).duration = data.(sites{j}).endTimes - data.(sites{j}).startTimes;
    data.(sites{j}).durationMins = minutes(data.(sites{j}).duration);
    % Change intensities to mm/hr (from mm/10min)
    data.(sites{j}).PI = data.(sites{j}).PI * 6;
    data.(sites{j}).AvgI = data.(sites{j}).AvgI * 6;
    data.(sites{j}).celestinoAvgI = data.(sites{j}).celestinoAvgI * 6;
    data.(sites{j}).celestinoPI = data.(sites{j}).celestinoPI * 6;

    %% Plot events
    plotScatters = true;
    if plotScatters
        % Plot Runoff Ratio vs Duration
          durationPlt.x = data.(sites{j}).RR;
          durationPlt.y = minutes(data.(sites{j}).duration);
          durationPlt.site = sites{j};
          durationPlt.title = 'RR vs Duration for Good Events';
          durationPlt.xlab = 'Runoff Ratio';
          durationPlt.ylab = 'Duration (min)';
          plotScatter(durationPlt);

          % Plot Runoff Ratio vs Peak Intensity
          PIPlt.x = data.(sites{j}).RR;
          PIPlt.y = data.(sites{j}).PI;
          PIPlt.site = sites{j};
          PIPlt.title = 'RR vs Peak Intensity for Good Events';
          PIPlt.xlab = 'Runoff Ratio';
          PIPlt.ylab = 'Peak Intensity (mm/hr)';
          plotScatter(PIPlt);

          % Plot Runoff Ratio vs Average Intensity
          AvgIPlt.x = data.(sites{j}).RR;
          AvgIPlt.y = data.(sites{j}).AvgI;
          AvgIPlt.site = sites{j};
          AvgIPlt.title = 'RR vs Average Intensity for Good Events';
          AvgIPlt.xlab = 'Runoff Ratio';
          AvgIPlt.ylab = 'Average Intensity (mm/hr)';
          plotScatter(AvgIPlt);



        % Plot extra figures using Celestino data for MAT
        if strcmpi(sites{j}, 'MAT')
            CelPIPlt.x = data.(sites{j}).celestinoRR;
            CelPIPlt.y = data.(sites{j}).celestinoPI;
            CelPIPlt.site = sites{j};
            CelPIPlt.title = 'Celestino RR vs Celestino Peak Intensity for Good Events';
            CelPIPlt.xlab = 'Runoff Ratio';
            CelPIPlt.ylab = 'Peak Intensity (mm/hr)';
            plotScatter(CelPIPlt);

            % Plot Runoff Ratio vs Average Intensity
            CelAvgIPlt.x = data.(sites{j}).celestinoRR;
            CelAvgIPlt.y = data.(sites{j}).celestinoAvgI;
            CelAvgIPlt.site = sites{j};
            CelAvgIPlt.title = 'Celestino RR vs Celestino Average Intensity for Good Events';
            CelAvgIPlt.xlab = 'Runoff Ratio';
            CelAvgIPlt.ylab = 'Average Intensity (mm/hr)';
            plotScatter(CelAvgIPlt);
        end
    end
end

%% Create a subset of the events where each MAT has a matching PAS.
% For each event in MAT
% Check to see if there's a PAS with start time within an hour.
% If so, add both to a special variable for use later.









%% Statistics comparing MAT and PAS
% Do a quick print out of the mean RRs for MAT and PAS.
avgMATRR = mean(data.MAT.RR);
avgPASRR = mean(data.PAS.RR);
disp(['Mean RR for good events in MAT is: ' num2str(avgMATRR)]);
disp(['Mean RR for good events in PAS is: ' num2str(avgPASRR)]);
disp(['PAS RR is: ' num2str((avgPASRR - avgMATRR) / avgMATRR * 100) '% higher than MAT.']);

% TTests comparing MAT and PAS for different measurements (RR, duration, etc.).
measurements = {'RR', 'durationMins', 'PI', 'AvgI'};
for whichMeas = 1:length(measurements)
    [h,p] = ttest2(data.(sites{1}).(measurements{whichMeas}), data.(sites{2}).(measurements{whichMeas}));
    display([measurements{whichMeas} ': The null hypothesis (that MAT and PAS share the same mean) was rejected?  (T/F): ' num2str(h) ' and p = ' num2str(p)]);
end

% Multicompare with Anova1 for different measurements, grouped by both MAT/PAS and by RR (0-0.2, 0.2-0.4, etc.)
for whichMeas = 2:length(measurements)
    % Establish edges for the groups.
    edges = 0:0.2:1;
    % Create names eg '0.2' for the groups.
    binNames = cellstr(num2str(edges(:)));
    binNames(1) = '';
    % Get indices telling which point goes into which group.
    [~, ~, binIdxMAT] = histcounts(data.(sites{1}).RR, edges);
    [~, ~, binIdxPAS] = histcounts(data.(sites{2}).RR, edges);
    % Create vectors with groups like {'0.2 MAT' '0.4 MAT'}
    MATGroups = strcat(binNames(binIdxMAT), ' MAT');
    PASGroups = strcat(binNames(binIdxPAS), ' PAS');
    % Sort so that groups appear in alphabetical order.
    [sortedMATGroups sortMATIdx] = sort(MATGroups);
    [sortedPASGroups sortPASIdx] = sort(PASGroups);
    sortedMATMeas = data.(sites{1}).(measurements{whichMeas})(sortMATIdx);
    sortedPASMeas = data.(sites{2}).(measurements{whichMeas})(sortPASIdx);
    % Stitch the MAT and PAS groups and measurements together.
    measVals = [sortedMATMeas sortedPASMeas];
    measGroups = [MATGroups', PASGroups'];
    details.title = ['Multi-compare for MAT and PAS: ' measurements{whichMeas}];
    [h, stats] = plotmultcomp(measVals, measGroups, details);
end





%% Plots for MAT and PAS
% Now that we've extracted data for both MAT and PAS, generate plots with both.
% First, sort the RR data into bins for the box plots.
% Need all bin edges to be uniform between MAT and PAS.
numBins = 5;
edges = 0:0.2:1;
[~, ~, binsMAT]  = histcounts(data.MAT.RR, edges);
[~, ~, binsPAS]  = histcounts(data.PAS.RR, edges);

% Ugly way to create grouping categories for the MAT and PAS boxes.
MATID = repmat('MAT', fliplr(size(data.MAT.RR)));
PASID = repmat('PAS', fliplr(size(data.PAS.RR)));

% Stitch MAT and PAS data together.
bins = [binsMAT'; binsPAS'];
duration = minutes([data.MAT.duration'; data.PAS.duration']);
peakIntensity = [data.MAT.PI'; data.PAS.PI'];
intensity = [data.MAT.AvgI'; data.PAS.AvgI'];
IDs = [MATID; PASID];

% Determine how many categories there will be eg MAT-Bin1, PAS-Bin6.
% For each rain event, stitch it's RR bin together with it's site (eg MAT) and
% then count the number of unique combinations.
groups = unique(cellstr([num2str(bins) IDs]));
% Create the labels for each box. If both MAT and PAS exist, (eg. 1MAT, 1PAS are
% both present) assign the label to only the first one of them.
labelIdx = 2;
boxLabels = {num2str(edges(labelIdx))};
labelIdx = labelIdx + 1;
for k = 2:length(groups)
    if ~strcmp(groups{k}(1), groups{k-1}(1))
        boxLabels{end+1} = num2str(edges(labelIdx));
        labelIdx = labelIdx + 1;
    else
        boxLabels{end+1} = '';
    end
end

binGap = 25;
MATPASGap = 1;
lineSize = 3;
textSize = 18;
axisFontSize = textSize;
if includeBootMerge
    titleText = '"Good" and bootstrapped-merged data combined.';
else
    titleText = '"Good" data only, no bootstrapped-merged data.';
end

% Plot peak intensity boxes.
figure
bh = boxplot(peakIntensity, {bins, IDs},  ...
    'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
% 'Colors', 'rb', 'Labels', boxLabels,
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% bh(:,2).linewidth = 6;
% title('RR vs Peak Intensity for Good Events');
ylabel('Peak Intensity (mm/hr)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
% legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);
title(titleText);

% Plot intensity boxes.
figure
bh = boxplot(intensity, {bins, IDs}, ...
    'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
% 'Colors', 'rb',  'Labels', boxLabels,
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% title('RR vs Mean Intensity for Good Events');
ylabel('Mean Intensity (mm/hr)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
% legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);
title(titleText);

% Plot duration boxes.
figure
bh = boxplot(duration, {bins, IDs}, ...
    'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
% 'Colors', 'rb',  'Labels', boxLabels,
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% title('RR vs Duration for Good Events');
ylabel('Event Duration (minutes)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
% legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);
title(titleText);

plotResponseTime = true;
if plotResponseTime
    for j = 1:length(sites)
        % Plot Runoff Ratio vs Response Time
        depths = {'10 cm', '30 cm', '50 cm', '100 cm'};
        for idx = 1:length(depths)
            RTPlt.x = data.(sites{j}).RR;
            RTPlt.y = minutes(data.(sites{j}).RT(idx, :));
            RTPlt.site = sites{j};
            RTPlt.title = ['RR vs Response Time for Good Events at depth: ' depths{idx}];
            RTPlt.xlab = 'Runoff Ratio';
            RTPlt.ylab = 'Response Time (minutes)';
            % Find the longest response time in either MAT or PAS, and give each graph the same y limits.
            RTPlt.ylim = [0, minutes(max(max(max(data.(sites{1}).RT)), max(max(data.(sites{2}).RT))))];
            plotScatter(RTPlt);
        end
    end
end

function handle = plotScatter(pltData)
handle = figure;
colors = linspace(1,10, length(pltData.x));
scatter(pltData.x, pltData.y, [], colors);
title([pltData.site ': ' pltData.title]);
xlabel(pltData.xlab);
ylabel(pltData.ylab);
if isfield(pltData, 'ylim')
    ylim(pltData.ylim);
end
end

function [handle, stats] = plotmultcomp(meas, groups, details)
      handle = figure;
      [stats.p, stats.t, stats.stats] = anova1(meas, groups, 'off');
      [stats.c, stats.m, stats.h, stats.nms] = multcompare(stats.stats);
      title(details.title);
end
