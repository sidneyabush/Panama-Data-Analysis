% This script loads a .mat file containing MAT and PAS rain events. 
figureDirectory = 'All_Runoff';
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents.mat');
load(matFile);
