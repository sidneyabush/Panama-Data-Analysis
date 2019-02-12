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
    data.(sites{j}).id = [];
    data.(sites{j}).evtIdx = [];
    data.(sites{j}).RR = [];
    data.(sites{j}).celestinoRR = [];
    data.(sites{j}).startTimes = [];
    data.(sites{j}).endTimes = [];
    data.(sites{j}).PI = [];
    data.(sites{j}).AvgI = [];
    data.(sites{j}).celestinoAvgI = [];
    data.(sites{j}).celestinoPI = [];
    data.(sites{j}).RT = [];
    data.(sites{j}).PreTot = [];
    numMerged = 0;
    numUnderPreTotThresh = 0;
    numEvtsGoodAndValidPrecip = 0;
    data.(sites{j}).mergedNames = {};
    data.(sites{j}).editedNames = {};
    RRUncerts = [];
    data.(sites{j}).NumTB = 0;
    data.(sites{j}).NumLL = 0;
    data.(sites{j}).TBNames = {};

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
        % It's possible that the minimum valid precip threshold has rendered
        % this event invalid. Don't use it if so.
        if any(isnan(thisEvt.site))
            numUnderPreTotThresh = numUnderPreTotThresh + 1;
            continue
        else
            % Note that this is a good event which we'll be using further.
            data.(sites{j}).evtIdx = [data.(sites{j}).evtIdx evtIdx];
            numEvtsGoodAndValidPrecip = numEvtsGoodAndValidPrecip + 1;
        end

        thisEvt_Old = allOldEvents{j}(evtIdx);
        % DEBUGGING: Make some noise if we found an event with edits.
        % if any(thisEvt_Old.precipZeroed)
        %     display([sites{j} num2str(evtIdx) 'contains the following zeroing: ' thisEvt_Old.precipZeroed]);
        % end

        % Copy over the edits from the old version of the event to the new.
        evtEdited = thisEvt.applyEdits(thisEvt_Old);
        data.numEdited = data.numEdited + double(evtEdited);
        if evtEdited
            data.(sites{j}).editedNames{end+1} = [sites{j} '_event_' num2str(evtIdx)];
        end
        % Make sure to calc all statistics after copying edits.
        thisEvt.calcAllStatistics();

        % Concatenate details about this event including RR, start and end times, Peak Intensity etc.
        % Check if there's a "merged" version of the RR. If so, use that instead of the original one.
        fieldName = ['evt' num2str(evtIdx)];
        includeBootMerge = false;
        if isfield(mergeRR.(sites{j}), fieldName) && includeBootMerge
            thisEvtRR = mean(mergeRR.(sites{j}).(fieldName));
            numMerged = numMerged + 1;
            data.(sites{j}).mergedNames{end+1} = [sites{j} '_event_' num2str(evtIdx)];
        else
            thisEvtRR = thisEvt.stats.mod.RR.(cells{i}{2}).precip;
        end
        data.(sites{j}).RR = [data.(sites{j}).RR thisEvtRR];
        % Notify if we just found an event with a RR > 1.
        if data.(sites{j}).RR(end) >= 1
            warning(['RR >= 1 for: ' sites{j} ' ' num2str(evtIdx)]);
        end

        % TODO: Move this so that we can breakpoint on it after the modifications have been made to update the rainevent, so we can check what the average rainfall rate was for the events where we're looking at the TB
        % DEBUGGING: count the number of TB and the number of LL events for both mat and PAS
        if strcmp(cells{i}{2}, 'LL')
            data.(sites{j}).NumLL = data.(sites{j}).NumLL + 1;
        elseif strcmp(cells{i}{2}, 'TB')
            data.(sites{j}).NumTB = data.(sites{j}).NumTB + 1;
            data.(sites{j}).TBNames{end+1} = [sites{j} '_event_' num2str(evtIdx) 'Peak rainfall rate(mmh-1): ' num2str(thisEvt.stats.mod.int.peak.precip*6) ' Avg. rainfall rate(mmh-1): ' num2str(thisEvt.stats.mod.int.avg.precip*6)];
        end

        % Calculate the uncertainty in the RR, and store for later.
        RRUncerts(end+1) = CalcRRUncertainty(thisEvt, []);

        data.(sites{j}).id = [data.(sites{j}).id evtIdx];
        data.(sites{j}).startTimes = [data.(sites{j}).startTimes thisEvt.startTime];
        data.(sites{j}).endTimes = [data.(sites{j}).endTimes thisEvt.endTime];
        data.(sites{j}).PI = [data.(sites{j}).PI thisEvt.stats.mod.int.peak.precip];
        data.(sites{j}).AvgI = [data.(sites{j}).AvgI thisEvt.stats.mod.int.avg.precip];
        data.(sites{j}).PreTot = [data.(sites{j}).PreTot thisEvt.getTotal()];
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


    % Sanity check the data. Did we get data from all the sites we expected?
    % measurements = {'RR', 'durationMins', 'PI', 'AvgI', 'PreTot'};
    % for whichMeas = 1:length(measurements)
    %     numGood = num2str(sum(~isnan(data.(sites{j}).(measurements{whichMeas}))));
    %     disp([measurements{whichMeas} ': ~NAN for ' sites{j} '= ' numGood]);
    % end
    % DEBUGGING:
    disp(['The number of merged events included for ' sites{j} ' is:' num2str(numMerged)]);
    disp(['The number of "good" events with sufficient precip total for ' sites{j} ' is:' num2str(numEvtsGoodAndValidPrecip)]);



    %% Plot events
    plotScatters = false;
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







