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
        
        tbValid;
        avRunoffRatioTB = NaN;
        
    end
    methods
        function obj = C_RainEvent(site)
            obj.site = site;
            
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
            
            obj.legendText{end+1} = obj.lowLLRunoff.plotEvent(figHandle, cmap(2,:));
            obj.legendText{end+1} = obj.midLLRunoff.plotEvent(figHandle, cmap(3,:));
            obj.legendText{end+1} = obj.upLLRunoff.plotEvent(figHandle, cmap(4,:));
            obj.legendText{end+1} = obj.lowTBRunoff.plotEvent(figHandle, cmap(2,:));
            obj.legendText{end+1} = obj.midTBRunoff.plotEvent(figHandle, cmap(3,:));
            obj.legendText{end+1} = obj.upTBRunoff.plotEvent(figHandle, cmap(4,:));
            
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
            % Stitch the four value columns together.
            %             allVals = [obj.precipVals, obj.lowLLRunoff.vals,...
            %                        obj.midLLRunoff.vals, obj.upLLRunoff.vals];
            % Plot the precip bars
            handle = bar(obj.precipTimes, obj.precipVals, 0.75);
            % Store the colormap values to use with other bars.
            cmap = colormap(lines);
            
            % Check to make sure all the runoffs have the same # of points
            lowLength = length(obj.lowLLRunoff.vals);
            midLength = length(obj.midLLRunoff.vals);
            upLength =  length(obj.upLLRunoff.vals);
            if(any(diff([lowLength, midLength, upLength])))
                text(obj.startTime,0.8*max(obj.precipVals),'Error with Runoff Plotting.');
                legend('Precip');
                return;
            end
            
            allVals =   [obj.lowLLRunoff.vals, obj.midLLRunoff.vals, ...
                obj.upLLRunoff.vals];
            % Plot LL bars inside precip bars.
            hold on;
            handle = bar(obj.precipTimes, allVals, 0.75);
            %             handle(1).FaceColor = 'r';
            %             handle(2).FaceColor = 'g';
            %             handle(3).FaceColor = 'c';
            for i = 1:length(handle)
                % Don't plot the first bar with the same color as the
                % precip
                handle(i).FaceColor = cmap(i+1,:);
                handle(i).EdgeColor = handle(i).FaceColor;
            end
            hold off;
            legend('Precip', 'LL-LOW', 'LL-MID', 'LL-UP');
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
            obj.upRunoffTBTotal=sum(obj.upRunoffTB);
            obj.midRunoffTBTotal=sum(obj.midRunoffTB);
            obj.lowRunoffTBTotal=sum(obj.lowRunoffTB);
            
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

