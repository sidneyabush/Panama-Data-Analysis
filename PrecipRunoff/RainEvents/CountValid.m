Create_RainEvents;
numInvalidMAT = 0;
numInvalidPAS = 0;
numValidMAT = 0;
numValidPAS = 0;
for i = 1:length(MAT_Events)
    if  MAT_Events(i).atLeastOneLLRunoffValid
        numValidMAT = numValidMAT + 1;
    else
        numInvalidMAT = numInvalidMAT + 1;
    end
end

for i = 1:length(PAS_Events)
    if  PAS_Events(i).atLeastOneLLRunoffValid
        numValidPAS = numValidPAS + 1;
    else
        numInvalidPAS = numInvalidPAS + 1;
    end
end
