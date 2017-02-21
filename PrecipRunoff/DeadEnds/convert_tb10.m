function [ tentime, tenvalue ] = convert_tb10( time, value )
%converts tipping bucket runoff data to ten minute resolution
% no

% If there are an odd number of points, we won't be able to add the last 5
% minute point to any other point to get 10 minutes of data. So cut off the
% last point in this case. 
isodd= mod(length(time),2);
if isodd
   time(end)=[];
end
tentime =[];
tenvalue = [];

for i= 1:2:length(time)
%   Totals can simply be added
    tenvalue = [tenvalue; value(i) + value(i+1)];
%   Just take the first of the two times
    tentime = [tentime; time(i)];
end

end

