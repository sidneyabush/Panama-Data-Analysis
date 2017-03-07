% Imports a single soil moisture file and plots. Just exploring the data.
%% Import the file. 
[TIMESTAMP,RECORD,SEVolt,SEVolt2,SEVolt3,SEVolt4,SEVolt5,SEVolt6,SEVolt7,...
 SEVolt8,SEVolt9,SEVolt10,SEVolt11,SEVolt12] = ...
 importSMFile('3755SM_Raw1.csv',5, 28512);

%% Clean data a bit. 
% Concatenate voltage columns into a matrix. 
disp(['There are: ' num2str(sum(isnan(SEVolt11))) ' NAN values in SEVolt11']);
allVolts = [SEVolt, SEVolt2, SEVolt3, SEVolt4, SEVolt5, SEVolt6, SEVolt7,...
    SEVolt8, SEVolt9, SEVolt10, SEVolt11, SEVolt12];
% Replace any NANs in the voltage matrix with 0s. 
allVolts(isnan(allVolts)) = 0;
disp(['There are: ' num2str(sum(isnan(allVolts(:,11)))) ' NAN values in SEVolt11']);

%% Plot it. 
plot(TIMESTAMP, allVolts);
legend({'SEVolt', 'SEVolt2', 'SEVolt3', 'SEVolt4', 'SEVolt5', 'SEVolt6', 'SEVolt7',...
    'SEVolt8', 'SEVolt9', 'SEVolt10', 'SEVolt11', 'SEVolt12'}, 'Location', 'southwest');