% Simple script to quickly plot the SM data.
% Import the MAT data.
[TIMESTAMP1,T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4] = importSMFile('MAT_SM_May23_July27_2016.csv',5, 6240);

figure; 
plot(TIMESTAMP1, [T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4]);
legend({'T1','T2','T3','T4','M1','M2','M3','M4','B1','B2','B3','B4'});

figure
bar(TIMESTAMP1, [T1,T2,T3,T4,M1,M2,M3,M4,B1,B2,B3,B4]);
legend({'T1','T2','T3','T4','M1','M2','M3','M4','B1','B2','B3','B4'});
