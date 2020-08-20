% =============================================
% ==        GIC Load Topology Options        ==
% ==  Rui Sun, Dominion Technical Solutions  ==
% =============================================

% This is the topology data selector for the GIC study

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================

function [GIC_TopologyOptions] = st02_GIC_TopologyOption(GIC_GlobalSettings)    
%% Screen Print Control
if 1==1 
    fprintf('Load topology options...');
    fprintf('\r\n');
end

%% Initialize the GIC_TopologyOptions
GIC_TopologyOptions = struct(... 
    'TopologyCaseName',[],...
    'TopologyCaseNum',1,...             % Defines how many topology events applied for GlobalSettings.EventType = 1 study, Default = 1
    'EventStartDate',[],...             % If it is historical event records, this is the starting date of the record
    'LineOutage',0,...
    'TXOutage',0,...
    'SROutage',0,...
    'BoundaryOutage',0);

GIC_Topologies = struct();
GIC_TopologyOptions.Topologies = GIC_Topologies;

%% Load topology files
% ---------------------- NERC TPL Planning Tests ---------------------- 
% Dominion_Topology2015_psse();   % psse bus numbers
Dominion_Full();
% ---------------------- Historial Storm Records ----------------------
% Dominion_20170907();
% Dominion_20170907detail();
% ---------------------------------------------------------------------
%% Process the Input Data
GIC_TopologyOptions.TopologyCaseName = TopologyCaseName;
GIC_TopologyOptions.TopologyCaseNum = TopologyCaseNum;
GIC_TopologyOptions.EventStartDate = datenum(Start_date);
GIC_TopologyOptions.LineOutage = Line_outage;
GIC_TopologyOptions.TXOutage = TX_outage;
GIC_TopologyOptions.SROutage = SR_outage;
GIC_TopologyOptions.BoundaryOutage = Boundary_outage;

end