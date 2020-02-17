classdef C_RunoffEvent < handle
    properties
        type          % LL or TB
        site          % MAT or PAS
        position      % UP, MID, LOW
        times
        vals
        valsModified;   % Modified copy of the values.
        valsShift;      % How much to shift the values relative to default.
        valsZeroed;     % Logical indicating values (post shift) that have been set to zero.
        totalRunoff
        totalRunoffModified;
        runoffRatio
        preceedingLLHeight
        minLLHeight
    end

    methods
        function obj = C_RunoffEvent(position, type)
            obj.position = position;
            obj.type = type;
            obj.site = '';
            obj.times = [];
            obj.vals = [];
            obj.valsShift = 0;
            obj.totalRunoff = NaN;
            obj.totalRunoffModified = NaN;
            obj.runoffRatio = NaN;
            obj.preceedingLLHeight = NaN;
            % Assume a minimum volume of 5L for LL data to be valid.
            obj.minLLHeight = calcMinValidLLHeight(5);
        end

        function initModifiedVals(obj)
            obj.valsModified = obj.vals;
            % Right now no measurements have been zeroed.
            obj.valsZeroed = zeros(length(obj.vals), 1);
        end

        function total = getTotal(obj, mod)
            if strcmpi(mod, 'mod')
                obj.totalRunoffModified = sum(obj.valsModified);
                total = obj.totalRunoffModified;
            elseif strcmpi(mod, 'orig')
                obj.totalRunoff = sum(obj.vals);
                total = obj.totalRunoff;
            end
        end

        function [validRunVals, validRunTimes] = getValidTimesAndRunVals(obj, startTime, endTime)
            % Need to account for the possible shift modification of vals.
            runoff = C_RainEvent.shiftVals(obj.valsModified, obj.valsShift);
            validIndices = (obj.times >= startTime) & (obj.times <= endTime);
            validRunVals = runoff(validIndices);
            validRunTimes = obj.times(validIndices);

            % Debugging: Make some noise if this event was modified
            doDebug = false;
            if doDebug
                if obj.valsShift ~= 0
                    disp(['Vals Shift: ' num2str(obj.valsShift)]);
                end
                anyValsModified = any(obj.vals - obj.valsModified);
                if anyValsModified
                    disp(['Vals Original and Modified:']);
                    [obj.vals obj.valsModified]
                end
            end  % doDebug

        end

        function isValid = isLLHeightValid(obj)
            if strcmp(obj.type, 'LL') && obj.preceedingLLHeight > obj.minLLHeight
                isValid = true;
            else
                isValid = false;
            end
        end

        function [peakRunTime, peakRunRate_MMperHr] = getPeakRunTimeAndRate(obj, startTime, endTime)
            [runVals, runTimes] = obj.getValidTimesAndRunVals(startTime, endTime);
            [peakRunRate_MMper10Min, maxIdx] = max(runVals);
            % Convert to mm/hr from mm/10min.
            peakRunRate_MMperHr = peakRunRate_MMper10Min * 6;
            if peakRunRate_MMperHr == 0
                peakRunTime = NaT;
            else
                peakRunTime = runTimes(maxIdx);          
            end
        end

        function [timeOfFirstRunoff] = getFirstRunoffTime(obj, startTime, endTime)
            [runVals, runTimes] = obj.getValidTimesAndRunVals(startTime, endTime);
            firstIdx = find(runVals > 0, 1);
            if isempty(firstIdx)
                timeOfFirstRunoff = NaT;
            else
                timeOfFirstRunoff = runTimes(firstIdx);
            end
        end

        function [legendText] = plotEvent(obj, figHandle, origOrMod, lineColor)
            % Take the handle to the figure that was passed in and make it the current figure
            figure(figHandle);
            hold on
            % Choose whether we'll plot the original or modified runoff.
            if strcmpi(origOrMod, 'orig')
                runoff = obj.vals;
            elseif strcmpi(origOrMod, 'mod')
                % Take into account the data shift.
                runoff = C_RainEvent.shiftVals(obj.valsModified, obj.valsShift);
            end
            % Add this events data to the existing plot.
            if strcmp(obj.type, 'TB')
                lineType = '-.';
            else
                lineType = '-';
            end
            plot(obj.times, runoff, lineType, 'Color', lineColor,'LineWidth',2);
            % Generate a string (eg. LL_LOW) that will identify this on the
            % plot. If LL type, also includes preceeding height.
            legendText = strcat(obj.type, '-', obj.position);
            % Uncomment to add back in the "Valid" LL height warning.
            %             if strcmp(obj.type, 'LL')
            %                 if obj.preceedingLLHeight > obj.minLLHeight
            %                     validText = ' - VALID';
            %                 else
            %                     validText = ' - INVALID';
            %                 end
            %                 legendText = strcat(legendText, ' - ', num2str(obj.preceedingLLHeight), validText);
            %             end
        end

        function plotBar(obj, figHandle)

        end
    end

end
