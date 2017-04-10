% Generates several plots (e.g. RR v. Intensity) from the "good" folder.

%% Determine which events to plot

matFolder = 'RainEventFigures/All_Runoff/';
eventFolder = 'Good';

% Load the .mat file containing our event data
load([matFolder 'allEvents.mat']);

% Get all the figures in the desired folder.
matFigs = dir([matFolder eventFolder '/MAT*.fig']);
pasFigs = dir([matFolder eventFolder '/PAS*.fig']);
allFigs = {matFigs, pasFigs};
allEvents = {MAT_Events, PAS_Events};
siteNames = {'MAT', 'PAS'};

% Create a structure to store the RR data, Intensity data, etc.
data = struct();
data.(siteNames{1}) = struct();
data.(siteNames{2}) = struct();

% Extract, using parentheses in the regex, the event number and TB or LL.
pattern = 'event_(\d+)_([L-T][B-L]).fig';
for j = 1:length(allFigs)
    tokens = regexp({allFigs{j}.name}, pattern, 'tokens');

    % Store the event number and type (TB or LL).
    data.(siteNames{j}).RR = [];
    data.(siteNames{j}).celestinoRR = [];
    data.(siteNames{j}).startTimes = [];
    data.(siteNames{j}).endTimes = [];
    data.(siteNames{j}).PI = [];
    data.(siteNames{j}).AvgI = [];
    data.(siteNames{j}).celestinoAvgI = [];
    data.(siteNames{j}).celestinoPI = [];
    cells = [tokens{:}];
    for i = 1:length(cells)
        evtIdx = str2double(cells{i}{1});
        data.(siteNames{j}).RR = [data.(siteNames{j}).RR allEvents{j}(evtIdx).stats.mod.RR.(cells{i}{2}).precip];
        % Notify if we just found something with a RR > 1.
        if data.(siteNames{j}).RR(end) >= 1
          warning(['RR >= 1 for: ' siteNames{j} ' ' num2str(evtIdx)]);
        end
        data.(siteNames{j}).startTimes = [data.(siteNames{j}).startTimes allEvents{j}(evtIdx).startTime];
        data.(siteNames{j}).endTimes = [data.(siteNames{j}).endTimes allEvents{j}(evtIdx).endTime];
        data.(siteNames{j}).PI = [data.(siteNames{j}).PI allEvents{j}(evtIdx).stats.mod.int.peak.precip];
        data.(siteNames{j}).AvgI = [data.(siteNames{j}).AvgI allEvents{j}(evtIdx).stats.mod.int.avg.precip];

        if strcmpi(siteNames{j}, 'MAT')
            data.(siteNames{j}).celestinoRR = [data.(siteNames{j}).celestinoRR allEvents{j}(evtIdx).stats.mod.RR.(cells{i}{2}).addl];
            if data.(siteNames{j}).celestinoRR(end) >= 1
              warning(['celestinoRR >= 1 for: ' siteNames{j} ' ' num2str(evtIdx)]);
            end
            data.(siteNames{j}).celestinoPI = [data.(siteNames{j}).celestinoPI allEvents{j}(evtIdx).stats.mod.int.peak.celestino];
            data.(siteNames{j}).celestinoAvgI = [data.(siteNames{j}).celestinoAvgI allEvents{j}(evtIdx).stats.mod.int.avg.celestino];
        end
    end

    % Calculate duration
    data.(siteNames{j}).duration = data.(siteNames{j}).endTimes - data.(siteNames{j}).startTimes;
    % Change intensities to mm/hr (from mm/10min)
    data.(siteNames{j}).PI = data.(siteNames{j}).PI * 6;
    data.(siteNames{j}).AvgI = data.(siteNames{j}).AvgI * 6;
    data.(siteNames{j}).celestinoAvgI = data.(siteNames{j}).celestinoAvgI * 6;
    data.(siteNames{j}).celestinoPI = data.(siteNames{j}).celestinoPI * 6;

    %% Plot events
    plotScatters = false;
    if plotScatters
        % Plot Runoff Ratio vs Duration
        figure
        plot(data.(siteNames{j}).RR, data.(siteNames{j}).duration, 'o');
        title([siteNames{j} ' RR vs Duration for Good Events']);
        xlabel('Runoff Ratio');
        ylabel('Duration');

        % Plot Runoff Ratio vs Peak Intensity
        figure
        plot(data.(siteNames{j}).RR, data.(siteNames{j}).PI, 'o');
        title([siteNames{j} ' RR vs Peak Intensity for Good Events']);
        xlabel('Runoff Ratio');
        ylabel('Peak Intensity (mm/hr)');

        % Plot Runoff Ratio vs Average Intensity
        figure
        plot(data.(siteNames{j}).RR, data.(siteNames{j}).AvgI, 'o');
        title([siteNames{j} ' RR vs Average Intensity for Good Events']);
        xlabel('Runoff Ratio');
        ylabel('Average Intensity (mm/hr)');

        % Plot extra figures using Celestino data for MAT
        if strcmpi(siteNames{j}, 'MAT')

            % Plot Runoff Ratio vs Peak Intensity
            figure
            plot(data.(siteNames{j}).celestinoRR, data.(siteNames{j}).celestinoPI, 'o');
            title([siteNames{j} ' Celestino RR vs Celestino Peak Intensity for Good Events']);
            xlabel('Runoff Ratio');
            ylabel('Peak Intensity (mm/hr)');

            % Plot Runoff Ratio vs Average Intensity
            figure
            plot(data.(siteNames{j}).celestinoRR, data.(siteNames{j}).celestinoAvgI, 'o');
            title([siteNames{j} ' Celestino RR vs Celestino Average Intensity for Good Events']);
            xlabel('Runoff Ratio');
            ylabel('Average Intensity (mm/hr)');
        end
    end
