% This converts precip data into rain event objects

%Load the mat file containing Precip and TB runoff
TBFile = 'TippingBucketCleaning/CleanedData/allTB.mat';
load(TBFile);

% Load the mat file containing LL runoff 
LLFile='LL Negative Cleaning/CleanedData/allLL.mat';
load(LLFile);

% Load the mat file containing Celestino TB Precip. 
celestinoFile = '../DataAndImport/Celestino/CleanedData/CelestinoClean.mat';
load(celestinoFile);

% Load the mat file containing Guabo Camp TB Precip. 
gcFile = '../DataAndImport/GuaboCamp/CleanedData/GCClean.mat';
load(gcFile);

%% Calculate Mature forest rain events. 
timeStampsTB= allTB.MAT_TimeStamp_10min;
precip = allTB.MAT_Precip_10min;
upRunoffTB=allTB.MAT_TBRunoff_Up_10min;
midRunoffTB=allTB.MAT_TBRunoff_Mid_10min;
lowRunoffTB=allTB.MAT_TBRunoff_Low_10min;

% Determine rain events for MAT
[startTimes, endTimes] = FindRainEvents(timeStampsTB, precip);

% Create an array of rain event objects
for i=1:length(startTimes)
%   clear thisEvent
  % Create a new event object. 
  thisEvent=C_RainEvent('MAT');
  
  numLeading = 3;
  numTrailing = 2;
  
  TBStartIndex = max(startTimes(i) - numLeading, 1);
  TBEndIndex = min(endTimes(i) + numTrailing, length(timeStampsTB));
  
  % Add the start and end times. 
  thisEvent.startTime=timeStampsTB(startTimes(i));
  thisEvent.endTime=timeStampsTB(endTimes(i));
  
   % Add the precip timestamps and values
  thisEvent.precipTimes=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.precipVals=precip(TBStartIndex:TBEndIndex);
  
  % Add the additional TB timestamps and values (celestino for MAT) 
  addlStartIndex= max(find(celestino.dates>thisEvent.startTime,1)-numLeading,1);
  addlEndIndex= min(find(celestino.dates>thisEvent.endTime,1)+numTrailing, length(celestino.dates));
  thisEvent.addlPrecipTB.times = celestino.dates(addlStartIndex:addlEndIndex);
  thisEvent.addlPrecipTB.vals = celestino.precip1(addlStartIndex:addlEndIndex);
  
  % Add the TB runoff values (which share the precip timestamps)
  thisEvent.upTBRunoff.vals=upRunoffTB(TBStartIndex:TBEndIndex);
  thisEvent.midTBRunoff.vals=midRunoffTB(TBStartIndex:TBEndIndex);
  thisEvent.lowTBRunoff.vals=lowRunoffTB(TBStartIndex:TBEndIndex);
  
  % Add the TB runoff times (same as the precip times)
  thisEvent.upTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.midTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.lowTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  
  % Add LL data, which is matched as closely as possible to the timestamps
  % of the TB runoff and precip. 
  %
  %
  % DANGER!! This only works for the Mature Forest right now, hard coded in
  % the variables below. 
  %
  %
  
  LLstartIndex= max(find(allLL.forLowLL.timeStamp>thisEvent.startTime,1)-numLeading,1);
  LLendIndex= min(find(allLL.forLowLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.forLowLL.timeStamp));
  thisEvent.lowLLRunoff.times = allLL.forLowLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.lowLLRunoff.vals = allLL.forLowLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.lowLLRunoff.preceedingLLHeight = allLL.forLowLL.correctedHeightMM(LLstartIndex);
  
  LLstartIndex= max(find(allLL.forMidLL.timeStamp>thisEvent.startTime,1)-numLeading, 1);
  LLendIndex= min(find(allLL.forMidLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.forMidLL.timeStamp));
  thisEvent.midLLRunoff.times = allLL.forMidLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.midLLRunoff.vals = allLL.forMidLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.midLLRunoff.preceedingLLHeight = allLL.forMidLL.correctedHeightMM(LLstartIndex);

  
  LLstartIndex= max(find(allLL.forUpLL.timeStamp>thisEvent.startTime,1)-numLeading, 1);
  LLendIndex= min(find(allLL.forUpLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.forUpLL.timeStamp));
  thisEvent.upLLRunoff.times = allLL.forUpLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.upLLRunoff.vals = allLL.forUpLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.upLLRunoff.preceedingLLHeight = allLL.forUpLL.correctedHeightMM(LLstartIndex);

  % Check to see if there are any valid LL runoffs for this event
  thisEvent.checkLLRunoffsValid();
  % Calculate all the runoff ratios
  thisEvent.calcAllStatistics();
  MAT_Events(i)=thisEvent;
