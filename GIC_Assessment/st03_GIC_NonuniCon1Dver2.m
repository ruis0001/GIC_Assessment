% =============================================
% =  GIC Non-uniform Condcutivity 1D/3D ver3  =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% This version analytically considered the line corridor impact

% =============================================
% ver perfect 1.0
% Last update: 7-3-2018 
% Strcuture level: 3
% =============================================

function [sumGIVNS,sumGIVEW] = st03_GIC_NonuniCon1Dver2(pointerQ,GIC_GlobalSettings,GIC_Calculation,GIC_FieldData)

%% Read GIC_FieldData
Calc_accuracy = GIC_GlobalSettings.CalcCurAccu;     % Accuracy to be 0.05km
Branch_updatefix = GIC_Calculation.BranchDistanceInfo;
CorridorDev = 0.5;  % Line corridor impact coefficient

%% Read Info
if GIC_GlobalSettings.EFieldConductivityZone==0  % Use the EPRI 1D model
    ConRegions = shaperead('.\ConductivityRegions\ConductivityRegions2.shp','UseGeoCoords', true);
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
        'SHIELD',1};  
    
    GeoMagLat_weightbase = 0.001*exp(0.115*GIC_FieldData.MeasuredLocMLat);
    
    FromLat = Branch_updatefix(pointerQ,1);
    FromLon = Branch_updatefix(pointerQ,2);
    ToLat = Branch_updatefix(pointerQ,3);
    ToLon = Branch_updatefix(pointerQ,4);
    slope = abs(Branch_updatefix(pointerQ,5)/Branch_updatefix(pointerQ,6));
    Line_Lat0 = [FromLat:round((ToLat-FromLat)/Branch_updatefix(pointerQ,7)*Calc_accuracy,10):ToLat];
    Line_Lon0 = [FromLon:round((ToLon-FromLon)/Branch_updatefix(pointerQ,7)*Calc_accuracy,10):ToLon];
     
    MaxDevDis = Branch_updatefix(pointerQ,7)*CorridorDev;
    Line_Lat = zeros(1,length(Line_Lat0));
    Line_Lon = zeros(1,length(Line_Lat0));
    Line_Lat(1) = Line_Lat0(1);
    Line_Lon(1) = Line_Lon0(1);
    Line_Lat(end) = Line_Lat0(end);
    Line_Lon(end) = Line_Lon0(end);
    for k = 1:ceil(length(Line_Lat)/2)
        LatDev_km(k) = k*MaxDevDis/ceil(length(Line_Lat)-2)*cos(atan(slope));
        LonDev_km(k) = k*MaxDevDis/ceil(length(Line_Lat)-2)*sin(atan(slope));
        Line_Lat(k+1) = Line_Lat0(k+1)+LatDev_km(k)/110.574;
        Line_Lat(end-k) = Line_Lat0(end-k)+LatDev_km(k)/110.574;
        Line_Lon(k+1) = Line_Lon0(k+1)+LonDev_km(k)/(111.32*cos(Line_Lat0(k+1)/180*2*pi));
        Line_Lon(end-k) = Line_Lon0(end-k)+LonDev_km(k)/(111.32*cos(Line_Lat0(end-k)/180*2*pi));
    end
    
    Local_coef = ones(1,length(Line_Lat));
    if ~isempty(GIC_FieldData.LocalHotSpot)
        for j = 1:length(GIC_FieldData.LocalHotSpot(:,1))
            InonHS(j,:) = GIC_FieldData.LocalHotSpot(j).Ratio*double(inpolygon(Line_Lat,Line_Lon,GIC_FieldData.LocalHotSpot(j).Lat,GIC_FieldData.LocalHotSpot(j).Lon));
            InonHS2(j,:) = double(inpolygon(Line_Lat,Line_Lon,GIC_FieldData.LocalHotSpot(j).Lat,GIC_FieldData.LocalHotSpot(j).Lon)); % in or out
        end
        if length(GIC_FieldData.LocalHotSpot(:,1))>1
            InonHS = sum(InonHS);
            InonHS2 = sum(InonHS2); % in or out
        end
        for j = 1:length(InonHS)
            if InonHS2(j)~=0                
                InonHS(j) = InonHS(j)/InonHS2(j);
            elseif InonHS2(j)==0
                InonHS(j) = 1;  % the section doesn't have local enhancement
            end
        end
        Local_coef = InonHS;
    end
    Inon = 0;
    sumGIVNS = zeros(1,length(ConRegions(:,1)));
    sumGIVEW = zeros(1,length(ConRegions(:,1)));   
    
    if GIC_Calculation.BranchDistanceInfo(pointerQ,7)~=0 % Line in service
        if GIC_GlobalSettings.EFieldMultiEF==0  % Use only one E-field channel for the study          
            T_region = GIC_FieldData.EarthModel{1,1};       % Use the first E-field channel if data file has multiple channels
            for i = 1:length(ConRegionsName(:,1))
                if strcmp(T_region,ConRegionsName{i,1})
                    ConRegionBase = ConRegionsName{i,2};
                    break;
                end
            end
            for j = 1:length(ConRegions(:,1))
                Inon = inpolygon(Line_Lat,Line_Lon,ConRegions(j).Lat,ConRegions(j).Lon);
                if sum(double(Inon))>0
                    GeoMagLat_weight = st04_GIC_GeoMagCoordinateCov(Line_Lat,Line_Lon);
                    GeoMagLat_weight = GeoMagLat_weight/GeoMagLat_weightbase;
                    if length(Inon)>1                  
                        for k = 1:length(Inon)-1
                            AveLat = (Line_Lat(k+1)+Line_Lat(k))/2;
                            Lat_Calc_unit = (111.133-0.56*cos(2*AveLat/180*pi))*(Line_Lat(k+1)-Line_Lat(k));
                            sumGIVNS(j) = sumGIVNS(j)+GeoMagLat_weight(k)*ConRegionsName{j,2}/ConRegionBase*double(Inon(k))*Local_coef(k)*Lat_Calc_unit;
                            Lon_Calc_unit = (111.5065-0.1872*cos(2*AveLat/180*pi))*cos(AveLat/180*pi)*(Line_Lon(k+1)-Line_Lon(k));
                            sumGIVEW(j) = sumGIVEW(j)+GeoMagLat_weight(k)*ConRegionsName{j,2}/ConRegionBase*double(Inon(k))*Local_coef(k)*Lon_Calc_unit;
                        end
                    end
                end
            end              
        elseif GIC_GlobalSettings.EFieldMultiEF==1  % Use multiple E-field channels for the study
            for j = 1:length(ConRegions(:,1))
                Inon = inpolygon(Line_Lat,Line_Lon,ConRegions(j).Lat,ConRegions(j).Lon);
                if sum(double(Inon))>0
                    GeoMagLat_weight = st04_GIC_GeoMagCoordinateCov(Line_Lat,Line_Lon);
                    GeoMagLat_weight = GeoMagLat_weight/GeoMagLat_weightbase;
                    if length(Inon)>1                  
                        for k = 1:length(Inon)-1
                            AveLat = (Line_Lat(k+1)+Line_Lat(k))/2;
                            Lat_Calc_unit = (111.133-0.56*cos(2*AveLat/180*pi))*(Line_Lat(k+1)-Line_Lat(k));
                            sumGIVNS(j) = sumGIVNS(j)+GeoMagLat_weight(k)*double(Inon(k))*Local_coef(k)*Lat_Calc_unit;
                            Lon_Calc_unit = (111.5065-0.1872*cos(2*AveLat/180*pi))*cos(AveLat/180*pi)*(Line_Lon(k+1)-Line_Lon(k));
                            sumGIVEW(j) = sumGIVEW(j)+GeoMagLat_weight(k)*double(Inon(k))*Local_coef(k)*Lon_Calc_unit;
                        end
                    end
                end
            end        
        end

        for j = 1:length(ConRegions(:,1))
            if abs(sumGIVNS(j))<10E-6;  % Line Induced Voltage coefficient, Northward, unit: 1
                sumGIVNS(j) = 0;
            end
            if abs(sumGIVEW(j))<10E-6;    % Line Induced Voltage coefficient, Eastward, unit: 1
                sumGIVEW(j) = 0;
            end
        end      
    end