end

% Do a quick print out of the mean RRs for MAT and PAS.
matRR = mean(data.MAT.RR);
pasRR = mean(data.PAS.RR);
display(['Mean RR for good events in MAT is: ' num2str(matRR)]);
display(['Mean RR for good events in PAS is: ' num2str(pasRR)]);
display(['PAS RR is: ' num2str((pasRR - matRR) / matRR * 100) '% higher than MAT.'])

% Now that we've extracted data for both MAT and PAS, generate plots with both.
% First, sort the RR data into bins for the box plots.
% Need all bin edges to be uniform between MAT and PAS, so use the one with the
% widest range to set the bin edges for the other.
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

% Plot peak intensity boxes.
figure
bh = boxplot(peakIntensity, {bins, IDs}, 'Colors', 'rb',  'Labels', boxLabels,...
        'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% bh(:,2).linewidth = 6;
% title('RR vs Peak Intensity for Good Events');
ylabel('Peak Intensity (mm/hr)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);


% Plot intensity boxes.
figure
bh = boxplot(intensity, {bins, IDs}, 'Colors', 'rb',  'Labels', boxLabels,...
        'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% title('RR vs Mean Intensity for Good Events');
ylabel('Mean Intensity (mm/hr)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);


% Plot duration boxes.
figure
bh = boxplot(duration, {bins, IDs}, 'Colors', 'rb',  'Labels', boxLabels,...
        'FactorGap', [binGap, MATPASGap], 'Symbol', '+');
set(bh(:), 'linewidth', lineSize);
set(gca,'FontSize',axisFontSize)
% title('RR vs Duration for Good Events');
ylabel('Event Duration (minutes)', 'FontSize', textSize);
xlabel('Runoff Ratio', 'FontSize', textSize);
% Turn on the legend (different colors for MAT and PAS).
legend(findobj(gca, 'Tag', 'Box'), {'PAS', 'MAT'}, 'FontSize', textSize);
