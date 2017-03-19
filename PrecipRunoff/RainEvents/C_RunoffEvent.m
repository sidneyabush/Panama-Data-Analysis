classdef C_RunoffEvent < handle
    properties
        type          % LL or TB
        site          % MAT or PAS
        position      % UP, MID, LOW
        times
        vals
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
            obj.totalRunoff = NaN;
            obj.runoffRatio = NaN;
            obj.preceedingLLHeight = NaN;
            % Assume a minimum volume of 5L for LL data to be valid.
            obj.minLLHeight = calcMinValidLLHeight(5);
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
        
        function [legendText] = plotEvent(obj, figHandle, lineColor)
            % Take the handle to the figure that was passed in and make it the current figure
            figure(figHandle);
            hold on
            % Add this events data to the existing plot.
            if strcmp(obj.type, 'TB')
                plot(obj.times, obj.vals, '-.', 'Color', lineColor,'LineWidth',2);
            else
                plot(obj.times, obj.vals, 'Color', lineColor,'LineWidth',2);
            end
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