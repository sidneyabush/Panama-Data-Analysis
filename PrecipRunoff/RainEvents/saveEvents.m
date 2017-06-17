% Processes events (updating zero index) and then save.
%
% !! DANGER !! This will overwrite the existing file.
%
for i = 1:length(MAT_Events)
    MAT_Events(i).updateModified();
    MAT_Events(i).calcAllStatistics();
end
for j = 1:length(PAS_Events)
    PAS_Events(j).updateModified();
    PAS_Events(j).calcAllStatistics();
end

% !! DANGER !! This will overwrite the existing file.
% Make sure you are sure which figure Directory you want to save to. 
figureDirectory = 'All_Runoff';
% figureDirectory = 'AustinTest';
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents');
save(matFile, 'MAT_Events', 'PAS_Events');
