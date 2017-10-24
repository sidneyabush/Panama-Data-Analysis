function [ ] = ExpSummStats(measurements, details)
% ExpSummStats: Takes in precip, runoff or soil characteristic data and
% exports summary statistics (quartiles, mean, etc.) to a csv.

% Make a table that will store the statistics for all measurements.
dataTable = table('RowNames', {'Min', 'First Quartile', 'Mean', 'Geo Mean', ...
                  'Median', 'Third Quartile', 'Max', 'Std Err. of Mean'});

% For each measurement:
for whichMeas = 1:length(measurements)
    thisMeas = measurements(whichMeas).vals;

    % Clean the measurement data.
    thisMeas(isnan(thisMeas)) = [];

    % Perform a variety of calculations.
    measQt = quantile(thisMeas, 4);
    measMin = min(thisMeas);
    measMax = max(thisMeas);
    measGMean = geomean(thisMeas);
    measMean = mean(thisMeas);
    measMedian = median(thisMeas);
    % Calculate the standard error of the mean (which tells us how
    % accurately our sample data represents the actual population it was
    % drawn from).
    measStdErrOfMean = std(thisMeas) / sqrt(length(thisMeas));

    % Combine for storage in table.
    allStats = [measMin; measQt(1); measMean; measGMean; measMedian; ...
                measQt(3); measMax; measStdErrOfMean];
    % Add to the table
    dataTable.(measurements(whichMeas).name) = allStats;
end


% Export table to CSV
fn = fullfile('Export', 'SummStats', details.fileName);
writetable(dataTable, fn, 'WriteRowNames', true);
