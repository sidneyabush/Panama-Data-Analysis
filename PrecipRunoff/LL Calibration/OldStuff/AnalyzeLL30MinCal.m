function [slope, intercept ] = AnalyzeLL30MinCal()
close all;
clear all;
% Import the data collected by the level logger. 
[llScan,llDate,llTime,llRaw,llMM,VarName6,llDateTime] = importLL30MinData('LL30MinCal.CSV',10, 229);
% Import the precise volume data collected by hand.
[llVolTime,llVol] = importLL30MinVolume('LL30MinVolume.csv',2, 40);
% Convert the precise volume times to datetime objects
% llVolTime = datetime(TimePrecise, 'InputFormat', 'HH:mm:ss');


% For each precise time, find the first ll data point that was collected
% after that precise time - this corresponds to the height measured 
% immediately after the volume was changed
for i = 1:length(llVolTime)  
    firstGreater(i) = find(llTime > llVolTime(i),1);
%     LLGreaterThanPrecise = LLTime(LLTime > PreciseTimes(i));
%     indAfterAdd(i) = LLGreaterThanPrecise(1);
end
firstGreater = firstGreater';

figure;
plot(llTime, llMM);
hold on;
selectedMeasurementMM = llMM(firstGreater);
selectedMeasurementTime = llTime(firstGreater);
plot(selectedMeasurementTime, selectedMeasurementMM,'o');

hold off;
% figure;
% plot(selectedMeasurementMM, llVol);


% Find the line of best fit with calibratedMM vs VolumePrecise, ignoring
% the first 8 samples because they seem to be below the ability of the
% level logger to register
lineFit = polyfit(selectedMeasurementMM(8:end), llVol(8:end), 1);
mmSamples = selectedMeasurementMM(8):10:selectedMeasurementMM(end);
calculatedVolumes = polyval(lineFit, mmSamples);
figure;
plot(selectedMeasurementMM, llVol, 'o', mmSamples, calculatedVolumes);
slope = lineFit(1);
intercept = lineFit(2);

% Add in the line that shows the theoretical volume of the bucket as a
% function of the height reported by the level logger
radiusUpper = 14.367;
hTotal = 309.240;
hLowerCone = 273.363;
volLowerCone = 46173.06;
theoMMSamples = 0:10:selectedMeasurementMM(end);
theoCMSamples = theoMMSamples/10; %The theoretical equation expects input heights in cm, not mm
theoVolume = pi * (radiusUpper/hTotal)^2 * 1/3 * (theoCMSamples + hLowerCone).^3 - volLowerCone;
theoVolume = theoVolume/1000;  %Theoretical volume calculated in mL, convert to L
hold on;
plot(theoMMSamples, theoVolume);
hold off;
legend('Experimental Measurements', 'Line of Best Fit (ignore first 8 points)','Theoretical Volume', 'Location', 'northwest');






