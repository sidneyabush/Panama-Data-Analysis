% Plot the runoff rate versus the rainfall rate

% Calculate what 0.2mm of precip as measured by the rain gauge equates to
% in terms of mm precip that fell on the runoff plot
areaRunoff = 156850; 
diameterRainGauge = 153.924;
areaRainGauge = pi*(diameterRainGauge/2)^2;
mmRunoff = 0.2 * areaRainGauge/areaRunoff;

% import 
