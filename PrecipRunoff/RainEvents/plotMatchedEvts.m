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


%
% TODO: Sort the data? Actually don't need to, cause I'm not doing scatter plots. 
%




% For each figure, extract the site, event number and LL/TB and store into an array.
for fileNum = 1:length(eventFiles)
    fnTokens = regexp({eventFiles(fileNum).name}, pattern, 'tokens');
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

% Select from all events just the events that were in our "good" folder.
matEvtIdx = all(evts.site == 'MAT', 2);
pasEvtIdx = all(evts.site == 'PAS', 2);
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
    withinOne = (pasTimes - st < hours(hrsBtwnEvts)) & (pasTimes - st > hours(-1 * hrsBtwnEvts));
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




%% Do TTest , PI, AvgI, RR.
data.MAT.RR = [matEvts(matchedMATEvts).avgRR];
