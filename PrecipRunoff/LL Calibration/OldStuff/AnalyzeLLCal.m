function [slope, intercept ] = AnalyzeLLCal()
% Import the data collected by the level logger. 
[ScanNo,Date,LLTime,Raw,CalibratedMM] = importLLData('Cal_Forest_Mid_1_19L.CSV',7, 89);
% Import the precise volume data collected by hand.
ImportPreciseVolume;
% Convert the precise volume times to datetime objects
PreciseTimes = datetime(TimePrecise, 'InputFormat', 'HH:mm:ss');


% For each precise time, find the first ll data point that was collected
% after that precise time - this corresponds to the height measured 
% immediately after the volume was changed
for i = 1:length(PreciseTimes)  
    firstGreater(i) = find(LLTime > PreciseTimes(i),1);
%     LLGreaterThanPrecise = LLTime(LLTime > PreciseTimes(i));
%     indAfterAdd(i) = LLGreaterThanPrecise(1);
end
firstGreater = firstGreater';

% figure;
% plot(LLTime, CalibratedMM);

% figure;
selectedMeasurements = CalibratedMM(firstGreater);
% plot(selectedMeasurements, VolumePrecise);


% Find the line of best fit with calibratedMM vs VolumePrecise, ignoring
% the first three samples because they seem to be below the ability of the
% level logger to register
lineFit = polyfit(selectedMeasurements(4:end), VolumePrecise(4:end), 1);
mmSamples = selectedMeasurements(4):10:selectedMeasurements(end);
calculatedVolumes = polyval(lineFit, mmSamples);
figure;
plot(selectedMeasurements, VolumePrecise, 'o', mmSamples, calculatedVolumes);
slope = lineFit(1);
intercept = lineFit(2);