%% Statistics comparing MAT and PAS
% Do a quick print out of the mean RRs for MAT and PAS.
avgMATRR = mean(data.MAT.RR);
avgPASRR = mean(data.PAS.RR);
disp(['Mean RR for good events in MAT is: ' num2str(avgMATRR)]);
disp(['Mean RR for good events in PAS is: ' num2str(avgPASRR)]);
disp(['PAS RR is: ' num2str((avgPASRR - avgMATRR) / avgMATRR * 100) '% higher than MAT.']);


% Calculate stats regarding SM (Soil Moisture) RT (Response Time)
% For each site, calculate what was the minimum peak intensity of precip needed to trigger a response time
for whichSite = 1:length(sites)
  curSite = data.(sites{whichSite});
  % Consider each event
  for whichEvt = 1:length(curSite.PI)
    % If we got a SM response
    if any(~isnan(curSite.RT(:, whichEvt)))
      % DEBUG: Check if SM responded faster at 100 than 30
      RT30  = curSite.RT(2,whichEvt);
      RT100 = curSite.RT(4,whichEvt);
      if RT100 < RT30
        disp(['RT100 < RT30 at event ' sites{whichSite} num2str(curSite.evtIdx(whichEvt)) ', idx: ' num2str(whichEvt) '. RT100: ' char(RT100) ', RT30: ' char(RT30)]);
      end % if RT100 < RT30
      % Compare current precip intensity to previous low
      thisEvtPrecip = curSite.PI(whichEvt);
      if thisEvtPrecip < minPrecipForSMResp
          % Store new low value
          minPrecipForSMResp = thisEvtPrecip;
          disp(['New low precip found at event ' sites{whichSite} num2str(curSite.evtIdx(whichEvt)) ': ' num2str(thisEvtPrecip)])
      end % Compare current precip intensity to previous low
    end % If we got a SM response
  end % For each event in 'data'
  disp(['Lowest PI precip for SM response at ' sites{whichSite} ': ' num2str(minPrecipForSMResp)]);

  % Calculate the mean soil moisture response at each depth for each site
  RTMeans = nanmean(curSite.RT, 2);
  % Calculate the number of NANs for each depth.
  allNans = isnan(curSite.RT);
  numNans = sum(allNans, 2);
  % Display the results of the mean
  RTTable = array2table(RTMeans, 'RowNames', {'10', '30', '50', '100'});
  RTTable.NumNans = numNans;
  disp(['Average response time at each depth for ' sites{whichSite}]);
  disp(RTTable);
end % For each site



