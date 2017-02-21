%% Import Forest Lower Level Logger Data

[Scans2,CombinedDatetime_ForLow,heightmmchange_ForLow,RunoffRatemmhr_ForLow] = importForLow_LL_Runoff('FORESTLOWER_LL_Runoff.csv',6, 9479);


minimumvalidchangeheight= 0.2;
minimumvalidchangerate = minimumvalidchangeheight*6;

heightmmchange_ForLow(heightmmchange_ForLow< minimumvalidchangeheight)=0; 
RunoffRatemmhr_ForLow(RunoffRatemmhr_ForLow< minimumvalidchangerate)=0;

