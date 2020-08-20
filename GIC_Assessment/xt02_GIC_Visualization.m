% =============================================
% =          GIC Flow Visualization           =
% =   Rui Sun, Dominion Technical Solutions   = 
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 7-5-2018 
% Strcuture level: 2
% =============================================

% function [GIC_Assessment] = xt02_GIC_Visualization(GIC_GlobalSettings,GIC_TXflow,GIC_Subflow,GIC_SRflow,GIC_Calculation,GIC_SystemData,GIC_TopologyOptions,GIC_FieldData,GIC_Assessment)

% if GIC_GlobalSettings.AsseVisualization==1 
    %% Screen Print Control
    if 1==1
        fprintf('Creating GIC powerflow diagram(s), it may take some time...');
        fprintf('\r\n');
    end
    
    %% Inherit the Constants
    Branch_update = GIC_Calculation.BranchDistanceInfo;
    latlim = [min(min(Branch_update(:,6)),min(Branch_update(:,8)))-0.3 max(max(Branch_update(:,6)),max(Branch_update(:,8)))+0.3];  % Create GIC canvas
    lonlim = [min(min(Branch_update(:,7)),min(Branch_update(:,9)))-0.3 max(max(Branch_update(:,7)),max(Branch_update(:,9)))+0.3];
    Bus_order = GIC_Calculation.GIC_BusOrder;
    GIC_Bus_data = GIC_SystemData.GIC_BusDataRaw;
    Sub_Num = GIC_Calculation.SubNum;
    Sub_order = GIC_Calculation.GIC_SubOrder;
    Sub_update = GIC_Calculation.SubUpdate;
    GIC_Substation_data = GIC_SystemData.GIC_SubstationData;
    Elec_Field_NS = GIC_FieldData.EField(:,:,1);
    Elec_Field_EW = GIC_FieldData.EField(:,:,2);

    % colorbar = rand(19,3);

    colorbar = [
        0.9058    0.6557    0.0344
        0.1270    0.0357    0.4387
        0.9134    0.8491    0.3816
        0.6324    0.9340    0.7655
        0.0975    0.6787    0.7952
        0.2785    0.7577    0.1869
        0.5469    0.7431    0.4898
        0.9575    0.3922    0.4456
        0.9649    0.6555    0.6463
        0.1576    0.1712    0.7094
        0.9706    0.7060    0.7547
        0.9572    0.0318    0.2760
        0.4854    0.2769    0.6797
        0.8003    0.0462    0.6551
        0.1419    0.0971    0.1626
        0.4218    0.8235    0.1190
        0.9157    0.6948    0.4984
        0.7922    0.3171    0.9597
        0.9595    0.9502    0.3404];

    %% Plot Lines, combine GIC flows on parallel lines
    pointer1 = 1;
    Branch_update2 = Branch_update; 
    pointer2 = 0;
    for i = 2:length(Branch_update(:,1))
        for j = 1:i-1
            if Branch_update2(i,1)==Branch_update2(j,1)&&Branch_update2(i,2)==Branch_update2(j,2)
                %Branch_update2(j,13:19) = Branch_update2(j,13:19)+Branch_update2(i,13:19);
                pointer2(pointer1,1) = i;
                pointer1 = pointer1+1;
                break;
            elseif Branch_update2(i,6)==Branch_update2(j,6)&&Branch_update2(i,7)==Branch_update2(j,7)&&Branch_update2(i,8)==Branch_update2(j,8)&&Branch_update2(i,9)==Branch_update2(j,9)
                if GIC_Bus_data{find(Bus_order==Branch_update(i,1)),3}==GIC_Bus_data{find(Bus_order==Branch_update(j,1)),3}
                    %Branch_update2(j,13:19) = Branch_update2(j,13:19)+Branch_update2(i,13:19);
                    pointer2(pointer1,1) = i;
                    pointer1 = pointer1+1;                
                end
            end
        end
    end
    if pointer2
        Branch_update2(pointer2,:) = [];
    end

    %% Compact Full GIC Map
    hFig = figure(1);
    set(gcf,'PaperPositionMode','auto');
    set(hFig,'Position',[0 0 1200 1200]);
    ax = usamap(latlim,lonlim);
    set(ax, 'Visible', 'off');
    if GIC_GlobalSettings.EFieldConductivityZone==0 % EPRI 1-D earth models
        ConRegions = shaperead('.\ConductivityRegions\ConductivityRegions2.shp','UseGeoCoords', true,'BoundingBox', [lonlim', latlim']);
    %     geoshow(ax,ConRegions,'FaceColor','none','EdgeColor',[0.5 0.5 0.5],'LineStyle','--','Linewidth',1.5)
        for i = 1:length(ConRegions(:,1))
            geoshow(ConRegions(i).Lat,ConRegions(i).Lon,'DisplayType','Polygon','FaceColor',colorbar(i,:),'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'LineStyle','--','Linewidth',1.5)
        end
        states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
        geoshow(ax,states,'FaceColor',[0.3 0.3 0.2],'FaceAlpha',0.2,'Linewidth',2)
        lat = [ConRegions.LabelLat];
        lon = [ConRegions.LabelLon];
        tf = ingeoquad(lat, lon, latlim, lonlim);
        textm(lat(tf),lon(tf),{ConRegions(tf).Name},'HorizontalAlignment','center','FontSize',15,'Color',[0.5 0.2 0.2])
    else
        states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
        geoshow(ax,states,'FaceColor',[0.6 0.7 0.6],'FaceAlpha',1,'Linewidth',2)
    end
    lat = [states.LabelLat];
    lon = [states.LabelLon];
    tf = ingeoquad(lat, lon, latlim, lonlim);
    textm(lat(tf),lon(tf),{states(tf).Name},'HorizontalAlignment','center','FontSize',18,'Color',[0.3 0.3 0.3])

    %%
    scaleruler on   % Plot scale
    p1 = getm(handlem('scaleruler1'),'YLoc');
    q1 = getm(handlem('scaleruler1'),'Lat');
    setm(handlem('scaleruler1'),'YLoc',p1*0.99,'MajorTick',0:50:150);
    northarrow('latitude', latlim(2)-0.3, 'longitude', lonlim(1)+0.2,'scaleratio',0.05);    % Plot northarrow
    if GIC_GlobalSettings.EFieldConductivityZone>0  % User defined E-field areas
        EField_lat = GIC_FieldData.MeasuredLocLatLon(1,:);
        EField_lon = GIC_FieldData.MeasuredLocLatLon(2,:);
        textm(latlim(2)-1,lonlim(1)+0.1,['User defined E-field areas']);
        for i = 1:length(EField_lat)
            plotm(EField_lat(i),EField_lon(i),'LineStyle','none','Color','c','Marker','v','MarkerFaceColor','c','MarkerEdgeColor','k','MarkerSize',6);
        end
    else
        if GIC_GlobalSettings.EFieldMultiEF==0      % Single E-field channel
            textm(latlim(2)-1,lonlim(1)+0.1,['Reference Geological Region: ',GIC_FieldData.EarthModel{1,1}]);
        else
            textm(latlim(2)-1,lonlim(1)+0.1,['Reference Geological Region: Multiple']);
        end
        if GIC_GlobalSettings.EFieldUniform==0
            textm(latlim(2)-1.1,lonlim(1)+0.1,['Uniform E-field mode']);
        else
            textm(latlim(2)-1.1,lonlim(1)+0.1,['Complex E-field mode']);
        end
    end

    GIC_legend = zeros(6,2);
    GIC_legendtext = {'500kV & above';'345kV';'230kV';'138 & 115kV';'69kV';'35kV & below'};

    %%
    hold on;
    pointer1 = 1;
    txtlen = 0;
    if GIC_GlobalSettings.CalcEnableTureCorridor==1
        load('GIC_LineCorridorData_db.mat');    % Load ture corridor information
    end
    for i = 1:length(Branch_update2(:,1))
        if i==10
            txta = ['  == Lines: ',num2str(i),'/',num2str(length(Branch_update2(:,1))),' =='];
            fprintf(txta);
            txtlen = length(txta);
        elseif mod(i,10)==0
            fprintf(repmat('\b',1,txtlen));
            txta = ['  == Lines: ',num2str(i),'/',num2str(length(Branch_update2(:,1))),' =='];
            fprintf(txta);
            txtlen = length(txta);
        end

        %  Line_status = Branch_update2(i,5);   % Lines status
        Line_status = 1;
        if Line_status==1
            PriBus_order = find(Bus_order==Branch_update2(i,1));
            PriBus_V = GIC_Bus_data{PriBus_order,3};
            LineCorridorData = [];  %Considered line corridor impact (implemetentable)
            if GIC_GlobalSettings.CalcEnableTureCorridor==1 && Branch_update2(i,12)>1 && 2==1 % now only consider applying line corridor info to lines with lengths>1km                                 
                for abranch = 1:length(fieldnames(GIC_LineCorridorData_db))                
                    name = ['Branch_' num2str(abranch)];
                    if GIC_LineCorridorData_db.(name).FromBus==Branch_update2(i,1) && GIC_LineCorridorData_db.(name).ToBus==Branch_update2(i,2)
                        LineCorridorData = GIC_LineCorridorData_db.(name).Coordinates;
                        break;
                    elseif GIC_LineCorridorData_db.(name).ToBus==Branch_update2(i,1) && GIC_LineCorridorData_db.(name).FromBus==Branch_update2(i,2)
                        LineCorridorData = flipud(GIC_LineCorridorData_db.(name).Coordinates);
                        break;
                    end
                end
            end
            LineCorridorPlotSetting = 8;  % Plot setting: plot one pair of coordinates every [LineCorridorPlotSetting] entries 
            if length(LineCorridorData)>LineCorridorPlotSetting+1  % lines are modeled using actual corridor info
                for sect = 1:LineCorridorPlotSetting:length(LineCorridorData)-LineCorridorPlotSetting
                    if PriBus_V==500
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-g','LineWidth',1.5);
                        if pointer1<7 && isempty(find(GIC_legend(:,1)==1,1))
                            GIC_legend(pointer1,1) = 1;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end
                    elseif PriBus_V==345
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-c','LineWidth',1);
                        if pointer1<7 && isempty(find(GIC_legend(:,1)==2,1))
                            GIC_legend(pointer1,1) = 2;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end
                    elseif PriBus_V==230
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-b','LineWidth',1);
                        if pointer1<7 && isempty(find(GIC_legend(:,1)==3,1))
                            GIC_legend(pointer1,1) = 3;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end
                    elseif PriBus_V==115||PriBus_V==138
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-r','LineWidth',1);
                        if pointer1<7 && isempty(find(GIC_legend(:,1)==4,1))
                            GIC_legend(pointer1,1) = 4;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end       
                    elseif PriBus_V==69
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-m','LineWidth',1);
                        if pointer1<7 && isempty(find(GIC_legend(:,1)==5,1))
                            GIC_legend(pointer1,1) = 5;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end
                    else
                        hLine(i) = plotm([LineCorridorData(sect,1) LineCorridorData(sect+LineCorridorPlotSetting,1)],[LineCorridorData(sect,2) LineCorridorData(sect+LineCorridorPlotSetting,2)],'-k','LineWidth',1);
                        if pointer1<7 && ~find(GIC_legend(:,1)==6,1)
                            GIC_legend(pointer1,1) = 6;
                            GIC_legend(pointer1,2) = i;
                            pointer1 = pointer1 +1;
                        end
                    end
                end                
            else    % lines are modeled as straight lines
                if PriBus_V==500
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-g','LineWidth',1.5);
                    if pointer1<7 && isempty(find(GIC_legend(:,1)==1,1))
                        GIC_legend(pointer1,1) = 1;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end
                elseif PriBus_V==345
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-c','LineWidth',1);
                    if pointer1<7 && isempty(find(GIC_legend(:,1)==2,1))
                        GIC_legend(pointer1,1) = 2;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end
                elseif PriBus_V==230
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-b','LineWidth',1);
                    if pointer1<7 && isempty(find(GIC_legend(:,1)==3,1))
                        GIC_legend(pointer1,1) = 3;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end
                elseif PriBus_V==115||PriBus_V==138
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-r','LineWidth',1);
                    if pointer1<7 && isempty(find(GIC_legend(:,1)==4,1))
                        GIC_legend(pointer1,1) = 4;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end       
                elseif PriBus_V==69
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-m','LineWidth',1);
                    if pointer1<7 && isempty(find(GIC_legend(:,1)==5,1))
                        GIC_legend(pointer1,1) = 5;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end
                else
                    hLine(i) = plotm([Branch_update2(i,6) Branch_update2(i,8)],[Branch_update2(i,7) Branch_update2(i,9)],'-k','LineWidth',1);
                    if pointer1<7 && ~find(GIC_legend(:,1)==6,1)
                        GIC_legend(pointer1,1) = 6;
                        GIC_legend(pointer1,2) = i;
                        pointer1 = pointer1 +1;
                    end
                end
            end
        end
    end

    fprintf('\r\n');


    if GIC_GlobalSettings.EventType==0 ||  GIC_TopologyOptions.TopologyCaseNum==1 % Non repeative single storm, time stamps included

        SampleNum = min(length(GIC_FieldData.TimeStamp),2000);    % high resolution long period 
        GIC_legend(find(GIC_legend(:,1)==0),:) = [];
        legend([hLine(GIC_legend(:,2))],GIC_legendtext{GIC_legend(:,1),1})
        n1 = round(60/GIC_SystemData.SystemFrequency);
        F(floor(SampleNum/n1)) = struct('cdata',[],'colormap',[]);
%         v = VideoWriter(['.\Results\Video1_',datestr(now,'yyyymmdd_HHMMSS'),'.avi']);
%         v.FrameRate = round(SampleNum/n1/120);
%         open(v);

        tx1 = [];
        tx2 = [];
        pl1 = [];
        pl2 = [];

        for i = 1:Sub_Num   % Plot Substations names
            tt = Sub_order(i);
            if ~ismember(tt,[93,704,705,706,707,708,709,710,711,712,713,714,715,716,717])
                if abs(Sub_update(i,3))>0
                    pl2(i) = textm(GIC_Substation_data{i,4}-0.03,GIC_Substation_data{i,5},0,GIC_Substation_data{i,2},'HorizontalAlignment','center','FontSize',5);
                end
            end
        end

        for j = 1:SampleNum
            if n1==1 || mod(j,n1)==1
                delete(tx1);
                delete(tx2);
                tx1 = textm(latlim(2)-0.8,lonlim(1)+0.1,['Max Geomagnetic field: ',num2str(sqrt(Elec_Field_NS(j,1)^2+Elec_Field_EW(j,1)^2)/1000),' V/km']);
                if Elec_Field_EW(j,1)>=0   
                    tx2 = textm(latlim(2)-0.9,lonlim(1)+0.1,['Direction: ',num2str(round(90-atan(Elec_Field_NS(j,1)/Elec_Field_EW(j,1))/pi*180,1)),' degrees clockwise']);
                else
                    tx2 = textm(latlim(2)-0.9,lonlim(1)+0.1,['Direction: ',num2str(round(270-atan(Elec_Field_NS(j,1)/Elec_Field_EW(j,1))/pi*180,1)),' degrees clockwise']);
                end
                delete(pl1);
                %delete(pl2);
                for i = 1:Sub_Num   % Plot Substations GICs
                    if i==100 && j==1
                        txta = ['  == Substations: ',num2str(i),'/',num2str(Sub_Num),' (Sample ',num2str(j),') =='];
                        fprintf(txta);
                        txtlen = length(txta);
                    elseif mod(i,100)==0 
                        fprintf(repmat('\b',1,txtlen));
                        txta = ['  == Substations: ',num2str(i),'/',num2str(Sub_Num),' (Sample ',num2str(j),') =='];
                        fprintf(txta);
                        txtlen = length(txta);
                    end       
                    tt = Sub_order(i);
                    if ~ismember(tt,[93,704,705,706,707,708,709,710,711,712,713,714,715,716,717])
                        if Sub_update(i,3)>0
                            if length(size(GIC_Subflow))==3
                                pl1(i) = plotm(GIC_Substation_data{i,4},GIC_Substation_data{i,5},'LineStyle','none','Color','k','Marker','o','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',max(int16(GIC_Subflow(i,3,j)/5),1));
                            elseif length(size(GIC_Subflow))==4
                                pl1(i) = plotm(GIC_Substation_data{i,4},GIC_Substation_data{i,5},'LineStyle','none','Color','k','Marker','o','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',max(int16(GIC_Subflow(i,3,j,1)/5),1));
                            end
                            %pl2(i) = textm(GIC_Substation_data{i,4}-0.03,GIC_Substation_data{i,5},0,GIC_Substation_data{i,2},'HorizontalAlignment','center','FontSize',5);
                        elseif Sub_update(i,3)<0
                            if length(size(GIC_Subflow))==3
                                pl1(i) = plotm(GIC_Substation_data{i,4},GIC_Substation_data{i,5},'LineStyle','none','Color','k','Marker','o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',max(abs(int16(GIC_Subflow(i,3,j)/5)),1));
                            elseif length(size(GIC_Subflow))==4
                                pl1(i) = plotm(GIC_Substation_data{i,4},GIC_Substation_data{i,5},'LineStyle','none','Color','k','Marker','o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',max(abs(int16(GIC_Subflow(i,3,j,1)/5)),1));
                            end                
                            %pl2(i) = textm(GIC_Substation_data{i,4}-0.03,GIC_Substation_data{i,5},0,GIC_Substation_data{i,2},'HorizontalAlignment','center','FontSize',5);
                        else
                        end
                    end
                end
                drawnow
                F(j) = getframe(gcf);
                GIC_Assessment.Visualization = struct('Video1',F);
%                 save([GIC_GlobalSettings.SaveDir,'\\Video1.mat'],'F','-v7.3'); 
%                 writeVideo(v,F(j));
            end
        end

        fprintf('\r\n');
%         close(v);
        close(gcf);

    end
% end

% SaveDir = GIC_GlobalSettings.SaveDir;
% save([SaveDir,'\GIC_TXflow_',GIC_FieldData.FieldName,'_',GIC_TopologyOptions.TopologyCaseName,'_EventType',num2str(GIC_GlobalSettings.EventType),'.mat'],'GIC_GlobalSettings','GIC_Calculation','GIC_TopologyOptions','GIC_SystemData','GIC_FieldData','GIC_Assessment','GIC_TXflow','GIC_Subflow','GIC_SRflow','-v7.3');

% end