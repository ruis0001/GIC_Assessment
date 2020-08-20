% =============================================
% =         GIC Distance Calculation          =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% In current technique, line distance doesn't change regardless the 1-D or
% 3-D method. In the future, line corrider shapes needs to be considered in
% the study. This function needs to be fully revised.

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

function [GIC_Calculation] = st02_GIC_LineDistanceCalc(GIC_SystemData)
%% Screen Print Control
if 1==1 
    fprintf('Calculating system distances...');
    fprintf('\r\n');
end

%% Constants for Earth Distance Calculation
Radius_a = 6378.137;    % Equatorial radius
Radius_b = 6356.752;    % Polar radius
Ecce_sqrt = 0.00669437999014;   % Eccentricity squared

%% Initialize the GIC_Calculation Structure
GIC_Calculation = struct();
GIC_Calculation.BusNum = length(GIC_SystemData.GIC_BusDataRaw(:,1));
GIC_Calculation.LineNum = length(GIC_SystemData.GIC_LineDataRaw(:,1));
if iscell(GIC_SystemData.GIC_TXDataRaw)
    GIC_Calculation.TXNum = length(GIC_SystemData.GIC_TXDataRaw(:,1));
else
    GIC_Calculation.TXNum = 0;
end
GIC_Calculation.SubNum = length(GIC_SystemData.GIC_SubstationData(:,1));
if iscell(GIC_SystemData.GIC_SwitchReactorDataRaw)
    GIC_Calculation.SRNum = length(GIC_SystemData.GIC_SwitchReactorDataRaw(:,1));
else
    GIC_Calculation.SRNum = 0;
end
if iscell(GIC_SystemData.GIC_BoundarySubDataRaw)
    GIC_Calculation.BoundaryNum = length(GIC_SystemData.GIC_BoundarySubDataRaw(:,1));
else
    GIC_Calculation.BoundaryNum = 0;
end
GIC_Calculation.GIC_BusOrder = cell2mat(GIC_SystemData.GIC_BusDataRaw(:,1));
GIC_Calculation.GIC_SubOrder = cell2mat(GIC_SystemData.GIC_SubstationData(:,1));
if GIC_Calculation.BoundaryNum>0
    GIC_Calculation.GIC_BoundaryOrder = cell2mat(GIC_SystemData.GIC_BoundarySubDataRaw(:,1));
else
    GIC_Calculation.GIC_BoundaryOrder = [];
end
if GIC_Calculation.TXNum>0
    GIC_Calculation.GIC_TXRelevant = cell2mat(GIC_SystemData.GIC_TXDataRaw(:,20));  % 1-Dominion TX, 2-Non-Dominion TX
    GIC_Calculation.GIC_TXMakeTempModel = cell2mat(GIC_SystemData.GIC_TXDataRaw(:,21)); % 1-Hydro One universal model, 2-Siemens auto TX model, 3-Mitsubishi auto TX model, 4-SMIT auto TX model
else
    GIC_Calculation.GIC_TXRelevant = [];
    GIC_Calculation.GIC_TXMakeTempModel = [];
end

%% Create TXName
TX_name = cell(GIC_Calculation.TXNum+GIC_Calculation.SRNum,1);
if iscell(TX_name)
    if GIC_Calculation.TXNum>0
        for i = 1:GIC_Calculation.TXNum
            Sub0 = find(GIC_Calculation.GIC_SubOrder==GIC_SystemData.GIC_BusSubstationData(find(GIC_Calculation.GIC_BusOrder==GIC_SystemData.GIC_TXDataRaw{i,2}),2));
            TX_name{i,1} = [GIC_SystemData.GIC_SubstationData{Sub0,2},' ',GIC_SystemData.GIC_TXDataRaw{i,5}];
        end
    end
    if GIC_Calculation.SRNum>0
        for i = 1:GIC_Calculation.SRNum
            TX_name{i+GIC_Calculation.TXNum,1} = [GIC_SystemData.GIC_SubstationData{find(cell2mat(GIC_SystemData.GIC_SubstationData(:,1))==GIC_SystemData.GIC_SwitchReactorDataRaw{i,5}),2},' ',GIC_SystemData.GIC_SwitchReactorDataRaw{i,4}];
        end
    end
    GIC_Calculation.GIC_TXName = TX_name;
