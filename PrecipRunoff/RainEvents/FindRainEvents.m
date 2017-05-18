function [startTimes, endTimes] = FindRainEvents(TimeStamp, Precip)
% TODO: Change to take input parameters

% Determine how many time stamps must be dry in a row to signal the end of
% a storm.
% minutesPerTimeStamp = 10; %Change this if we start using 10 minute data
minutesPerTimeStamp = minutes(TimeStamp(2) - TimeStamp(1));
minutesSeparatingRainEvents = 120; % Change here if we want eg. 2 hrs to separate rain events
numTimeStampsBtwnRainEvts = minutesSeparatingRainEvents/minutesPerTimeStamp;
if ~(numTimeStampsBtwnRainEvts == floor(numTimeStampsBtwnRainEvts))
    warning('FindRainEvents: Mismatch between minutes per timestamp and minutes separating rain events.');
end

dry = conv(Precip', ones(1,numTimeStampsBtwnRainEvts), 'valid') == 0;
% You can then detect rain->dry events with diff (dry changes from 0 to 1)

% Stitch the identifier matrix (dry) and the precip matrix together to easily visually check that dry is valid
dry=[dry ones(1, numTimeStampsBtwnRainEvts - 1)];
combined=[Precip dry'];


endTimes = find(diff(dry) == 1) + 1;
% That will give you the index of the first dry hour after each storm.

% Special case: there's an event ending within the last 
% numTimeStamptsBtwnEvts samples.
precipAtEnd = nan;
precipAtEnd = find(Precip(end-numTimeStampsBtwnRainEvts:end));
if any(~isnan(precipAtEnd))
    endTimes(end) = (precipAtEnd(end) + length(Precip) - numTimeStampsBtwnRainEvts);
end

startTimes = [];
% Special case: the very first timestamp contains rain. 
if Precip(1) > 0
   startTimes(1) = 1;
end
startTimes = [startTimes find(diff(dry) == -1) + numTimeStampsBtwnRainEvts];

% Now you just treat your data as a series of events. Chuck the first and last index of rainfall in there.
evt = [startTimes', endTimes'];
