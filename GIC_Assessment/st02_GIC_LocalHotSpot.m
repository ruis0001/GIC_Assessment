% =============================================
% =      GIC Local Hot Spot Definition        =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% According to TPL-007-2, local hotspot should be a retangular box
% There are two ways to define local hot spot
% 1-defined as a box with center at one substation
% 2-defined as a box with given center coordinates

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

function [GIC_FieldData] = st02_GIC_LocalHotSpot(GIC_GlobalSettings,GIC_FieldData)	% To define localized hot spot EF area
GIC_FieldData.LocalHotSpot = [];

if GIC_GlobalSettings.EFieldLocalHotSpot==1
    %% Screen Print Control
    if 1==1 
        fprintf('Preparing local enhancement configuration...');
        fprintf('\r\n');
    end
    
    warning('off','all')
    % Local hot spot area is defined in two methods
    GIC_localHS = [];
    %% 1-defined as a box with center at one substation
    load('GIC_Substation_db.mat');   
    % The local hot spot is defined as a cycle with given radius, the EF in the cycle has even values at the same latitude, the hot spot is impacted by different latitude factors. 
    % Definition:     
    GIC_localHS1 = [
    % | Localized Substation ID | Localized peak GIC ratio to other area | Local area box length (km) | Local area box width (km) |
    212  2.5 200 100
    %65  2   100 50
    %220 1.5 150 100
    ]; 

    if ~isempty(GIC_localHS1)
        GIC_localHS(:,1) = GIC_localHS1(:,1);
        GIC_localHS(:,4:6) = GIC_localHS1(:,2:4);
        for i = 1:length(GIC_localHS(:,1))
            p1 = find(cell2mat(GIC_Substation_db(:,1))==GIC_localHS(i,1));
            if ~isempty(p1)
                GIC_localHS(i,2:3) = cell2mat(GIC_Substation_db(p1,4:5));
            end
        end
    end

    %% 2-defined as a box with given center coordinates    
    GIC_localHS2 = [
    % Definition: | Localized ID (0) | Latitude| Longitude | Localized peak GIC ratio to other area | Local area box length (km) | Local area box width (km) |
    0 37.0500 -77.5000 2.5 200 80
    ]; 

    if ~isempty(GIC_localHS2)
        GIC_localHS(end+1:end+length(GIC_localHS2(:,1)),:) = GIC_localHS2;
    end

    %% Create SHAPE file from the data
    if ~isempty(GIC_localHS)
        p2 = 1;
        LocalHS = struct('LocalSubID',[],'Lat',[],'Lon',[],'Ratio',[]);
        for i = 1:length(GIC_localHS(:,1))
            CenterLat = GIC_localHS(i,2);
            CenterLon = GIC_localHS(i,3);
            BoxLength = GIC_localHS(i,5);
            BoxWidth = GIC_localHS(i,6);
            syms x;
            BottomLat = round(double(solve((111.133-0.56*cos((CenterLat+x)/180*pi))*(CenterLat-x)==0.5*BoxWidth)),5);
            UpLat = round(double(solve((111.133-0.56*cos((CenterLat+x)/180*pi))*(x-CenterLat)==0.5*BoxWidth)),5);
            LeftLon = round(double(solve((111.5065-0.1872*cos(2*CenterLat/180*pi))*cos(CenterLat/180*pi)*(x-CenterLon)==0.5*BoxLength)),5);
            RightLon = round(double(solve((111.5065-0.1872*cos(2*CenterLat/180*pi))*cos(CenterLat/180*pi)*(CenterLon-x)==0.5*BoxLength)),5);
            LocalHS1 = struct('LocalSubID',GIC_localHS(i,1),'Lat',[BottomLat BottomLat UpLat UpLat],'Lon',[LeftLon RightLon RightLon LeftLon],'Ratio',GIC_localHS(i,4)); 
            LocalHS(end+1,1) = LocalHS1;
            p2 = p2+1;
        end
        LocalHS(1) = [];
        GIC_localHS = LocalHS;
    end  
    GIC_FieldData.LocalHotSpot = GIC_localHS;
    warning('on','all')
end

end