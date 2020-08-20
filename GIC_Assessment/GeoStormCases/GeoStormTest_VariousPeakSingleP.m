% === GeoStormTest_VariousPeakSingleP() ===

%% Static
FieldName = 'GeoStormTest_60N_VariousPeakSingleP_20Vkm';
FieldIsReal = 0;        % Fictional
FieldType = 0;          % E-field
DataSamplingRate = 2000;% Sampling rate in sec
EventStartTime = '1-1-2020 11:00:00 PM';   
MeasuredLocMLat = 60;   % Measured location in geomagnetic Latitude
EarthModelType = 0;     % If to use 1-D/3-D Earth Ground conductivity model
EFieldUniform = 1;      % Uniform E-field
EFieldMultiEF = 0;      % Type of multiple E field inputs for the study
EFieldConductivityZone = 0; % EPRI conductivity zones
EarthModel = {
'SHIELD'
};

%% Field -> 8V/km, 10V/km, 15V/km, 20V/km, 25V/km, 30V/km, 35V/km, 40V/km
%NS
% Field_NS = 8000*[0.0871557427476582;0.173648177666930];
% Field_NS = 10000*[0.0871557427476582;0.173648177666930];
% Field_NS = 15000*[0.0871557427476582;0.173648177666930];
Field_NS = 20000*[0.0871557427476582;0.173648177666930];
% Field_NS = 25000*[0.0871557427476582;0.173648177666930];
% Field_NS = 30000*[0.0871557427476582;0.173648177666930];
% Field_NS = 35000*[0.0871557427476582;0.173648177666930];
% Field_NS = 40000*[0.0871557427476582;0.173648177666930];

%EW
% Field_EW = 8000*[0.996194698091746;0.984807753012208];
% Field_EW = 10000*[0.996194698091746;0.984807753012208];
% Field_EW = 15000*[0.996194698091746;0.984807753012208];
Field_EW = 20000*[0.996194698091746;0.984807753012208];
% Field_EW = 25000*[0.996194698091746;0.984807753012208];
% Field_EW = 30000*[0.996194698091746;0.984807753012208];
% Field_EW = 35000*[0.996194698091746;0.984807753012208];
% Field_EW = 40000*[0.996194698091746;0.984807753012208];
