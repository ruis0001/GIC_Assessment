% =============================================
% =     GIC Create User Defined Shape File    =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 8-21-2018 
% Strcuture level: 3
% =============================================

function [GIC_Calculation] = st03_CreateShape(GIC_GlobalSettings,GIC_Calculation,GIC_FieldData)

%% Read GIC_FieldData
Calc_accuracy = GIC_GlobalSettings.CalcCurAccu;     % Accuracy to be 0.05km
Branch_updatefix = GIC_Calculation.BranchDistanceInfo;

if GIC_GlobalSettings.EFieldConductivityZone==1  % Use the User defined survey zones 
%% Create SHAPE file from the data  
    if isempty(GIC_Calculation.GIC_LocalArea)
        LocalArea = struct('LocalAreaid',[],'Lat',[],'Lon',[]);
        if GIC_FieldData.MeasuredRadius~=0      % Regular E-Field observation distribution
            for i = 1:length(GIC_FieldData.MeasuredLocLatLon(1,:))
                CenterLat = GIC_FieldData.MeasuredLocLatLon(1,i);
                CenterLon = GIC_FieldData.MeasuredLocLatLon(2,i);
                BottomLat = CenterLat-GIC_FieldData.MeasuredRadius;
                UpLat = CenterLat+GIC_FieldData.MeasuredRadius;
                LeftLon = CenterLon-GIC_FieldData.MeasuredRadius;
                RightLon = CenterLon+GIC_FieldData.MeasuredRadius;
                Local3D1 = struct('LocalAreaid',num2str(i),'Lat',[BottomLat BottomLat UpLat UpLat],'Lon',[LeftLon RightLon RightLon LeftLon]); 
                LocalArea(end+1,1) = Local3D1;
            end        
        else    % Non-Regular E-Field observation distribution - Define polygon from observation locations
            EField_lat = GIC_FieldData.MeasuredLocLatLon(1,:);
            EField_lon = GIC_FieldData.MeasuredLocLatLon(2,:);
            latmin = floor(min(EField_lat));
            latmax = ceil(max(EField_lat));
            lonmin = floor(min(EField_lon));
            lonmax = ceil(max(EField_lon));

            PointSet = [];
            for i = lonmin:0.01:lonmax
                for j = latmin:0.01:latmax
                    dist = sqrt((i-EField_lon).^2+(j-EField_lat).^2);
                    [p,r] = min(dist);
                    PointSet(int16((j-latmin)*100+1),int16((i-lonmin)*100+1)) = r; 
                end
            end

            [X,Y] = meshgrid(lonmin:0.01:lonmax,latmin:0.01:latmax);       

            for LayerNo = 1:length(EField_lat)
                PointSet1 = PointSet;
                for i = 1:length(PointSet1(:,1))
                    for j = 1:length(PointSet1(1,:))
                        if PointSet1(i,j)~=LayerNo
                            PointSet1(i,j) = 0;
                        end
                    end
                end 
                if max(max(PointSet1))~=0
                    ConTregIndi = contour(X,Y,PointSet1,'LevelList',[LayerNo]);   
                    if ~isempty(ConTregIndi)
                        [x, y, z] = st04_GIC_C2xyz(ConTregIndi);
                        shapeTreg = struct('LocalAreaid',num2cell(z),'Lat',[y],'Lon',[x]);
                        if length(shapeTreg(1).Lat)>3
                            LocalArea(end+1,1) = shapeTreg(1);
                        else
                            LocalArea(end+1,1) = shapeTreg(2);
                        end
                        LocalArea(end).LocalAreaid = num2str(LocalArea(end).LocalAreaid);
                    end 
                end
            end                
        end
        LocalArea(1) = [];
        GIC_Calculation.GIC_LocalArea = LocalArea;
    end
end
%% Validation
    % ------------------------------
%     hold on
%     for i = 1:length(GIC_LocalArea)
%         plot(GIC_LocalArea(i).Lon,GIC_LocalArea(i).Lat)
%     end
%     plot(GIC_FieldData.MeasuredLocLatLon(2,:),GIC_FieldData.MeasuredLocLatLon(1,:),'linestyle','none','marker','*')
    % -----------------------------

end
