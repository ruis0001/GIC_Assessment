% =============================================
% =           GIC Line Preparation            =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% To save calculation time, it is wise to condense latitude and ground
% effect (other than the field) on lines into co-efficients
% EFV_coefficient is LineNum x 2 x n, where 2 includes the Northward and
% Eastward coefficients and n is defined by the number of E field channels

% =============================================
% ver perfect 1.0
% Last update: 11-20-2018 
% Strcuture level: 2
% =============================================

function [GIC_Calculation] = st02_GIC_LineGICPrep(GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_FieldData)
%% Screen Print Control
if 1==1 
    fprintf('Generating Field Coefficients...');
    fprintf('\r\n');    
end

if GIC_GlobalSettings.EFieldUniform==0       % A uniformed E-field is applied for study
    EFV_coefficient = ones(GIC_Calculation.BusNum,2,1);     % The GIC_FieldData.MeasuredLocMLat is not used for this calculation 
elseif GIC_GlobalSettings.EFieldUniform==1   % Non uniformed E-field
    [GIC_Calculation] = st03_GIC_CreateShape(GIC_GlobalSettings,GIC_Calculation,GIC_FieldData);   % Build user defined earth model shape
    for i = 1:GIC_Calculation.LineNum
        if i>1
            fprintf(repmat('\b',1,length(['  == Line: ',num2str(i-1),'/',num2str(GIC_Calculation.LineNum),' =='])));  
        end
        fprintf(['  == Line: ',num2str(i),'/',num2str(GIC_Calculation.LineNum),' ==']);        
                 
        [a,b] = st03_GIC_NonuniCon1D(i,GIC_GlobalSettings,GIC_Calculation,GIC_FieldData);    % Not considered line corridor impact         
        if GIC_GlobalSettings.CalcEnableTureCorridor==1
            load('GIC_LineCorridorData_db.mat');    % Load ture corridor information
            %[a,b] = st03_GIC_NonuniCon1Dver2(i,GIC_GlobalSettings,GIC_Calculation,GIC_FieldData);     %Considered line corridor impact (demo)
            
            LineCorridorData = [];  %Considered line corridor impact (implemetentable)
            for abranch = 1:length(fieldnames(GIC_LineCorridorData_db))                
                name = ['Branch_' num2str(abranch)];
                if GIC_LineCorridorData_db.(name).FromBus==GIC_SystemData.GIC_LineDataRaw{i,1} && GIC_LineCorridorData_db.(name).ToBus==GIC_SystemData.GIC_LineDataRaw{i,2}
                    LineCorridorData = GIC_LineCorridorData_db.(name).Coordinates;
                    break;
                elseif GIC_LineCorridorData_db.(name).ToBus==GIC_SystemData.GIC_LineDataRaw{i,1} && GIC_LineCorridorData_db.(name).FromBus==GIC_SystemData.GIC_LineDataRaw{i,2}
                    LineCorridorData = flipud(GIC_LineCorridorData_db.(name).Coordinates);
                    break;
                end
            end
            [a,b] = st03_GIC_NonuniCon1Dver3(i,GIC_GlobalSettings,GIC_Calculation,GIC_FieldData,LineCorridorData);     
        end
        EFV_coefficient(i,1,:) = a;
        EFV_coefficient(i,2,:) = b;
    end
end
GIC_Calculation.EFV_coefficient = EFV_coefficient;
fprintf('\r\n');  
end