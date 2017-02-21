%% Import June 9 Rain Event - PrecipRunoff
plot(selectedMeasurementMM, llVol, 'o', mmSamples, calculatedVolumes);
slope = lineFit(1);
intercept = lineFit(2);