elseif GIC_GlobalSettings.EFieldConductivityZone==1  % Use the User defined survey zones 
%% Create SHAPE file from the data   
    GIC_LocalArea = GIC_Calculation.GIC_LocalArea;

    FromLat = Branch_updatefix(pointerQ,1);
    FromLon = Branch_updatefix(pointerQ,2);
    ToLat = Branch_updatefix(pointerQ,3);
    ToLon = Branch_updatefix(pointerQ,4);
    slope = abs((FromLat-ToLat)/(FromLon-ToLon));
    Line_Lat0 = [FromLat:round((ToLat-FromLat)/Branch_updatefix(pointerQ,7)*Calc_accuracy,10):ToLat];
    Line_Lon0 = [FromLon:round((ToLon-FromLon)/Branch_updatefix(pointerQ,7)*Calc_accuracy,10):ToLon];

    MaxDevDis = Branch_updatefix(pointerQ,7)*CorridorDev;
    Line_Lat = zeros(1,length(Line_Lat0));
    Line_Lon = zeros(1,length(Line_Lat0));
    Line_Lat(1) = Line_Lat0(1);
    Line_Lon(1) = Line_Lon0(1);
    Line_Lat(end) = Line_Lat0(end);
    Line_Lon(end) = Line_Lon0(end);
    for k = 1:ceil(length(Line_Lat)/2)
        LatDev_km(k) = k*MaxDevDis/ceil(length(Line_Lat)-2)*cos(atan(slope));
        LonDev_km(k) = k*MaxDevDis/ceil(length(Line_Lat)-2)*sin(atan(slope));
        Line_Lat(k+1) = Line_Lat0(k+1)+LatDev_km(k)/110.574;
        Line_Lat(end-k) = Line_Lat0(end-k)+LatDev_km(k)/110.574;
        Line_Lon(k+1) = Line_Lon0(k+1)+LonDev_km(k)/(111.32*cos(Line_Lat0(k+1)/180*2*pi));
        Line_Lon(end-k) = Line_Lon0(end-k)+LonDev_km(k)/(111.32*cos(Line_Lat0(end-k)/180*2*pi));
    end    
    
    Local_coef = ones(1,length(Line_Lat));
    if ~isempty(GIC_FieldData.LocalHotSpot)
        for j = 1:length(GIC_FieldData.LocalHotSpot(:,1))
            InonHS(j,:) = GIC_FieldData.LocalHotSpot(j).Ratio*double(inpolygon(Line_Lat,Line_Lon,GIC_FieldData.LocalHotSpot(j).Lat,GIC_FieldData.LocalHotSpot(j).Lon));
            InonHS2(j,:) = double(inpolygon(Line_Lat,Line_Lon,GIC_FieldData.LocalHotSpot(j).Lat,GIC_FieldData.LocalHotSpot(j).Lon));
        end
        InonHS = sum(InonHS);
        InonHS2 = sum(InonHS2);
        for j = 1:length(InonHS)
            if InonHS2(j)~=0                
                InonHS(j) = InonHS(j)/InonHS2(j);
            elseif InonHS2(j)==0
                InonHS(j) = 1;
            end
        end
        Local_coef = InonHS;
    end
    
    Inon = 0;
    sumGIVNS = zeros(1,length(GIC_LocalArea(:,1)));
    sumGIVEW = zeros(1,length(GIC_LocalArea(:,1)));
    if GIC_Calculation.BranchDistanceInfo(pointerQ,7)~=0 % Line in service
        for j = 1:length(GIC_LocalArea(:,1))
            Inon = inpolygon(Line_Lat,Line_Lon,GIC_LocalArea(j).Lat,GIC_LocalArea(j).Lon);
            if sum(double(Inon))>0
