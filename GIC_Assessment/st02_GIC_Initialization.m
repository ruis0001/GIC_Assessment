% =============================================
% ==           GIC Global Settings           ==
% ==  Rui Sun, Dominion Technical Solutions  == 
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 11-20-2018 
% Strcuture level: 2
% =============================================

function GIC_GlobalSettings = st02_GIC_Initialization()
clear
clc
    
%% Add Paths
addpath .\;
addpath .\ConductivityRegions\;
addpath .\GeoStormCases\;
addpath .\TopologyCases\;
addpath .\SystemMaps\;
addpath .\SystemMaps\SupportiveFiles\;
addpath .\IntermediateFiles\;
addpath .\Results\;
addpath .\VarModels\;
addpath .\addaxis6\;
fprintf('Program initializing...');
fprintf('\r\n');

%% Initialize the GIC_GlobalSettings Structure
GIC_GlobalSettings = struct(...     % |Defaults       |Type of Setting                  |Description                                                |Options                                                                                         |Comments                   
    'EarthModelType',0,...          % |0              |Earth Conductivity Setting       |If to use 1-D/3-D Earth Ground conductivity model          |0-1D model, 1-3D model                                                                          |
    'EFieldUniform',1,...           % |1              |Field Inputs Setting             |If to use a uniform E field for the study                  |0-Uniform E field, 1-Non-uniform E field                                                        |EFieldUniform = 1 if EarthModelType == 1
    'EFieldMultiEF',0,...           % |0              |Field Inputs Setting             |If to use multiple E field inputs for the study            |0-Single E field, 1-Multiple E fields                                                           |EFieldMultiEF = 0 if EFieldUniform == 0
    'EFieldConductivityZone',0,...  % |0              |Field Inputs Setting             |If to use EPRI conductivity zone for the study             |0-EPRI earth conductivity zone, 1 or 2-User defined survey zones                                |EFieldConductivityZone = 0 if EarthModelType == 0
    'EFieldLocalHotSpot',0,...      % |0              |Field Inputs Setting             |If to apply local enhancement for the study                |0-No local enhancement, 1-Use local enhencement                                                 |   
    'EventType',0,...               % |0              |Event Setting                    |Type of storm event for the study                          |0-Non repeative single storm, time stamps included, 1-Repeative system reliability study        |
    'SystemModelType',1,...         % |0              |System Model Setting             |Type of system model for the study                         |0-System model from a PSSE RAW file, 1-System model from a MATLAB inputs                        |
    'CalcCurAccu',0.05,...          % |0.05           |Calculation Setting              |Define line GIC calculation accuracy                       |Real values, unit: km                                                                           |
    'CalcEnableTureCorridor',0,...  % |0              |Calculation Setting              |If to use ture line corridor GIS information               |1-enable, 0-disable function                                                                    |
    'CalcSkinEffFactor',0.9,...     % |0.9            |Calculation Setting              |Define Skin Effect R value for transmission lines          |Real values, <1                                                                                 |
    'CalcLineXRratio',30,...        % |30             |Calculation Setting              |Define branch R/X ratio if original model without R value  |Real values                                                                                     |
    'CalcTXXRratio',30,...          % |30             |Calculation Setting              |Define TX R/X ratio if original model without R value      |Real values                                                                                     |
    'CalcSubGrdingR',0.3,...        % |0.3            |Calculation Setting              |Define substation grounding resistance if empty            |Real values, unit: ohm                                                                          |
    'CalcLineTemp',50,...           % |50             |Calculation Setting              |Define line conductor operating temperature                |Real values, unit: degree C                                                                     |
    'CalcTXTemp',75,...             % |75             |Calculation Setting              |Define operating TX stationary bulk oil temperature        |Real values, unit: degree C                                                                     |
    'CalcPSSEFileName',[],...       % |n/a            |Calculation Setting              |Define PSSE file name for building GIC model               |Text                                                                                            |
    'CalcVARFileName',[],...        % |n/a            |Calculation Setting              |Define PSSE file name for build new VAR model              |Text                                                                                            |    
    'AsseTXEvenlopTRise',1,...      % |1              |Assessment Setting               |If to apply TX thermal asseessment using Evenlop method    |1-enable, 0-disable function                                                                    |
    'AsseVARConsumption',1,...      % |1              |Assessment Setting               |If to assess transformer VAR consumption                   |1-enable, 0-disable function                                                                    |
    'AsseVisualization',0,...       % |1              |Assessment Setting               |If to apply GIC visualization                              |1-enable, 0-disable function                                                                    |
    'AsseCurrentContour',0,...      % |1              |Assessment Setting               |If to apply GIC current contour map                        |1-enable, 0-disable function                                                                    |
    'AsseWriteVARLoss',0,...        % |0              |Assessment Setting               |If to write VAR files                                      |1-enable, 0-disable function                                                                    |
    'AsseDynThermalStudy',0,...     % |1              |Assessment Setting               |If to TX dynamic thermal assessment                        |1-enable, 0-disable function                                                                    |
    'AsseGenSelectedTX',1,...       % |1              |Assessment Setting               |If to generate Selected TX for dynamic thermal assessment 	|1-enable, 0-disable function                                                                    |   
    'AsseTXTempRiseMon',50,...      % |50             |Assessment Setting               |Define TX temp rise boundary to be watched                 |Real values, unit: degree C                                                                     |   
    'AsseTXMVARRiseMon',40);        % |40             |Assessment Setting               |Define TX MVAR rise boundary to be watched                 |Real values, unit: degree MVAr                                                                  |   

%% Define File Names
GlobalSetting_PSSEfile_name = 'MMWG_2018SUM_2017Series_v1Trial1B.raw';  % PSSE file name for building GIC model
% GlobalSetting_PSSEfile_name = 'MMWG_2018SUM_2017Series_v1Trial1B.raw';  % PJM validation request
GlobalSetting_VARfile_name = 'MMWG_2018SUM_2017Series_Final.raw';       % PSSE file name for build new VAR model
    
%% Update the GIC_GlobalSettings Structure
GIC_GlobalSettings.CalcPSSEFileName = GlobalSetting_PSSEfile_name;
GIC_GlobalSettings.CalcVARFileName = GlobalSetting_VARfile_name;
GIC_GlobalSettings.SaveDir = [];

end    