% This script loads a .mat file containing MAT and PAS rain events.

%
% WARNING!!!!! Make sure this is the directory you want to be loading from.
% 
figureDirectory = 'All_Runoff';
%

% figureDirectory = 'AustinTest';

matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents.mat');
load(matFile);
