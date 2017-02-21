%% Import 10 minute Forest Upper Runoff (heightmmchange), 10 minute rainfall (total)
% Import Forest Upper Runoff (heightmmchange)
ForestUpper_LL_Runoff

% Import 10 minute rainfall MAT
Convert_Rainfall_MAT_PAS_To_10min

% plot 10 minute forest upper runoff & 10 min rainfall vs. time
plot(tenminutetime_MAT, tenminutetotal_MAT);
hold on
plot(CombinedDatetime, heightmmchange);
legend('Rainfall','ForestUpperRunoff')
ylabel('Rainfall/Runoff (mm/hr)')
xlabel('Time')