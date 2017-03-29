% Processes events (updating zero index) and then save. 
% 
% !! DANGER !! This will overwrite the existing file. 
%
for i = 1:length(MAT_Events)
   MAT_Events(i).updateModified();
end
for j = 1:length(PAS_Events)
   PAS_Events(i).updateModified(); 
end

figureDirectory = 'AusTest';
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents');
save(matFile, 'MAT_Events', 'PAS_Events');
