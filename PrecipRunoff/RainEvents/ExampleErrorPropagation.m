%% Error propagation for Hydrological Processes Water Balance Paper
%John Knowles
%January 27, 2015

%% Forest Penman PET data
data=dlmread('Forest_PET_WY2008.csv');
data=dlmread('Forest_PET_WY2009.csv');
data=dlmread('Forest_PET_WY2010.csv');
data=dlmread('Forest_PET_WY2011.csv');
data=dlmread('Forest_PET_WY2012.csv');

% ID variables
DOY = data(:,1); % decimal day of year (MST)
Ta = data(:,2); % air temperature (deg C)
U = data(:,3); % wind speed (m s^-1)
D = data(:,4); % vapor pressure deficit (kPa)
G = data(:,5); % soil heat flux (W m^-2)
RH = data(:,6); % relative humidity
Rn = data(:,7); % net radiation (W m^-2)
P = data(:,8); % barometric pressure (kPa)
wy_DOY = data(:,9); % water year day of year 
es = SAT_VP(Ta); % saturation vapor pressure (kPa)
ea = es-D; % vapor pressure (kPa)
gamma = PSY_CONS(Ta,ea,P); % psychrometric constant
S = DS_DT(Ta); % slope of the saturation vaopr pressure v. temp curve
LHV = lambda(Ta); % latent heat of vaporization

% Generate Daily means over time 
[doy,day_Rn] = DAY_AVG(wy_DOY,Rn,1,366,Rn,2);
[doy,day_G] = DAY_AVG(wy_DOY,G,1,366,Rn,2);
[doy,day_U] = DAY_AVG(wy_DOY,U,1,366,Rn,2);
[doy,day_D] = DAY_AVG(wy_DOY,D,1,366,Rn,2);
[doy,day_S] = DAY_AVG(wy_DOY,S,1,366,Rn,2);
[doy,day_gamma] = DAY_AVG(wy_DOY,gamma,1,366,Rn,2);
[doy,day_lambda] = DAY_AVG(wy_DOY,LHV,1,366,Rn,2);

% Net radiation
syms S gamma Rn_err % turn applicable variables into symbolic variable
f = (S/(S + gamma))*Rn_err; %left side of the Penman equation (see Graham_Error_Propagation_Example.docx)
Rn_diff = diff(f,Rn_err); %take partial derivataive of f with respect to Rn
%answer = S/(S+gamma)

% Calculate net radiation error term
day_Rn = day_Rn*3600*24/10^6/2.45; %convert from W m^-2 to mm/day
Rn_err = day_Rn*0.03; %multiply variable(Rn) by the uncertainty (fraction) to get measurement uncertainty in W m^-2
Rn_uncert = (day_S./(day_S + day_gamma)).*Rn_err; %final uncertainty for Rn at a 0.5-hour timestep

% Soil heat flux
syms S gamma G_err
f = -(S/(S + gamma))*G_err;
G_diff = diff(f,G_err);
%answer = -S/(S+gamma)

% Calculate soil heat flux error term
day_G = day_G*3600*24/10^6/2.45/48; %convert from W m^-2 to mm/day
G_err = day_G*0.05;
G_uncert = -(day_S./(day_S+day_gamma)).*G_err;

