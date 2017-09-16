classdef C_RainEvent < handle
    properties
        site;
        id; % A unique identifier, like "40". Derived from index number.
        startTime;
        endTime;
        precipTotal;
        precipTimes;
        precipVals;
        precipValsModified;
        precipValsShift;
        precipZeroed;
        LLValid;
        tbValid;
        legendText;
        atLeastOneLLRunoffValid;

        % C_Runoff objects, representing the LLs and TBs
        lowLLRunoff;
        midLLRunoff;
        upLLRunoff;
        lowTBRunoff;
        midTBRunoff;
        upTBRunoff;
        addlPrecipTB;
        allRunoff;

        % Soil Moisture data
        SM;

        % Statistics
        stats
        avgRR = NaN;
        avgRRAddl = NaN;            % Runoff Ratio at Celestino (MAT only)
        peakIntensity = NaN;
        avgIntensity = NaN;
        peakAddlIntensity = NaN;    % Peak intensity for Celestino (MAT only)
        avgAddlIntensity = NaN;     % Avg intensity for Celestino (MAT only)
        mergedRR = NaN;             % Optional RR, calc'd by bootstrapping LL and TB.

    end


    methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construction and Data Modification.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = C_RainEvent(site)
            obj.site = site;
            obj.id = nan;
            obj.precipValsShift = 0;
            obj.stats = struct();
            obj.SM = struct();

            if(strcmp(site, 'MAT'))
                obj.addlPrecipTB = C_RunoffEvent('Celestino', 'TB');
            elseif(strcmp(site, 'PAS'))
                obj.addlPrecipTB = C_RunoffEvent('GuaboCamp', 'TB');
            else
                % warning('C_RainEvent(site) called with incorrect site value');
            end

            % Initialize the runoff events.
            obj.lowLLRunoff = C_RunoffEvent('LOW', 'LL');
            obj.midLLRunoff = C_RunoffEvent('MID', 'LL');
            obj.upLLRunoff = C_RunoffEvent('UP', 'LL');

            obj.lowTBRunoff = C_RunoffEvent('LOW', 'TB');
            obj.midTBRunoff = C_RunoffEvent('MID', 'TB');
            obj.upTBRunoff = C_RunoffEvent('UP', 'TB');

            obj.allRunoff = [obj.lowLLRunoff obj.midLLRunoff obj.upLLRunoff ...
                obj.lowTBRunoff obj.midTBRunoff obj.upTBRunoff, obj.addlPrecipTB];
        end

        % When we assign the precip values, copy them to the modified
        % precip values variable, too.
        function initModifiedVals(obj)
            obj.precipValsModified = obj.precipVals;
            % Right now no measurements have been zeroed.
            obj.precipZeroed = zeros(length(obj.precipVals), 1);

            % Do the same for all the runoff events.
            for i = 1:length(obj.allRunoff)
                % Set runoff event's modified values equal to original and
                % Create empty array to store later modifications.
                obj.allRunoff(i).initModifiedVals();
            end
        end

        % Update the 'zeroed' vector (indicates where we've zeroed data).
        function updateModified(obj)
            obj.precipZeroed = (obj.precipValsModified == 0) & (obj.precipVals ~= 0);
            % Do the same for all the runoff events.
            for i = 1:length(obj.allRunoff)
                % Set runoff event's modified values equal to original and
                % Create empty array to store later modifications.
                obj.allRunoff(i).valsZeroed = (obj.allRunoff(i).valsModified == 0) & ( obj.allRunoff(i).vals ~= 0);
            end
        end

        function [edited] = applyEdits(obj, edEvt)
            edited = false;
            % Make sure the edited event has recorded all the changes made to it.
            edEvt.updateModified();
            % Apply the shifts.
            obj.precipValsShift = edEvt.precipValsShift;
            edited = edited || edEvt.precipValsShift ~= 0;
            % Do the same for all the runoff events.
            for run = 1:length(obj.allRunoff)
                obj.allRunoff(run).valsShift = edEvt.allRunoff(run).valsShift;
                edited = edited || edEvt.allRunoff(run).valsShift ~= 0;
            end
            % Apply the zeroing.
            obj.precipValsModified(edEvt.precipZeroed) = 0;
            obj.precipZeroed = edEvt.precipZeroed;
            edited = edited || any(edEvt.precipZeroed);
            % Do the same for all the runoff events.
            for run = 1:length(obj.allRunoff)
                % DEBUGGING: Make some noise if we found a modified event.
                % if any(edEvt.allRunoff(run).valsZeroed)
                %     display([obj.site ' : ' datestr(obj.startTime) ...
                %         ' contains the following amount of zeroing for runoff index : ' ...
                %         num2str(run) ' : ' num2str(sum(edEvt.allRunoff(run).valsZeroed))]);
                % end
                obj.allRunoff(run).valsModified(edEvt.allRunoff(run).valsZeroed) = 0;
                obj.allRunoff(run).valsZeroed = edEvt.allRunoff(run).valsZeroed;
                edited = edited || any(edEvt.allRunoff(run).valsZeroed);
            end
        end

        function checkLLRunoffsValid(obj)
            obj.atLeastOneLLRunoffValid = obj.upLLRunoff.isLLHeightValid || obj.midLLRunoff.isLLHeightValid || obj.lowLLRunoff.isLLHeightValid;
        end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function handle = plotEvent(obj, origOrMod, type)
            % Validate inputs
            origOrMod = lower(origOrMod);
            origOrModOK = any(strcmp(origOrMod, {'orig', 'mod'}));
            type = upper(type);
            typeOK = any(strcmp(type, {'TB', 'LL', 'BOTH'}));
            if ~typeOK || ~origOrModOK
                warning(['plotEvent called with invalid arguments: ' origOrMod ' ' type]);
            end

            % Choose the precip and runoff values to plot.
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, true);

            figHandle = figure;
            plot(obj.precipTimes, precip, '--', 'LineWidth', 3);
            % Clear out the legend in case it already exists.
            obj.legendText = {};
            obj.legendText{1} = 'Precip';
            % Save the current color scheme so we can match line colors.
            cmap = colormap(lines);
            hold on

            % Plot each of the chosen types of runoff
            for i = 1:length(runoffEvents)
                obj.legendText{end+1} = runoffEvents(i).plotEvent(figHandle, origOrMod, cmap(i+1,:));
            end

            title({[origOrMod, ' ', obj.site '  Event: ' datestr(obj.startTime) '-' datestr(obj.endTime)], ...
                rrText})
            legend(obj.legendText);

            hold off
            handle = figHandle;
        end

        function handle = plotDualAlt(obj, figHandle, origOrMod, type, plotSM)
          % Validate inputs
          origOrMod = lower(origOrMod);
          origOrModOK = any(strcmp(origOrMod, {'orig', 'mod'}));
          type = upper(type);
          typeOK = any(strcmp(type, {'TB', 'LL', 'BOTH'}));
          if ~typeOK || ~origOrModOK
              warning(['plotDualAlt called with invalid arguments: ' origOrMod ' ' type]);
          end

            % Select our data: TB/LL, Original/Modified
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, false);

            width= 0.89;
            height= 0.4;
            leftcorner=0.05;
            bottomcorner1=0.5;
            bottomcorner2=bottomcorner1-height;
            linewidth = 3;
            titleFontSize = 20;
            axisFontSize = 16;
            labelFontSize = 18;
            grayscale = true;

            % Set the current figure to the passed handle, if available.
            if ishandle(figHandle)
                figure(figHandle);
            else
                figHandle = figure('units','normalized','outerposition',[0 0 1 1]);
            end
            hold on
            clf

            % Set the axis colors to black (useful for plotting soil moisture).
            set(figHandle,'defaultAxesColorOrder',[[0 0 0]; [0 0 0]]);

            %This is the first part of the subplot - precip
            ax(1)= axes('position',[leftcorner bottomcorner1 width height]);
            % plot(obj.precipTimes, precip, 'LineWidth', linewidth);
            barHandle = bar(obj.precipTimes, precip);
            if grayscale == true
              barHandle(1).FaceColor = [0, 0, 0]+0.1;
              barHandle(1).EdgeColor = barHandle(1).FaceColor;
            end
            % TODO: Revert the hard coding of these axes.
            ax(1).YLim(2) = 16;
            %             g=gca;
            %             g.XTickSize=4
            % Sace colormap for use later
            cmap = colormap(lines);
            currentYTicks = get(gca, 'YTick');
            % Remove the last tick that would overlap with the bottom graph tick
            set(gca, 'YTick', currentYTicks(1:end-1));
            set(gca,'ydir','reverse');
            linkaxes(ax,'x');
            ylab = ylabel('Rainfall (mm)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
            % Shift away from the plot a little.
            ylab.Units = 'Normalized';
            ylab.Position = ylab.Position + [-0.015 0 0];
            % titleTxt = {[origOrMod, ' ', obj.site '  Event: ' ...
            %     datestr(obj.startTime) '-' datestr(obj.endTime)], rrText};
            % title(titleTxt, 'FontSize', titleFontSize);

            set(gca,'xtick',[])
            set(gca, 'xticklabel',[])
            set(gca,'FontSize',axisFontSize)

            % This is the second part of the subplot - runoff
            ax(2)= axes('position',[leftcorner bottomcorner2 width height]);
            if plotSM
                yyaxis left;
            end
            % Plot bar here.
            runoffHandle = obj.plotBar(origOrMod, type, false);
            % TODO: Revert the hard coding of these axes.
            ax(2).YLim(2) = 16;
            % Give the Y axes the same scale.
            % if ax(1).YLim(2) > ax(2).YLim(2)
            %     ax(2).YLim(2) = ax(1).YLim(2);
            % else
            %     ax(1).YLim(2) = ax(2).YLim(2);
            % end
            linkaxes(ax,'x');
            currentYTicks = get(gca, 'YTick');
            % Remove the last tick that would overlap with the top graph tick
            set(gca, 'YTick', currentYTicks(1:end-1));
            set(gca,'FontSize',axisFontSize)
            ylab = ylabel('Runoff (mm)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
            % Shift away from the plot a little.
            ylab.Units = 'Normalized';
            ylab.Position = ylab.Position + [-0.015 0 0];
            xlab = xlabel('Time', 'FontWeight', 'bold', 'FontSize', labelFontSize);
            % Shift away from the plot a little.
            xlab.Units = 'Normalized';
            xlab.Position = xlab.Position + [0 -0.015 0];

            % Add the soil moisture data.
            if plotSM
                yyaxis right;
                SMHandle = obj.plotSM();
                % TODO: Revert the hard coding of these axes.
                set(gca,'YLim',[35 60])
            end
        end

        function handle = plotDual(obj, figHandle, origOrMod, type)
          % Validate inputs
          origOrMod = lower(origOrMod);
          origOrModOK = any(strcmp(origOrMod, {'orig', 'mod'}));
          type = upper(type);
          typeOK = any(strcmp(type, {'TB', 'LL', 'BOTH'}));
          if ~typeOK || ~origOrModOK
              warning(['plotDual called with invalid arguments: ' origOrMod ' ' type]);
          end

            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, false);

            % Set the current figure to the passed handle, if available.
            if ~isnan(figHandle)
                figure(figHandle);
            else
                figHandle = figure;
            end
            hold on

            % Plot precip on the left axis (top).
            yyaxis left
            % plot(obj.precipTimes, precip, '--', 'LineWidth', 3);
            bar(obj.precipTimes, precip);
            % Clear out the legend in case it already exists.
            obj.legendText = {};
            obj.legendText{1} = 'Precip';
            % Flip the precip upside down.
            ax = gca;
            ax.YDir = 'reverse';
            % Expand the Y-axis to give room for runoff below.
            ax.YLim = ax.YLim * 2;
            yLims = ax.YLim;
            % Save the current color scheme so we can match line colors.
            cmap = colormap(lines);

            % Plot each of the chosen types of runoff on the bottom of the plot.
            yyaxis right
            for i = 1:length(runoffEvents)
                obj.legendText{end+1} = runoffEvents(i).plotEvent(figHandle, origOrMod, cmap(i+1,:));
            end
            ax = gca;
            ax.YLim = yLims;
            title({[origOrMod, ' ', obj.site '  Event: ' datestr(obj.startTime) '-' datestr(obj.endTime)], ...
                rrText})
            legend(obj.legendText);
            hold off
        end

        function handle = plotLineAndBar(obj, origOrMod, type)
            obj.plotEvent(origOrMod, type);
            % Make the figure extra wide to accomodate both plots.
            fig = gcf;
            fig.Position = [1,100, 1400, 600];
            subplot(1,2,1,gca);
            subplot(1,2,2);
            obj.plotBar(origOrMod, type, true);
        end

        % TODO: Fix this so that all plots show up on one figure.
        function handle = plotTBAndLL(obj, origOrMod)
            obj.plotEvent(origOrMod, 'TB');
            % Make the figure extra wide to accomodate both plots.
            fig = gcf;
            fig.Position = [1,100, 1400, 600];
            subplot(2,2,1,gca);
            subplot(2,2,2);
            obj.plotBar(origOrMod, 'TB', true);

            subplot(2,2,4);
            obj.plotBar(origOrMod, 'LL', true);

            obj.plotEvent(origOrMod, 'LL');
            subplot(2,2,3, gca);
        end

        function handle = plotBar(obj, origOrMod, type, plotPrecip)
          % Validate inputs
          origOrMod = lower(origOrMod);
          origOrModOK = any(strcmp(origOrMod, {'orig', 'mod'}));
          type = upper(type);
          typeOK = any(strcmp(type, {'TB', 'LL', 'BOTH'}));
          if ~typeOK || ~origOrModOK
              warning(['plotBar called with invalid arguments: ' origOrMod ' ' type]);
          end

          grayscale = true;

            % Consider switching BOTH to just TB here, would be ugly to plot all
            % 6 TB and runoff bars together.
            % Choose the precip values to plot.
            plotCelestino = false;
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, plotCelestino);

            % Choose the runoff values. Make a note if they're different sizes.
            runoffSizeMismatch = false;
            try
                allVals = [];
                switch origOrMod
                    case 'orig'
                        allVals = [runoffEvents.vals];
                    case 'mod'
                        % Need to account for the possible shift modification in each event.
                        for rEvt = 1:length(runoffEvents)
                            runoff = C_RainEvent.shiftVals(runoffEvents(rEvt).valsModified, runoffEvents(rEvt).valsShift);
                            % TODO: check that we're concatenating in the correct dimension.
                            allVals = [allVals runoff];
                        end
                        % allVals = [runoffEvents.valsModified];
                end
            catch ME
                if (strcmp(ME.identifier, 'MATLAB:catenate:dimensionMismatch'))
                    runoffSizeMismatch = true;
                    allVals = [];
                end
            end

            legText = {};
            % Plot the precip bars
            if plotPrecip
                handle = bar(obj.precipTimes, precip, 0.75);
                % Store the colormap values to use with other bars.
                cmap = colormap(lines);
                legText = {'Precip'};
            end

            if ~runoffSizeMismatch
                % Plot runoff bars inside precip bars.
                hold on;
                handle = bar(obj.precipTimes, allVals, 0.75);
                cmap = colormap(lines);
                for i = 1:length(handle)
                    % Don't plot the first bar with the same color as the
                    % precip
                    if grayscale == true
                        handle(i).FaceColor = [0, 0, 0]+0.2*(i);
                    else
                        handle(i).FaceColor = cmap(i+1,:);
                    end
                    handle(i).EdgeColor = handle(i).FaceColor;
                end
                legText = [legText {['Lower'], ['Middle'], ['Upper']}];
                legend(legText, 'FontSize', 16);
                hold off;
            end
        end

        function handle = plotSM(obj)
            avgs = [obj.SM.avg1.vals, obj.SM.avg2.vals, obj.SM.avg3.vals, obj.SM.avg4.vals];
            handle = plot(obj.SM.TIME.vals, avgs, 'LineWidth', 3);
            hold on
            % Plot a point showing where we think the response to precip began.
            avgNames = {'avg1', 'avg2', 'avg3', 'avg4'};
            for avgIdx = 1:length(avgNames)
                idx = obj.SM.(avgNames{avgIdx}).RT.idx;
                if ~isnan(idx)
                    % plot(obj.SM.TIME.vals(idx), obj.SM.(avgNames{avgIdx}).vals(idx), 'r*');
                end
            end

            % Get the existing legend(if there is one) and append our entries to it.
            lgd = legend();
            if isempty(lgd)
                legText = {'10 cm', '30 cm', '50 cm', '100 cm'};
            else
                legText = [lgd.String {'10 cm', '30 cm', '50 cm', '100 cm'}];
            end
            legend(legText);
            ylab = ylabel('VWC (%)', 'FontSize', 18, 'FontWeight', 'bold');
            ylab.Units = 'Normalized';
            ylab.Position = ylab.Position + [0.015 0 0];
            % Remove the downward pointing tick marks.
            box(gca, 'off');

            % One of the lines is plain dotted, hard to see. Add a marker.
            handle(3).Marker = '*';
            hold off
        end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Statistics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function total = getTotal(obj)
            obj.precipTotal = sum(obj.precipVals);
            total = obj.precipTotal;
        end

        function calcRunoffRatios(obj)
            % Calculate runoff ratio for the original and modified data.
            mod = {'orig', 'mod'};
            for i = 1:length(mod)
                % The general equation to get the average runoff ratio is:
                % (tb1/tot + tb2/tot + tb3/tot) / 3
                % Sum precip and sum each runoff (up, mid, low) for each event
                % NOTE - this doesn't actually change to use the modified
                % precip vals - we're expecting to never modify precip.
                obj.precipTotal = sum(obj.precipVals);

                sumLL = obj.lowLLRunoff.getTotal(mod{i});
                sumLL = sumLL + obj.midLLRunoff.getTotal(mod{i});
                sumLL = sumLL + obj.upLLRunoff.getTotal(mod{i});

                sumTB = obj.lowTBRunoff.getTotal(mod{i});
                sumTB = sumTB + obj.midTBRunoff.getTotal(mod{i});
                sumTB = sumTB + obj.upTBRunoff.getTotal(mod{i});

                obj.stats.(mod{i}).RR.LL.precip = sumLL / (obj.precipTotal * 3);
                obj.stats.(mod{i}).RR.TB.precip = sumTB / (obj.precipTotal * 3);
                obj.stats.(mod{i}).RR.both.precip = mean([obj.stats.(mod{i}).RR.LL.precip obj.stats.(mod{i}).RR.TB.precip]);

                if strcmp(obj.site, 'MAT')
                    celestinoTot = obj.addlPrecipTB.getTotal((mod{i}));
                    if celestinoTot == 0
                        obj.stats.(mod{i}).RR.LL.addl = 0; % IS THIS THE BEST ERROR CODE?
                        obj.stats.(mod{i}).RR.TB.addl = 0;
                        obj.stats.(mod{i}).RR.both.addl = 0;
                    else
                        obj.stats.(mod{i}).RR.LL.addl  = sumLL / (celestinoTot * 3);
                        obj.stats.(mod{i}).RR.TB.addl  = sumTB / (celestinoTot * 3);
                        obj.stats.(mod{i}).RR.both.addl = mean([obj.stats.(mod{i}).RR.LL.addl obj.stats.(mod{i}).RR.TB.addl]);
                    end
                else
                    obj.stats.(mod{i}).RR.LL.addl = NaN;
                    obj.stats.(mod{i}).RR.TB.addl = NaN;
                    obj.stats.(mod{i}).RR.both.addl = NaN;
                end
            end
        end

        function calcAvgRunoffAmt(obj)
            % Calculate average height of runoff recorded for the LLs and the TBs
            obj.stats.mod.RunAmt.LL = obj.stats.mod.RR.LL.precip * obj.precipTotal;
            obj.stats.mod.RunAmt.TB = obj.stats.mod.RR.TB.precip * obj.precipTotal;
        end

        function calcPeakIntensity(obj)
            obj.stats.orig.int.peak.precip = max(obj.precipVals);
            obj.stats.mod.int.peak.precip = max(obj.precipValsModified);
        end

        function calcAvgIntensity(obj)
            % We've added some zeros to the start and end of the precipVals
            % vector. Need to remove those so they're not incorrectly
            % counted in the averaging.
            validIndices = (obj.precipTimes >= obj.startTime) & (obj.precipTimes <= obj.endTime);
            obj.stats.orig.int.avg.precip = mean(obj.precipVals(validIndices));
            obj.stats.mod.int.avg.precip = mean(obj.precipValsModified(validIndices));
