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

        % Statistics
        stats
        avgRR = NaN;
        avgRRAddl = NaN;        % Runoff Ratio at Celestino (MAT only)
        peakIntensity = NaN;
        avgIntensity = NaN;
        peakAddlIntensity = NaN;    % Peak intensity for Celestino (MAT only)
        avgAddlIntensity = NaN;     % Avg intensity for Celestino (MAT only)

    end
    methods
        function obj = C_RainEvent(site)
            obj.site = site;
            obj.precipValsShift = 0;
            obj.stats = struct();

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
            % Stuff the runoff events into an array
            %             allSites = [obj.lowLLRunoff obj.midLLRunoff obj.upLLRunoff ...
            %                 obj.lowTBRunoff obj.midTBRunoff obj.upTBRunoff, obj.addlPrecipTB];
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

            % Choose the precip values to plot.
            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type);

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

        function handle = plotDual(obj, figHandle, origOrMod, type)
            % Validate inputs
            validatestring(origOrMod, {'orig', 'mod'});
            origOrMod = lower(origOrMod);
            validatestring(type, {'TB', 'LL', 'both'});
            type = upper(type);

            [precip, runoffEvents, rrText] = obj.selectPlotData(origOrMod, type);

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
            obj.plotBar(origOrMod, type);
        end

        % TODO: Fix this so that all plots show up on one figure.
        function handle = plotTBAndLL(obj, origOrMod)
            obj.plotEvent(origOrMod, 'TB');
            % Make the figure extra wide to accomodate both plots.
            fig = gcf;
            fig.Position = [1,100, 1400, 600];
            subplot(2,2,1,gca);
            subplot(2,2,2);
            obj.plotBar(origOrMod, 'TB');

            subplot(2,2,4);
            obj.plotBar(origOrMod, 'LL');

            obj.plotEvent(origOrMod, 'LL');
            subplot(2,2,3, gca);
        end

        % TODO: Update to plot LL or TB (or both) as well as original or modified.
        function handle = plotBar(obj, origOrMod, type)
            if strcmpi(origOrMod, 'original')
                precip = obj.precipVals;
            elseif strcmpi(origOrMod, 'modified')
                % Take into account the data shift.
                precip = obj.precipValsModified;
                if obj.precipValsShift > 0
                    precip = [zeros(obj.precipValsShift, 1); precip(1:(end-obj.precipValsShift))];
                elseif obj.precipValsShift < 0
                    precip = [precip((-1 * obj.precipValsShift + 1):end); zeros(-1 * obj.precipValsShift, 1)];
                end
            else
                warning('Need to pass either "original" or "modified" to plotEvent');
                return;
            end

            % Choose which types of runoff we'll be plotting.
            if strcmpi(type, 'TB')


                if strcmpi(origOrMod, 'original')
                    lowRunoffVals = obj.lowTBRunoff.vals;
                    midRunoffVals = obj.midTBRunoff.vals;
                    upRunoffVals = obj.upTBRunoff.vals;
                elseif strcmpi(origOrMod, 'modified')

                    lowRunoffVals = obj.lowTBRunoff.valsModified;
                    midRunoffVals = obj.midTBRunoff.valsModified;
                    upRunoffVals = obj.upTBRunoff.valsModified;

                    % Take into account the data shift.
                    precip = obj.precipValsModified;
                    if obj.precipValsShift > 0
                        precip = [zeros(obj.precipValsShift, 1); precip(1:(end-obj.precipValsShift))];
                    elseif obj.precipValsShift < 0
                        precip = [precip((-1 * obj.precipValsShift + 1):end); zeros(-1 * obj.precipValsShift, 1)];
                    end
                end

                lowLength = length(obj.lowTBRunoff.vals);
                midLength = length(obj.midTBRunoff.vals);
                upLength =  length(obj.upTBRunoff.vals);
                legText = {'Precip', 'TB-LOW', 'TB-MID', 'TB-UP'};
            elseif strcmpi(type, 'LL')
                lowLength = length(obj.lowLLRunoff.vals);
                midLength = length(obj.midLLRunoff.vals);
                upLength =  length(obj.upLLRunoff.vals);
                legText = {'Precip', 'LL-LOW', 'LL-MID', 'LL-UP'};
            elseif strcmpi(type, 'both')
                warning('Plotting both LL and TB is not supported yet. Plotting just TB. ');
                lowLength = length(obj.lowTBRunoff.vals);
                midLength = length(obj.midTBRunoff.vals);
                upLength =  length(obj.upTBRunoff.vals);
                legText = {'Precip', 'TB-LOW', 'TB-MID', 'TB-UP'};
            else
                warning('Need to pass either "LL" or "TB" or "both" to plotBar');
                return;
            end


            lowLength = length(lowRunoffVals);
            midLength = length(midRunoffVals);
            upLength = length(upRunoffVals);

            % Plot the precip bars
            handle = bar(obj.precipTimes, precip, 0.75);
            % Store the colormap values to use with other bars.
            cmap = colormap(lines);

            % Do we want to plot Celestino or Guabo Camp?
            plotAddlPrecip = false;

            allLengths = [lowLength, midLength, upLength];
            if(plotAddlPrecip == true)
                addlLength = length(obj.addlPrecipTB);
                allLengths = [allLengths, addlLength];
            end

            if(any(diff(allLengths)))
                text(obj.startTime,0.8*max(obj.precipVals),'Error with Runoff Plotting.');
                legend('Precip');
                return;
            end

            if strcmpi(type, 'TB')
                allVals = [obj.lowTBRunoff.vals, obj.midTBRunoff.vals, ...
                    obj.upTBRunoff.vals];
            elseif strcmpi(type, 'LL')
                allVals =   [obj.lowLLRunoff.vals, obj.midLLRunoff.vals, ...
                    obj.upLLRunoff.vals];
            elseif strcmpi(type, 'both')
                allVals = [obj.lowTBRunoff.vals, obj.midTBRunoff.vals, ...
                    obj.upTBRunoff.vals];
            end


            if(plotAddlPrecip == true)
                allVals = [allVals, obj.addlPrecipTB,vals];
            end
            % Plot runoff bars inside precip bars.
            hold on;
            handle = bar(obj.precipTimes, allVals, 0.75);
            for i = 1:length(handle)
                % Don't plot the first bar with the same color as the
                % precip
                handle(i).FaceColor = cmap(i+1,:);
                handle(i).EdgeColor = handle(i).FaceColor;
            end
            hold off;
            if(plotAddlPrecip == true)
                if(strcmp(obj.site, 'MAT'))
                    legText{end+1} = 'Celestino';
                elseif(strcmp(obj.site, 'PAS'))
                    legText{end+1} = 'GuaboCamp';
                end
            end
            legend(legText);
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

        function calcAllStatistics(obj)
            % Calcualtes statistics for both original and modified data.
            % Modified data will be equal to the original if unchanged.
            obj.calcRunoffRatios();
            obj.calcPeakIntensity();
            obj.calcAvgIntensity();
            obj.calcPeakAddlIntensity();
            obj.calcAvgAddlIntensity();
        end
    end

    methods (Access = private)
        function [precip, runoffEvents, rrText] = selectPlotData(obj, origOrMod, type)
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
            plotCelestino = true;
            if plotCelestino && strcmpi(obj.site, 'MAT')
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
