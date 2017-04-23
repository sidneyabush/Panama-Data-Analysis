% Finds the start time for an increase in soil moisture.
function [timeIdx] = FindResponseTime(SM, startTime, threshPct)
% Inputs:   a vector (or multiple vertical vectors concatenated into a matrix)
%           of soil moisture data, a precip start time, and a threshold for
%           the percent increase that qualifies a response.
% Outputs:  A scalar or vector containing the indexes of the response(s) to
%           precip.

% Probably take the derivative (discrete, so diff) of this and filter out negative values.
% Either a vertical vector, or a matrix where we consider each column to be a distinct series.
[rows, cols] = size(SM);
diffs = zeros(1, cols);
diffs = [diffs; diff(SM)];


% Find the first place where the increase meets a condition.
% Right now that condition is: where there are two nonzero increases in a row.
timeIdx = zeros(1, cols);
% TODO: Vectorize this ugly for loop.
for c = 1:cols
    for r = 1:rows-1
        % Find the first occurrence of two increases in soil moisture.
        if ((diffs(r,c) > 0) && (diffs(r+1, c) > 0))
            % Store which row in SM it was where the increase began.
            timeIdx(1,c) = r-1;
            break
        end
    end
end

end
