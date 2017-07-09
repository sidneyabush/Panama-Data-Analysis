function [handle] = plotErrorBars(xFieldName, yFieldName, data, details, fixedEdges)
% Generates plots displaying mean values and error bars. Also prints kruskalwallis multcompare and KSTest2 results.

    % Sort values into bins.
    bins = struct();
    if isempty(fixedEdges)
        % Need the same bin edges for both MAT and PAS, so use whichever is larger as
        % reference.
        if (max(data.PAS.(xFieldName)) > max(data.MAT.(xFieldName)))
            [NPAS, edgesPAS, bins.PAS] = histcounts(data.PAS.(xFieldName));
            [NMAT, edgesMAT, bins.MAT] = histcounts(data.MAT.(xFieldName), edgesPAS);
        else
            [NMAT, edgesMAT, bins.MAT] = histcounts(data.MAT.(xFieldName));
            [NPAS, edgesPAS, bins.PAS] = histcounts(data.PAS.(xFieldName), edgesMAT);
        end
    else
        [NPAS, edgesPAS, bins.PAS] = histcounts(data.PAS.(xFieldName), fixedEdges);
        [NMAT, edgesMAT, bins.MAT] = histcounts(data.MAT.(xFieldName), fixedEdges);
    end
    % DEBUGGING: Show how many values are in each bin.
    disp([xFieldName ':Contents of MAT Bins: ']);
    disp(NMAT);
    disp(edgesMAT);
    disp(sum(NMAT));
    disp([xFieldName ':Contents of PAS Bins: ']);
    disp(NPAS);
    disp(edgesPAS);
    disp(sum(NPAS));

    % Create the labels for our bins.
    if isfield(details, 'xtickfmt')
        % Apply a special format if specified.
        frmt = details.xtickfmt;
    else
        frmt = '%.1f';
    end
    edges = {};
    for idx = 1:length(edgesMAT)-1
        edges{end+1} = [num2str(edgesMAT(idx), frmt) ' - ' num2str(edgesMAT(idx+1), frmt)];
    end

    % For both MAT and PAS,
    pltData.labels = {};
    pltData.x = [];
    pltData.y = [];
    pltData.err = [];
    pltData.isMAT = [];
    multData.vals = [];
    multData.groups = {};
    % Create a cell in the array for each group and for each site.
    numBins = length(edgesPAS) - 1;
    multData.ksvals = cell(numBins, 2);
    sites = {'MAT', 'PAS'};
    xOffset = [0, 0.2];
    for siteIdx = 1:length(sites)
        thisSite = sites{siteIdx};
        % For each bin,
        for binIdx = 1:max(bins.(thisSite))
            % Get the RR values that fall into each bin.
            valsThisBin = data.(thisSite).(yFieldName)(bins.(thisSite) == binIdx);
            multData.vals = [multData.vals valsThisBin];
            multData.groups(end+1:end+length(valsThisBin)) = ...
                                  cellstr([thisSite num2str(edgesMAT(binIdx))]);
            % Store values in this bin into a cell array for easy processing with kstest2.
            multData.ksvals{binIdx, siteIdx} = valsThisBin;
            % pltData.labels{end+1} = [thisSite num2str(binIdx)];
            pltData.labels{end+1} = [thisSite];
            pltData.isMAT = [pltData.isMAT strcmp(thisSite, 'MAT')];
            % Assign an x value (just a position along the X axis for tidy grouping)
            pltData.x = [pltData.x binIdx+xOffset(siteIdx)];
            % Calc and store mean for this group.
            pltData.y = [pltData.y mean(valsThisBin)];
            % Calculate the standard error of the mean (which tells us how
            % accurately our sample data represents the actual population it was
            % drawn from).
            stdErrOfMean = std(valsThisBin) / sqrt(length(valsThisBin));
            pltData.err = [pltData.err stdErrOfMean];
        end
    end
    % the isMAT marker comes out as doubles, convert it to a logical.
    pltData.isMAT = logical(pltData.isMAT);

    linesize = 1.5;
    capsize = 10;
    textSize = 18;
    tickSize = 16;
    legendSize = 16;
    titleSize = 20;
    markerSize = 14;

    % To get different colors for MAT and PAS, plot them separately.
    handle = figure('position', [0, 0, 800, 800]);
    ebMAT = errorbar(pltData.x(pltData.isMAT), pltData.y(pltData.isMAT), pltData.err(pltData.isMAT), 'o', 'LineWidth', linesize, 'MarkerSize', markerSize, 'CapSize', capsize);
    ebMAT.Color = 'black';
    ebMAT.MarkerFaceColor = 'black';
    hold on;
    ebPAS = errorbar(pltData.x(~pltData.isMAT), pltData.y(~pltData.isMAT), pltData.err(~pltData.isMAT), '^', 'LineWidth', linesize, 'MarkerSize', markerSize, 'CapSize', capsize);
    ebPAS.Color = [0.5 0.5 0.5];
    ebPAS.MarkerFaceColor = [0.5 0.5 0.5];

    set(gca,'FontSize',tickSize);
    xticks(1:floor(max(pltData.x)));
    % Set the xtick to describe the bins.
    xticklabels(edges);
    xlab = xlabel(details.xlab, 'FontSize', textSize, 'FontWeight', 'bold');
    % Shift away from the plot a little.
    xlab.Units = 'Normalized';
    xlab.Position = xlab.Position + [0 -0.015 0];
    % xtickangle(20);
    xl = xlim();
    xlim([xl(1) - 0.4,  xl(2)]);
    ylab = ylabel(details.ylab, 'FontSize', textSize, 'FontWeight', 'bold');
    % Shift away from the plot a little.
    ylab.Units = 'Normalized';
    ylab.Position = ylab.Position + [-0.015 0 0];
    % title(details.title ,'FontSize', titleSize);
    % Ugly hack to get just the symbols (w/o error bars) in the legend, and the
    % proper font size.
    [lgd, icons, plots, txt] = legend({'Forest', 'Pasture'});
    lgd.FontSize = textSize;
    icons(1).FontSize = legendSize;
    icons(2).FontSize = legendSize;
    % legend('boxoff');
    hold off;

    % Save to a hi-res .png.
    ExportPNG(details.filename);

    multDet.title = ['MultiCompare: ' details.title];
    multDet.dispTextComp = true;
    plotmultcomp(multData.vals, multData.groups, multDet);

    dispStatTests(multData.ksvals, details.xlab, edgesMAT);