% Wind speed (skipping the derivative step since this is done by Chris Graham in Graham_Error_Propagation_Example.docx
U_uncert = (day_gamma./(day_S+day_gamma)).*((0.536.*day_gamma.*day_D)./(day_lambda./(10.^6))).*0.0005;

% Vapor pressure deficit
D_err = day_D*0.02;
D_uncert = ((day_gamma./(day_S+day_gamma)).*((6.43.*(1+(0.536.*day_U)))./(day_lambda./(10.^6)))).*D_err;

% Propagate error from Rn, G, U, and D into PET
PET_err = sqrt((Rn_uncert.^2)+(G_uncert.^2)+(U_uncert.^2)+(D_uncert.^2));
PET_uncert = nansum(PET_err); %daily mean PET systematic measurement uncertainty (mm)

%% Penman equation
penman = (day_S./(day_S+day_gamma)).*(day_Rn-day_G)+(day_gamma./(day_S+day_gamma)).*(((6.43.*(1+(0.536.*day_U))).*day_D)./(day_lambda./(10.^6))); %delta, gamma, and lambda need to be calculated via equations in the handbook of hydrology for this to be accurate in mm

%% Tundra Penman PET data
data=dlmread('Tundra_PET_WY2008.csv');
data=dlmread('Tundra_PET_WY2009.csv');
data=dlmread('Tundra_PET_WY2010.csv');
data=dlmread('Tundra_PET_WY2011.csv');
data=dlmread('Tundra_PET_WY2012.csv');

% ID variables
DOY = data(:,1); % decimal day of year (MST)
U = data(:,2); % wind speed (m s^-1)
G = data(:,3); % soil heat flux (W m^-2)
Ta = data(:,4); % air temperature (deg C)
RH = data(:,5); % relative humidity
Rn = data(:,6); % net radiation (W m^-2)
es = data(:,7); % saturation vapor pressure (kPa)
ea = data(:,8); % vapor pressure (kPa)
D = data(:,9); % vapor pressure deficit (kPa)
P = data(:,10); % barometric pressure (kPa)
wy_DOY = data(:,11); % water year day of year 
gamma = PSY_CONS(Ta,ea,P); % psychrometric constant
S = DS_DT(Ta); % slope of the saturation vaopr pressure v. temp curve
LHV = lambda(Ta); % latent heat of vaporization

% Generate Daily means over time 
[doy,day_Rn] = DAY_AVG(wy_DOY,Rn,1,366,Rn,2);
[doy,day_G] = DAY_AVG(wy_DOY,G,1,366,Rn,2);
[doy,day_U] = DAY_AVG(wy_DOY,U,1,366,Rn,2);
[doy,day_D] = DAY_AVG(wy_DOY,D,1,366,Rn,2);
[doy,day_S] = DAY_AVG(wy_DOY,S,1,366,Rn,2);
[doy,day_gamma] = DAY_AVG(wy_DOY,gamma,1,366,Rn,2);
[doy,day_lambda] = DAY_AVG(wy_DOY,LHV,1,366,Rn,2);

% Calculate net radiation error term
day_Rn = day_Rn*3600*24/10^6/2.45; %convert from W m^-2 to mm/day
Rn_err = day_Rn*0.03; %multiply variable(Rn) by the uncertainty (fraction) to get measurement uncertainty in W m^-2
Rn_uncert = (day_S./(day_S + day_gamma)).*Rn_err; %final uncertainty for Rn at a 0.5-hour timestep

% Calculate soil heat flux error term
day_G = day_G*3600*24/10^6/2.45/48; %convert from W m^-2 to mm/day
G_err = day_G*0.05;
G_uncert = -(day_S./(day_S+day_gamma)).*G_err;

% Wind speed (skipping the derivative step since this is done by Chris Graham in Graham_Error_Propagation_Example.docx
U_uncert = (day_gamma./(day_S+day_gamma)).*((0.536.*day_gamma.*day_D)./(day_lambda./(10.^6))).*0.0005;

% Vapor pressure deficit
D_err = day_D*0.02;
D_uncert = ((day_gamma./(day_S+day_gamma)).*((6.43.*(1+(0.536.*day_U)))./(day_lambda./(10.^6)))).*D_err;

% Propagate error from Rn, G, U, and D into PET
PET_err = sqrt((Rn_uncert.^2)+(G_uncert.^2)+(U_uncert.^2)+(D_uncert.^2));
PET_uncert = nansum(PET_err); %annual PET systematic measurement uncertainty (mm)

%% Catchment PET uncertainty
%forest data
forest_data=dlmread('Forest_PET_WY2008.csv');
forest_data=dlmread('Forest_PET_WY2009.csv');
forest_data=dlmread('Forest_PET_WY2010.csv');
forest_data=dlmread('Forest_PET_WY2011.csv');
forest_data=dlmread('Forest_PET_WY2012.csv');
%tundra data
tundra_data=dlmread('Tundra_PET_WY2008.csv');
tundra_data=dlmread('Tundra_PET_WY2009.csv');
tundra_data=dlmread('Tundra_PET_WY2010.csv');
tundra_data=dlmread('Tundra_PET_WY2011.csv');
tundra_data=dlmread('Tundra_PET_WY2012.csv');

% ID forest variables
forest_DOY = forest_data(:,1); % decimal day of year (MST)
forest_Ta = forest_data(:,2); % air temperature (deg C)
forest_U = forest_data(:,3); % wind speed (m s^-1)
forest_D = forest_data(:,4); % vapor pressure deficit (kPa)
forest_G = forest_data(:,5); % soil heat flux (W m^-2)
forest_RH = forest_data(:,6); % relative humidity
forest_Rn = forest_data(:,7); % net radiation (W m^-2)
forest_P = forest_data(:,8); % barometric pressure (kPa)
forest_wy_DOY = forest_data(:,9); % water year day of year 
forest_es = SAT_VP(forest_Ta); % saturation vapor pressure (kPa)
forest_ea = forest_es-forest_D; % vapor pressure (kPa)
forest_gamma = PSY_CONS(forest_Ta,forest_ea,forest_P); % psychrometric constant
forest_S = DS_DT(forest_Ta); % slope of the saturation vaopr pressure v. temp curve
forest_LHV = lambda(forest_Ta); % latent heat of vaporization

% ID tundra variables
tundra_DOY = tundra_data(:,1); % decimal day of year (MST)
tundra_U = tundra_data(:,2); % wind speed (m s^-1)
tundra_G = tundra_data(:,3); % soil heat flux (W m^-2)
tundra_Ta = tundra_data(:,4); % air temperature (deg C)
tundra_RH = tundra_data(:,5); % relative humidity
tundra_Rn = tundra_data(:,6); % net radiation (W m^-2)
tundra_es = tundra_data(:,7); % saturation vapor pressure (kPa)
tundra_ea = tundra_data(:,8); % vapor pressure (kPa)
tundra_D = tundra_data(:,9); % vapor pressure deficit (kPa)
tundra_P = tundra_data(:,10); % barometric pressure (kPa)
tundra_wy_DOY = tundra_data(:,11); % water year day of year 
tundra_gamma = PSY_CONS(tundra_Ta,tundra_ea,tundra_P); % psychrometric constant
tundra_S = DS_DT(tundra_Ta); % slope of the saturation vaopr pressure v. temp curve
tundra_LHV = lambda(tundra_Ta); % latent heat of vaporization

% Generate Daily means over time 
%Forest
[doy,forest_day_Rn] = DAY_AVG(forest_wy_DOY,forest_Rn,1,366,forest_Rn,2);
[doy,forest_day_G] = DAY_AVG(forest_wy_DOY,forest_G,1,366,forest_Rn,2);
[doy,forest_day_U] = DAY_AVG(forest_wy_DOY,forest_U,1,366,forest_Rn,2);
[doy,forest_day_D] = DAY_AVG(forest_wy_DOY,forest_D,1,366,forest_Rn,2);
[doy,forest_day_S] = DAY_AVG(forest_wy_DOY,forest_S,1,366,forest_Rn,2);
[doy,forest_day_gamma] = DAY_AVG(forest_wy_DOY,forest_gamma,1,366,forest_Rn,2);
[doy,forest_day_lambda] = DAY_AVG(forest_wy_DOY,forest_LHV,1,366,forest_Rn,2);
%Tundra
[doy,tundra_day_Rn] = DAY_AVG(tundra_wy_DOY,tundra_Rn,1,366,tundra_Rn,2);
[doy,tundra_day_G] = DAY_AVG(tundra_wy_DOY,tundra_G,1,366,tundra_Rn,2);
[doy,tundra_day_U] = DAY_AVG(tundra_wy_DOY,tundra_U,1,366,tundra_Rn,2);
[doy,tundra_day_D] = DAY_AVG(tundra_wy_DOY,tundra_D,1,366,tundra_Rn,2);
[doy,tundra_day_S] = DAY_AVG(tundra_wy_DOY,tundra_S,1,366,tundra_Rn,2);
[doy,tundra_day_gamma] = DAY_AVG(tundra_wy_DOY,tundra_gamma,1,366,tundra_Rn,2);
[doy,tundra_day_lambda] = DAY_AVG(tundra_wy_DOY,tundra_LHV,1,366,tundra_Rn,2);

%FOREST
% Calculate net radiation error term
forest_day_Rn = forest_day_Rn*3600*24/10^6/2.45; %convert from W m^-2 to mm/day
forest_Rn_err = forest_day_Rn*0.03; %multiply variable(Rn) by the uncertainty (fraction) to get measurement uncertainty in W m^-2
forest_Rn_uncert = (forest_day_S./(forest_day_S + forest_day_gamma)).*forest_Rn_err; %final uncertainty for Rn at a 0.5-hour timestep

% Calculate soil heat flux error term
forest_day_G = forest_day_G*3600*24/10^6/2.45/48; %convert from W m^-2 to mm/day
forest_G_err = forest_day_G*0.05;
forest_G_uncert = -(forest_day_S./(forest_day_S+forest_day_gamma)).*forest_G_err;

% Wind speed (skipping the derivative step since this is done by Chris Graham in Graham_Error_Propagation_Example.docx
forest_U_uncert = (forest_day_gamma./(forest_day_S+forest_day_gamma)).*((0.536.*forest_day_gamma.*forest_day_D)./(forest_day_lambda./(10.^6))).*0.0005;

% Vapor pressure deficit
forest_D_err = forest_day_D*0.02;
forest_D_uncert = ((forest_day_gamma./(forest_day_S+forest_day_gamma)).*((6.43.*(1+(0.536.*forest_day_U)))./(forest_day_lambda./(10.^6)))).*forest_D_err;

%TUNDRA
% Calculate net radiation error term
tundra_day_Rn = tundra_day_Rn*3600*24/10^6/2.45; %convert from W m^-2 to mm/day
tundra_Rn_err = tundra_day_Rn*0.03; %multiply variable(Rn) by the uncertainty (fraction) to get measurement uncertainty in W m^-2
tundra_Rn_uncert = (tundra_day_S./(tundra_day_S + tundra_day_gamma)).*tundra_Rn_err; %final uncertainty for Rn at a 0.5-hour timestep

% Calculate soil heat flux error term
tundra_day_G = tundra_day_G*3600*24/10^6/2.45/48; %convert from W m^-2 to mm/day
tundra_G_err = tundra_day_G*0.05;
tundra_G_uncert = -(tundra_day_S./(tundra_day_S+tundra_day_gamma)).*tundra_G_err;

% Wind speed (skipping the derivative step since this is done by Chris Graham in Graham_Error_Propagation_Example.docx
tundra_U_uncert = (tundra_day_gamma./(tundra_day_S+tundra_day_gamma)).*((0.536.*tundra_day_gamma.*tundra_day_D)./(tundra_day_lambda./(10.^6))).*0.0005;

% Vapor pressure deficit
tundra_D_err = tundra_day_D*0.02;
tundra_D_uncert = ((tundra_day_gamma./(tundra_day_S+tundra_day_gamma)).*((6.43.*(1+(0.536.*tundra_day_U)))./(tundra_day_lambda./(10.^6)))).*tundra_D_err;

%% Propagate error from forest and tundra Rn, G, U, and D into catchmnet PET
catchment_PET_err = sqrt((forest_Rn_uncert.^2)+(forest_G_uncert.^2)+(forest_U_uncert.^2)+(forest_D_uncert.^2)+(tundra_Rn_uncert.^2)+(tundra_G_uncert.^2)+(tundra_U_uncert.^2)+(tundra_D_uncert.^2));
catchment_PET_uncert = nansum(catchment_PET_err); %annual PET systematic measurement uncertainty (mm)

%% Forest precipitation 
LTER = dlmread('C1_LTER_precip_WY2008.csv'); % 2008 uncert = 27.1 mm
LTER = dlmread('C1_LTER_precip_WY2009.csv'); % 2009 uncert = 24.1 mm
LTER = dlmread('C1_LTER_precip_WY2010.csv'); % 2010 uncert = 24.5 mm
LTER = dlmread('C1_LTER_precip_WY2011.csv'); % 2011 uncert = 31.0 mm
LTER = dlmread('C1_LTER_precip_WY2012.csv'); % 2012 uncert = 25.2 mm

SNOTEL = dlmread('SNOTEL_precip_WY2008.csv');
SNOTEL = dlmread('SNOTEL_precip_WY2009.csv');
SNOTEL = dlmread('SNOTEL_precip_WY2010.csv');
SNOTEL = dlmread('SNOTEL_precip_WY2011.csv');
SNOTEL = dlmread('SNOTEL_precip_WY2012.csv');

USCRN = dlmread('USCRN_precip_WY2008.csv');
USCRN = dlmread('USCRN_precip_WY2009.csv');
USCRN = dlmread('USCRN_precip_WY2010.csv');
USCRN = dlmread('USCRN_precip_WY2011.csv');
USCRN = dlmread('USCRN_precip_WY2012.csv');

% Calculate LTER error term
LTER_err = LTER*0.02;

% Calculate SNOTEL error term
SNOTEL_err = SNOTEL*0.025;

% Calculate USCRN error term
USCRN = USCRN*25.4; % convert inches to mm
USCRN_err = USCRN*0.001;

% Propagate error from LTER, SNOTEL, and USCRN gages into C1 precipitation
C1_precip_err = sqrt((LTER_err.^2)+(SNOTEL_err.^2)+(USCRN_err.^2));
C1_precip_uncert = nansum(C1_precip_err); %annual systematic precipitation measurement uncertainty (mm)

