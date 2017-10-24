function [ linearCoefs1, linearCoefs2, rsq1, rsq2, selectedMeasurementMM, truthVol ] = FindBestFit( truthDir, measuredDir, cutoffBeginning, cutoffInLiters, plot2 )
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
% Two different lines roughly approximate the entire dataset.
linearSplit = cutoffInLiters * 2; % Two data points per liter.

linearCoefs1 = polyfit(selectedMeasurementMM(cutoffBeginning:linearSplit), ...
    truthVol(cutoffBeginning:linearSplit), 1);
% Compute the R Squared measure of error for this linear regression.
yfit1 = polyval(linearCoefs1, selectedMeasurementMM(cutoffBeginning:linearSplit));
yresid1 = truthVol(cutoffBeginning:linearSplit) - yfit1;
SSresid1 = sum(yresid1.^2);
SStotal1 = (length(truthVol(cutoffBeginning:linearSplit))-1) * var(truthVol(cutoffBeginning:linearSplit));
rsq1 = 1 - SSresid1/SStotal1;

linearCoefs2 = polyfit(selectedMeasurementMM(linearSplit:end), ...
    truthVol(linearSplit:end), 1);
% Compute the R Squared measure of error for this linear regression.
yfit2 = polyval(linearCoefs2, selectedMeasurementMM(linearSplit:end));
yresid2 = truthVol(linearSplit:end) - yfit2;
SSresid2 = sum(yresid2.^2);
SStotal2 = (length(truthVol(linearSplit:end))-1) * var(truthVol(linearSplit:end));
rsq2 = 1 - SSresid2/SStotal2;

if(plot2)
    linearSamples1 = selectedMeasurementMM(cutoffBeginning):0.1:selectedMeasurementMM(linearSplit);
    calculatedLinearVolumes1 = polyval(linearCoefs1, linearSamples1);
    linearSamples2 = selectedMeasurementMM(linearSplit):10:selectedMeasurementMM(end);
    calculatedLinearVolumes2 = polyval(linearCoefs2, linearSamples2);

    figure;
    hold on;
    title(measuredDir);
    plot(selectedMeasurementMM, truthVol, 'o');
    plot(linearSamples1, calculatedLinearVolumes1);
    plot(linearSamples2, calculatedLinearVolumes2);
    hold off;
end

end