%                 if mod(pointerQ,100)==0
%                     pointerQ
%                 end
                if length(Inon)>1                  
                    for k = 1:length(Inon)-1
                        AveLat = (Line_Lat(k+1)+Line_Lat(k))/2;
                        Lat_Calc_unit = (111.133-0.56*cos(2*AveLat/180*pi))*(Line_Lat(k+1)-Line_Lat(k));
                        sumGIVNS(j) = sumGIVNS(j)+double(Inon(k))*Local_coef(k)*Lat_Calc_unit;
                        Lon_Calc_unit = (111.5065-0.1872*cos(2*AveLat/180*pi))*cos(AveLat/180*pi)*(Line_Lon(k+1)-Line_Lon(k));
                        sumGIVEW(j) = sumGIVEW(j)+double(Inon(k))*Local_coef(k)*Lon_Calc_unit;
                    end
                end
            end
        end
        for j = 1:length(GIC_LocalArea(:,1))
            if abs(sumGIVNS(j))<10E-6;  % Line Induced Voltage coefficient, Northward, unit: 1
                sumGIVNS(j) = 0;
            end
            if abs(sumGIVEW(j))<10E-6;    % Line Induced Voltage coefficient, Eastward, unit: 1
                sumGIVEW(j) = 0;
            end
        end
    end
end