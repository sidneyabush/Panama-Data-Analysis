% This script imports the tipping bucket data (both precip and runoff
% varieties) and converts them from 5 to 10 minute samples before saving to
% a .mat file for convenient later usage. 

%% Process MAT Precip/Runoff Data
% [TimeStamp,Precip,RainfallRate] = importMATprecip('MAT_Precip_May22-July27_2016 - Sheet1.csv',2, 19120);

% Import ALL MAT tipping bucket data (precip & runoff)
[MAT_TimeStamp,~,MAT_Precip_5min,MAT_TBRunoff_Up_5min,MAT_TBRunoff_Mid_5min,MAT_TBRunoff_Low_5min] = ...
import_MAT_PAS_TippingBucket('PrecipRunoff_Mature_Combined.csv',5, 31877);

% If there are an odd number of points, we won't be able to add the last 5
% minute point to any other point to get 10 minutes of data. So cut off the
% last point in this case. 
isodd= mod(length(MAT_TimeStamp),2);
if isodd
    MAT_TimeStamp(end)=[];
end

% tenminuterate_MAT=[];
allTB.MAT_TimeStamp_10min=[];
allTB.MAT_Precip_10min=[];
allTB.MAT_TBRunoff_Up_10min=[];
allTB.MAT_TBRunoff_Mid_10min=[];
allTB.MAT_TBRunoff_Low_10min=[];

for i= 1:2:length(MAT_TimeStamp)
%   Just take the first of the two timestamps for our 10 min stamp.
    allTB.MAT_TimeStamp_10min = [allTB.MAT_TimeStamp_10min; MAT_TimeStamp(i)];
%   Add two sequential 5 min Precip values together to get a 10 min value.
    allTB.MAT_Precip_10min = [allTB.MAT_Precip_10min; MAT_Precip_5min(i) + MAT_Precip_5min(i+1)];
%   Do the same for the runoff TBs
    allTB.MAT_TBRunoff_Up_10min = [allTB.MAT_TBRunoff_Up_10min; MAT_TBRunoff_Up_5min(i) + MAT_TBRunoff_Up_5min(i+1)];
    allTB.MAT_TBRunoff_Mid_10min = [allTB.MAT_TBRunoff_Mid_10min; MAT_TBRunoff_Mid_5min(i) + MAT_TBRunoff_Mid_5min(i+1)];
    allTB.MAT_TBRunoff_Low_10min = [allTB.MAT_TBRunoff_Low_10min; MAT_TBRunoff_Low_5min(i) + MAT_TBRunoff_Low_5min(i+1)];

%   Divide rainfall rate by 2 after adding, because we're now doing the
%   rate over 10 instead of 5 minutes
%   tenminuterate_MAT = [tenminuterate_MAT; (RainfallRate(i) + RainfallRate(i+1))/2];
end

% Timestamp for precip is an hour later than it should be, so subtract an
% hour from it. 
% tenminutetime_MAT = tenminutetime_MAT - hours(1);

%% Process PAS Precip/Runoff Data

% [TimeStampPAS,PrecipPAS,RainfallRatePAS] = importPASPrecip2('PAS_Precip_May22-July27_2016 - Sheet1.csv',2, 19153);
[PAS_TimeStamp_5min,~,PAS_Precip_5min,PAS_TBRunoff_Up_5min,PAS_TBRunoff_Mid_5min,PAS_TBRunoff_Low_5min] = ...
import_PAS_TippingBucket('PrecipRunoff_Pasture_Combined.csv',5, 36884);

% If there are an odd number of points, we won't be able to add the last 5
% minute point to any other point to get 10 minutes of data. So cut off the
% last point in this case. 
isodd= mod(length(PAS_TimeStamp_5min),2);
if isodd
    PAS_TimeStamp_5min(end)=[];
end

allTB.PAS_TimeStamp_10min=[];
allTB.PAS_Precip_10min=[];
allTB.PAS_TBRunoff_Up_10min=[];
allTB.PAS_TBRunoff_Mid_10min=[];
allTB.PAS_TBRunoff_Low_10min=[];

