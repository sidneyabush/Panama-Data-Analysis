%% Import

[Scans,CombinedDatetime_ForUp,heightmmchange_ForUp,RunoffRatemmhr] = importForestUPPER_LL_Runoff('FORESTUPPER_LL_Runoff.csv',2, 9462);

minimumvalidchangeheight= 0.2;
minimumvalidchangerate = minimumvalidchangeheight*6;

heightmmchange_ForUp(heightmmchange_ForUp< minimumvalidchangeheight)=0; 
RunoffRatemmhr(RunoffRatemmhr< minimumvalidchangerate)=0;

