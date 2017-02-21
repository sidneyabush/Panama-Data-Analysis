[PasPrecip_Times, PasPrecip_Precip, PasPrecip_RainfallRate] = importPASPrecip2('PAS_Precip_May22-July27_2016 - Sheet1.csv',2, 19153);
% Determine what folder this script is in, then save to the same folder
path = mfilename('fullpath');
[pathstr, ~, ~] = fileparts(path);
save(fullfile(pathstr, 'PAS_Precip.mat'), 'PasPrecip_Times', 'PasPrecip_Precip', 'PasPrecip_RainfallRate');