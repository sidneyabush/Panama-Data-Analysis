% matFolder = 'RainEventFigures/All_Runoff/';
% oldEvts = load([matFolder 'allEvents.mat']);
% for evtIdx = 1:length(oldEvts.MAT_Events)
%    % DEBUGGING: Make some noise if we found an event with edits.
%    oldEvts.MAT_Events(evtIdx).updateModified();
%     if any(oldEvts.MAT_Events(evtIdx).precipZeroed)
%         display(['MAT' num2str(evtIdx) 'contains the following zeroing: ' oldEvts.MAT_Events(evtIdx).precipZeroed]);
%     end
% end

fns = {'avg1', 'avg2', 'avg3', 'avg4'};
Create_RainEvents;
for idx = 1:length(MAT_Events)
    doPlot = false;
    for field = 1:length(fns)
        doPlot = doPlot || MAT_Events(idx).SM.(fns{field}).RT.dur < 0;
    end
    if doPlot
        MAT_Events(idx).plotDualAlt(nan, 'mod', 'LL', true);
    end
end