else
    GIC_Calculation.GIC_TXName = [];
end

%% Create the first 4 columns of the Branch_update
for i = 1:GIC_Calculation.LineNum
    Branch_updateP(i,:) = cell2mat(GIC_SystemData.GIC_LineDataRaw(i,[1,2]));    % Unit: p.u.
end

%% Branch_updateK saves all Geometry info
Branch_updateK = zeros(GIC_Calculation.LineNum,7);
for i = 1:GIC_Calculation.LineNum
    Sub1 = GIC_SystemData.GIC_BusSubstationData(find(GIC_SystemData.GIC_BusSubstationData==Branch_updateP(i,1),1),2);  % GIS info for Substation A
    Mid1 = GIC_Calculation.GIC_SubOrder;
    Branch_updateK(i,1) = GIC_SystemData.GIC_SubstationData{find(Mid1==Sub1,1),4}; % Latitude
    Branch_updateK(i,2) = GIC_SystemData.GIC_SubstationData{find(Mid1==Sub1,1),5}; % Longitude
    Sub1 = GIC_SystemData.GIC_BusSubstationData(find(GIC_SystemData.GIC_BusSubstationData==Branch_updateP(i,2),1),2);  % GIS info for Substation B
    Branch_updateK(i,3) = GIC_SystemData.GIC_SubstationData{find(Mid1==Sub1,1),4}; % Latitude
    Branch_updateK(i,4) = GIC_SystemData.GIC_SubstationData{find(Mid1==Sub1,1),5}; % Longitude
    LatAve = (Branch_updateK(i,1)+Branch_updateK(i,3))/2; % average latitudes
    Branch_updateK(i,5) = (111.133-0.56*cos(2*LatAve/180*pi))*(Branch_updateK(i,3)-Branch_updateK(i,1)); % Northward distance - Ln, unit: km | consider From Bus is north to To Bus, then the Northward distance is negative
    Branch_updateK(i,6) = (111.5065-0.1872*cos(2*LatAve/180*pi))*cos(LatAve/180*pi)*(Branch_updateK(i,4)-Branch_updateK(i,2)); % Eastward distance - Le, unit: km
    Branch_updateK(i,7) = sqrt(Branch_updateK(i,5).^2+Branch_updateK(i,6).^2);  % Absolute Distance
end
GIC_Calculation.BranchDistanceInfo = Branch_updateK;
GIC_Calculation.BranchDistanceInfoTitle = {'From Bus','To Bus','R_DC','X_DC','LineServiceStatus','From Bus Lat','From Bus Longi','To Bus Lat','To Bus Longi','Length Northward',...
                                'Length Eastward','Absolute Distance'}; 

%% Update Initialization
GIC_Calculation.TXUpdateTitle = {'In Service','PriWind GIC(1-ph) NS','PriWind GIC(1-ph) EW','PriWind GIC(1-ph) total','SecWind GIC(1-ph) NS','SecWind GIC(1-ph) EW','SecWind GIC(1-ph) total',...
    'TerWind GIC(1-ph) NS','TerWind GIC(1-ph) EW','TerWind GIC(1-ph) total','Neutral GIC(3-ph) NS','Neutral GIC(3-ph) EW','Neutral GIC(3-ph) total'};
GIC_Calculation.TXUpdate = [];
GIC_Calculation.SubUpdateTitle = {'Grd GIC(3-ph) NS','Grd GIC(3-ph) EW','Grd GIC(3-ph) total'};
GIC_Calculation.SubUpdate = [];
GIC_Calculation.SRUpdateTitle = {'Grd GIC(3-ph) total'};
GIC_Calculation.SRUpdate = [];
GIC_Calculation.BusUpdateTitle = {'Bus Num','Node GIC sum NS', 'Node GIC sum EW','Node GIC sum total','Node GIV sum NS','Node GIV sum EW','Node GIV sum total'};
GIC_Calculation.BusUpdate = [];
GIC_Calculation.BranchUpdateTitle = {'Line induced GIV NS','Line induced GIV EW', 'Line induced GIC(1-ph) NS','Line induced GIC(1-ph) EW','Line meshed GIC(1-ph) NS','Line meshed GIC(1-ph) EW','Line meshed GIC(1-ph) total'};
GIC_Calculation.BranchUpdate = [];
GIC_Calculation.GIC_LocalArea = [];
end
