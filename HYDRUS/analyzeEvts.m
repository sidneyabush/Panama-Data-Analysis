% Imports hydrus data and uses it to calculate runoff ratios.
% Import runoff (in mm/min).
% First: PAS_EVENT_56
[hydTime, hydRunoff] = importOutFile('RawData/T_Level_PAS56.out');
duration = [0; diff(hydTime)];
runoffMM = duration .* hydRunoff;
totalRunoffMM = sum(runoffMM);

pas56PrecipMM = 10.6;
rr = totalRunoffMM / pas56PrecipMM;
disp(['Runoff ratio for Hydrus/ PAS_56: ' num2str(rr)]);

% Trying with my soil characteristics (My BD and Ks)
[hydTime, hydRunoff] = importOutFile('RawData/T_Level_PAS56_mysoil.out');
duration = [0; diff(hydTime)];
runoffMM = duration .* hydRunoff;
totalRunoffMM = sum(runoffMM);

pas56_PrecipMM = 10.6;
rr = totalRunoffMM / pas56PrecipMM;
disp(['Runoff ratio for Hydrus/ PAS_56_mysoil: ' num2str(rr)]);
% hassler
[hydTime, hydRunoff] = importOutFile('RawData/T_Level_PAS56_hassler.out');
duration = [0; diff(hydTime)];
runoffMM = duration .* hydRunoff;
totalRunoffMM = sum(runoffMM);

pas56PrecipMM = 10.6;
rr = totalRunoffMM / pas56PrecipMM;
disp(['Runoff ratio for Hydrus/ PAS_56_hassler: ' num2str(rr)]);


% Second: MAT_EVENT_40
[hydTime, hydRunoff] = importOutFile('RawData/T_Level_MAT40.out');
duration = [0; diff(hydTime)];
runoffMM = duration .* hydRunoff;
totalRunoffMM = sum(runoffMM);

mat40PrecipMM = 5;
rr = totalRunoffMM / mat40PrecipMM;
disp(['Runoff ratio for Hydrus/ MAT_40: ' num2str(rr)]);

% try with mysoil data
[hydTime, hydRunoff] = importOutFile('RawData/T_Level_MAT40_mysoil.out');
duration = [0; diff(hydTime)];
runoffMM = duration .* hydRunoff;
totalRunoffMM = sum(runoffMM);

mat40_PrecipMM = 5;
rr = totalRunoffMM / mat40PrecipMM;
disp(['Runoff ratio for Hydrus/ MAT_40_mysoil: ' num2str(rr)]);
