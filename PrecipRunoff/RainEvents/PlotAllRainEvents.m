% Creates rain events, plots each of them and saves their plots into
% a folder.

% !!!DANGER!!! Rerunning this script will overwrite existing figures in the
% folder!

% Check to make sure we're in the right directory - need to be able to save
% the rain events to a folder nearby. 

pathParts = strsplit(pwd, '/');
currentFolder = pathParts{end}; 
shouldBeInFolder = 'RainEvents';
if ~strcmpi(currentFolder, shouldBeInFolder)
    warning(['Change to the directory: ' shouldBeInFolder ' in order to run.']); 
    return;
end

close all;

Create_RainEvents


figureDirectory = '3LCutoff_05mm';

for i = 1:length(MAT_Events)
   MAT_Events(i).plotLineAndBar();
   %Save figure to folderName - only open with Matlab 2014b or newer. 
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['MAT_event_' num2str(i) '.fig']), 'compact');
   close all;
end

for i = 1:length(PAS_Events)
   PAS_Events(i).plotLineAndBar();
   %Save figure to folderName - only open with Matlab 2014b or newer. 
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['PAS_event_' num2str(i) '.fig']), 'compact');
   close all;
end

% Save our events to a .mat file so we can modify and save them later. 
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents');
save(matFile, 'MAT_Events', 'PAS_Events');

