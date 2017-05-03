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

% Convert VWC from 0.5 -> 50%
S.Val(S.Measurement == 'VWC') = S.Val(S.Measurement == 'VWC') * 100;


% Universal values for text sizes.
yLabTxtSize = 14;
lgdTxtSize = 14;
yTickTxtSize = 14;
lineSize = 3;
titleFontSize = 20;
axisFontSize = 18;




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








plotBDSpatialDate = false;
if plotBDSpatialDate
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
    ylabel('Spatial Bulk Density (g/cm^3)', 'Fontsize', axisFontSize);
end






plotBDSpatial = false;
if plotBDSpatial
    % Choose which type and which measurement we're looking at.
    rows = (S.Type == 'spa' & S.Measurement == 'BD');
    sites = S.Site(rows(:,3));
    vals =  S.Val(rows(:,3));

    colors = 'rb';
    labels = {'Forest', 'Pasture'};
    figure
    bh = boxplot(vals, {sites}, 'Symbol', '+', 'Colors', colors, 'Labels', labels);
    set(bh(:), 'linewidth', lineSize);
    set(gca,'FontSize',axisFontSize)
    ylabel('Spatial Bulk Density (g/cm^3)', 'Fontsize', axisFontSize);
    title('Spatial Bulk Density for Forest and Pasture', 'Fontsize', titleFontSize);
end






plotVWCSpatial = false;
if plotVWCSpatial
    % Choose which type and which measurement we're looking at.
    rows = (S.Type == 'spa' & S.Measurement == 'VWC');
    sites = S.Site(rows(:,3));
    vals =  S.Val(rows(:,3));

    colors = 'rb';
    labels = {'Forest', 'Pasture'};
    figure
    bh = boxplot(vals, {sites}, 'Symbol', '+', 'Colors', colors, 'Labels', labels);
    set(bh(:), 'linewidth', lineSize);
    set(gca,'FontSize',axisFontSize)
    ylabel('Volumetric Water Content (%)', 'Fontsize', axisFontSize);
    title('Volumetric Water Content for Forest and Pasture', 'Fontsize', titleFontSize);
end






plotBDDepthDate = false;
if plotBDDepthDate
    % Choose which type and which measurement we're looking at.
    rows = (S.Type == 'dep' & S.Measurement == 'BD');
    sites = S.Site(rows(:,3));
    dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rbbrbb';
    % colors = 'rb';
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












