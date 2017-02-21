[MatPrecip_Times, MatPrecip_Precip, MatPrecip_RainfallRate] = importMATprecip('MAT_Precip_May22-July27_2016 - Sheet1.csv',2, 19120);
% Determine what folder this script is in, then save to the same folder
path = mfilename('fullpath');
[pathstr, ~, ~] = fileparts(path);
save(fullfile(pathstr, 'MAT_Precip.mat'), 'MatPrecip_Times', 'MatPrecip_Precip', 'MatPrecip_RainfallRate');   