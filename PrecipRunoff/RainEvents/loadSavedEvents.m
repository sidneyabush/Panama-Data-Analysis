% This script loads a .mat file containing MAT and PAS rain events. 
figureDirectory = '3LCutoff_05mm';
matFile = fullfile('RainEventFigures', figureDirectory, 'allEvents.mat');
load(matFile);
