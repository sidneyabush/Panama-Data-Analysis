% Stores information about infiltration during a rain event. 
classdef C_InfiltrationEvent < handle
    properties
        type;     % LL or TB (only expecting to use LL at this point)
        position; % UP, MID or LOW
        times;    % Timestamps, will be copied from the runoff when created
        vals;     % Values at each timestamp
    end

    methods
        function [ obj ] = C_InfiltrationEvent(position, type)
            obj.position = position;
            obj.type = type;
            obj.times = [];
            obj.vals = [];
        end  % C_InfiltrationEvent
    end
end
