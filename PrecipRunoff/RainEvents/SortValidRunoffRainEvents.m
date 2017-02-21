% Creates rain events, plots each of them and saves their plots into
% different folders depending on whether or not they have a valid LL runoff
% event. 

% !!!DANGER!!! Rerunning this script will overwrite existing figures in the
% folders!

% Check to make sure we're in the right directory - need to be able to save
% the rain events to folders nearby. 

pathParts = strsplit(pwd, '/');
currentFolder = pathParts{end}; 
shouldBeInFolder = 'RainEvents';
if ~strcmpi(currentFolder, shouldBeInFolder)
    warning(['Change to the directory: ' shouldBeInFolder ' in order to run.']); 
    return;
end

close all;

Create_RainEvents

for i = 1:length(MAT_Events)
   if MAT_Events(i).atLeastOneLLRunoffValid
       folderName = 'MAT_LL_valid';
   else
       folderName = 'MAT_LL_invalid';
   end
   MAT_Events(i).plotEvent();
   %Save figure to folderName - only open with Matlab 2014b or newer. 
   savefig(figure(1), fullfile('RainEventFigures', folderName, ['event_' num2str(i) '.fig']), 'compact');
   close all;
end

for i = 1:length(PAS_Events)
   if PAS_Events(i).atLeastOneLLRunoffValid
       folderName = 'PAS_LL_valid';
   else
       folderName = 'PAS_LL_invalid';
   end
   PAS_Events(i).plotEvent();
   %Save figure to folderName - only open with Matlab 2014b or newer. 
   savefig(figure(1), fullfile('RainEventFigures', folderName, ['event_' num2str(i) '.fig']), 'compact');
   close all;
end