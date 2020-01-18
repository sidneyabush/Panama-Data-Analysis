function calcMeanAndVariability(data, site, fields)
% calcMeanAndVariability calculates the mean and variability of
% low/mid/upper RR or infiltration

    disp([site ': temporal mean and variability:']);
    % TODO: Could vectorize this.
    for field = fields
        thisRRData = data.(site).(field{1});
        thisMean = mean(thisRRData);
        thisStdErrofMean = std(thisRRData) / sqrt(length(thisRRData));
        disp([field{1} ': mean = ' num2str(thisMean) '. std err of the mean = ' num2str(thisStdErrofMean)]);
    end
end
