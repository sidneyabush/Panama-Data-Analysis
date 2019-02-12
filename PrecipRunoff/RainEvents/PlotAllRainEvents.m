% Creates rain events, plots each of them and saves their plots into
% a folder.

% !!!DANGER!!! Rerunning this script will overwrite existing figures in the
% folder!

% Check to make sure we're in the right directory - need to be able to save
% the rain events to a folder nearby.

pathParts = strsplit(pwd, filesep);
currentFolder = pathParts{end};
shouldBeInFolder = 'RainEvents';
if ~strcmpi(currentFolder, shouldBeInFolder)
    warning(['Change to the directory: ' shouldBeInFolder ' in order to run.']);
    return;
end

close all;

Create_RainEvents

% for j = 1:length(MAT_Events)
%   if ~isfield(MAT_Events(j).stats, 'orig')
%     disp(['MAT Event ' num2str(j) ' has an issue.'])
%   end
% end

figureDirectory = 'All_Runoff';
originalOrModified = 'orig';
% TBOrLL = 'TB';

for i = 1:length(MAT_Events)
    % if ~isfield(MAT_Events(i).stats, 'orig')
    %   disp(['Event ' string(i) ' has an issue.']);
    % end
   if any(isnan(MAT_Events(i).site))
     disp(['Found an issue with: ' num2str(i)]);
     continue
   end
   MAT_Events(i).plotLineAndBar(originalOrModified, 'TB');
   %Save figure to folderName - only open with Matlab 2014b or newer.
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['MAT_event_' num2str(i) '_TB.fig']), 'compact');
   close all;
   MAT_Events(i).plotLineAndBar(originalOrModified, 'LL');
   %Save figure to folderName - only open with Matlab 2014b or newer.
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['MAT_event_' num2str(i) '_LL.fig']), 'compact');
   close all;
end

for i = 1:length(PAS_Events)
    if any(isnan(PAS_Events(i).site))
      disp(['Found an issue with: ' num2str(i)]);
      continue
    end
   PAS_Events(i).plotLineAndBar(originalOrModified, 'TB');
   %Save figure to folderName - only open with Matlab 2014b or newer.
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['PAS_event_' num2str(i) '_TB.fig']), 'compact');
   close all;
   PAS_Events(i).plotLineAndBar(originalOrModified, 'LL');
   %Save figure to folderName - only open with Matlab 2014b or newer.
   savefig(figure(1), fullfile('RainEventFigures', figureDirectory, ['PAS_event_' num2str(i) '_LL.fig']), 'compact');
   close all;
end

% Save our events to a .mat file so we can modify and save them later.
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents');
save(matFile, 'MAT_Events', 'PAS_Events');
