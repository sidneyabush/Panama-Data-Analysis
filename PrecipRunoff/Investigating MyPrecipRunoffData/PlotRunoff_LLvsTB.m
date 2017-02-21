% Plot runoff mm as determined by level logger vs runoff mm as determined by
% tipping bucket. This will help determine whether one or the other
% functioned more reliably. 
close all;
clear all;

%% Import the LL data. 
% This data has all negatives removed, and is in 10 minute increments. 
load('allLL.mat');

%% Clean and prepare the LL data. 
% Just do this for one site for now - could loop through all sites later. 

% Save into temporary variables to save repetitive typing...
llTimes = allLL.forMidLL.timeStamp;
llMeasuredMM = allLL.forMidLL.heightMM;

% Convert the height(mm) of water in the the LL bucket into a height(mm) of
% runoff collected over the area of the plot. 

% First step is to figure out the conversion between the measured height
% and the corresponding volume. 
% TODO: This calculates a conversion equation based on the forest upper ll,
% so change it to use the other ll's if desired. 
[slope, intercept] = AnalyzeLLCal;

% Convert level logger mm to volumes
llVolume = slope.*llMeasuredMM + intercept;

% Convert level logger volume(in L) to mm of precip that fell on the runoff plot
areaRunoff = 156850; % In MM
llRunoffMM = llVolume.*1000000/areaRunoff;

%% Import the TB data. 
% this is in five minute increments.
[TIMESTAMP,RECORD,Precip_Tot,TR525_Up_Tot,TR525_Mid_Tot,TR525_Low_Tot] = import_MAT_PAS_TippingBucket('PrecipRunoff_Mature_Combined.csv',1, 31877);

%% Clean and prepare the TB data. 
% convert to ten minute increments
[tentime, tenvalue]= convert_tb10(TIMESTAMP, TR525_Mid_Tot);

% Use conversion factor to adjust for runoff plot size
conversionfactor=0.11875;
tenvalue = tenvalue * conversionfactor;

%% Plot Both LL and TB. 
%  Plot the LL data. 
plot(llTimes, llRunoffMM);
hold on
% Plot the TB data. 
plot(tentime, tenvalue);
