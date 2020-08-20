% =============================================
% =          GIC System Data Read             =
% =   Rui Sun, Dominion Technical Solutions   = 
% =============================================

% Read PSSE raw data file and covert to GIC calculation engine data format
% Current supported version PSSE V33

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 2
% =============================================
function [GIC_SystemData] = st02_GIC_SystemFileRead(GIC_GlobalSettings)    
%% Screen Print Control
if 1==1 
    fprintf('Read GIC system data...');
    fprintf('\r\n');
end

if GIC_GlobalSettings.SystemModelType==0        % System model from a PSSE RAW file
    %% Prepare PSSE File
    pssefid = fopen(GIC_GlobalSettings.CalcPSSEFileName);
    newline = fgetl(pssefid);
    comma1 = find(newline==',');

    %% System Std.
    System_base_MVA = str2num(newline(comma1(1)+1:comma1(2)-1));
    System_base_Freq = str2num(newline(comma1(5)+1:comma1(5)+7));

    newline = fgetl(pssefid);   % skip two lines of description
    newline = fgetl(pssefid);

    %% Bus data
    % Bus# | Bus Name | Bus Voltage
    n1 = 1;
    GIC_Bus_data = {};
    newline = fgetl(pssefid);
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFBUSDATA,BEGINLOADDATA'))
        comma1 = find(newline==',');
        GIC_Bus_data{n1,1} = str2num(newline(1:comma1(1)-1));               % Bus#
        GIC_Bus_data{n1,2} = newline(comma1(1)+2:comma1(2)-2);              % Bus Name
        GIC_Bus_data{n1,3} = str2num(newline(comma1(2)+1:comma1(3)-1));     % Bus Voltage
        n1 = n1+1;
        newline = fgetl(pssefid);
    end
    [~,I] = sort(cell2mat(GIC_Bus_data(:,1)));
    GIC_Bus_data = GIC_Bus_data(I,:);

    %% Line data
    % FromBus | ToBus | Circuit# | LineRpu | LineXpu | Line_Status | Line_Length
    n1 = 1;
    GIC_Line_data = {};
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFGENERATORDATA,BEGINBRANCHDATA'))
        newline = fgetl(pssefid);
    end
    newline = fgetl(pssefid);
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFBRANCHDATA,BEGINTRANSFORMERDATA'))
        comma1 = find(newline==',');
        GIC_Line_data{n1,1} = str2num(newline(1:comma1(1)-1));              % FromBus
        GIC_Line_data{n1,2} = str2num(newline(comma1(1)+1:comma1(2)-1));    % ToBus
        GIC_Line_data{n1,3} = newline(comma1(2)+2:comma1(3)-2);             % Circuit#
        GIC_Line_data{n1,4} = str2num(newline(comma1(3)+1:comma1(4)-1));    % LineRpu
        GIC_Line_data{n1,5} = str2num(newline(comma1(4)+1:comma1(5)-1));    % LineXpu
        if GIC_Line_data{n1,4}==0
            GIC_Line_data{n1,4} = GIC_Line_data{n1,5}/GIC_GlobalSettings.CalcLineXRratio;
        end
        GIC_Line_data{n1,6} = str2num(newline(comma1(13)+1:comma1(14)-1));  % Line_Status
        GIC_Line_data{n1,7} = str2num(newline(comma1(15)+1:comma1(16)-1));  % Line_Length
        n1 = n1+1;
        newline = fgetl(pssefid);
    end
    [~,I] = sort(cell2mat(GIC_Line_data(:,1)));
    GIC_Line_data = GIC_Line_data(I,:);

    %% Transformer data
    % PriBus | SecBus | TerBus | TX ID# | TXName | PriR | SecR | TerR | GICblockingPri | GICblockingSec | GICblockingTer | Connection | CoreType | Kfactor | PriGrdingR | SecGrdingR | TerGrdingR | NoUse | InService | Relevant to Study (If Dominion owned)| Make
    load('GIC_Transformer_db.mat');
    n1 = 1;
    GIC_TX_data = {};
    newline = fgetl(pssefid);
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFTRANSFORMERDATA,BEGINAREAINTERCHANGEDATA') && ~strcmp(strrep(upper(newline),' ',''),'0/ENDOFTRANSFORMERDATA,BEGINAREADATA'))
        comma1 = find(newline==',');
        PriNum1 = str2num(newline(1:comma1(1)-1));               % PriBus
        SecNum1 = str2num(newline(comma1(1)+1:comma1(2)-1));     % SecBus
        TerNum1 = str2num(newline(comma1(2)+1:comma1(3)-1));     % TerBus
        TxID1 = newline(comma1(3)+2:comma1(4)-2);                % TX ID#
        TxName1 = newline(comma1(10)+2:comma1(11)-2);            % TXName
        TxinSer1 = str2num(newline(comma1(11)+1:comma1(12)-1));  % InService
        m1 = n1;
        for i = 1:length(GIC_Transformer_db(:,1))
            if (PriNum1==GIC_Transformer_db{i,1}&&SecNum1==GIC_Transformer_db{i,2})||(PriNum1==GIC_Transformer_db{i,2}&&SecNum1==GIC_Transformer_db{i,1})   % TX in Database
                if TerNum1==GIC_Transformer_db{i,3}&&strcmp(strrep(TxID1,' ',''),strrep(GIC_Transformer_db{i,4},' ',''))
                    GIC_TX_data(n1,:) = GIC_Transformer_db(i,:);
                    % GIC_TX_data{n1,5} = TxName1;  % sometimes the raw file TX name is missing 
                    if GIC_TX_data{n1,end}==1
                        GIC_TX_data{n1,end} = TxinSer1;
                    end
                    n1 = n1+1;
                    break;
                end
            end
        end
        if m1==n1   % TX not in Database
            if TerNum1>0    % Three windings
                % Create 3-winding TX data entries
                GIC_TX_data{n1,1} = PriNum1;
                GIC_TX_data{n1,2} = SecNum1;
                GIC_TX_data{n1,3} = TerNum1;
                GIC_TX_data{n1,4} = strrep(TxID1,' ','');
                GIC_TX_data{n1,5} = TxName1;
                GIC_TX_data(n1,6:18) = [{'unknown'},{'unknown'},{'unknown'},{0},{0},{0},{'YNa0d1'},{0},{0.6},{0},{0},{0},{0}];
                GIC_TX_data{n1,19} = TxinSer1;
                GIC_TX_data(n1,20:21) = [{0}, {1}];                    
            else    % Two windings
                % Create 2-winding TX data entries
                GIC_TX_data{n1,1} = PriNum1;
                GIC_TX_data{n1,2} = SecNum1;
                GIC_TX_data{n1,3} = 0;
                GIC_TX_data{n1,4} = strrep(TxID1,' ','');
                GIC_TX_data{n1,5} = TxName1;
                GIC_TX_data(n1,6:18) = [{'unknown'},{'unknown'},{0},{0},{0},{0},{'YNa0d1'},{0},{0.6},{0},{0},{0},{0}];
                GIC_TX_data{n1,19} = TxinSer1;
                GIC_TX_data(n1,20:21) = [{0}, {1}];  
            end
            n1 = n1+1;
        end
        newline = fgetl(pssefid);
        newline = fgetl(pssefid);
        newline = fgetl(pssefid);
        newline = fgetl(pssefid);
        if GIC_TX_data{n1-1,3}~=0
            newline = fgetl(pssefid);
        end
    end
    [~,I] = sort(cell2mat(GIC_TX_data(:,1)));
    GIC_TX_data = GIC_TX_data(I,:);
    % TX_relevant = cell2mat(GIC_TX_data(:,20));  % 1-Dominion TX, 2-Non-Dominion TX
    % TX_maketempmodel = cell2mat(GIC_TX_data(:,21)); % 1-Hydro One universal model, 2-Siemens auto TX model, 3-Mitsubishi auto TX model, 4-SMIT auto TX model
    % GIC_TX_data = GIC_TX_data(:,1:19);

    %% Bussubstation data
    % Bus# | Substation#
    load('GIC_BusSubstation_db.mat');
    n1 = 1;
    GIC_BusSubstation_data = [];
    for i = 1:length(GIC_Bus_data(:,1))
        P2 = find(GIC_BusSubstation_db(:,1)==GIC_Bus_data{i,1});
        if ~isempty(P2)
            GIC_BusSubstation_data(n1,:) = GIC_BusSubstation_db(P2,:);
            n1 = n1+1;
        end
    end
    GIC_BusSubstation_data = sortrows(GIC_BusSubstation_data);

    %% Substation data
    % Substation# | SubstationName | Latitude | Longitude | GroundingR
    load('GIC_Substation_db.mat');
    n1 = 1;
    GIC_Substation_data = {};
    P3 = unique(GIC_BusSubstation_data(:,2));
    for i = 1:length(P3)
        GIC_Substation_data(n1,:) = GIC_Substation_db(find(cell2mat(GIC_Substation_db(:,1))==P3(i,1)),:);
        if GIC_Substation_data{n1,5}==0;
            GIC_Substation_data{n1,5} = GIC_GlobalSettings.CalcSubGrdingR;    % 3-phase value
        end
        n1 = n1+1;
    end
    [~,I] = sort(cell2mat(GIC_Substation_data(:,1)));
    GIC_Substation_data = GIC_Substation_data(I,:);

    %% Boundary Substation data
    % ------------------
    % Equivalent Boundary, using Infinite long line scheme, following paper: "Equivalent Circuits for Modelling Geomagnetically Induced Currents from a Neighbouring Network"
    % ------------------
    % Substation# | SubstationName | Bus# | EquiLineR | in-service (1/0)
    load('GIC_BoundarySub_db.mat');
    n1 = 1;
    GIC_BoundarySub_data = {};
    P1 = cell2mat(GIC_Bus_data(:,1));
    for i = 1:length(GIC_BoundarySub_db(:,1))
        for j = 3:6
            if GIC_BoundarySub_db{i,j}==0
                break;
            elseif ~isempty(find(P1==GIC_BoundarySub_db{i,j}))
                GIC_BoundarySub_data(n1,1:2) = GIC_BoundarySub_db(i,1:2);
                GIC_BoundarySub_data{n1,3} = GIC_BoundarySub_db{i,j};
                GIC_BoundarySub_data(n1,4:5) = GIC_BoundarySub_db(i,7:8);
                n1 = n1+1;
                break;
            end
        end
    end
    GIC_BoundarySub_data = sortrows(GIC_BoundarySub_data);

    %% Reactor bank data
    % Bus# | ReactorR | Inservice | Name | Substation#
    load('GIC_RX_db.mat');
    n1 = 1;
    GIC_SR_data = {}; % Reactor Bank
    newline = fgetl(pssefid);
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFFACTSDEVICEDATA,BEGINSWITCHEDSHUNTDATA'))
        newline = fgetl(pssefid);
    end
    newline = fgetl(pssefid);
    while(~strcmp(strrep(upper(newline),' ',''),'0/ENDOFSWITCHEDSHUNTDATA,BEGINGNEDEVICEDATA') && ~strcmp(strrep(upper(newline),' ',''),'0/ENDOFSWITCHEDSHUNTDATA,BEGINGNEDATA'))
        comma1 = find(newline==',');
        if length(comma1)<12&&str2num(newline(comma1(11)+1:comma1(11)+8))<0 || length(comma1)>=12&&str2num(newline(comma1(11)+1:comma1(12)-1))<0     % reactor
            BusNum1 = str2num(newline(1:comma1(1)-1));             % Bus#       
            RXinSer1 = str2num(newline(comma1(3)+1:comma1(4)-1));   % In service 
            for i = 1:length(GIC_RX_db(:,1))
                if BusNum1==GIC_RX_db{i,1}
                    GIC_SR_data(n1,:) = GIC_RX_db(i,:);
                    GIC_SR_data{n1,3} = RXinSer1;
                    n1 = n1+1;
                end
            end
        end
        newline = fgetl(pssefid);
    end
    [~,I] = sort(cell2mat(GIC_SR_data(:,1)));
    GIC_SR_data = GIC_SR_data(I,:);
    
    fclose(pssefid);
elseif GIC_GlobalSettings.SystemModelType==1        % System model from a MATLAB inputs
%     GIC_6BusBenchmarkCase();
    GIC_20BusBenchmarkCase();
end
%% Form the GIC_System Data Structure
GIC_SystemData =struct(...
    'FileName',GIC_GlobalSettings.CalcPSSEFileName,...
    'Ver',33,...
    'SystemBaseMVA',System_base_MVA,...
    'SystemFrequency',System_base_Freq,...
    'GIC_BusDataRaw',{GIC_Bus_data},...
    'GIC_BusData',[],...
    'GIC_LineDataRaw',{GIC_Line_data},...
    'GIC_LineData',[],...
    'GIC_TXDataRaw',{GIC_TX_data},...
    'GIC_TXData',[],...
    'GIC_BusSubstationData',{GIC_BusSubstation_data},...
    'GIC_SubstationData',{GIC_Substation_data},...
    'GIC_BoundarySubDataRaw',{GIC_BoundarySub_data},...
    'GIC_BoundarySubData',[],...
    'GIC_SwitchReactorDataRaw',{GIC_SR_data},...
    'GIC_SwitchReactorData',[]);

end