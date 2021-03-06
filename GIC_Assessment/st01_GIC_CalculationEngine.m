% =============================================
% ==         GIC Calculation Engine          ==
% ==             ver perfect 1.0             ==
% ==  Rui Sun, Dominion Technical Solutions  == 
% =============================================

% Time to create a perfect version ofr the GIC calculation engine...
% This is a complete re-write of the previous GIC calculation engine, as
% the evolution of the 3-D earth model and visualization technique.
% Hopefully the application can be more compatible in the future and can be
% plugged into other applications

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 1
% =============================================
% Last changes this run:
% 1.Global settings -> read from Matlab system 
% 2.Load storm data -> 2018Marcch storm data
% 3.GIC prepare -> NouniCon1Dver2, various Corridor settings
% 4.Topology options -> Dominion 2017-9-7
% =============================================

%% Calculation
if 1==1    
    [GIC_GlobalSettings] = st02_GIC_Initialization();  % Initialization - Store GIC global settings       
    [GIC_FieldData,GIC_GlobalSettings] = st02_GIC_LoadStormData(GIC_GlobalSettings); % Load Field Options - Load GIC storm data, convert M-field data to E-field data if necessary          
    [GIC_SystemData] = st02_GIC_SystemFileRead(GIC_GlobalSettings);  % Load System Models - Convert PSSE RAW file data to GIC analysis format      
    [GIC_TopologyOptions] = st02_GIC_TopologyOption(GIC_GlobalSettings);  % Load Topology Options - Load topology options for the study          
    [GIC_Calculation] = st02_GIC_LineDistanceCalc(GIC_SystemData);  % Calculate Eastward and Northward distances       
    [GIC_FieldData] = st02_GIC_LocalHotSpot(GIC_GlobalSettings,GIC_FieldData);   % Determine if there is local E-field hot spot in the studied area   
    [GIC_Calculation] = st02_GIC_LineGICPrep(GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_FieldData);  % Apply Preparation for Non-uniform Geo-electric Voltage Calculation - Calculate line co-efficients for GIC calculation
    % Main Loop
    [GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_TopologyOptions,GIC_TXflow,GIC_Subflow,GIC_SRflow,GIC_Branchflow] = st02_GIC_MainCalc(GIC_GlobalSettings,GIC_TopologyOptions,GIC_SystemData,GIC_FieldData,GIC_Calculation);        
else
    [GIC_GlobalSettings] = st02_GIC_Initialization();
    % load('xxxxx.mat');
end

%% Assessment
xt02_GIC_AGM(GIC_GlobalSettings,GIC_FieldData,GIC_Calculation,GIC_Subflow,GIC_Branchflow,GIC_SystemData)  % Averaged Line GIC Magnitude (AGM) at the Peak
%USE AS INDIVIDUAL FUNCTION/need to prepare reference dataset -> xt02_GIC_CurrentContourMap(GIC_GlobalSettings,GIC_FieldData,GIC_Calculation,GIC_Subflow,GIC_Branchflow,GIC_SystemData)  % GIC Current Contour Map
%USE AS INDIVIDUAL FUNCTION -> [GIC_Assessment] = xt02_GIC_Visualization(GIC_GlobalSettings,GIC_TXflow,GIC_Subflow,GIC_SRflow,GIC_Calculation,GIC_SystemData,GIC_TopologyOptions,GIC_FieldData,GIC_Assessment);     % GIC Flow Visualization 
% Save Results
if GIC_GlobalSettings.CalcEnableTureCorridor==1
    save([GIC_GlobalSettings.SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_RC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_Assessment','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
else
    save([GIC_GlobalSettings.SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_noRC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_Assessment','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
end                                                                                                                                                                                   

    
    
    
    