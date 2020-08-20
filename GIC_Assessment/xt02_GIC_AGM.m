% =============================================================================
% =         GIC Current Averaged Line GIC Magnitude (AGM) Calculation         =
% =                  Rui Sun, Dominion Technical Solutions                    = 
% =============================================================================

% =============================================
% ver perfect 1.0
% Last update: 12-12-2018 
% Strcuture level: 2
% =============================================

function xt02_GIC_AGM(GIC_GlobalSettings,GIC_FieldData,GIC_Calculation,GIC_Subflow,GIC_Branchflow,GIC_SystemData)
  
%% Find the peak of the solar storm
Efield_NS = GIC_FieldData.EField(:,:,1);
Efield_EW = GIC_FieldData.EField(:,:,2);
PeakI = sum(sqrt(Efield_NS.^2+Efield_EW.^2),2);
[a,indx] = max(PeakI);  % the index when the peak of the storm happens

%% AGM calculation
Branch_updatefix = GIC_Calculation.BranchDistanceInfo;

Line500kvAGMmean = [];
Line230kvAGMmean = [];
Line115kvbelowAGMmean = [];
LineAGMmean = [];

LineLength = zeros(1,length(Branch_updatefix));
Line500kvLength = 0;
Line230kvLength = 0;
Line115kvbelowLength = 0;

LineActualLength = zeros(1,length(Branch_updatefix));
Line500kvTotalLength = 0;
Line230kvTotalLength = 0;
Line115kvbelowTotalLength = 0;

for aline = 1:GIC_Calculation.LineNum
    if Branch_updatefix(aline,12)>=1    % only calculate ALGM for line lengths > 1km
        Line_kv = GIC_SystemData.GIC_BusDataRaw{find(cell2mat(GIC_SystemData.GIC_BusDataRaw(:,1))==Branch_updatefix(aline,1)),3};
        if GIC_GlobalSettings.CalcEnableTureCorridor==1
            FromBus = Branch_updatefix(aline,1);
            ToBus = Branch_updatefix(aline,2);
            load('GIC_LineCorridorData_db.mat');    % Load ture corridor information               
            LineCorridorData = [];  %Considered line corridor impact (implemetentable)
            for abranch = 1:length(fieldnames(GIC_LineCorridorData_db))                
                name = ['Branch_' num2str(abranch)];
                if GIC_LineCorridorData_db.(name).FromBus==FromBus && GIC_LineCorridorData_db.(name).ToBus==ToBus
                    LineCorridorData = GIC_LineCorridorData_db.(name).Coordinates;
                    break;
                elseif GIC_LineCorridorData_db.(name).ToBus==FromBus && GIC_LineCorridorData_db.(name).FromBus==ToBus
                    LineCorridorData = flipud(GIC_LineCorridorData_db.(name).Coordinates);
                    break;
                end
            end
            if LineCorridorData                    
                for i = 1:length(LineCorridorData)-1
                    LatAve = (LineCorridorData(i,1)+LineCorridorData(i+1,1))/2; % average latitudes 
                    NSLength = (111.133-0.56*cos(2*LatAve/180*pi))*(LineCorridorData(i+1,1)-LineCorridorData(i,1)); % Northward distance - Ln, unit: km 
                    EWLength = (111.5065-0.1872*cos(2*LatAve/180*pi))*cos(LatAve/180*pi)*(LineCorridorData(i+1,2)-LineCorridorData(i,2)); % Eastward distance - Le, unit: km
                    LineActualLength(aline) = LineActualLength(aline)+sqrt(NSLength^2+EWLength^2);  % Absolute Length
                end
            else
                LineActualLength(aline) = Branch_updatefix(aline,12);
            end
        else
            LineActualLength(aline) = Branch_updatefix(aline,12);
        end          

        if Line_kv==500
            Line500kvTotalLength = Line500kvTotalLength+LineActualLength(aline);
        elseif Line_kv==230
            Line230kvTotalLength = Line230kvTotalLength+LineActualLength(aline);
        else
            Line115kvbelowTotalLength = Line115kvbelowTotalLength+LineActualLength(aline);
        end      
    end
end

