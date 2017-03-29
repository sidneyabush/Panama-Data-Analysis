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
        
        function handle = plotEvent(obj, origOrMod)
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
            figHandle = figure;
            plot(obj.precipTimes, precip, '--', 'LineWidth', 3);
            % Clear out the legend in case it already exists.
            obj.legendText = {};
            obj.legendText{1} = 'Precip';
            % Save the current color scheme so we can match line colors.
            cmap = colormap(lines);
            hold on
            
            % Plot the runoff events. Uncomment to add to plot.
                         obj.legendText{end+1} = obj.lowLLRunoff.plotEvent(figHandle, origOrMod, cmap(2,:));
                         obj.legendText{end+1} = obj.midLLRunoff.plotEvent(figHandle, origOrMod, cmap(3,:));
                         obj.legendText{end+1} = obj.upLLRunoff.plotEvent(figHandle, origOrMod, cmap(4,:));
            % obj.legendText{end+1} = obj.lowTBRunoff.plotEvent(figHandle, origOrMod, cmap(2,:));
            % obj.legendText{end+1} = obj.midTBRunoff.plotEvent(figHandle, origOrMod, cmap(3,:));
            % obj.legendText{end+1} = obj.upTBRunoff.plotEvent(figHandle, origOrMod, cmap(4,:));
            
            obj.legendText{end+1} = obj.addlPrecipTB.plotEvent(figHandle, origOrMod, cmap(5,:));
            
            title({[origOrMod, ' ', obj.site '  Event: ' datestr(obj.startTime) '-' datestr(obj.endTime)], ...
                ['Avg. RR: ' num2str(obj.avgRR)], ...
                ['Avg. RR (Celestino): ' num2str(obj.avgRRAddl)]})
            legend(obj.legendText);
            
            if 0
                %             if all(~isnan([obj.avgRR obj.avgRRAddl]))
                dimensions = [0.63 0.5 0.2 0.2];
                str = {['Avg. RR: ' num2str(obj.avgRR)], ['Avg. RR (Celestino): ' num2str(obj.avgRRAddl)]};
                annotation('textbox', dimensions, 'String', str, 'FitBoxToText', 'on');
                %
            end
            
            hold off
            handle = figHandle;
        end
        
        function handle = plotLineAndBar(obj)
            obj.plotEvent('original');
            % Make the figure extra wide to accomodate both plots.
            fig = gcf;
            fig.Position = [1,100, 1400, 600];
            subplot(1,2,1,gca);
            subplot(1,2,2);
            obj.plotBar();
        end
        
        function handle = plotBar(obj)
            % Plot the precip bars
            handle = bar(obj.precipTimes, obj.precipVals, 0.75);
            % Store the colormap values to use with other bars.
            cmap = colormap(lines);
            
            % Do we want to plot Celestino or Guabo Camp?
            plotAddlPrecip = false;
            
            % Check to make sure all the runoffs have the same # of points
                         lowLength = length(obj.lowLLRunoff.vals);
                         midLength = length(obj.midLLRunoff.vals);
                         upLength =  length(obj.upLLRunoff.vals);
            
            % lowLength = length(obj.lowTBRunoff.vals);
            % midLength = length(obj.midTBRunoff.vals);
            % upLength =  length(obj.upTBRunoff.vals);
            
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
            
                         allVals =   [obj.lowLLRunoff.vals, obj.midLLRunoff.vals, ...
                             obj.upLLRunoff.vals];
            % allVals = [obj.lowTBRunoff.vals, obj.midTBRunoff.vals, ...
            %    obj.upTBRunoff.vals];
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
            legText = {'Precip', 'LL-LOW', 'LL-MID', 'LL-UP'};
            % legText = {'Precip', 'TB-LOW', 'TB-MID', 'TB-UP'};
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
        
        function calcRunoffRatio(obj)
            % The general equation to get the average runoff ratio is:
            % (tb1/tot + tb2/tot + tb3/tot) / 3
            % Sum precip and sum each runoff (up, mid, low) for each event
            obj.precipTotal=sum(obj.precipVals);
            sumOfRRs = obj.lowLLRunoff.getTotal();
            sumOfRRs = sumOfRRs + obj.midLLRunoff.getTotal();
            sumOfRRs = sumOfRRs + obj.upLLRunoff.getTotal();
            sumOfRRs = sumOfRRs + obj.lowTBRunoff.getTotal();
            sumOfRRs = sumOfRRs + obj.midTBRunoff.getTotal();
            sumOfRRs = sumOfRRs + obj.upTBRunoff.getTotal();
            
            obj.avgRR = sumOfRRs / (obj.precipTotal * 6);
            
            if strcmp(obj.site, 'MAT')
                celestinoTot = obj.addlPrecipTB.getTotal();
                if celestinoTot == 0
                    obj.avgRRAddl = 0; % IS THIS THE BEST ERROR CODE?
                else
                    obj.avgRRAddl = sumOfRRs / (celestinoTot * 6);
                end
            end
        end
        
        function calcPeakIntensity(obj)
            obj.peakIntensity = max(obj.precipVals);
        end
        
        function calcAvgIntensity(obj)
            % We've added some zeros to the start and end of the precipVals
            % vector. Need to remove those so they're not incorrectly
            % counted in the averaging.
            validIndices = (obj.precipTimes >= obj.startTime) & (obj.precipTimes <= obj.endTime);
            obj.avgIntensity = mean(obj.precipVals(validIndices));
        end
        
        function calcPeakAddlIntensity(obj)
            if strcmp(obj.site, 'MAT')
                obj.peakAddlIntensity = max(obj.addlPrecipTB.vals);
            end
        end
        
        function calcAvgAddlIntensity(obj)
            if strcmp(obj.site, 'MAT')
                % We've added some zeros to the start and end of the precipVals
                % vector. Need to remove those so they're not incorrectly
                % counted in the averaging.
                validIndices = (obj.addlPrecipTB.times >= obj.startTime) & (obj.addlPrecipTB.times <= obj.endTime);
                obj.avgAddlIntensity = mean(obj.addlPrecipTB.vals(validIndices));
            end
        end
        
        function calcAllStatistics(obj)
            obj.calcRunoffRatio();
            obj.calcPeakIntensity();
            obj.calcAvgIntensity();
            obj.calcPeakAddlIntensity();
            obj.calcAvgAddlIntensity();
        end
        
    end
end

