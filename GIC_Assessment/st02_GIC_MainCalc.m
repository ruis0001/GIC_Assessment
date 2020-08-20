% =============================================
% =           GIC Main Calculation            =
% =   Rui Sun, Dominion Technical Solutions   = 
% =============================================

% GIC calculation main entrance. Save the intermediate calculation results
% into files for later assessment

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

function [GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_TopologyOptions,GIC_TXflow,GIC_Subflow,GIC_SRflow,GIC_Branchflow] = st02_GIC_MainCalc(GIC_GlobalSettings,GIC_TopologyOptions,GIC_SystemData,GIC_FieldData,GIC_Calculation)

warning('off','all')
if GIC_GlobalSettings.EventType==0      % Non repeative single storm, time stamps included
    fprintf(['### Topology Case Number ',num2str(GIC_TopologyOptions.TopologyCaseNum),' ###']);
    fprintf('\r\n');
    %% Apply GIC data process form Admittance matrix
    fprintf('  Forming the GIC admittance matrix...');
    fprintf('\r\n');
    for Loop = 1:length(GIC_FieldData.TimeStamp(:,1))
        if Loop>1
            fprintf(repmat('\b',1,length(['  == LOOP: ',num2str(Loop-1),'/',num2str(length(GIC_FieldData.TimeStamp(:,1))),' =='])));  
        end
        fprintf(['  == LOOP: ',num2str(Loop),'/',num2str(length(GIC_FieldData.TimeStamp(:,1))),' ==']);
        [GIC_SystemData,GIC_TopologyOptions] = st03_GIC_TopologyUpdate(Loop,GIC_GlobalSettings,GIC_SystemData,GIC_TopologyOptions,GIC_FieldData); 
        [GIC_Calculation,GIC_SystemData] = st03_GIC_MatrixFormation(Loop,GIC_GlobalSettings,GIC_SystemData,GIC_Calculation);
        [GIC_Calculation] = st03_GIC_NodeVoltageCalc(Loop,GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_FieldData);    
        GIC_TXflow(:,:,Loop) = GIC_Calculation.TXUpdate;
        GIC_Subflow(:,:,Loop) = GIC_Calculation.SubUpdate;
        GIC_SRflow(:,:,Loop) = GIC_Calculation.SRUpdate;
        GIC_Branchflow(:,:,Loop) = GIC_Calculation.BranchUpdate;
    end
    
    SaveDir = ['.\Results\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName];
    if exist(SaveDir)==7    % Folder exists
    else
        mkdir(SaveDir);
    end
    addpath SaveDir;
    GIC_GlobalSettings.SaveDir = SaveDir;
    if GIC_GlobalSettings.CalcEnableTureCorridor==1
        save([SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_RC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
    else
        save([SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_noRC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
    end
    fprintf('\r\n');
elseif GIC_TopologyOptions.TopologyCaseNum>1    % Repeative system reliability study  
    for TopoCase = 1:GIC_TopologyOptions.TopologyCaseNum            
        fprintf(['### Topology Case Number ',num2str(TopoCase),' ###']);
        fprintf('\r\n');
        fprintf('  Forming the GIC admittance matrix...');
        fprintf('\r\n');
        [GIC_SystemData,GIC_TopologyOptions] = st03_GIC_TopologyUpdate(TopoCase,GIC_GlobalSettings,GIC_SystemData,GIC_TopologyOptions,GIC_FieldData); 
        for Loop = 1:length(GIC_FieldData.TimeStamp(:,1))
            if Loop>1
                fprintf(repmat('\b',1,length(['  == LOOP: ',num2str(Loop-1),'/',num2str(length(GIC_FieldData.TimeStamp(:,1))),' =='])));  
            end
            fprintf(['  == LOOP: ',num2str(Loop),'/',num2str(length(GIC_FieldData.TimeStamp(:,1))),' ==']);
            [GIC_Calculation,GIC_SystemData] = st03_GIC_MatrixFormation(Loop,GIC_GlobalSettings,GIC_SystemData,GIC_Calculation);
            [GIC_Calculation] = st03_GIC_NodeVoltageCalc(Loop,GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_FieldData);    
            GIC_TXflow(:,:,Loop,TopoCase) = GIC_Calculation.TXUpdate;
            GIC_Subflow(:,:,Loop,TopoCase) = GIC_Calculation.SubUpdate;
            GIC_SRflow(:,:,Loop,TopoCase) = GIC_Calculation.SRUpdate;
            GIC_Branchflow(:,:,Loop,TopoCase) = GIC_Calculation.BranchUpdate;
        end
        fprintf('\r\n');
    end
    
    SaveDir = ['.\Results\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName];
    if exist(SaveDir)==7    % Folder exists
    else
        mkdir(SaveDir);
    end
    addpath SaveDir;
    GIC_GlobalSettings.SaveDir = SaveDir;
    if GIC_GlobalSettings.CalcEnableTureCorridor==1
        save([SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_RC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
    else
        save([SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'_noRC.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_TXflow','GIC_Subflow','GIC_SRflow','GIC_Branchflow','-v7.3');
    end
    fprintf('\r\n');
end

end