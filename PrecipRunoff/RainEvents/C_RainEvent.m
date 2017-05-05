classdef C_RainEvent < handle
    properties
        site;
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
        function obj = C_RainEvent(site)
            obj.site = site;
            obj.precipValsShift = 0;
            obj.stats = struct();
            obj.SM = struct();

            if(strcmp(site, 'MAT'))
                obj.addlPrecipTB = C_RunoffEvent('Celestino', 'TB');
            elseif(strcmp(site, 'PAS'))
                obj.addlPrecipTB = C_RunoffEvent('GuaboCamp', 'TB');
            else
                warning('C_RainEvent(site) called with incorrect site value');
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

        function handle = plotEvent(obj, origOrMod, type)
            % Validate inputs
            validatestring(origOrMod, {'orig', 'mod'});
            origOrMod = lower(origOrMod);
            validatestring(type, {'TB', 'LL', 'both'});
            type = upper(type);

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
            validatestring(origOrMod, {'orig', 'mod'});
            origOrMod = lower(origOrMod);
            validatestring(type, {'TB', 'LL', 'both'});
            type = upper(type);

            % Select our data: TB/LL, Original/Modified
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, false);

            width= 0.89;
            height= 0.4;
            leftcorner=0.05;
            bottomcorner1=0.5;
            bottomcorner2=bottomcorner1-height;
            linewidth = 3;
            titleFontSize = 20;
            axisFontSize = 18;

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
            bar(obj.precipTimes, precip);
            % TODO: Revert the hard coding of these axes.
            ax(1).YLim(2) = 9;
            %             g=gca;
            %             g.XTickSize=4
            % Sace colormap for use later
            cmap = colormap(lines);
            currentYTicks = get(gca, 'YTick');
            % Remove the last tick that would overlap with the bottom graph tick
            set(gca, 'YTick', currentYTicks(1:end-1));
            set(gca,'ydir','reverse');
            linkaxes(ax,'x');
            ylabel('Rainfall (mm)');
            titleTxt = {[origOrMod, ' ', obj.site '  Event: ' ...
                datestr(obj.startTime) '-' datestr(obj.endTime)], rrText};
            title(titleTxt, 'FontSize', titleFontSize);

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
            ax(2).YLim(2) = 9;
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
            ylabel('Runoff (mm)')
            xlabel('Time')

            % Add the soil moisture data.
            if plotSM
                yyaxis right;
                SMHandle = obj.plotSM();
                % TODO: Revert the hard coding of these axes.
                set(gca,'YLim',[30 60])
            end
        end

        function handle = plotDual(obj, figHandle, origOrMod, type)
            % Validate inputs
            validatestring(origOrMod, {'orig', 'mod'});
            origOrMod = lower(origOrMod);
            validatestring(type, {'TB', 'LL', 'both'});
            type = upper(type);

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
            validatestring(origOrMod, {'orig', 'mod'});
            origOrMod = lower(origOrMod);
            validatestring(type, {'TB', 'LL', 'both'});
            type = upper(type);

            % Consider switching BOTH to just TB here, would be ugly to plot all
            % 6 TB and runoff bars together.
            % Choose the precip values to plot.
            plotCelestino = false;
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type, plotCelestino);

            % Choose the runoff values. Make a note if they're different sizes.
            runoffSizeMismatch = false;
            try
                switch origOrMod
                    case 'orig'
                        allVals = [runoffEvents.vals];
                    case 'mod'
                        allVals = [runoffEvents.valsModified];
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
                    handle(i).FaceColor = cmap(i+1,:);
                    handle(i).EdgeColor = handle(i).FaceColor;
                end
                legText = [legText {['Lower'], ['Middle'], ['Upper']}];
                legend(legText);
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
                    plot(obj.SM.TIME.vals(idx), obj.SM.(avgNames{avgIdx}).vals(idx), 'r*');
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
            ylabel('VWC (%)');

            % One of the lines is plain dotted, hard to see. Add a marker.
            handle(3).Marker = '*';
            hold off
        end

        function checkLLRunoffsValid(obj)
            obj.atLeastOneLLRunoffValid = obj.upLLRunoff.isLLHeightValid || obj.midLLRunoff.isLLHeightValid || obj.lowLLRunoff.isLLHeightValid;
        end

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

    end

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
    end

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
    end
end
