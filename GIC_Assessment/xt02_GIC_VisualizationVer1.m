% =============================================
% =          GIC Flow Visualization           =
% =   Rui Sun, Dominion Technical Solutions   = 
% =           2018-03-01, 8:20 AM             =
% =============================================

% Ver.2: for Corridor study
%function GIC_Visualization()
indx = 2;
Branch_update = GIC_Calculation.BranchDistanceInfo;
Branch_update(:,5:8) = Branch_update(:,6:9);
Branch_update(:,end+1:end+7) = GIC_Branchflow(:,:,indx);
Sub_Num = GIC_Calculation.SubNum;
Sub_update = GIC_Subflow(:,:,indx);
PSSE_GIC_Substation = GIC_SystemData.GIC_SubstationData;
Bus_order = GIC_Calculation.GIC_BusOrder;
PSSE_Loadflow_Bus = GIC_SystemData.GIC_BusDataRaw;
Elec_Field_Method = GIC_GlobalSettings.EFieldUniform;
Elec_Field_NS = GIC_FieldData.EField(indx,1,1);
Elec_Field_EW = GIC_FieldData.EField(indx,1,2);
if Elec_Field_EW>=0
    Elec_Field_Degrees = round(90-atan(Elec_Field_NS/Elec_Field_EW)/pi*180,1);
else
    Elec_Field_Degrees = round(270-atan(Elec_Field_NS/Elec_Field_EW)/pi*180,1);
end
Elec_Field_Voltage_Mag = sqrt(Elec_Field_NS^2+Elec_Field_EW^2)/1000;

% load('PSSE_GIC_data6.mat');
latlim = [floor(min(min(Branch_update(:,5)),min(Branch_update(:,7))))-0.2 ceil(max(max(Branch_update(:,5)),max(Branch_update(:,7))))+0.2];  % Create GIC canvas
lonlim = [floor(min(min(Branch_update(:,6)),min(Branch_update(:,8))))-0.2 ceil(max(max(Branch_update(:,6)),max(Branch_update(:,8))))+0.2];

colorbar = rand(19,3);

hFig = figure(1);
set(gcf,'PaperPositionMode','auto');
set(hFig,'Position',[0 0 1800 1800]);
ax = usamap(latlim,lonlim);
set(ax, 'Visible', 'off');
if Elec_Field_Method>0
    ConRegions = shaperead('.\ConductivityRegions\ConductivityRegions2.shp','UseGeoCoords', true,'BoundingBox', [lonlim', latlim']);
