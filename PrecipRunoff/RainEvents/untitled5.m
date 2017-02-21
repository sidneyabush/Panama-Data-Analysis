% Quick test to see how many of the events have at least one valid LL
% runoff event. 
Create_RainEvents
for i = 1:length(MAT_Events)
   if MAT_Events(i).atLeastOneLLRunoffValid
       disp(strcat(num2str(i), ' has a valid runoff'));
   end
end