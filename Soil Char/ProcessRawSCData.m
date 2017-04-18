% Purpose: import and graph the Soil Characteristic data.

[Date,Site,Location,Point,Type,SWC,GWC,BD,VWC] = importSCFile('MAT_PAS_SWC_GWC_DryBulkDensity_VWC_Combined.csv',2, 149);

% Create a table out of the variable so we can stack it
T = table(Date, Site, Location, Point, Type, SWC, GWC, BD, VWC);
S = stack(T, {'SWC', 'GWC', 'BD', 'VWC'}, 'NewDataVariableName', 'Val', 'IndexVariableName', 'Measurement');

% Convert table columns that contain text from cell array to char for easier indexing.
for row = 1:height(S)
    S.Location{row} = S.Location{row}(1:3);
end

for row = 1:height(S)
    S.Type{row} = S.Type{row}(1:3);
end

% Convert parts of table to arrays for use with boxplot.
S.Site = cell2mat(S.Site);
S.Location = cell2mat(S.Location);
S.Type = cell2mat(S.Type);
S.Point = cell2mat(S.Point);


% Universal values for text sizes.
yLabTxtSize = 14;
lgdTxtSize = 14;
yTickTxtSize = 14;
lineSize = 3;




plotMATSpatial = false;
if plotMATSpatial
    % Choose which site and which type of measurement we're looking at. Also exclude SWC.
    rows = (S.Site == 'MAT' & S.Type == 'spa' & S.Measurement ~= 'SWC');
    dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));
    msr = S.Measurement(rows(:,3));

    % Set the group labels equal to the dates.
    boxLabels = {};
    unqDates = (unique(dates));
    for groupNum = 1:3:(length(unqDates)*3-1)
        boxLabels{groupNum} = datestr(unqDates(ceil(groupNum/3)));
        boxLabels{groupNum + 1} = '';
        boxLabels{groupNum + 2} = '';
    end

    cmap = colormap(lines);
    colors = cmap(1:3,:);
    figure
    bh = boxplot(vals, {dates, msr},  ...
        'FactorGap', [25, 1], 'Symbol', '+', 'Colors', colors, 'Labels', boxLabels);
    set(bh(:), 'linewidth', lineSize);
    % Turn on the legend (different colors for MAT and PAS).
    legend(findobj(gca, 'Tag', 'Box'), {'VWC', 'BD', 'GWC'}, 'FontSize', 14, 'location', 'northwest');
end








plotBDSpatial = false;
if plotBDSpatial
    % Choose which type and which measurement we're looking at.
    rows = (S.Type == 'spa' & S.Measurement == 'BD');
    sites = S.Site(rows(:,3));
    dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rbbrrrbr';
    figure
    bh = boxplot(vals, {dates}, 'Symbol', '+', 'Colors', colors);
    set(bh(:), 'linewidth', lineSize);
    % Turn on the legend (different colors for MAT and PAS).
    legend(findobj(gca, 'Tag', 'Box'), {'MAT', 'PAS'}, 'FontSize', 14, 'location', 'northwest');
    % Rotate the x axis tick labels.
    g = gca;
    g.XTickLabelRotation = 20;
    ylabel('Spatial Bulk Density (g/cm^3)', 'Fontsize', 14);
end;






plotBDDepth = false;
if plotBDDepth
    % Choose which type and which measurement we're looking at.
    rows = (S.Type == 'dep' & S.Measurement == 'BD');
    sites = S.Site(rows(:,3));
    dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rbbrbb';
    % colors = 'rb';/
    figure
    bh = boxplot(vals, {dates}, 'Symbol', '+', 'Colors', colors);
    set(bh(:), 'linewidth', lineSize);
    % Turn on the legend (different colors for MAT and PAS).
    boxes = findobj(gca, 'Tag', 'Box');
    legend(boxes(end-1:end), {'PAS', 'MAT'}, 'FontSize', 14, 'location', 'northwest');
    % Rotate the x axis tick labels.
    g = gca;
    g.XTickLabelRotation = 20;
    ylabel('Depth Bulk Density (g/cm^3)', 'Fontsize', 14);
end

plotBDVsType = false;
if plotBDVsType
    % We're looking at the depth measurements of bulk density.
    rows = (S.Type == 'dep' & S.Measurement == 'BD');
    points = S.Point(rows(:,3));
    sites = S.Site(rows(:,3));
    % dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rb';
    figure
    bh = boxplot(vals, {points, sites}, 'Symbol', '+', 'FactorGap', [25, 1], 'Colors', colors);
    set(bh(:), 'linewidth', lineSize);

    % Turn on the legend (different colors for MAT and PAS).
    boxes = findobj(gca, 'Tag', 'Box');
    legend(boxes(end-1:end), {'Pasture', 'Forest'}, 'FontSize', yLabTxtSize, 'location', 'northwest');
    % Modify the axis tick labels.
    g = gca;
    g.FontSize = yTickTxtSize;
    % g.XTickLabelRotation = 20;
    ylabel('Depth Bulk Density (g/cm^3)', 'Fontsize', 14);
end







plotMultCompSpatial = true;
if plotMultCompSpatial
    % We're looking at spatial measurements grouped by Up, Mid, Low, and pooled across time.
    sites = {'MAT', 'PAS'};
    for site = 1:length(sites)
        % First plot MAT and PAS separately.
        rows = (S.Type == 'spa' & S.Measurement == 'BD' & S.Site == sites{site});
        % Pick out the group markers - Upper, Middle, Lower.
        locs = S.Location(rows(:,3), :);
        measurements = S.Val(rows(:,3));
        details.title = ['Spatial multi-compare for: ' sites{site}];
        [h, stats] = plotmultcomp(measurements, locs, details);
    end

    % Now put Up, mid, low for MAT and PAS on the same plot.
    % We're looking at spatial measurements grouped by Up, Mid, Low, and pooled across time.
    rows = (S.Type == 'spa' & S.Measurement == 'BD');
    % Pick out the group markers - Upper, Middle, Lower and combine with MAT or PAS.
    groups = [S.Site(rows(:,3),:) S.Location(rows(:,3),:)];
    measurements = S.Val(rows(:,3));
    details.title = 'Spatial multi-compare for MAT and PAS';
    [h, stats] = plotmultcomp(measurements, groups, details);

    % Now compare all of MAT against all of PAS
    rows = (S.Type == 'spa' & S.Measurement == 'BD');
    groups = S.Site(rows(:,3),:);
    measurements = S.Val(rows(:,3));
    details.title = 'Spatial multi-compare for MAT and PAS, entire hillslopes.'
    [h, stats] = plotmultcomp(measurements, groups, details);
end




function [handle, stats] = plotmultcomp(meas, groups, details)
      handle = figure;
      [stats.p, stats.t, stats.stats] = anova1(meas, groups, 'off');
      [stats.c, stats.m, stats.h, stats.nms] = multcompare(stats.stats);
      title(details.title);
end
