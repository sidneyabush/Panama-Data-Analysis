% Goal: Create a 
% Create times at which precise volume measurements were made
% Create vector of precise volume measurements
% Plot measured value against precise volume measurement

sampleHeights = 50:5:305;
% Determine the formula for the volume of the bucket - it's a section of a
% cone
upperRadius = 14.3665;
lowerRadius = 12.7;
bucketHeight = 35.877;

% Volume of bucket = volume of entire cone (bucket is top half) minus
% volume of the cone that's not actually attached to the bottom of the
% bucket. Cone volume = pi*r^2*height/3
bottomConeHeight = 273.41;
bottomConeVolume = pi*(lowerRadius^2)/3*bottomConeHeight;

totalConeVolume = pi*(upperRadius^2)/3*(bottomConeHeight+sampleHeights);

bucketVolume = totalConeVolume - bottomConeVolume;
bucketVolume = bucketVolume/1000;