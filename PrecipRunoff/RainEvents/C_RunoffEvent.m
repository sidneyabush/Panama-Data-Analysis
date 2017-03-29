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
        
        function total = getTotal(obj)
            obj.totalRunoff = sum(obj.vals);
            total = obj.totalRunoff;
        end
        
        function isValid = isLLHeightValid(obj)
            if strcmp(obj.type, 'LL') && obj.preceedingLLHeight > obj.minLLHeight
                isValid = true;
            else
                isValid = false;
            end
        end
        
        function [legendText] = plotEvent(obj, figHandle, origOrMod, lineColor)
            % Take the handle to the figure that was passed in and make it the current figure
            figure(figHandle);
            hold on
            % Choose whether we'll plot the original or modified runoff.
            if strcmpi(origOrMod, 'original')
                runoff = obj.vals;
            elseif strcmpi(origOrMod, 'modified')
                % Take into account the data shift.
                runoff = obj.valsModified;
                if obj.valsShift > 0
                    runoff = [zeros(obj.valsShift, 1); runoff(1:(end-obj.valsShift))];
                elseif obj.valsShift < 0
                    runoff = [runoff((-1 * obj.valsShift+ 1):end); zeros(-1 * obj.valsShift, 1)];
                end
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