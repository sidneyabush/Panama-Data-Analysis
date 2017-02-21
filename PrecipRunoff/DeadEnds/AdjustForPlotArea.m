% We want to know what depth of rainfall corresponds to one tip of the
% tipping bucket. The area of the plot is different than the area of the tipping bucket
% opening. So, we need to scale our measurements to get the correct depth
% in mm. 

% Set up our assumptions/dimensions (mm). 
areaPlot = 156850;
diamTippingBucket = 154; 
areaTippingBucket = pi * (diamTippingBucket/2)^2; 
depthTippingBucket = 0.2;

% We know that the volume of water in each tip of the bucket is constant,
% no matter whether you collect that over a big area (the plot) or a small
% area (the tipping bucket opening). So we calculate that volume: 
volume = areaTippingBucket * depthTippingBucket; 
% And then determine what depth of rainfall would fill one tips volume when
% collected over the area of the entire plot: 
depthPlot = volume/areaPlot; 

display(['The depth of rain across the whole plot for one tip is: ' num2str(depthPlot)]);

% Find a constant that we can multiply the tipping bucket depth by to get
% the correct depth. We know that a depth of 0.2 for the tipping bucket
% should correspond to a depth of "depthPlot". 
% depthTippingBucket * conversionFactor = depthPlot. 
conversionFactor = depthPlot / depthTippingBucket; 

display(['We should multiply the tipping bucket depth by: ' num2str(conversionFactor) ' to get the correct depth for the plot.']);