% Statistical tests comparing MAT and PAS for different measurements (RR, duration, etc.).
measurements = {'RR', 'durationMins', 'PI', 'AvgI', 'PreTot'};
for whichMeas = 1:length(measurements)
    [h,p] = ttest2(data.(sites{1}).(measurements{whichMeas}), data.(sites{2}).(measurements{whichMeas}));
    display([measurements{whichMeas} ': TTest: The null hypothesis (that MAT and PAS share the same mean) was rejected?  (T/F): ' num2str(h) ' and p = ' num2str(p)]);

    combinedMeasData = [data.(sites{1}).(measurements{whichMeas})'; data.(sites{2}).(measurements{whichMeas})'];
    numMAT = length(data.(sites{1}).(measurements{whichMeas}));
    numPAS = length(data.(sites{2}).(measurements{whichMeas}));
    groups(1:numMAT) = {'MAT'};
    groups(numMAT + 1:numMAT + numPAS) = {'PAS'};
    p = kruskalwallis(combinedMeasData, groups, 'off');
    disp([measurements{whichMeas} ': Kruskal Wallis: The probability that MAT and PAS come from the same distribution: ' num2str(p)]);

    [h,p] = kstest2(data.(sites{1}).(measurements{whichMeas}), data.(sites{2}).(measurements{whichMeas}));
    disp([measurements{whichMeas} ': KSTest2: The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);
end

% Print all the max values (useful for establishing how large our quantiles need to be).
for whichMeas = 1:length(measurements)
    disp(['Max value for measurement ' sites{1} ' ' measurements{whichMeas} ': ' num2str(max(data.(sites{1}).(measurements{whichMeas})))]);
    disp(['Max value for measurement ' sites{2} ' ' measurements{whichMeas} ': ' num2str(max(data.(sites{2}).(measurements{whichMeas})))]);
    disp(['Min value for measurement ' sites{1} ' ' measurements{whichMeas} ': ' num2str(min(data.(sites{1}).(measurements{whichMeas})))]);
    disp(['Min value for measurement ' sites{2} ' ' measurements{whichMeas} ': ' num2str(min(data.(sites{2}).(measurements{whichMeas})))]);
end

plotGroupedByRR = false;
if plotGroupedByRR
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
        % NOTE: plotmultcomp has been moved with plotErrorBars to a new file.
        % [h, stats] = plotmultcomp(measVals, measGroups, details);
    end
end

% Calculate the average uncertainty in the RR equation.
avgRRUc = mean(RRUncerts);
disp(['The average uncertainty in the RR calculation for good events is:' ...
      num2str(avgRRUc * 100) '%']);






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
labelIdx = 2;   % Don't create a label for the edge "0".
boxLabels = {[ '0 - ' num2str(edges(labelIdx))]};
labelIdx = labelIdx + 1;
for k = 2:length(groups)
    if ~strcmp(groups{k}(1), groups{k-1}(1))
        boxLabels{end+1} = [num2str(edges(labelIdx - 1)) ' - ' num2str(edges(labelIdx))];
        labelIdx = labelIdx + 1;
    else
        boxLabels{end+1} = '';
    end
end

% Display the number of points that fell into each bin.
[counts, namesOfBins] = histcounts(categorical(cellstr([num2str(bins) IDs])));
binSummaryTable = table(counts', namesOfBins', 'VariableNames', {'Number', 'Grouping'});
disp(binSummaryTable);

% Assign a color to each bin based on whether it's MAT or PAS.
binColors = '';
for binIdx = 1:length(namesOfBins)
    if strfind(namesOfBins{binIdx}, 'MAT')
        binColors = [binColors 'r'];
    else
        binColors = [binColors 'b'];
    end
end

% Plot peak intensity boxes.
pkIntBoxPlt.data = peakIntensity;
pkIntBoxPlt.groups = {bins, IDs};
pkIntBoxPlt.ylab = 'Peak Intensity (mm/hr)';
pkIntBoxPlt.xlab = 'Runoff Ratio';
pkIntBoxPlt.title = 'Peak Intensity vs Runoff Ratio for Forest and Pasture';
% plotBox(pkIntBoxPlt, boxLabels, binColors);


% Plot intensity boxes.
intBoxPlt.data = intensity;
intBoxPlt.groups = {bins, IDs};
intBoxPlt.ylab = 'Mean Intensity (mm/hr)';
intBoxPlt.xlab = 'Runoff Ratio';
intBoxPlt.title = 'Mean Intensity vs Runoff Ratio for Forest and Pasture';
% plotBox(intBoxPlt, boxLabels, binColors);


% Plot duration boxes.
durBoxPlt.data = duration;
durBoxPlt.groups = {bins, IDs};
durBoxPlt.ylab = 'Event Duration (minutes)';
durBoxPlt.xlab = 'Runoff Ratio';
durBoxPlt.title = 'Event Duration vs Runoff Ratio for Forest and Pasture';
% plotBox(durBoxPlt, boxLabels, binColors);


plotResponseTime = false;
if plotResponseTime
    for j = 1:length(sites)
        % Plot Runoff Ratio vs Response Time
        depths = {'10 cm', '30 cm', '50 cm', '100 cm'};
        for idx = 1:length(depths)
            RTPlt.y = data.(sites{j}).RR;
            RTPlt.x = minutes(data.(sites{j}).RT(idx, :));
            RTPlt.site = sites{j};
            RTPlt.title = ['Response Time vs RR at: ' depths{idx}];
            RTPlt.ylab = 'Runoff Ratio';
            RTPlt.xlab = 'Response Time (minutes)';
            % Find the longest response time in either MAT or PAS, and give each graph the same y limits.
            RTPlt.xlim = [0, minutes(max(max(max(data.(sites{1}).RT)), max(max(data.(sites{2}).RT))))];
            plotScatter(RTPlt);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box Plots with different X Variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot Average Intensity Vs RR.
details.xlab = 'Mean Rainfall Intensity (mm hr^{-1})';
details.ylab = 'Runoff Ratio';
details.title = 'Average Precip Intensity vs RR';
details.filename = 'All_AvgI';
details.printEvtBins = true;
details.expBarData = true;
% 3 mm threshold cutoff, 5 quantiles:
% edges = [ 0    4.0861    9.0401   13.7391   23.5329   25]; % Arnulfo Multi Year
% edges = [ 0    5.1359   11.6378   19.8397   25]; % Arnulfo Multi Year
edges = [0    3.9744    7.3152   11.3707   25]; % Guabo Camp Multi Year
% edges = linspace(0, 37, 6);
handleAvgI = plotErrorBars('AvgI', 'RR', data, details, edges);

% Plot Peak Intensity Vs RR.
details.xlab = 'Peak Rainfall Intensity (mm hr^{-1})';
details.ylab = 'Runoff Ratio';
details.title = 'Max Rainfall Intensity vs RR';
details.filename = 'All_PeakI';
details.printEvtBins = true;
details.expBarData = true;
% 3mm, 5 quant
% edges = [0   21.3360   42.6720   76.2000  120.3960  250]; % Arnulfo Multi Year
% edges = [0   27.4320   54.8640  109.7280  250]; % Arnulfo Multi Year
edges = [ 0   21.3360   30.4800   41.9100  250]; % Guabo Camp Multi Year
% edges = linspace(0, 125, 6);
handlePI = plotErrorBars('PI', 'RR', data, details, edges);

% Plot Duration Vs RR.
details.xlab = 'Duration (minutes)';
details.ylab = 'Runoff Ratio';
details.title = 'Duration vs RR';
details.filename = 'All_Dur';
details.printEvtBins = true;
details.expBarData = true;
% 3mm, 5 quantiles
% edges = [ 0    55   100   165   270   410]; % Arnulfo Multi Year
% edges = [ 0    70   130   240   410]; % Arnulfo Multi Year
edges = [0   60   110   180   410]; % Guabo Camp Multi Year
% edges = linspace(0, 680, 6);
handleDur = plotErrorBars('durationMins', 'RR', data, details, edges);

allEBOnePlot = true;
if allEBOnePlot == true

end

% Plot Precip Total vs RR.
details.xlab = 'Rainfall Total (mm)';
details.ylab = 'Runoff Ratio';
details.title = 'Precip Total vs RR';
details.filename = 'All_PreTot';
details.printEvtBins = true;
details.expBarData = true;
% 3mm, 5 quant
% edges =[3    5.0800    8.5090   14.3510   27.0510   91.6940]; % Arnulfo Multi Year
edges = [0    4.0640    6.0960   10.0965   84]; % Guabo Camp Multi Year
% edges = linspace(0, 60, 6);
plotErrorBars('PreTot', 'RR', data, details, edges);







%% Export data for use elsewhere.
% Create summary statistics and save to .csvs
measurements = {'RR', 'durationMins', 'PI', 'AvgI','PreTot'};
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
    details.fileName = ['AllGood_' sites{whichSite} '.csv'];
    ExpSummStats(allMeas, details);
end % For each site.







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting Functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handle = plotScatter(pltData)
textSize = 18;
axisFontSize = textSize;
titleSize = 20;
handle = figure;
colors = linspace(1,10, length(pltData.x));
scatter(pltData.x, pltData.y, 50, colors, 'filled');
set(gca,'FontSize',axisFontSize)
title([pltData.site ': ' pltData.title], 'FontSize', titleSize);
xlabel(pltData.xlab);
ylabel(pltData.ylab);
if isfield(pltData, 'xlim')
    xlim(pltData.xlim);
end
% DEBUGGING: Tell how many non-nan values there are.
% disp([pltData.title ': There are ' num2str(sum(~isnan(pltData.x))) ',' num2str(sum(~isnan(pltData.y))) ' samples.']);
end

function handle = plotBox(pltData, labels, colors)
    binGap = 25;
    MATPASGap = 1;

    lineSize = 3;
    textSize = 18;
    axisFontSize = textSize;
    % if pltData.includeBootMerge
    %     titleText = '"Good" and bootstrapped-merged data combined.';
    % else
    %     titleText = '"Good" data only, no bootstrapped-merged data.';
    % end

    handle = figure;
    bh = boxplot(pltData.data, pltData.groups, ...
        'FactorGap', [binGap, MATPASGap], 'Colors', colors,  'Labels', labels, 'Symbol', '+');
    % 'Colors', 'rb',  'Labels', labels,
    set(bh(:), 'linewidth', lineSize);
    set(gca,'FontSize',axisFontSize)
    ylabel(pltData.ylab, 'FontSize', textSize);
    xlabel(pltData.xlab, 'FontSize', textSize);
    title(pltData.title);
    % Turn on the legend (different colors for MAT and PAS).
    % DANGER DANGER DANGER This is hard coded, could create misleading plot legends if not updated.
    individualBoxes = findobj(gca, 'Tag', 'Box');
    legend([individualBoxes(end) individualBoxes(end-1)], {'Forest', 'Pasture'}, 'FontSize', textSize);
end
