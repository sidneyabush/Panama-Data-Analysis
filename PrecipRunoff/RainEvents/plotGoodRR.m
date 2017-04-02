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

% Extract, using "(...)" the number and TB or LL.
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
