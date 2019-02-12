%PlotAllEventsDualAlt - Plots all rain events (that passed the minimum precip cutoff) using C_RainEvent.plotDualAlt and store them into a folder. Later, give the option for plotting using the original soil moisture SM data or the new (December 2018) calibrated SM data.

% Instructions for use: Run ProcessNewRawSMData. Change Create_RainEvents to point to the SMDataNew.mat rather than the original SMData.mat file. In this script, change figureDirectory to point wherever you want eg. "DualAltFigsNewSM" assuming we're running with new SM data like we just setup for above. Run this script.

% Check that we're in the right directory
pathParts = strsplit(pwd, filesep);
currentDir = pathParts{end};
shouldBeInDir = 'RainEvents';
CheckCurrentDir(currentDir, shouldBeInDir);

% Tidy up our matlab workspace
close all;

% Create the rain events
Create_RainEvents

% Plot and save the MAT events
plotAndSave(MAT_Events, 'MAT_Events_');
% Plot and save the PAS events
plotAndSave(PAS_Events, 'PAS_Events_');







function [] = plotAndSave(evtArray, evtArrayName)
  % For each MAT event
  for evtIdx = 1:length(evtArray)
    % Check that we're looking at a valid event (not NANed due to a lack of precip)
    if any(isnan(evtArray(evtIdx).site))
      % disp(['Found an issue with: ' num2str(evtIdx)]);
      continue
    end

    % Plot the event
    try
      evtArray(evtIdx).plotDualAlt(nan, 'mod', 'LL', true);
    catch ME
      disp(['There was an error plotting ' evtArrayName ' ' num2str(evtIdx)]);
      close all;
      continue
    end

    % Folder (within current directory) to save figs in.
    % figureDirectory = 'DualAltFigs';
    figureDirectory = 'DualAltFigsNewSM';
    %Save figure to folderName - only open with Matlab 2014b or newer.
    outputPath = fullfile('RainEventFigures', figureDirectory, [evtArrayName num2str(evtIdx) '_LL.fig']);
    savefig(figure(1), outputPath, 'compact');
    close all;
  end
end