end


function [handle, stats] = plotmultcomp(meas, groups, details)
      handle = figure;
      % [stats.p, stats.t, stats.stats] = anova1(meas, groups, 'off');
      [stats.p, stats.tbl, stats.stats] = kruskalwallis(meas, groups, 'off');
      [stats.c, stats.m, stats.h, stats.nms] = multcompare(stats.stats,'Alpha',0.1);
      title(details.title);

      % Optionally display a table of p-values comparing each group.
      if (details.dispTextComp == true)
          comp = array2table(stats.c, 'VariableNames', {'First_Group', 'Second_Group', 'Low_Conf_Int', 'Est_of_Mean', 'Up_Conf_Int', 'P_Val'});
          % Replace the numberic group names with text (easier to read).
          gNames = char(stats.stats.gnames);
          comp = [table(gNames(comp.Second_Group, :), 'VariableNames', {'Group2'}) comp];
          comp = [table(gNames(comp.First_Group, :), 'VariableNames', {'Group1'}) comp];
          comp.First_Group = [];
          comp.Second_Group = [];
          disp(' ');
          disp(details.title);
          disp(comp);
      end
end

function [] = dispStatTests(groups, measName, binEdges)
      [numBins, numSites] = size(groups);
      if numSites ~= 2
          warning('dispStatTests: called with incorrect number of sites, should be 2.');
          return
      end
      for whichBin = 1:numBins
          MATData = groups{whichBin, 1};
          PASData = groups{whichBin, 2};
          if ~isempty(MATData) && ~isempty(PASData)
              [h,p] = kstest2(MATData, PASData);
              disp([measName ': KSTest2 - Bin starting with:' num2str(binEdges(whichBin)) '. The probability that MAT and PAS come from populations with the same distribution: ' num2str(p)]);
              % Do a Mann-Whitney test
              [p,h] = ranksum(MATData, PASData);
              disp([measName ': Mann-Whitney - Bin starting with:' num2str(binEdges(whichBin)) 'The probability that MAT and PAS have distributions with the same median:' num2str(p)]);
          else
              disp([measName ': Bin starting with:' num2str(binEdges(whichBin)) ' did not contain samples for both MAT and PAS, so it could not be tested.']);
          end
      end
end