%     geoshow(ax,ConRegions,'FaceColor','none','EdgeColor',[0.5 0.5 0.5],'LineStyle','--','Linewidth',1.5)
    for i = 1:length(ConRegions(:,1))
        geoshow(ConRegions(i).Lat,ConRegions(i).Lon,'DisplayType','Polygon','FaceColor',colorbar(i,:),'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'LineStyle','--','Linewidth',1.5)
    end
    states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
    geoshow(ax,states,'FaceColor',[0.3 0.3 0.2],'FaceAlpha',0.2,'Linewidth',2)
else
    states = shaperead('usastatehi','UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
    geoshow(ax,states,'FaceColor',[0.6 0.6 0.4],'FaceAlpha',1,'Linewidth',2)
end

lat = [states.LabelLat];
lon = [states.LabelLon];
tf = ingeoquad(lat, lon, latlim, lonlim);

textm(lat(tf),lon(tf),{states(tf).Name},'HorizontalAlignment','center','FontSize',18,'Color',[0.3 0.3 0.3])

if Elec_Field_Method>0
    lat = [ConRegions.LabelLat];
    lon = [ConRegions.LabelLon];
    tf = ingeoquad(lat, lon, latlim, lonlim);
    textm(lat(tf),lon(tf),{ConRegions(tf).Name},'HorizontalAlignment','center','FontSize',15,'Color',[0.5 0.2 0.2])
end

scaleruler on   % Plot scale
p1 = getm(handlem('scaleruler1'),'YLoc');
q1 = getm(handlem('scaleruler1'),'Lat');
setm(handlem('scaleruler1'),'YLoc',latlim(1)/q1*p1*1.035,'MajorTick',0:50:150);
northarrow('latitude', latlim(2)-0.3, 'longitude', lonlim(1)+0.2,'scaleratio',0.05);    % Plot northarrow
r1 = 0.5/(lonlim(2)-lonlim(1))+0.12; % Plot Electric Field direction
r2 = 1-0.15-0.6/(latlim(2)-latlim(1))/(lonlim(2)-lonlim(1))*(latlim(2)-latlim(1));
p1 = cos(Elec_Field_Degrees/180*pi)*0.05;  
q1 = sin(Elec_Field_Degrees/180*pi)*0.05/(lonlim(2)-lonlim(1))*(latlim(2)-latlim(1));
annotation('arrow',[r1-0.5*q1 r1+0.5*q1],[r2-0.5*p1 r2+0.5*p1],'Color','r','LineWidth',2)
textm(latlim(2)-0.8,lonlim(1)+0.1,['Max Geomagnetic field: ',num2str(Elec_Field_Voltage_Mag),' V/km']);
textm(latlim(2)-0.9,lonlim(1)+0.1,['Geomagnetic field direction: ',num2str(Elec_Field_Degrees),' degree']);
if Elec_Field_Method==0
    textm(latlim(2)-1,lonlim(1)+0.1,['Uniform ground conductivity mode']);
else
    textm(latlim(2)-1,lonlim(1)+0.1,['Complex ground conductivity mode']);
end
        
GIC_legend = zeros(6,2);
GIC_legendtext = {'500kV & above';'345kV';'230kV';'138 & 115kV';'69kV';'35kV & below'};
pointer1 = 1;
Branch_update2 = Branch_update; % Plot Lines, combine GIC flows on parallel lines
pointer2 = 0;
for i = 2:length(Branch_update(:,1))
    for j = 1:i-1
        if Branch_update2(i,1)==Branch_update2(j,1)&&Branch_update2(i,2)==Branch_update2(j,2)
            Branch_update2(j,13:19) = Branch_update2(j,13:19)+Branch_update2(i,13:19);
            pointer2(pointer1,1) = i;
            pointer1 = pointer1+1;
            break;
        end
    end
end
if pointer2
    Branch_update2(pointer2,:) = [];
end
hold on;
pointer1 = 1;
for i = 1:length(Branch_update2(:,1))
    PriBus_order = find(Bus_order==Branch_update2(i,1));
    PriBus_V = PSSE_Loadflow_Bus{PriBus_order,3};
    if PriBus_V==500
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-g','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'g');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'g');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'g');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'g');
        end
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(3*abs(Branch_update2(i,19))),'HorizontalAlignment','center','Color','g','FontWeight','bold');
        if pointer1<7 && isempty(find(GIC_legend(:,1)==1,1))
            GIC_legend(pointer1,1) = 1;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end
    elseif PriBus_V==345
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-c','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'c');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'c');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'c');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'c');
        end
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-c','LineWidth',1.5);
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(abs(3*Branch_update2(i,19))),'HorizontalAlignment','center','Color','c','FontWeight','bold');
        if pointer1<7 && isempty(find(GIC_legend(:,1)==2,1))
            GIC_legend(pointer1,1) = 2;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end
    elseif PriBus_V==230
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-b','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'b');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'b');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'b');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'b');
        end
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(abs(3*Branch_update2(i,19))),'HorizontalAlignment','center','Color','b','FontWeight','bold');
        if pointer1<7 && isempty(find(GIC_legend(:,1)==3,1))
            GIC_legend(pointer1,1) = 3;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end
    elseif PriBus_V==115||PriBus_V==138
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-r','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'r');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'r');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'r');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'r');
        end
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(abs(3*Branch_update2(i,19))),'HorizontalAlignment','center','Color','r','FontWeight','bold');
        if pointer1<7 && isempty(find(GIC_legend(:,1)==4,1))
            GIC_legend(pointer1,1) = 4;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end       
    elseif PriBus_V==69
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-m','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'m');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'m');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'m');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'m');
        end
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(abs(3*Branch_update2(i,19))),'HorizontalAlignment','center','Color','m','FontWeight','bold');
        if pointer1<7 && isempty(find(GIC_legend(:,1)==5,1))
            GIC_legend(pointer1,1) = 5;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end
    else
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-k','LineWidth',1.5);
        rate1 = 0.2/sqrt((Branch_update2(i,7)-Branch_update2(i,5))^2+(Branch_update2(i,8)-Branch_update2(i,6))^2);
        if Branch_update2(i,19)>0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'k');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),rate1*(Branch_update2(i,7)-Branch_update2(i,5)),rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'k');
        elseif Branch_update2(i,19)<0
            quiverm(2/3*Branch_update2(i,5)+1/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),2/3*Branch_update2(i,6)+1/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'k');
            quiverm(1/3*Branch_update2(i,5)+2/3*Branch_update2(i,7)+rate1*(Branch_update2(i,7)-Branch_update2(i,5)),1/3*Branch_update2(i,6)+2/3*Branch_update2(i,8)+rate1*(Branch_update2(i,8)-Branch_update2(i,6)),-rate1*(Branch_update2(i,7)-Branch_update2(i,5)),-rate1*(Branch_update2(i,8)-Branch_update2(i,6)),'k');
        end
        hLine(i) = plotm([Branch_update2(i,5) Branch_update2(i,7)],[Branch_update2(i,6) Branch_update2(i,8)],'-k','LineWidth',1.5);
        textm((Branch_update2(i,5)+Branch_update2(i,7))/2,(Branch_update2(i,6)+Branch_update2(i,8))/2,0,num2str(abs(3*Branch_update2(i,19))),'HorizontalAlignment','center','Color','k','FontWeight','bold');
        if pointer1<7 && ~find(GIC_legend(:,1)==6,1)
            GIC_legend(pointer1,1) = 6;
            GIC_legend(pointer1,2) = i;
            pointer1 = pointer1 +1;
        end
    end
