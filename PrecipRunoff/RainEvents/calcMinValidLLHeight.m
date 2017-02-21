function minCorrectedHeight = calcMinValidLLHeight(volumeL)
    % Multiply volumes by 1000 to get cm^3 rather than L
    volumeCM = volumeL * 1000;
    % Divide by area of plot to return a height in cm. 
    plotAreaCM = 1568.5; 
    minHeightCM = volumeCM / plotAreaCM;
    % Multiply by 10 to get height in mm. 
    minCorrectedHeight = minHeightCM * 10; 
end