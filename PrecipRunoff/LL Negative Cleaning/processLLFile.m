% File Purpose: Take in a level logger .csv file with multiple columns. Convert the
% multiple date formats into one DateTime vector, and extract the heightMM
% vector

function [timeStamp, heightMM] = processLLFile(fileToProcess)
% Import the csv file, start reading on second row to headers
rawData = readtable(fileToProcess);
% Extract the date and time variables into cell arrays so we can process
% them 
date = rawData{:,3};
time = rawData{:,4};
% Stich each date and time together into one string - date and time get
% messed up part way through the excel file 
combined = strcat(datestr(date), '-', time);
% Turn each string into a datetime object
timeStamp = datetime(combined,'InputFormat', 'dd-MMM-yyyy-HH:mm:ss');

% Extract the height in mm
heightMM = rawData{:,5};

end