%             disp([obj.precipVals obj.precipValsModified]);
%             disp('  ');
        end

        function calcPeakAddlIntensity(obj)
            if strcmp(obj.site, 'MAT')
                obj.stats.orig.int.peak.celestino = max(obj.addlPrecipTB.vals);
                obj.stats.mod.int.peak.celestino = max(obj.addlPrecipTB.valsModified);
            end
        end

        function calcAvgAddlIntensity(obj)
            if strcmp(obj.site, 'MAT')
                % We've added some zeros to the start and end of the precipVals
                % vector. Need to remove those so they're not incorrectly
                % counted in the averaging.
                validIndices = (obj.addlPrecipTB.times >= obj.startTime) & (obj.addlPrecipTB.times <= obj.endTime);
                obj.stats.orig.int.avg.celestino = mean(obj.addlPrecipTB.vals(validIndices));
                obj.stats.mod.int.avg.celestino = mean(obj.addlPrecipTB.valsModified(validIndices));
            end
        end

        function calcSMStats(obj)
            % Old events don't have SM data. Check if this is an old event, and don't do anything if so.
            if isempty(obj.SM)
                return
            end
            % Calculate the response time for each SM trace.
            fn = fieldnames(obj.SM);
            % Remove the TIME fieldname, we'll calculate response times for all others.
            fn = fn(~strcmp(fn, 'TIME'));
            % For each SM trace, eg T1, M1, B1, avg1, etc.
            for field = 1:length(fn)
                % Only look for a SM response after the precip starts.
                SMStartIdx = find(obj.SM.TIME.vals >= obj.startTime, 1);
                rtIdx = FindResponseTime(obj.SM.(fn{field}).vals(SMStartIdx:end), nan, nan);
                if rtIdx ~= 0
                    % Bump up the index because we didn't search the first part of the SM data.
                    rtIdx = rtIdx + SMStartIdx - 1;
                    obj.SM.(fn{field}).RT.idx = rtIdx;
                    obj.SM.(fn{field}).RT.dur = obj.SM.TIME.vals(rtIdx) - obj.startTime;
                    % DEBUGGING: Make some noise if the duration was less than 0
                    if obj.SM.(fn{field}).RT.dur < 0
                        disp('Found a SM RT duration less than 0. ');
                    end
                else
                    obj.SM.(fn{field}).RT.idx = nan;
                    obj.SM.(fn{field}).RT.dur = nan;
                end
            end
            % Store an average of the four average Response Times
            avgs = [obj.SM.avg1.RT.dur;
                obj.SM.avg2.RT.dur;
                obj.SM.avg3.RT.dur;
                obj.SM.avg4.RT.dur];
            obj.stats.orig.SM.RT = nanmean(avgs);
        end

        function calcAllStatistics(obj)
            % Calcualtes statistics for both original and modified data.
            % Modified data will be equal to the original if unchanged.
            obj.calcRunoffRatios();
            obj.calcPeakIntensity();
            obj.calcAvgIntensity();
            obj.calcPeakAddlIntensity();
            obj.calcAvgAddlIntensity();
            obj.calcSMStats();
            obj.getTotal();
            obj.calcAvgRunoffAmt();
        end

        function minTimeToRunoff = timeToFirstRunoff(obj, type)
          runThresh = 0.2;
          % Choose the runoff sources that could contain our first runoff
          [~, runoffEvents, ~] = obj.selectPlotData('mod', type, false);
          % For each runoff source, find how long it is until there's substantial runoff
          minTimeToRunoff = minutes(nan);
          for rEvt = 1:length(runoffEvents)
              % Need to account for the possible shift modification in each event.
              % runoff = C_RainEvent.shiftVals(runoffEvents(rEvt).valsModified, runoffEvents(rEvt).valsShift);
              % validIndices = (runoffEvents(rEvt).times >= obj.startTime) & (runoffEvents(rEvt).times <= obj.endTime);
              % runoff = runoff(validIndices);
              % runTimes = runoffEvents(rEvt).times(validIndices);

              [runoff, runTimes] = runoffEvents(rEvt).getValidTimesAndRunVals(obj.startTime, obj.endTime);
              runStartIdx = find(runoff > runThresh, 1);
              if isempty(runStartIdx)
                  % disp('ERROR: Could not find substantial runoff in observed data.')
                  return
              end
              firstRunTime = runTimes(runStartIdx) - obj.startTime;
              if isnan(minTimeToRunoff)
                  minTimeToRunoff = firstRunTime;
              else
                  minTimeToRunoff = min(minTimeToRunoff, firstRunTime);
              end
          end
        end

        function maxRunoffRate = findMaxRunoffRate(obj, type)
          % Choose the runoff sources that could contain our first runoff
          [~, runoffEvents, ~] = obj.selectPlotData('mod', type, false);
          maxRunoffRate = 0;
          for runEvtIdx = 1:length(runoffEvents)
              [runVals, runTimes] = runoffEvents(runEvtIdx).getValidTimesAndRunVals(obj.startTime, obj.endTime);
              thisEvtMax = max(runVals);
              thisEvtMaxEasy = max(runoffEvents(runEvtIdx).valsModified);
              
              maxRunoffRate = nanmax(thisEvtMax, maxRunoffRate);
          end
          % Convert to mm/hr from mm/10min.
          maxRunoffRate = maxRunoffRate * 6;
          % Return error code if somehow we didn't find any runoff rates greater than 0.
          if maxRunoffRate == 0
              maxRunoffRate = nan;
          end
        end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Export.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function exportPrecipRunoff(obj, origOrMod, type, whichEvt)
            % Exports precip and runoff data from an event to a .csv.
            genPlots = false;

            % Validate inputs
            origOrMod = lower(origOrMod);
            origOrModOK = any(strcmp(origOrMod, {'orig', 'mod'}));
            type = upper(type);
            typeOK = any(strcmp(type, {'TB', 'LL', 'BOTH'}));
            if ~typeOK || ~origOrModOK
                warning(['exportPrecipRunoff called with invalid arguments: ' origOrMod ' ' type ' ' num2str(whichEvt)]);
            end

            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, false);
            % Don't include extra data before and after start/end time.
            validPreIdxs = obj.precipTimes >= obj.startTime & obj.precipTimes <= obj.endTime;
            PreTimes = obj.precipTimes(validPreIdxs);
            PreVals = obj.precipValsModified(validPreIdxs);
            % Determine timestamp duration.
            diffPreTS = PreTimes(2) - PreTimes(1);
            % Plot the precip timestamps.
            if genPlots == true
                figure;
                hold on;
                plot(PreTimes, zeros(length(PreTimes), 1), '.', 'Marker', 'o', 'MarkerSize', 6);
            end

            % Prepare to store data from all three runoff sources.
            allRunVals = [];
            runTimeOffsets = [];
            for runIdx = 1:length(runoffEvents)
                % Get just the runoff data between start and end times.
                validRunIdxs = runoffEvents(runIdx).times >= obj.startTime & runoffEvents(runIdx).times <= obj.endTime;
                diffPreRunIdxLength = sum(validPreIdxs) - sum(validRunIdxs);
                if diffPreRunIdxLength == 1
                    % And add in one more timestamp to equal the mumber of Precip and Runoff datapoints
                    validRunIdxs(find(validRunIdxs, 1, 'last')+1) = 1;
                elseif diffPreRunIdxLength == 0
                    % Do nothing, they're already the same length.
                else
                    warning('Precip and Runoff lengths are different.');
                end
                runTimes = runoffEvents(runIdx).times(validRunIdxs);
                % All runoff timeseries need to be uniform time resolution, so
                % check that we're working with 10-minute data.
                runTimeRes = runTimes(2) - runTimes(1);
                if runTimeRes ~= minutes(10)
                    warning('C_RainEvent.exportPrecipRunoff: runoff time series with non-uniform timestamps.');
                end
                % Make sure we take into account the possible shifting of values.
                runVals = C_RainEvent.shiftVals(runoffEvents(runIdx).valsModified, runoffEvents(runIdx).valsShift);
                % Plot the runoff values.
                if genPlots == true
                    stem(runTimes, runVals(validRunIdxs));
                end
                % Determine how far ahead (or behind) this time series is relative to precip.
                timeOffset = runTimes(1) - PreTimes(1);
                % Average the three runoff values that are nearest each precip timestamp.
                % Might need to shift the runoff values by one to achieve this.
                % Is the first runoff timestamp actually closer to the second precip timestamp than the first?
                if (runTimes(1) - PreTimes(1)) > diffPreTS/2
                    runVals = C_RainEvent.shiftVals(runVals, 1);
                    timeOffset = timeOffset - minutes(10);
                end
                runVals = runVals(validRunIdxs);
                allRunVals = [allRunVals runVals];
                runTimeOffsets = [runTimeOffsets timeOffset];
            end
            meanRun = mean(allRunVals, 2);
            meanRunTimeOffset = mean(runTimeOffsets);
            meanRunTimes = PreTimes + meanRunTimeOffset;
            if genPlots == true
                try
                    stem(meanRunTimes, meanRun, 'LineWidth', 2);
                catch
                    disp('Stem Error');
                end
                if 3 == length(runoffEvents)
                    legend({'precip', 'low', 'mid', 'up', 'avg'});
                elseif 6 == length(runoffEvents)
                    legend({'precip', 'low', 'mid', 'up', 'low', 'mid', 'up', 'avg'});
                else
                    warning(['C_RainEvent.exportPrecipRunoff: Got an unexpected number (' num2str(length(runoffEvents)) ') of runoff sources.']);
                end
                title([obj.site ' ' num2str(whichEvt) ' ' type ' ' datestr(obj.startTime)]);
                hold off;
            end

            % Export the data we've assembled to a csv file.
            evtIdx = 17;
            fn = ['Export/' obj.site '_' num2str(whichEvt) '_' type '.csv'];
            T = table(PreTimes, PreVals, meanRunTimes, meanRun);
            writetable(T, fn);
        end

    end % methods (Access = public)


    methods (Access = private)
        function [precip, runoffEvents, rrText] = selectPlotData(obj, origOrMod, type, plotAddl)
            switch origOrMod
                case 'orig'
                    precip = obj.precipVals;
                case 'mod'
                    precip = C_RainEvent.shiftVals(obj.precipValsModified, obj.precipValsShift);
            end

            % Choose which types of runoff we'll be plotting.
            switch type
                case 'TB'
                    runoffEvents = [obj.lowTBRunoff obj.midTBRunoff obj.upTBRunoff];
                    rrText = ['Avg. RR TB: ' num2str(obj.stats.(origOrMod).RR.TB.precip)];
                case 'LL'
                    runoffEvents = [obj.lowLLRunoff obj.midLLRunoff obj.upLLRunoff];
                    rrText = ['Avg. RR LL: ' num2str(obj.stats.(origOrMod).RR.LL.precip) ];
                case 'BOTH'
                    runoffEvents = obj.allRunoff(1:(end-1));
                    rrText = ['Avg. RR TB: ' num2str(obj.stats.(origOrMod).RR.TB.precip) ...
                        'Avg. RR LL: ' num2str(obj.stats.(origOrMod).RR.LL.precip) ...
                        'Avg. RR both: ' num2str(obj.stats.(origOrMod).RR.both.precip)];
            end

            % Add the celestino data.
            if plotAddl && strcmpi(obj.site, 'MAT')
                runoffEvents = [runoffEvents obj.addlPrecipTB];
                % Add references to celestino data.
                switch type
                    case 'TB'
                        rrText = [rrText 'Avg. RR TB (Celestino): ' num2str(obj.stats.(origOrMod).RR.TB.addl)];
                    case 'LL'
                        rrText = [rrText 'Avg. RR LL (Celestino): ' num2str(obj.stats.(origOrMod).RR.LL.addl)];
                    case 'BOTH'
                        rrText = [rrText ...
                            'Avg. RR TB (Celestino): ' num2str(obj.stats.(origOrMod).RR.TB.addl) ...
                            'Avg. RR LL (Celestino): ' num2str(obj.stats.(origOrMod).RR.LL.addl) ...
                            'Avg. RR both (Celestino): ' num2str(obj.stats.(origOrMod).RR.both.addl)];
                end
            end
        end
    end % methods (Access = private)

    methods(Static)
        function [shiftedVals] = shiftVals(vals, shift)
            if shift > 0
                shiftedVals = [zeros(shift, 1); vals(1:(end-shift))];
            elseif shift < 0
                shiftedVals = [vals((-1 * shift + 1):end); zeros(-1 * shift, 1)];
            else
                shiftedVals = vals;
            end
        end
    end % methods(Static)
end
