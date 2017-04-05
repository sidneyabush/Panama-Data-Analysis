% Purpose: import and graph the Falling Head data.
[Date,Site,Location,Point,kfs] = importFHFile('Falling_Head_MAT_PAS_Combined.csv',2, 93);

% [Date,Site,Location,Point,Type,SWC,GWC,BD,VWC] = importSCFile('MAT_PAS_SWC_GWC_DryBulkDensity_VWC_Combined.csv',2, 149);

% Create a table out of the variable so we can stack it
T = table(Date, Site, Location, Point, kfs);
% S = stack(T, {'SWC', 'GWC', 'BD', 'VWC'}, 'NewDataVariableName', 'Val', 'IndexVariableName', 'Measurement');

% Convert parts of table to arrays for use with boxplot.
% S.Site = cell2mat(S.Site);
% S.Location = cell2mat(S.Location);
% S.Point = cell2mat(S.Point);


% Universal values for text sizes.
yLabTxtSize = 14;
lgdTxtSize = 14;
yTickTxtSize = 14;
lineSize = 3;

% We're looking at the depth measurements of bulk density.
% rows = (S.Type == 'dep' & S.Measurement == 'BD');
% points = S.Point(rows(:,3));
% sites = S.Site(rows(:,3));
% % dates = S.Date(rows(:,3));
% vals =  S.Val(rows(:,3));

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
ylabel('Kfs (mm/hr)', 'Fontsize', 14);