end
GIC_legend(find(GIC_legend(:,1)==0),:) = [];
for i = 1:Sub_Num   % Plot Substations
    hLine2(i) = plotm(PSSE_GIC_Substation{i,4},PSSE_GIC_Substation{i,5},'LineStyle','none','Color','k','Marker','s','MarkerFaceColor','k','MarkerSize',8);
    textm(PSSE_GIC_Substation{i,4}+0.1,PSSE_GIC_Substation{i,5},0,PSSE_GIC_Substation{i,2},'HorizontalAlignment','center')
    if Sub_update(i,3)>0
        l1 = quiverm(PSSE_GIC_Substation{i,4}-0.02,PSSE_GIC_Substation{i,5},-0.08,0,'r');
        textm(PSSE_GIC_Substation{i,4}-0.15,PSSE_GIC_Substation{i,5},0,num2str(abs(Sub_update(i,3))),'HorizontalAlignment','center','Color','r','FontWeight','bold')
    elseif Sub_update(i,3)<0
        l1 = quiverm(PSSE_GIC_Substation{i,4}-0.1,PSSE_GIC_Substation{i,5},0.08,0,'r');
        textm(PSSE_GIC_Substation{i,4}-0.15,PSSE_GIC_Substation{i,5},0,num2str(abs(Sub_update(i,3))),'HorizontalAlignment','center','Color','r','FontWeight','bold')
    else
        textm(PSSE_GIC_Substation{i,4}-0.07,PSSE_GIC_Substation{i,5},0,num2str(abs(Sub_update(i,3))),'HorizontalAlignment','center','Color','r','FontWeight','bold')
    end
end
legend([hLine(GIC_legend(:,2)),hLine2(end)],GIC_legendtext{GIC_legend(:,1),1},'Substation')

%saveas(gcf,['.\Results\GIC_Flow_',datestr(now,'yyyymmdd_HHMMSS'),'.jpg']);
%close(gcf);

% end