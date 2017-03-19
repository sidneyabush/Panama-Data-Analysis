classdef C_RainEvent < handle
    properties
        site;
        startTime;
        endTime;
        LLValid;
        precipTotal;
        precipTimes;
        precipVals;
        llTimes;
        llVals;
        legendText;
        atLeastOneLLRunoffValid;
        
        lowLLRunoff;
        midLLRunoff;
        upLLRunoff;
        
        lowTBRunoff;
        midTBRunoff;
        upTBRunoff;
        
        addlPrecipTB;
        
        tbValid;
        avRunoffRatioTB = NaN;
        
    end
    methods
        function obj = C_RainEvent(site)
            obj.site = site;
            
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
        end
        
        function handle = plotEvent(obj)
            figHandle = figure;
            plot(obj.precipTimes,obj.precipVals, '--', 'LineWidth', 3);
            % Clear out the legend in case it already exists.
            obj.legendText = {};
            obj.legendText{1} = 'Precip';
            % Save the current color scheme so we can match line colors.
            cmap = colormap(lines);
            hold on
            
            % Plot the runoff events. Uncomment to add to plot.
%             obj.legendText{end+1} = obj.lowLLRunoff.plotEvent(figHandle, cmap(2,:));
%             obj.legendText{end+1} = obj.midLLRunoff.plotEvent(figHandle, cmap(3,:));
%             obj.legendText{end+1} = obj.upLLRunoff.plotEvent(figHandle, cmap(4,:));
            obj.legendText{end+1} = obj.lowTBRunoff.plotEvent(figHandle, cmap(2,:));
            obj.legendText{end+1} = obj.midTBRunoff.plotEvent(figHandle, cmap(3,:));
            obj.legendText{end+1} = obj.upTBRunoff.plotEvent(figHandle, cmap(4,:));
            obj.legendText{end+1} = obj.addlPrecipTB.plotEvent(figHandle, cmap(5,:));
            
            title([obj.site '  Event: ' datestr(obj.startTime) '-' datestr(obj.endTime)])
            legend(obj.legendText);
            
            if ~isnan(obj.avRunoffRatioTB)
                text(obj.startTime,0.8*max(obj.precipVals),['Avg. Runoff Ratio: ' num2str(obj.avRunoffRatioTB)]);
            end
            
            hold off
            handle = figHandle;
        end
        
        function handle = plotLineAndBar(obj)
            obj.plotEvent();
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
%             lowLength = length(obj.lowLLRunoff.vals);
%             midLength = length(obj.midLLRunoff.vals);
%             upLength =  length(obj.upLLRunoff.vals);
            
            lowLength = length(obj.lowTBRunoff.vals);
            midLength = length(obj.midTBRunoff.vals);
            upLength =  length(obj.upTBRunoff.vals);
            
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
            
%             allVals =   [obj.lowLLRunoff.vals, obj.midLLRunoff.vals, ...
%                 obj.upLLRunoff.vals];
            allVals = [obj.lowTBRunoff.vals, obj.midTBRunoff.vals, ...
                obj.upTBRunoff.vals];
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
            %legText = {'Precip', 'LL-LOW', 'LL-MID', 'LL-UP'};
            legText = {'Precip', 'TB-LOW', 'TB-MID', 'TB-UP'};
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
        end
        
        % %     Doesn't work yet, changed the underlying data structure.
        function calcRunoffRatio(obj)
            % Sum precip and sum each runoff (up, mid, low) for each event
            obj.precipTotal=sum(obj.precipVals);
            obj.lowLLRunoff.getTotal();
            obj.midLLRunoff.getTotal();
            obj.upLLRunoff.getTotal();
            
            
            
            % Divide Runoff Totals for each TB runoff by precip total for each
            % event
            obj.upRunoffTBRatio=(obj.upRunoffTBTotal/obj.precipTotal);
            if obj.upRunoffTBRatio == inf
                obj.upRunoffTBRatio = 0;
            end
            obj.midRunoffTBRatio=(obj.midRunoffTBTotal/obj.precipTotal);
            if obj.midRunoffTBRatio == inf
                obj.midRunoffTBRatio = 0;
            end
            obj.lowRunoffTBRatio=(obj.lowRunoffTBTotal/obj.precipTotal);
            if obj.lowRunoffTBRatio == inf
                obj.lowRunoffTBRatio = 0;
            end
            % Calculate Average TB Runoff Ratio for each event
            obj.avRunoffRatioTB=mean([obj.upRunoffTBRatio, obj.midRunoffTBRatio,obj.lowRunoffTBRatio]);
        end
        
    end
end