plotBDDepthVsType = false;
if plotBDDepthVsType
    % We're looking at the depth measurements of bulk density.
    rows = (S.Type == 'dep' & S.Measurement == 'BD');
    points = S.Point(rows(:,3));
    sites = S.Site(rows(:,3));
    % dates = S.Date(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rb';
    figure
    plotPretty = true;
    if plotPretty == true
        labels = {'-50', '', '-30', '', '-10', '', '0', ''};
        order = { 'D,M', 'D,P', 'C,M', 'C,P', 'B,M', 'B,P', 'A,M', 'A,P'};
        bh = boxplot(vals, {points, sites}, 'Symbol', '+', ...
                    'FactorGap', [25, 1], 'Colors', colors, ...
                    'Orientation', 'horizontal', 'GroupOrder', order, ...
                    'Labels', labels);
    else
        bh = boxplot(vals, {points, sites}, 'Symbol', '+', 'FactorGap', [25, 1], 'Colors', colors, 'Orientation', 'horizontal');
    end
    set(bh(:), 'linewidth', lineSize);

    % Turn on the legend (different colors for MAT and PAS).
    boxes = findobj(gca, 'Tag', 'Box');
    legend(boxes(end-1:end), {'Pasture', 'Forest'}, 'FontSize', yLabTxtSize, 'location', 'northeast');
    % Modify the axis tick labels.
    g = gca;
    g.FontSize = yTickTxtSize;
    ylabel('Depth (cm)', 'Fontsize', 18);
    xlabel('Bulk Density (g/cm^3)', 'Fontsize', 18);
    title('Bulk Density vs Depth','FontSize', 20);
end







plotVWCvsDepthType = false;
if plotVWCvsDepthType
    % We're looking at the depth measurements of bulk density.
    rows = (S.Type == 'dep' & S.Measurement == 'VWC');
    points = S.Point(rows(:,3));
    sites = S.Site(rows(:,3));
    vals =  S.Val(rows(:,3));

    % TODO: Change this nasty hard coding of colors.
    colors = 'rb';
    figure
    plotPretty = true;
    if plotPretty == true
        labels = {'-50', '', '-30', '', '-10', '', '0', ''};
        order = { 'D,M', 'D,P', 'C,M', 'C,P', 'B,M', 'B,P', 'A,M', 'A,P'};
        bh = boxplot(vals, {points, sites}, 'Symbol', '+', ...
                    'FactorGap', [25, 1], 'Colors', colors, ...
                    'Orientation', 'horizontal', 'GroupOrder', order, ...
                    'Labels', labels);
    else
        bh = boxplot(vals, {points, sites}, 'Symbol', '+', 'FactorGap', [25, 1], 'Colors', colors, 'Orientation', 'horizontal');
    end
    set(bh(:), 'linewidth', lineSize);

    % Turn on the legend (different colors for MAT and PAS).
    boxes = findobj(gca, 'Tag', 'Box');
    legend(boxes(end-1:end), {'Pasture', 'Forest'}, 'FontSize', yLabTxtSize, 'location', 'northeast');
    % Modify the axis tick labels.
    g = gca;
    g.FontSize = yTickTxtSize;
    ylabel('Depth (cm)', 'Fontsize', 18);
    xlabel('Volumetric Water Content (%)', 'Fontsize', 18);
    title('Volumetric Water Content vs Depth','FontSize', 20);
end







plotVWCVsDepthTime = false;
if plotVWCVsDepthTime == true
    rows = (strcmp(T.Type, 'depth'));
    points = T.Point(rows);
    sites = T.Site(rows);
    VWC = T.VWC(rows);
    dates = T.Date(rows);
    subT = table(points, sites, VWC, dates);

    % Combine to group by date.
    U = unstack(subT, 'VWC', 'dates');

    % Combine to get trace names.
    lineNames =strcat(U.points, U.sites);

    dates = U.Properties.VariableNames(3:end);
    dates = extractAfter(dates, 'x');
    dates = datetime(dates, 'InputFormat', 'MM_dd_00yy');
    VWCArr = table2array(U(:,3:end));
    figure
    % TODO: Figure out why the MAT data isn't plotting.
    plot(dates, VWCArr, 'Color', 'r');

    legend(lineNames);

    figure;
    plot(dates(1), VWCArr(1:4,1));


end







plotMultCompSpatial = false;
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
    details.title = 'Spatial multi-compare for MAT and PAS, entire hillslopes.';
    [h, stats] = plotmultcomp(measurements, groups, details);
end







plotMultCompBDDepth = false;
if plotMultCompBDDepth
    % We're looking at depth values pooled across time and grouped by depth and site.
    rows = (S.Type == 'dep' & S.Measurement == 'BD');
    % Pick out the group markers - Upper, Middle, Lower and combine with MAT or PAS.
    groups = [S.Site(rows(:,3),:) S.Point(rows(:,3),:)];
    measurements = S.Val(rows(:,3));
    details.title = 'Depth multi-compare of BD for MAT and PAS';
    [h, stats] = plotmultcomp(measurements, groups, details);

    sites = {'MAT', 'PAS'};
    for idx = 1:length(sites)
        % We're looking at depth values pooled across time and grouped by depth and location (up, mid, low).
        rows = (S.Type == 'dep' & S.Measurement == 'BD' & S.Site == sites{idx});
        % Pick out the group markers - Upper, Middle, Lower and combine with MAT or PAS.
        groups = [S.Location(rows(:,3),:) S.Point(rows(:,3),:)];
        measurements = S.Val(rows(:,3));
        details.title = ['Depth multi-compare of BD for: ' sites{idx}];
        [h, stats] = plotmultcomp(measurements, groups, details);
    end
end







plotMultCompVWCDepth = true;
if plotMultCompVWCDepth
    % We're looking at depth values pooled across time and grouped by depth and site.
    rows = (S.Type == 'dep' & S.Measurement == 'VWC');
    % Pick out the group markers - Upper, Middle, Lower and combine with MAT or PAS.
    groups = [S.Site(rows(:,3),:) S.Point(rows(:,3),:)];
    measurements = S.Val(rows(:,3));
    details.title = 'Depth multi-compare of VWC for Forest and Pasture';
    [h, stats] = plotmultcomp(measurements, groups, details);

    % sites = {'MAT', 'PAS'};
    % for idx = 1:length(sites)
    %     % We're looking at depth values pooled across time and grouped by depth and location (up, mid, low).
    %     rows = (S.Type == 'dep' & S.Measurement == 'VWC' & S.Site == sites{idx});
    %     % Pick out the group markers - Upper, Middle, Lower and combine with MAT or PAS.
    %     groups = [S.Location(rows(:,3),:) S.Point(rows(:,3),:)];
    %     measurements = S.Val(rows(:,3));
    %     details.title = ['Depth multi-compare of VWC for: ' sites{idx}];
    %     [h, stats] = plotmultcomp(measurements, groups, details);
    % end
end







doTTests = true;
if doTTests
    allMeasurements = {'SWC', 'GWC', 'BD', 'VWC'};
    % Foe each measurement
    for idx = 1:length(allMeasurements)
        % Pick out this particular measurement from the table
        MATRows = (S.Measurement == allMeasurements{idx} & S.Site == 'MAT');
        PASRows = (S.Measurement == allMeasurements{idx} & S.Site == 'PAS');
        MATVals = S.Val(MATRows(:,3));
        PASVals = S.Val(PASRows(:,3));
        % Then do a two-sample t-test on it.
        [h,p] = ttest2(MATVals, PASVals);
        display([allMeasurements{idx} ': The null hypothesis (that they share the same mean) was rejected (T/F): ' num2str(h) ' and p = ' num2str(p)]);
    end
end






function [handle, stats] = plotmultcomp(meas, groups, details)
      handle = figure;
      [stats.p, stats.t, stats.stats] = anova1(meas, groups, 'off');
      [stats.c, stats.m, stats.h, stats.nms] = multcompare(stats.stats);
      title(details.title, 'FontSize', 20);
end
