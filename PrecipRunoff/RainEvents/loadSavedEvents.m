% This script loads a .mat file containing MAT and PAS rain events.

%
% WARNING!!!!!AUSTIN CHANGED THIS
figureDirectory = 'All_Runoff';
%

% figureDirectory = 'AustinTest';

matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents.mat');
load(matFile);
