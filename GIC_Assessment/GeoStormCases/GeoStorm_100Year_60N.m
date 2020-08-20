% === GeoStorm_100Year_60N() ===

%% Static
FieldName = 'GeoStorm_100Year_60N_360degree';
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

%% Field
%NS
Field_NS = 8000*[0.0871557427476582;0.173648177666930;0.258819045102521;0.342020143325669;0.422618261740699;0.500000000000000;0.573576436351046;0.642787609686539;0.707106781186548;0.766044443118978;0.819152044288992;0.866025403784439;0.906307787036650;0.939692620785908;0.965925826289068;0.984807753012208;0.996194698091746;1;0.996194698091746;0.984807753012208;0.965925826289068;0.939692620785908;0.906307787036650;0.866025403784439;0.819152044288992;0.766044443118978;0.707106781186548;0.642787609686540;0.573576436351046;0.500000000000000;0.422618261740700;0.342020143325669;0.258819045102521;0.173648177666931;0.0871557427476582;0.0000001;-0.0871557427476579;-0.173648177666930;-0.258819045102520;-0.342020143325669;-0.422618261740699;-0.500000000000000;-0.573576436351046;-0.642787609686539;-0.707106781186548;-0.766044443118978;-0.819152044288992;-0.866025403784439;-0.906307787036650;-0.939692620785908;-0.965925826289068;-0.984807753012208;-0.996194698091746;-1;-0.996194698091746;-0.984807753012208;-0.965925826289068;-0.939692620785908;-0.906307787036650;-0.866025403784439;-0.819152044288992;-0.766044443118978;-0.707106781186548;-0.642787609686540;-0.573576436351047;-0.500000000000000;-0.422618261740699;-0.342020143325669;-0.258819045102521;-0.173648177666930;-0.0871557427476583;0.000001];

%EW
Field_EW = 8000*[0.996194698091746;0.984807753012208;0.965925826289068;0.939692620785908;0.906307787036650;0.866025403784439;0.819152044288992;0.766044443118978;0.707106781186548;0.642787609686539;0.573576436351046;0.500000000000000;0.422618261740699;0.342020143325669;0.258819045102521;0.173648177666930;0.0871557427476584;0.00001;-0.0871557427476582;-0.173648177666930;-0.258819045102521;-0.342020143325669;-0.422618261740699;-0.500000000000000;-0.573576436351046;-0.642787609686539;-0.707106781186548;-0.766044443118978;-0.819152044288992;-0.866025403784439;-0.906307787036650;-0.939692620785908;-0.965925826289068;-0.984807753012208;-0.996194698091746;-1;-0.996194698091746;-0.984807753012208;-0.965925826289068;-0.939692620785908;-0.906307787036650;-0.866025403784439;-0.819152044288992;-0.766044443118978;-0.707106781186548;-0.642787609686540;-0.573576436351046;-0.500000000000000;-0.422618261740699;-0.342020143325669;-0.258819045102521;-0.173648177666930;-0.0871557427476583;0.0000001;0.0871557427476579;0.173648177666930;0.258819045102520;0.342020143325669;0.422618261740699;0.500000000000000;0.573576436351046;0.642787609686539;0.707106781186547;0.766044443118978;0.819152044288992;0.866025403784438;0.906307787036650;0.939692620785908;0.965925826289068;0.984807753012208;0.996194698091746;1];