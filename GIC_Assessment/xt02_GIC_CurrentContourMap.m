% =============================================================================
% =           GIC Current Contour Map at the Peak Point of the Storm          =
% =                  Rui Sun, Dominion Technical Solutions                    = 
% =============================================================================

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

% function xt02_GIC_CurrentContourMap(GIC_GlobalSettings,GIC_FieldData,GIC_Calculation,GIC_Subflow,GIC_Branchflow,GIC_SystemData)

% if GIC_GlobalSettings.AsseCurrentContour==1
%     %% Screen Print Control
%     if 1==1 
%         fprintf('Creating GIC current contour diagram(s), it may take some time...');
%         fprintf('\r\n');
%     end
    
    %% Find the peak of the solar storm
    Efield_NS = GIC_FieldData.EField(:,:,1);
    Efield_EW = GIC_FieldData.EField(:,:,2);
    PeakI = sum(sqrt(Efield_NS.^2+Efield_EW.^2),2);
    [a,indx] = max(PeakI);  % the index when the peak of the storm happens
    
    %% Define the map size and meshed points
%     EField_lat = GIC_FieldData.MeasuredLocLatLon(1,:);
%     EField_lon = GIC_FieldData.MeasuredLocLatLon(2,:);
%     latmin = floor(min(EField_lat));
%     latmax = ceil(max(EField_lat));
%     lonmin = floor(min(EField_lon));
%     lonmax = ceil(max(EField_lon));
    
    ContourVisualFactor = 20;    % factor determines how much resolution the controur map will be visualized, default set to be 20 (1000m)
    Calc_accuracy = GIC_GlobalSettings.CalcCurAccu*ContourVisualFactor;     % accuracy to be 0.05km * factor
    Branch_updatefix = GIC_Calculation.BranchDistanceInfo;
    LineLat = [];
    LineLon = [];
    LineCurrent = [];
    Line500kvAGM = [0,0];
    Line230kvAGM = [0,0];
    Line115kvbelowAGM = [0,0];
%   test = [];
    
    for pointerQ = 1:GIC_Calculation.LineNum
        if Branch_updatefix(pointerQ,12)>=1
            FromLat = Branch_updatefix(pointerQ,6);
            FromLon = Branch_updatefix(pointerQ,7);
            ToLat = Branch_updatefix(pointerQ,8);
            ToLon = Branch_updatefix(pointerQ,9);
            Line_Lat = [FromLat:round((ToLat-FromLat)/Branch_updatefix(pointerQ,12)*Calc_accuracy,10):ToLat];
            Line_Lon = [FromLon:round((ToLon-FromLon)/Branch_updatefix(pointerQ,12)*Calc_accuracy,10):ToLon];
            e = length(Line_Lat);
            Line_Current = GIC_Branchflow(pointerQ,end,indx)*3;    % convert single phase to 3-ph
            Line_kv = GIC_SystemData.GIC_BusDataRaw{find(cell2mat(GIC_SystemData.GIC_BusDataRaw(:,1))==Branch_updatefix(pointerQ,1)),3};
            if Line_Current~=0 && abs(Line_Current)<200% && Branch_updatefix(pointerQ,1)>313700 && Branch_updatefix(pointerQ,2)>313700
                LineLat(end+1:end+e) = Line_Lat;
                LineLon(end+1:end+e) = Line_Lon;
                LineCurrent(end+1:end+e) = abs(Line_Current);
                if Line_kv==500
                    Line500kvAGM(1) = Line500kvAGM(1)+ abs(Line_Current)*Branch_updatefix(pointerQ,12);
                    Line500kvAGM(2) = Line500kvAGM(2)+ Branch_updatefix(pointerQ,12);
                elseif Line_kv==230
                    Line230kvAGM(1) = Line230kvAGM(1)+ abs(Line_Current)*Branch_updatefix(pointerQ,12);
                    Line230kvAGM(2) = Line230kvAGM(2)+ Branch_updatefix(pointerQ,12);
                else
                    Line115kvbelowAGM(1) = Line115kvbelowAGM(1)+ abs(Line_Current)*Branch_updatefix(pointerQ,12);
                    Line115kvbelowAGM(2) = Line115kvbelowAGM(2)+ Branch_updatefix(pointerQ,12);
                end
            end
        end
    end    
        
    Line500kvAGMmean = Line500kvAGM(1)/Line500kvAGM(2);
    Line230kvAGMmean = Line230kvAGM(1)/Line230kvAGM(2);
    Line115kvbelowAGMmean = Line115kvbelowAGM(1)/Line115kvbelowAGM(2);
    LineAGMmean = (Line500kvAGM(1)+Line230kvAGM(1)+Line115kvbelowAGM(1))/(Line500kvAGM(2)+Line230kvAGM(2)+Line115kvbelowAGM(2));
    
    %% Visualize
    colormap(cool);

%     F = scatteredInterpolant(LineLon',LineLat',LineCurrent');
%     [xq,yq] = meshgrid(linspace(lonmin,lonmax,100),linspace(latmin,latmax,100));
%     cq = F(xq,yq);
%     for i = 1:length(cq)
%         for j = 1:length(cq)
%             if cq(i,j)>75 || cq(i,j)<0
%                 cq(i,j) = 0;
%             end
%         end
%     end
                
%     h = pcolor(xq,yq,cq);
%       h = surf(xq,yq,cq)
%     h.EdgeColor = 'none';

    
    subplot(3,2,1)
    scatter(LineLonRef,LineLatRef,20,LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('FRD GIC flow - Reference','FontSize',14)
    subplot(3,2,2)
    scatter(LineLon2,LineLat2,10,LineCurrent2-LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('Mix - Dev. from Reference','FontSize',14)
    subplot(3,2,3)
    scatter(LineLon3,LineLat3,10,LineCurrent3-LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('Noavg - Dev. from Reference','FontSize',14)
    subplot(3,2,4)
    scatter(LineLon4,LineLat4,10,LineCurrent4-LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('Noavg intp. - Dev. from Reference','FontSize',14)
    subplot(3,2,5)
    scatter(LineLon5,LineLat5,10,LineCurrent5-LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('100km Smoothed - Dev. from Reference','FontSize',14)
    subplot(3,2,6)    
    scatter(LineLon6,LineLat6,10,LineCurrent6-LineCurrentRef,'filled','MarkerFaceAlpha',.75)
    colorbar
    caxis([-35 100])
    set(gca, 'FontSize', 14)
    box on
    grid on
    xlim([-80,-75])
    xticks([-80 -79 -78 -77 -76 -75])
    ylim([35 40])
    yticks([35 36 37 38 39 40])
    title('100km Smoothed intp. - Dev. from Reference','FontSize',14)


% end

% end
    
    
    
