% =============================================
% =            GIC Topology Update            =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 3
% =============================================

function [GIC_SystemData,GIC_TopologyOptions] = st03_GIC_TopologyUpdate(Loop,GIC_GlobalSettings,GIC_SystemData,GIC_TopologyOptions,GIC_FieldData)

%% Find Outages from TopologyOptions File
LineOpen = 0;
TXOpen = 0;
SROpen = 0;
BoundaryOpen = 0;

if GIC_GlobalSettings.EventType==0  % Non-repeative single event
    Date = GIC_FieldData.TimeStamp(Loop,1)-GIC_TopologyOptions.EventStartDate;
else    % Repeative system reliability study 
    Date = GIC_TopologyOptions.EventStartDate-1+Loop;
end

if iscell(GIC_TopologyOptions.LineOutage)
    LineOpen = cell(0);
    c1 = 1;
    for i = 1:length(GIC_TopologyOptions.LineOutage(:,1))
        if Date>=GIC_TopologyOptions.LineOutage{i,4}&&Date<=GIC_TopologyOptions.LineOutage{i,5}   % outage at selected time range
            LineOpen(c1,:) = GIC_TopologyOptions.LineOutage(i,1:3);
            c1 = c1+1;
        end
    end
end

if iscell(GIC_TopologyOptions.TXOutage)
    TXOpen = cell(0);
    c1 = 1;
    for i = 1:length(GIC_TopologyOptions.TXOutage(:,1))
        if Date>=GIC_TopologyOptions.TXOutage{i,5}&&Date<=GIC_TopologyOptions.TXOutage{i,6}   % outage at selected time range
            TXOpen(c1,:) = GIC_TopologyOptions.TXOutage(i,1:4);
            c1 = c1+1;
        end
    end
end

if iscell(GIC_TopologyOptions.SROutage)
    SROpen = {
    313810,0.63940,1,'SR-182',86
    313833,0.66700,1,'SR-122',130
    313834,0.49051,1,'SR-172',31
    314005,0.64870,1,'SR-162',152
    314022,0.48904,1,'SR-182',66
    314052,0.64330,1,'SR-112',177
    314053,0.64460,1,'SR-122',179
    314089,0.48592,1,'SR-132',320
    314140,0.65130,1,'SR-222',130
    314232,0.49240,1,'SR-102',226
    314282,0.65900,1,'SR-172',46
    314453,0.49001,1,'SR-152',61
    314514,0.65230,1,'SR-112',50
    314537,0.48702,1,'SR-142',299
    314574,0.48480,1,'SR-112',118
    314583,0.48611,1,'SR-162',193
    314647,0.49473,1,'SR-112',279
    314794,0.48446,1,'SR-142',91
    314817,0.48844,1,'SR-112',321};
    for i = 1:length(GIC_TopologyOptions.SROutage(:,1))
        if Date>=GIC_TopologyOptions.SROutage{i,3}&&Date<=GIC_TopologyOptions.SROutage{i,4}   % outage at selected time range
            for j = 1:length(SROpen(:,1))
                if SROpen{j,1}==GIC_TopologyOptions.SROutage{i,1}&&strcmp(SROpen{j,4},GIC_TopologyOptions.SROutage{i,2})
                    SROpen{j,3} = 0;
                end
            end
        end
    end
end

if GIC_TopologyOptions.BoundaryOutage~=0
    BoundaryOpen = [];
    c1 = 1;
    for i = 1:length(GIC_TopologyOptions.BoundaryOutage(:,1))
        if Date>=GIC_TopologyOptions.BoundaryOutage(i,2)&&Date<=GIC_TopologyOptions.BoundaryOutage(i,3)   % outage at selected time range
            BoundaryOpen(c1,1) = GIC_TopologyOptions.BoundaryOutage(i,1);
            c1 = c1+1;
        end
    end
end

%% Topology Update
% Line
% -----------------------
GIC_Line_data_R = GIC_SystemData.GIC_LineDataRaw;
if iscell(LineOpen)&&~isempty(LineOpen) % These lines are open
    for i = 1:length(LineOpen(:,1))
        for j = 1:length(GIC_Line_data_R(:,1))
            if isequal(sort(cell2mat(LineOpen(i,1:2))),sort(cell2mat(GIC_Line_data_R(j,1:2))))&&~isempty(strfind(LineOpen{i,3},GIC_Line_data_R{j,3}))
                GIC_Line_data_R{j,6} = 0;
                break;
            end
        end
    end
end
GIC_SystemData.GIC_LineData = GIC_Line_data_R;

% TX
% ------------------------
GIC_TX_data_R = GIC_SystemData.GIC_TXDataRaw;  
if iscell(TXOpen)&&~isempty(TXOpen)   % These TXs are open
    for i = 1:length(TXOpen(:,1))
        for j = 1:length(GIC_TX_data_R(:,1))
            if isequal(sort(cell2mat(TXOpen(i,1:3))),sort(cell2mat(GIC_TX_data_R(j,1:3))))&&~isempty(strfind(TXOpen{i,4},GIC_TX_data_R{j,4}))
               GIC_TX_data_R{j,19} = 0;
               break;
            end
        end
    end
end
GIC_SystemData.GIC_TXData = GIC_TX_data_R;

% SR
% -------------------------
GIC_SR_data_R = GIC_SystemData.GIC_SwitchReactorDataRaw;
if iscell(SROpen)
    for i = 1:length(SROpen(:,1))
        GIC_SR_data_R{i,3} = SROpen{i,3}; 
    end
end
GIC_SystemData.GIC_SwitchReactorData = GIC_SR_data_R;

% Boundary
GIC_BoundarySub_data_R = GIC_SystemData.GIC_BoundarySubDataRaw;
if BoundaryOpen~=0
    for i = 1:length(BoundaryOpen(:,1))
        GIC_BoundarySub_data_R{find(cell2mat(GIC_BoundarySub_data(:,1))==BoundaryOpen(i,1)),5} = 0;
    end
end
GIC_SystemData.GIC_BoundarySubData = GIC_BoundarySub_data_R;

%% Write to File
GIC_TopologyCur = struct('Line',[],'TX',[],'SR',[],'Boundary',[]);
GIC_TopologyCur.Line = LineOpen;
GIC_TopologyCur.TX = TXOpen;
GIC_TopologyCur.SR = SROpen;
GIC_TopologyCur.Boundary = BoundaryOpen;

name = ['Topo_' num2str(Loop)];
GIC_TopologyOptions.Topologies.(name) = GIC_TopologyCur;
end