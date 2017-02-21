% This is an example to demonstrate using the new LL and TB data formats. 
LLFile = 'LL Negative Cleaning/CleanedData/allLL.mat';
load(LLFile);
TBFile = 'TippingBucketCleaning/CleanedData/allTB.mat';
load(TBFile);

plot(allLL.forLowLL.timeStamp, allLL.forLowLL.heightMM, allTB.MAT_TimeStamp_10min, allTB.MAT_TBRunoff_Low_10min);
hold on
plot(allTB.MAT_TimeStamp_10min, allTB.MAT_Precip_10min);
legend('Mat Low Height MM', 'Mat Low Runoff','MAT Precip');