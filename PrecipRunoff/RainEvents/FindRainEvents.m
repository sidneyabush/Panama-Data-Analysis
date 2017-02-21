function [startTimes, endTimes] = FindRainEvents(TimeStamp, Precip) 
% TODO: Change to take input parameters
%% DETERMINE RAIN EVENTS - MAT
    
% import rainfall data for MAT forest 
% [TimeStamp,Precip,RainfallRate] = importMATprecip('MAT_Precip_May22-July27_2016 - Sheet1.csv',2, 19120);

% Determine how many time stamps must be dry in a row to signal the end of
% a storm. 
minutesPerTimeStamp = 10; %Change this if we start using 10 minute data
minutesSeparatingRainEvents = 120; % Change here if we want eg. 2 hrs to separate rain events
numTimeStampsBtwnRainEvts = minutesSeparatingRainEvents/minutesPerTimeStamp;

dry = conv(Precip', ones(1,numTimeStampsBtwnRainEvts), 'valid') == 0;
% You can then detect rain->dry events with diff (dry changes from 0 to 1)

% Stitch the identifier matrix (dry) and the precip matrix together to easily visually check that dry is valid 
dry=[dry ones(1, numTimeStampsBtwnRainEvts - 1)];
combined=[Precip dry'];

endTimes = find(diff(dry) == 1) + 1;
% That will give you the index of the first dry hour after each storm.

startTimes = find(diff(dry) == -1) + numTimeStampsBtwnRainEvts; 

% Now you just treat your data as a series of events. Chuck the first and last index of rainfall in there.
evt = [startTimes', endTimes'];
