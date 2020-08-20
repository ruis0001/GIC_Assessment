% =============================================
% ==           GIC Load Storm Data           ==
% ==  Rui Sun, Dominion Technical Solutions  ==
% =============================================

% This is the Storm data selector for the GIC study, also here defines what
% a normal GIC data file should contain for the analysis

% A normal GIC Storm data file should contain following information:
% 1- Storm name
% 2- if it is a real storm or fictional storm: 1-Real, 0-Fictional
% 3- if it is an Electric field data file or a Magnetic field data file: 0-EField, 1-MField
% 4- The data sampling rate and timestamp of the storm
% 4- Measured location(s)
% 5- Any changes to the Field Inputs Settings of the existing GIC_GlobalSettings

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

function [GIC_FieldData,GIC_GlobalSettings] = st02_GIC_LoadStormData(GIC_GlobalSettings)
%% Screen Print Control
if 1==1 
    fprintf('Load electric field options...');
    fprintf('\r\n');
end

%% Selection of GMD Events
% --------------------------- Program Tests ---------------------------
% GeoStormTest_UniformSingleP();
% GeoStormTest_VariousPeakSingleP(); % Various storm peak
% GeoStormTest_FRD_1m();
% GeoStormTest_Mixed_1m();
% GeoStormTest_100kmSmth_1m_Mar2018data();
% GeoStormTest_100kmSmthIntp_1m_Mar2018data();
% GeoStormTest_MultiInput_1m();
% ---------------------- NERC TPL Planning Tests ---------------------- 
% GeoStorm_100Year_NercBench_60N_10s();   % 30-hour
GeoStorm_100Year_60N();   % 5 degree rotation with 8V/km peak
% GeoStorm_100Year_60N_dom(); % 5 degree rotation with various storm peaks
% GeoStorm_100Year_60N_singleP();   % single point for storm peak 
% ---------------------- Historial Storm Records ---------------------- 
% GeoStorm20170907G4_FRD_1m();
% GeoStorm20170907G4_Mixed_1m();

% GeoStorm20170907G4_FRD_1m_newdata();     
% GeoStorm20170907G4_Mixed_1m_newdata();

% GeoStorm20170907G4_100kmSmthIntp_1m_Jan2018data();
% GeoStorm20170907G4_noavg_1m_Jan2018data();
% GeoStorm20170907G4_100kmSmth_1m_Jan2018data();
% GeoStorm20170907G4_noavgIntp_1m_Jan2018data();

% GeoStorm20170907G4_100kmSmthIntp_1m_Mar2018data();
% GeoStorm20170907G4_noavg_1m_Mar2018data();
% GeoStorm20170907G4_100kmSmth_1m_Mar2018data();
% GeoStorm20170907G4_noavgIntp_1m_Mar2018data();
% GeoStorm20170907G4_AnnaModel_1m_Mar2018data();

% GeoStorm20170907G4_100kmSmthIntp_1m_Mar2018_ALGA();
% GeoStorm20170907G4_noavg_1m_Mar2018_ALGA();
% GeoStorm20170907G4_100kmSmth_1m_Mar2018_ALGA();
% GeoStorm20170907G4_noavgIntp_1m_Mar2018_ALGA();
% ---------------------------------------------------------------------
%% Process the Input Data
GIC_FieldData = struct(...
    'FieldName',FieldName,...
    'FieldIsReal',FieldIsReal,...
    'FieldType',FieldType,...    % Type of input field data: 0-E field, 1-Magnetic field       
    'MeasuredLocMLat',MeasuredLocMLat,...
    'MeasuredLocLatLon',[],...
    'MeasuredRadius',[],...
    'DataSamplingRate',DataSamplingRate,...
    'EarthModelType',EarthModelType,...     % 0-1D model, 1-3D model
    'EFieldUniform',EFieldUniform,...    % 0-Uniform, 1-Non-uniform
    'EFieldMultiEF',EFieldMultiEF,...    % 0-Single E-field input, 1-Multiple inputs
    'EFieldConductivityZone',EFieldConductivityZone,...  %0-EPRI conductivity zones, 1-User defined survey zones
    'EarthModel',{EarthModel},...
    'TimeStamp',[],...
    'MField',[],...
    'EField',[],...
    'EField1D',[]);

