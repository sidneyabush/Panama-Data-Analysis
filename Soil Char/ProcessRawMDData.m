% This script imports the Mini Disk data and performs stats analysis and graphing tasks.

[Date,Site,Location,Point,Type,Kmmhr,Smmhr05] = importMDFile('MiniDisk_K_S_PAS_MAT_combined_CImethod.csv',2, 149);

% There are some spaces in the Type variable, remove them.
Type = strtrim(Type);

% Create a table out of the variables so we can stack them.
T = table(Date, Site, Location, Point, Type, Kmmhr, Smmhr05);
S = stack(T, {'Kmmhr', 'Smmhr05'}, 'NewDataVariableName', 'Val', 'IndexVariableName', 'Measurement');

% Measurement comes out as a Categorical, convert to cell str.
S.Measurement = cellstr(S.Measurement);

% Standardize to three characters for text fields.
% for row = 1:height(S)
%     S.Location{row} = S.Location{row}(1:3);
%     S.Type{row} = S.Type{row}(1:3);
% end

% Convert parts of table to arrays for use with boxplot.
% S.Site = cell2mat(S.Site);
% S.Location = cell2mat(S.Location);
% S.Point = cell2mat(S.Point);
% S.Type = cell2mat(S.Type);


% Perform statistical tests comparing MAT and PAS.

allMeasurements = {'Kmmhr', 'Smmhr05'};
for whichMeas = 1:length(allMeasurements)
    % Valid measurements are all Spatial ones plus Depth A.
    MATRows = strcmp(S.Site, 'MAT') & strcmp(S.Measurement, allMeasurements{whichMeas}) & (strcmp(S.Type, 'spatial') | strcmp(S.Point, 'A'));
    % test = [strcmp(S.Site, 'MAT')  strcmp(S.Measurement, allMeasurements{whichMeas}) strcmp(S.Type, 'spatial') strcmp(S.Point, 'A')];
    PASRows = strcmp(S.Site, 'PAS') & strcmp(S.Measurement, allMeasurements{whichMeas}) & (strcmp(S.Type, 'spatial') | strcmp(S.Point, 'A'));
    MATVals = S.Val(MATRows);
    PASVals = S.Val(PASRows);

    disp('Mini Disk Statistical Tests ----------------------------------------');
    disp([allMeasurements{whichMeas} ' : MAT - Min = ' num2str(min(MATVals)) ' Max = ' num2str(max(MATVals)) ' Mean = ' num2str(nanmean(MATVals))]);
    disp([allMeasurements{whichMeas} ' : PAS - Min = ' num2str(min(PASVals)) ' Max = ' num2str(max(PASVals)) ' Mean = ' num2str(nanmean(PASVals))]);

    % Do a two sample TTest.
    [h,p] = ttest2(MATVals, PASVals);
    display([allMeasurements{whichMeas} ' : TTest - The probability that MAT and PAS have distributions with the same mean:' num2str(p)]);
    % Do a two-sample KS test
    [h,p] = kstest2(MATVals, PASVals);
    disp([allMeasurements{whichMeas} ' : KSTest2 - The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);
    % Do a Kruskal Wallis test
    [p, tbl, stats] = kruskalwallis([MATVals;PASVals], [zeros(length(MATVals), 1); ones(length(PASVals), 1)], 'off');
    disp([allMeasurements{whichMeas} ' : KruskalWallis - The probability that MAT and PAS have the same distribution: ' num2str(p)]);
    % Do a Mann-Whitney test
    [p,h] = ranksum(MATVals, PASVals);
    disp([allMeasurements{whichMeas} ' : Mann-Whitney - The probability that MAT and PAS have distributions with the same median:' num2str(p)]);


end
