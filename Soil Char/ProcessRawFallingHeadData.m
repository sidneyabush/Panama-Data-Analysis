% Purpose: import and graph the Falling Head data.
[Date,Site,Location,Point,kfs] = importFHFile('Falling_Head_MAT_PAS_Combined.csv',2, 93);

% [Date,Site,Location,Point,Type,SWC,GWC,BD,VWC] = importSCFile('MAT_PAS_SWC_GWC_DryBulkDensity_VWC_Combined.csv',2, 149);

% Create a table out of the variable so we can stack it
T = table(Date, Site, Location, Point, kfs);

% Universal values for text sizes.
yLabTxtSize = 14;
lgdTxtSize = 14;
yTickTxtSize = 14;
lineSize = 3;

% TODO: Change this nasty hard coding of colors.
colors = 'rb';
boxLabels = {'Forest', 'Pasture'};
figure
bh = boxplot(T.kfs, {T.Site}, 'Symbol', '+', 'FactorGap', 25, 'Colors', colors, 'Labels', boxLabels);
set(bh(:), 'linewidth', lineSize);

% Turn on the legend (different colors for MAT and PAS).
% boxes = findobj(gca, 'Tag', 'Box');
% legend(boxes(end-1:end), {'Pasture', 'Forest'}, 'FontSize', yLabTxtSize, 'location', 'northwest');
% Modify the axis tick labels.
g = gca;
g.FontSize = yTickTxtSize;
% g.XTickLabelRotation = 20;
ylabel('Kfs (mm/hr)', 'Fontsize', 18);


% Statistical tests comparing MAT and PAS falling head.
MATVals = T.kfs(strcmp(T.Site, 'MAT'));
PASVals = T.kfs(strcmp(T.Site, 'PAS'));
disp('Falling Head Statistical Tests ----------------------------------------');
disp(['Kfs : MAT - Min = ' num2str(min(MATVals)) ' Max = ' num2str(max(MATVals)) ' Mean = ' num2str(nanmean(MATVals))]);
disp(['Kfs : PAS - Min = ' num2str(min(PASVals)) ' Max = ' num2str(max(PASVals)) ' Mean = ' num2str(nanmean(PASVals))]);
% Do a two sample TTest.
[h,p] = ttest2(MATVals, PASVals);
display(['Kfs : TTest - The probability that MAT and PAS have distributions with the same mean:' num2str(p)]);
% Do a two-sample KS test
[h,p] = kstest2(MATVals, PASVals);
disp(['Kfs : KSTest2 - The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);
% Do a Kruskal Wallis test
[p, tbl, stats] = kruskalwallis([MATVals;PASVals], [zeros(length(MATVals), 1); ones(length(PASVals), 1)], 'off');
disp(['Kfs : KruskalWallis - The probability that MAT and PAS have the same distribution: ' num2str(p)]);
% Do a Mann-Whitney test
[p,h] = ranksum(MATVals, PASVals);
disp(['Kfs : Mann-Whitney - The probability that MAT and PAS have distributions with the same median:' num2str(p)]);


%% Calculate summary statistics and store in csv files.
sites = {'MAT', 'PAS'};
% For each site:
for whichSite = 1:length(sites)
    thisMeas.vals = T.kfs(strcmp(T.Site, sites{whichSite}));
    thisMeas.name = 'KS';
    details.fileName = ['FallingHead_' sites{whichSite} '.csv'];
    ExpSummStats(thisMeas, details);
end % For each site.