% Update global settings
GIC_GlobalSettings.EarthModelType = EarthModelType; 
GIC_GlobalSettings.EFieldUniform = EFieldUniform;
GIC_GlobalSettings.EFieldMultiEF = EFieldMultiEF;
GIC_GlobalSettings.EFieldConductivityZone = EFieldConductivityZone;

if EFieldConductivityZone>0     % User defined survey zones    
    GIC_FieldData.MeasuredLocLatLon = EField_latlon;
    GIC_FieldData.MeasuredRadius = MRadius;
end

TimeStamp1 = datenum(EventStartTime);
for i = 1:length(Field_NS(:,1))
    TimeStamp(i,1) = TimeStamp1+(i-1)*DataSamplingRate/3600/24;
end
GIC_FieldData.TimeStamp = TimeStamp;    % Time stamps saved in MATLAB format

if FieldType==1     % Magnetic field data, basically use all existing global field inputs settings
    a = length(Field_NS(1,:));
    MField(:,:,1) = Field_NS;   % Northward M Field data
    MField(:,:,2) = Field_EW;   % Eastward M Field data
    GIC_FieldData.MField = MField;
    for i = 1:a  % Inputs have multiple MField Channels
        % Apply MField -> EField 
    end
    EField(:,:,1) = EField_NS;   % Northward E Field data
    EField(:,:,2) = EField_EW;   % Eastward E Field data
    GIC_FieldData.EField = EField;
elseif FieldType==0     % Electric field data
    EField(:,:,1) = Field_NS;   % Northward E Field data
    EField(:,:,2) = Field_EW;   % Eastward E Field data
    GIC_FieldData.EField = EField;
end

%% Correction of Initialized Settings with the Storm data
if GIC_GlobalSettings.EarthModelType==1 % 3D model
    GIC_GlobalSettings.EFieldUniform = 1; % must be non-uniformed fields
else    % 1D model
    GIC_GlobalSettings.EFieldConductivityZone = 0; % must use EPRI earth conductivity zone
end
if GIC_GlobalSettings.EFieldUniform==0  % Uniformed fields
    GIC_GlobalSettings.EFieldMultiEF = 0; % then E-field inputs must be 1 channel; non-uniformed fields can still have 1 channel inputs
end  

%% Multi_Elec_Field Settings
if GIC_GlobalSettings.EarthModelType==0&&GIC_GlobalSettings.EFieldMultiEF==1      % 1D model and multiple E-fields
    ConRegionsName = {
        'PB-2',0.46
        'PB-1',0.62
        'CS-1',0.41
        'CO-1',0.27
        'BR-1',0.22
        'CL-1',0.76
        'IP-2',0.28
        'IP-4',0.41
        'SU-1',0.93
        'IP-3',0.93
        'IP-1',0.94
        'CP-2',0.95
        'SL-1',0.53
        'AK-1',0.56
        'NE-1',0.81
        'AP-2',0.82
        'PT-1',1.17
        'AP-1',0.33
        'CP-1',0.81
        'SHIELD',1
        'ELSE',1};    
    
    EField1D = zeros(length(Field_NS(:,1)),length(ConRegionsName(:,1)),2);  
    for i = 1:length(EarthModel(:,1))
        for j = 1:length(ConRegionsName(:,1)) 
            if strcmp(EarthModel{i,1},ConRegionsName{j,1})
                EField1D(:,j,1) = Field_NS(:,i);
                EField1D(:,j,2) = Field_EW(:,i);
            end
        end
    end 
    GIC_FieldData.EField1D = EField1D;
end
        
end        
        