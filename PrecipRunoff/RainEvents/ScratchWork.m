% matFolder = 'RainEventFigures/All_Runoff/';
% oldEvts = load([matFolder 'allEvents.mat']);
% for evtIdx = 1:length(oldEvts.MAT_Events)
%    % DEBUGGING: Make some noise if we found an event with edits.
%    oldEvts.MAT_Events(evtIdx).updateModified();
%     if any(oldEvts.MAT_Events(evtIdx).precipZeroed)
%         display(['MAT' num2str(evtIdx) 'contains the following zeroing: ' oldEvts.MAT_Events(evtIdx).precipZeroed]);
%     end
% end
%
% fns = {'avg1', 'avg2', 'avg3', 'avg4'};
% Create_RainEvents;
% for idx = 1:length(MAT_Events)
%     doPlot = false;
%     for field = 1:length(fns)
%         doPlot = doPlot || MAT_Events(idx).SM.(fns{field}).RT.dur < 0;
%     end
%     if doPlot
%         MAT_Events(idx).plotDualAlt(nan, 'mod', 'LL', true);
%     end
% end

D = normrnd(0, 1, 10, 4) + repmat([0 1 2 3]*0.5,10,1);
M = mean(D);
G = {'A' 'B' 'C' 'D'};
N = [12  5  8  10];
figure
boxplot(D,G, 'positions', [3.2 3.8 1.2 1.8 ])
for k1 = 1:size(D,2)
    text(k1-0.15,M(k1)*1.2, sprintf('N = %d', N(k1)), 'FontSize',8);
end

figure 
X = [1.2 1.8 3.2 3.8 5.2 5.8];
Y = rand(100, 6);
boxplot(Y, 'positions', fliplr(X) , 'labels', X)
