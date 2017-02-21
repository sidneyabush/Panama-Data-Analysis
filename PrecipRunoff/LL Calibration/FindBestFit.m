function [ logCoefs, linearCoefs, selectedMeasurementMM ] = FindBestFit( truthDir, measuredDir, cutoffBeginning, cutoffInLiters, plot2 )
%FINDBESTFIT Finds the two equations converting mm to L.

% Import the truth file
[truthTime,truthVol] = importLLTruthData(truthDir,2);
% Import the measured file
[measuredTime, Raw, measuredMM] = importLLMeasuredData(measuredDir, 7);

% Clear out variables so they are not mistakenly carried over from
% previous loop.
firstGreater = 0;
selectedMeasurementMM = 0;
selectedMeasurementTime = 0;

% For each truth timestamp, find the first ll data point that was collected
% after that truth time - this corresponds to the height measured
% immediately after the volume was changed.
for j = 1:length(truthTime)
    firstGreater(j) = find(measuredTime > truthTime(j),1);
end
firstGreater = firstGreater';

% Pull out the height measurements.
selectedMeasurementMM = measuredMM(firstGreater);
selectedMeasurementTime = measuredTime(firstGreater);
% Uncomment to re enable these plots.
%     % Plot the selected measurements to allow visual inspection.
%     figure;
%     hold on;
%     plot(measuredTime, measuredMM);
%     plot(selectedMeasurementTime, selectedMeasurementMM,'o');
%     hold off;

% Find lines of best fit between selectedMeasurementMM and truthVol.
% The larger volumes follow a linear relationship. The smaller ones
% follow a logarithmic one.
cutoff = 1;
cutoffInLiters = 5;
linearOrLogCutoff = cutoffInLiters * 2; % Two data points per liter.
logFunc = @(B,x) B(1).*log(x + B(2)) + B(3);
logCoefs = nlinfit(selectedMeasurementMM(cutoff:linearOrLogCutoff), ...
    truthVol(cutoff:linearOrLogCutoff), logFunc, [0.1, 0, 0]);

%
% !!!DANGER!!!
%
% The log coefficients turn out to be complex numbers. I'm discarding
% the imaginary parts, because they cause issues with plotting later
% on. And, plotting just the real parts seems to have a very good fit.
% But I'm not 100% sure if this is mathematically valid to do...
logCoefs = real(logCoefs);
linearCoefs = polyfit(selectedMeasurementMM(linearOrLogCutoff:end), ...
    truthVol(linearOrLogCutoff:end), 1);

if(plot2)
    logSamples = selectedMeasurementMM(cutoffBeginning):0.1:selectedMeasurementMM(linearOrLogCutoff);
    calculatedLogVolumes = logFunc(logCoefs, logSamples);
    
    linearSamples = selectedMeasurementMM(linearOrLogCutoff):10:selectedMeasurementMM(end);
    calculatedLinearVolumes = polyval(linearCoefs, linearSamples);
    
    figure;
    plot(selectedMeasurementMM, truthVol, 'o', linearSamples, calculatedLinearVolumes);
    hold on;
    plot(logSamples, calculatedLogVolumes);
    hold off;
end

end

