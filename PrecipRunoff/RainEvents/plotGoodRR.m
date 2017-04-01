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

% Extract, using "(...)" the number and TB or LL.
pattern = 'event_(\d+)_([L-T][B-L]).fig';
for j = 1:length(allFigs)
    tokens = regexp({allFigs{j}.name}, pattern, 'tokens');
    
    % Store the event number and type (TB or LL).
    matIdx = [];
    matType = {};
    RR = [];
    celestinoRR = [];
    startTimes = [];
    endTimes = [];
    PI = [];
    AvgI = [];
    celestinoAvgI = [];
    celestinoPI = [];
    cells = [tokens{:}];
    for i = 1:length(cells)
        RR = [RR allEvents{j}(str2double(cells{i}{1})).stats.mod.RR.(cells{i}{2}).precip];
        startTimes = [startTimes allEvents{j}(str2double(cells{i}{1})).startTime];
        endTimes = [endTimes allEvents{j}(str2double(cells{i}{1})).endTime];
        PI = [PI allEvents{j}(str2double(cells{i}{1})).stats.mod.int.peak.precip];
        AvgI = [AvgI allEvents{j}(str2double(cells{i}{1})).stats.mod.int.avg.precip];
        
        if strcmpi(siteNames{j}, 'MAT')
            celestinoRR = [celestinoRR allEvents{j}(str2double(cells{i}{1})).stats.mod.RR.(cells{i}{2}).addl];
            celestinoPI = [celestinoPI allEvents{j}(str2double(cells{i}{1})).stats.mod.int.peak.celestino];
            celestinoAvgI = [celestinoAvgI allEvents{j}(str2double(cells{i}{1})).stats.mod.int.avg.celestino];
        end
    end
    
    % Calculate duration
    duration = endTimes - startTimes;
    % Change intensities to mm/hr (from mm/10min)
    PI = PI * 6;
    AvgI = AvgI * 6;
    celestinoAvgI = celestinoAvgI * 6;
    celestinoPI = celestinoPI * 6;
    
    %% Plot events
    
    % Plot Runoff Ratio vs Duration
    figure
    plot(RR, duration, 'o');
    title([siteNames{j} ' RR vs Duration for Good Events']);
    xlabel('Runoff Ratio');
    ylabel('Duration');
    
    % Plot Runoff Ratio vs Peak Intensity
    figure
    plot(RR, PI, 'o');
    title([siteNames{j} ' RR vs Peak Intensity for Good Events']);
    xlabel('Runoff Ratio');
    ylabel('Peak Intensity (mm/hr)');
    
    % Plot Runoff Ratio vs Average Intensity
    figure
    plot(RR, AvgI, 'o');
    title([siteNames{j} ' RR vs Average Intensity for Good Events']);
    xlabel('Runoff Ratio');
    ylabel('Average Intensity (mm/hr)');
    
    % Plot extra figures using Celestino data for MAT
    if strcmpi(siteNames{j}, 'MAT')
        
        % Plot Runoff Ratio vs Peak Intensity
        figure
        plot(celestinoRR, celestinoPI, 'o');
        title([siteNames{j} ' Celestino RR vs Celestino Peak Intensity for Good Events']);
        xlabel('Runoff Ratio');
        ylabel('Peak Intensity (mm/hr)');
        
        % Plot Runoff Ratio vs Average Intensity
        figure
        plot(celestinoRR, celestinoAvgI, 'o');
        title([siteNames{j} ' Celestino RR vs Celestino Average Intensity for Good Events']);
        xlabel('Runoff Ratio');
        ylabel('Average Intensity (mm/hr)');
    end
end