for aline = 1:GIC_Calculation.LineNum
    if Branch_updatefix(aline,12)>=1    % only calculate ALGM for line lengths > 1km
        Line_Current = max(abs(GIC_Branchflow(aline,end,:)))*3;
        Line_kv = GIC_SystemData.GIC_BusDataRaw{find(cell2mat(GIC_SystemData.GIC_BusDataRaw(:,1))==Branch_updatefix(aline,1)),3};
        if Line_Current>0.1 && abs(Line_Current)<200
            if GIC_GlobalSettings.CalcEnableTureCorridor==1
                FromBus = Branch_updatefix(aline,1);
                ToBus = Branch_updatefix(aline,2);
                load('GIC_LineCorridorData_db.mat');    % Load ture corridor information               
                LineCorridorData = [];  %Considered line corridor impact (implemetentable)
                for abranch = 1:length(fieldnames(GIC_LineCorridorData_db))                
                    name = ['Branch_' num2str(abranch)];
                    if GIC_LineCorridorData_db.(name).FromBus==FromBus && GIC_LineCorridorData_db.(name).ToBus==ToBus
                        LineCorridorData = GIC_LineCorridorData_db.(name).Coordinates;
                        break;
                    elseif GIC_LineCorridorData_db.(name).ToBus==FromBus && GIC_LineCorridorData_db.(name).FromBus==ToBus
                        LineCorridorData = flipud(GIC_LineCorridorData_db.(name).Coordinates);
                        break;
                    end
                end
                if LineCorridorData                    
                    for i = 1:length(LineCorridorData)-1
                        LatAve = (LineCorridorData(i,1)+LineCorridorData(i+1,1))/2; % average latitudes 
                        NSLength = (111.133-0.56*cos(2*LatAve/180*pi))*(LineCorridorData(i+1,1)-LineCorridorData(i,1)); % Northward distance - Ln, unit: km 
                        EWLength = (111.5065-0.1872*cos(2*LatAve/180*pi))*cos(LatAve/180*pi)*(LineCorridorData(i+1,2)-LineCorridorData(i,2)); % Eastward distance - Le, unit: km
                        LineLength(aline) = LineLength(aline)+sqrt(NSLength^2+EWLength^2);  % Absolute Length
                    end
                else
                    LineLength(aline) = Branch_updatefix(aline,12);
                end
            else
                LineLength(aline) = Branch_updatefix(aline,12);
            end          

            if Line_kv==500
                Line500kvLength = Line500kvLength+LineLength(aline);
            elseif Line_kv==230
                Line230kvLength = Line230kvLength+LineLength(aline);
            else
                Line115kvbelowLength = Line115kvbelowLength+LineLength(aline);
            end
        end
    end
end

for t = 1:length(GIC_Branchflow)
    %t
    Line500kvAGM = 0;
    Line230kvAGM = 0;
    Line115kvbelowAGM = 0;
    
    for aline = 1:GIC_Calculation.LineNum
        if Branch_updatefix(aline,12)>=1             
            Line_Current = GIC_Branchflow(aline,end,t)*3;    % convert single phase to 3-ph
            Line_kv = GIC_SystemData.GIC_BusDataRaw{find(cell2mat(GIC_SystemData.GIC_BusDataRaw(:,1))==Branch_updatefix(aline,1)),3};
            if Line_Current~=0 && abs(Line_Current)<200% && Branch_updatefix(aline,1)>313700 && Branch_updatefix(aline,2)>313700
                if Line_kv==500
                    Line500kvAGM = Line500kvAGM+abs(Line_Current)*LineLength(aline);
                elseif Line_kv==230
                    Line230kvAGM = Line230kvAGM+abs(Line_Current)*LineLength(aline);
                else
                    Line115kvbelowAGM = Line115kvbelowAGM+abs(Line_Current)*LineLength(aline);
                end
            end             
        end
    end    

    Line500kvAGMmean(t) = Line500kvAGM/Line500kvLength;
    Line230kvAGMmean(t) = Line230kvAGM/Line230kvLength;
    Line115kvbelowAGMmean(t) = Line115kvbelowAGM/Line115kvbelowLength;
    LineAGMmean(t) = (Line500kvAGM+Line230kvAGM+Line115kvbelowAGM)/(Line500kvLength+Line230kvLength+Line115kvbelowLength);
end

clear a aline Branch_updatefix FromBus ToBus Line115kvbelowAGM Line230kvAGM Line500kvAGM Line_Current Line_kv PeakI t Efield_NS Efield_EW abranch EWLength NSLength name i LatAve LineCorridorData
end 
    
    
    