for i= 1:2:length(PAS_TimeStamp_5min)
%   Just take the first of the two timestamps for our 10 min stamp.
    allTB.PAS_TimeStamp_10min = [allTB.PAS_TimeStamp_10min; PAS_TimeStamp_5min(i)];
%   Add two sequential 5 min Precip values together to get a 10 min value.
    allTB.PAS_Precip_10min = [allTB.PAS_Precip_10min; PAS_Precip_5min(i) + PAS_Precip_5min(i+1)];
%   Do the same for the runoff TBs
    allTB.PAS_TBRunoff_Up_10min = [allTB.PAS_TBRunoff_Up_10min; PAS_TBRunoff_Up_5min(i) + PAS_TBRunoff_Up_5min(i+1)];
    allTB.PAS_TBRunoff_Mid_10min = [allTB.PAS_TBRunoff_Mid_10min; PAS_TBRunoff_Mid_5min(i) + PAS_TBRunoff_Mid_5min(i+1)];
    allTB.PAS_TBRunoff_Low_10min = [allTB.PAS_TBRunoff_Low_10min; PAS_TBRunoff_Low_5min(i) + PAS_TBRunoff_Low_5min(i+1)];
end



% for i= 1:2:length(PAS_TimeStamp_5min)
% %   Divide rainfall rate by 2 after adding, because we're now doing the
% %   rate over 10 instead of 5 minutes
%     tenminuterate_PAS = [tenminuterate_PAS; (RainfallRatePAS(i) + RainfallRatePAS(i+1))/2];
%     tenminutetotal_PAS = [tenminutetotal_PAS; PrecipPAS(i) + PrecipPAS(i+1)];
%     tenminutetime_PAS = [tenminutetime_PAS; PAS_TimeStamp_5min(i)];
% end


% Timestamp for precip is an hour later than it should be, so subtract an
% hour from it. 
% tenminutetime_PAS = tenminutetime_PAS - hours(1);

%% Scale measurements for plot area. 
% The tipping bucket reports in mm recorded over the area of its opening.
% But we're not collecting over the area of its opening, we're collecting
% over the area of the plot. So scale the measurements here. 
% Set up our assumptions/dimensions (in mm). 
areaPlot = 156850;
diamRunoffTB = 163;  
diamPrecipTB = 254;
areaRunoffTB = pi * (diamRunoffTB/2)^2; 
areaPrecipTB = pi * (diamPrecipTB/2)^2; 
depthRunoffTB = 0.2;
depthPrecipTB = 0.1;
% Our formula is : depthAcrossPlot = depthPrecipTB * areaPrecipTB / areaPlot; 
precipTBCorrection = areaPrecipTB / areaPlot; 
runoffTBCorrection = areaRunoffTB / areaPlot; 

% This was a mistake - the precip TB doesn't need to be corrected for plot
% size!
% allTB.MAT_Precip_10min = allTB.MAT_Precip_10min * precipTBCorrection; 
% allTB.PAS_Precip_10min = allTB.PAS_Precip_10min * precipTBCorrection;

allTB.MAT_TBRunoff_Low_10min = allTB.MAT_TBRunoff_Low_10min * runoffTBCorrection; 
allTB.MAT_TBRunoff_Mid_10min = allTB.MAT_TBRunoff_Mid_10min * runoffTBCorrection; 
allTB.MAT_TBRunoff_Up_10min = allTB.MAT_TBRunoff_Up_10min * runoffTBCorrection; 

allTB.PAS_TBRunoff_Low_10min = allTB.PAS_TBRunoff_Low_10min * runoffTBCorrection; 
allTB.PAS_TBRunoff_Mid_10min = allTB.PAS_TBRunoff_Mid_10min * runoffTBCorrection; 
allTB.PAS_TBRunoff_Up_10min = allTB.PAS_TBRunoff_Up_10min * runoffTBCorrection; 


%% Save MAT and PAS data into a .mat file for later use
saveDir = [pwd '/CleanedData/allTB'];
save(saveDir, 'allTB');