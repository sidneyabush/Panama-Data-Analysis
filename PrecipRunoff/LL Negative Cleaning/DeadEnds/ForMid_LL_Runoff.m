%% Import Forest Middle Level Logger Runoff

[Scans1,CombinedDatetime_ForMid,heightmmchange_ForMid,RunoffRatemmhr_ForMid] = importForMid_LL_Runoff('FORESTMIDDLE_LL_Runoff.csv',6, 9616);


minimumvalidchangeheight= 0.2;
minimumvalidchangerate = minimumvalidchangeheight*6;

heightmmchange_ForMid(heightmmchange_ForMid< minimumvalidchangeheight)=0; 
RunoffRatemmhr_ForMid(RunoffRatemmhr_ForMid< minimumvalidchangerate)=0;