end


%% Very ugly way to calculate rain events for Pasture - just copied from above. 
timeStampsTB= allTB.PAS_TimeStamp_10min;
precip = allTB.PAS_Precip_10min;
upRunoffTB=allTB.PAS_TBRunoff_Up_10min;
midRunoffTB=allTB.PAS_TBRunoff_Mid_10min;
lowRunoffTB=allTB.PAS_TBRunoff_Low_10min;

% Determine rain events for PAS
[startTimes, endTimes] = FindRainEvents(timeStampsTB, precip);

% Create an array of rain event objects
for i=1:length(startTimes)
  % Create a new event object.
  thisEvent=C_RainEvent('PAS');
  
  numLeading = 3;
  numTrailing = 2;
  
  % Add the start and end times. 
   TBStartIndex = max(startTimes(i) - numLeading, 1);
  TBEndIndex = min(endTimes(i) + numTrailing, length(timeStampsTB));
  
  thisEvent.startTime=timeStampsTB(startTimes(i));
  thisEvent.endTime=timeStampsTB(endTimes(i));
  
   % Add the precip timestamps and values
  thisEvent.precipTimes=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.precipVals=precip(TBStartIndex:TBEndIndex);
  
  % Add the additional TB timestamps and values (Guabo Camp for PAS) 
  addlStartIndex= max(find(gc.timeStamps>thisEvent.startTime,1)-numLeading,1);
  addlEndIndex= min(find(gc.timeStamps>thisEvent.endTime,1)+numTrailing, length(gc.timeStamps));
  thisEvent.addlPrecipTB.times = gc.timeStamps(addlStartIndex:addlEndIndex);
  thisEvent.addlPrecipTB.vals = gc.precipMM(addlStartIndex:addlEndIndex);
  
  % Add the TB runoff values (which share the precip timestamps)
  thisEvent.upTBRunoff.vals=upRunoffTB(TBStartIndex:TBEndIndex);
  thisEvent.midTBRunoff.vals=midRunoffTB(TBStartIndex:TBEndIndex);
  thisEvent.lowTBRunoff.vals=lowRunoffTB(TBStartIndex:TBEndIndex);
  
  % Add the TB runoff times (same as the precip times)
  thisEvent.upTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.midTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  thisEvent.lowTBRunoff.times=timeStampsTB(TBStartIndex:TBEndIndex);
  
  % Add LL data, which is matched as closely as possible to the timestamps
  % of the TB runoff and precip. 
  %
  %
  % DANGER!! This only works for the Pasture right now, hard coded in
  % the variables below. 
  %
  %
  
  LLstartIndex= max(find(allLL.pasLowLL.timeStamp>thisEvent.startTime,1)-numLeading,1);
  LLendIndex= min(find(allLL.pasLowLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.pasLowLL.timeStamp));
  thisEvent.lowLLRunoff.times = allLL.pasLowLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.lowLLRunoff.vals = allLL.pasLowLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.lowLLRunoff.preceedingLLHeight = allLL.pasLowLL.correctedHeightMM(LLstartIndex);
  
  LLstartIndex= max(find(allLL.pasMidLL.timeStamp>thisEvent.startTime,1)-numLeading, 1);
  LLendIndex= min(find(allLL.pasMidLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.pasMidLL.timeStamp));
  thisEvent.midLLRunoff.times = allLL.pasMidLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.midLLRunoff.vals = allLL.pasMidLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.midLLRunoff.preceedingLLHeight = allLL.pasMidLL.correctedHeightMM(LLstartIndex);

  
  LLstartIndex= max(find(allLL.pasUpLL.timeStamp>thisEvent.startTime,1)-numLeading, 1);
  LLendIndex= min(find(allLL.pasUpLL.timeStamp>thisEvent.endTime,1)+numTrailing, length(allLL.pasUpLL.timeStamp));
  thisEvent.upLLRunoff.times = allLL.pasUpLL.timeStamp(LLstartIndex:LLendIndex);
  thisEvent.upLLRunoff.vals = allLL.pasUpLL.heightMM(LLstartIndex:LLendIndex);
  thisEvent.upLLRunoff.preceedingLLHeight = allLL.pasUpLL.correctedHeightMM(LLstartIndex);

  % Check to see if there are any valid LL runoffs for this event
  thisEvent.checkLLRunoffsValid();
  % Calculate all the runoff ratios
  thisEvent.calcAllStatistics();
  PAS_Events(i)=thisEvent;
end

