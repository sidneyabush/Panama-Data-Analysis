% Purpose: Import Soil Moisture data from CSV and store it into a MAT file for use by other programs.
% Data directories, relative to current working directory.
rawDataDir = 'RawData/';
cleanedDataDir = 'CleanedData/';

rawFiles = dir([rawDataDir '*.csv']);

if length(rawFiles) ~= 2
    error(['Expected 2 csv Soil Moisture files, but found ' num2str(length(RawFiles))]);
end
SMData = struct();
for i = 1:length(rawFiles)
    fileName = rawFiles(i).name;
    % Separate out just the filename, we'll use that below
    [~,siteName,~] = fileparts(fileName);
    % siteName looks like 'MAT_SM', strip the _SM part.
    siteName = siteName(1:end-3);
    % Import the file.
    [TIME,T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4] = importSMFile([rawDataDir fileName], 5);
    % Check to make sure we don't have any timestamp interpretation issues.
    if any(isnat(TIME))
        warning(['Some timestamps in ' siteName ' were not interpreted properly!']);
    end

    % Average T1, M1, B1. Average T2, M2, B2, etc.
    avg1 = mean([T1 M1 B1], 2, 'omitnan');
    avg2 = mean([T2 M2 B2], 2, 'omitnan');
    avg3 = mean([T3 M3 B3], 2, 'omitnan');
    avg4 = mean([T4 M4 B4], 2, 'omitnan');

    % Store all fields in the struct.
    SMData.(siteName) = struct('TIME',TIME,'T1',T1,'T2',T2,'T3',T3,'T4',T4,...
                               'M1',M1,'M2',M2,'M3',M3,'M4',M4,'B1',B1,...
                               'B2',B2,'B3',B3,'B4',B4,'avg1', avg1,...
                               'avg2', avg2,'avg3', avg3,'avg4', avg4);
end

% Save the struct
saveDir = [cleanedDataDir 'SMData'];
save(saveDir, 'SMData')
