a = [1 2 3]';
b = [4 5 6]';
c = [7 8]';

try 
    c = [a b c]
    
catch ME
	if (strcmp(ME.identifier, 'MATLAB:catenate:dimensionMismatch'))
        runoffSizeErr = true; 
    end
end