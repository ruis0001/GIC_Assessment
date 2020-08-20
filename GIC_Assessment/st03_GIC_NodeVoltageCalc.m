% =============================================
% =       GIC Node Voltage Calculation        =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 3
% =============================================

function [GIC_Calculation] = st03_GIC_NodeVoltageCalc(Loop,GIC_GlobalSettings,GIC_Calculation,GIC_SystemData,GIC_FieldData)

%% Inherit constants
Bus_Num = GIC_Calculation.BusNum;
Line_Num = GIC_Calculation.LineNum;
Sub_Num = GIC_Calculation.SubNum;
TX_Num = GIC_Calculation.TXNum;
SR_Num = GIC_Calculation.SRNum;
Boundary_Num = GIC_Calculation.BoundaryNum;
Bus_order = GIC_Calculation.GIC_BusOrder;
Sub_order = GIC_Calculation.GIC_SubOrder;
Boundary_order = GIC_Calculation.GIC_BoundaryOrder;
GIC_TX_data_R = GIC_SystemData.GIC_TXData(:,1:19);
GIC_SR_data_R = GIC_SystemData.GIC_SwitchReactorData;
GIC_Substation_data = GIC_SystemData.GIC_SubstationData;
GIC_BusSubstation_data = GIC_SystemData.GIC_BusSubstationData;
EFV_coefficient = GIC_Calculation.EFV_coefficient;

if GIC_GlobalSettings.EFieldMultiEF==0   % single E-field input channel
    EFVMag_NS = GIC_FieldData.EField(Loop,1,1);
    EFVMag_EW = GIC_FieldData.EField(Loop,1,2);  
elseif GIC_GlobalSettings.EFieldMultiEF==1 && GIC_GlobalSettings.EarthModelType==0   % 1D model and multiple E-fields
    EFVMag_NS = GIC_FieldData.EField1D(Loop,:,1);
    EFVMag_EW = GIC_FieldData.EField1D(Loop,:,2); 
elseif GIC_GlobalSettings.EFieldMultiEF==1 && GIC_GlobalSettings.EarthModelType==1   % 3D model and multiple E-fields
    EFVMag_NS = GIC_FieldData.EField(Loop,:,1);
    EFVMag_EW = GIC_FieldData.EField(Loop,:,2);    
end   
EFVMag_NS = EFVMag_NS/1000;     % unit: V
EFVMag_EW = EFVMag_EW/1000;     % unit: V

%% Calculating induced currents
Branch_update = [GIC_Calculation.BranchDistanceInfo,zeros(Line_Num,7)];
% Branch_update: | 1-From Bus | To Bus | R_DC | X_DC | LineServiceStatus | From Bus Lat | From Bus Longi | To Bus Lat | To Bus Longi | Length Northward |
% 11-Length Eastward | Absolute Distance | Line Induced Voltage Northward | Line Induced Voltage Eastward | Line induced Current Northward | Line induced Current Eastward |
% GIC Flow Northward | GIC Flow Eastward | GIC Flow Total |; note: all in per phase value, 3-phase value times 3

for i = 1:Line_Num
    if Branch_update(i,12)~=0
        if GIC_GlobalSettings.EFieldUniform==0  % Uniform Geo-electric voltage
            Branch_update(i,13) = EFVMag_NS*Branch_update(i,10);    % Line Induced Voltage, Northward, unit: V
            Branch_update(i,14) = EFVMag_EW*Branch_update(i,11);    % Line Induced Voltage, Eastward, unit: V
        elseif GIC_GlobalSettings.EFieldMultiEF==0   % Non-uniform, Use one set of EF data for entire system
            Branch_update(i,13) = EFVMag_NS*sum(EFV_coefficient(i,1,:));   % Line Induced Voltage, Northward, unit: V
            Branch_update(i,14) = EFVMag_EW*sum(EFV_coefficient(i,2,:));   % Line Induced Voltage, Eastward, unit: V
        elseif GIC_GlobalSettings.EFieldMultiEF==1  % Use individual EF data for each region
            for j = 1:length(EFV_coefficient(1,1,:))
                Branch_update(i,13) = Branch_update(i,13)+EFVMag_NS(j)*EFV_coefficient(i,1,j); % Line Induced Voltage, Northward, unit: V
                Branch_update(i,14) = Branch_update(i,14)+EFVMag_EW(j)*EFV_coefficient(i,2,j); % Line Induced Voltage, Eastward, unit: V
            end
        end
        if abs(Branch_update(i,13))<10E-6;
            Branch_update(i,13) = 0;
        end
        if abs(Branch_update(i,14))<10E-6;
            Branch_update(i,14) = 0;
        end
    end
    if Branch_update(i,3)>0  
        if Branch_update(i,1)==314901 || Branch_update(i,1)==314901
            Branch_update(i,4) = -1; % lines who have SERIES CAPACITORS will not generate GIC
        else
            Branch_update(i,15) = Branch_update(i,13)/Branch_update(i,3);   % Line induced Current Northward, unit: amp
            Branch_update(i,16) = Branch_update(i,14)/Branch_update(i,3);   % Line induced Current Eastward, unit: amp
        end
        if abs(Branch_update(i,15))<10E-6;
            Branch_update(i,15) = 0;
        end
        if abs(Branch_update(i,16))<10E-6;
            Branch_update(i,16) = 0;
        end
    end
end

%% Calculating line GIC flow
Bus_update = [[Bus_order;Sub_order+9900000;Boundary_order+9900000] zeros(Bus_Num+Sub_Num+Boundary_Num,6)];
% Bus_update(Substation_update): | Bus(Substation) Number | Node induced Current summation Northward | Node induced Current summation Eastward |
% Node induced Current summation total | Node induced Voltage summation Northward | Node induced Voltage summation Eastward | Node induced Voltage summation total 
for i = 1:Bus_Num
    for j = 1:Line_Num
        if Bus_update(i,1)==Branch_update(j,1)
            Bus_update(i,2) = Bus_update(i,2)-Branch_update(j,15);  % Node induced Current submition Northward 
            Bus_update(i,3) = Bus_update(i,3)-Branch_update(j,16);  % Node induced Current submition Eastward            
        elseif Bus_update(i,1)==Branch_update(j,2)
            Bus_update(i,2) = Bus_update(i,2)+Branch_update(j,15);  % Node induced Current submition Northward 
            Bus_update(i,3) = Bus_update(i,3)+Branch_update(j,16);  % Node induced Current submition Eastward 
        end
    end
end

GIC_Resistance_Matrix3 = GIC_Calculation.GIC_AdmitanceMatrix;    % prevent singular
for i = 1:Bus_Num+Sub_Num+Boundary_Num
    if GIC_Resistance_Matrix3(i,i)==0
        GIC_Resistance_Matrix3(i,i) = 1;
    end
end

Bus_update(:,4) = Bus_update(:,2)+Bus_update(:,3);   % Node induced Current summation total
Bus_update(:,5) = inv(GIC_Resistance_Matrix3)*Bus_update(:,2);   % Node induced Voltage submition Northward
Bus_update(find(abs(Bus_update(:,5))<10E-4),5) = 0;
Bus_update(:,6) = inv(GIC_Resistance_Matrix3)*Bus_update(:,3);   % Node induced Voltage submition Eastward
Bus_update(find(abs(Bus_update(:,6))<10E-4),6) = 0;
Bus_update(:,7) = Bus_update(:,5)+Bus_update(:,6);   % Node induced Voltage summation total

for i = 1:Line_Num
    if Branch_update(i,4)>0&&Branch_update(i,5)~=0  % lines who have SERIES CAPACITORS will not generate GI
        LineR = Branch_update(i,3);
        Branch_update(i,17) = Branch_update(i,15)+(Bus_update(find(Bus_order==Branch_update(i,1)),5)-Bus_update(find(Bus_order==Branch_update(i,2)),5))/LineR;    % GIC Flow Eastward, unit: amp
        if abs(Branch_update(i,17))<10E-6;
            Branch_update(i,17) = 0;
        end
        Branch_update(i,18) = Branch_update(i,16)+(Bus_update(find(Bus_order==Branch_update(i,1)),6)-Bus_update(find(Bus_order==Branch_update(i,2)),6))/LineR;   % GIC Flow Northward, unit: amp
        if abs(Branch_update(i,18))<10E-6;
            Branch_update(i,18) = 0;
        end
        Branch_update(i,19) = Branch_update(i,17)+Branch_update(i,18);   % GIC Flow total, unit: amp
        if abs(Branch_update(i,19))<10E-6;
            Branch_update(i,19) = 0;
        end
    end
end

%% Calculating transformer GIC flow finished 
GIC_Neutral = zeros(TX_Num+SR_Num,3);
Sub_update = zeros(Sub_Num,3);
% Sub_update: | Substation grounding GIC flow Northward | Substation grounding GIC flow Eastward | Substation grounding GIC flow total | note: grounding is considered three phase combined
TX_update = zeros(length(GIC_TX_data_R(:,1)),9);
% TX_update: | TX Primary side (Auto TX series winding side) GIC flow Northward | TX Primary side (Auto TX series winding side) GIC flow Eastward | 
% TX Primary side (Auto TX series winding side) GIC flow total | TX Secondary side (Auto TX common winding side) GIC flow Northward | 
% TXSecondary side (Auto TX common winding side) GIC flow Eastward | TXSecondary side (Auto TX common winding side) GIC flow total | 
% TX Tertiary side GIC flow Northward | TX Tertiary side GIC flow Eastward | TX Tertiary side GIC flow total                            ALL VALUES IN PER PHASE
for i = 1:TX_Num
    if GIC_TX_data_R{i,19}~=0   % in service
        Sub1 = find(Sub_order==GIC_BusSubstation_data(find(Bus_order==GIC_TX_data_R{i,2}),2));
        if GIC_TX_data_R{i,3}==0  % 2-winding TX
            if strfind(GIC_TX_data_R{i,12},'Na')  % Auto Transformer
                TX_update(i,1) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),5)-Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5))/GIC_TX_data_R{i,6}; % GIC Flow through Rs from High voltage side to low side ( = From primary bus into the TX)
                TX_update(i,2) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),6)-Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6))/GIC_TX_data_R{i,6}; 
                TX_update(i,3) = TX_update(i,1)+TX_update(i,2);
                if GIC_TX_data_R{i,9}==0&&GIC_TX_data_R{i,10}==0 
                    TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16}));	% GIC Flow through Rc to ground
                    TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16}));   
                    TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                    GIC_Neutral(i,1) = 3*TX_update(i,4);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = 3*TX_update(i,5);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = 3*TX_update(i,6);    % Neutral, total, 3-phase
%                     TX_update(i,4) = TX_update(i,4) - TX_update(i,1);   % GIC Flow from secondary bus into the TX
%                     TX_update(i,5) = TX_update(i,5) - TX_update(i,2);
%                     TX_update(i,6) = TX_update(i,6) - TX_update(i,3);
                end
                
            elseif strfind(GIC_TX_data_R{i,11},'YNyn') % Wye-ground wye-ground connection
                if GIC_TX_data_R{i,9}==0
                    TX_update(i,1) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});	% GIC Flow through Primary to ground ( = primary bus into the TX)
                    TX_update(i,2) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});   
                    TX_update(i,3) = TX_update(i,1)+TX_update(i,2);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,1);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,2);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                end
                if GIC_TX_data_R{i,10}==0
                    TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});	% GIC Flow through Secondary to ground ( = secondary bus into the TX)
                    TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});   
                    TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                end
                GIC_Neutral(i,1) = 3*(TX_update(i,1)+TX_update(i,4));    % Neutral, NS, 3-phase
                GIC_Neutral(i,2) = 3*(TX_update(i,2)+TX_update(i,5));    % Neutral, EW, 3-phase
                GIC_Neutral(i,3) = 3*(TX_update(i,3)+TX_update(i,6));    % Neutral, total, 3-phase
            elseif ~isempty(strfind(GIC_TX_data_R{i,12},'YNd'))||~isempty(strfind(GIC_TX_data_R{i,12},'YNy')) % Wye-ground-delta connection
                if GIC_TX_data_R{i,9}==0
                    TX_update(i,1) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});	% GIC Flow through Primary to ground ( = primary bus into the TX)
                    TX_update(i,2) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});   
                    TX_update(i,3) = TX_update(i,1)+TX_update(i,2);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,1);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,2);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                    GIC_Neutral(i,1) = 3*TX_update(i,1);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = 3*TX_update(i,2);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = 3*TX_update(i,3);    % Neutral, total, 3-phase
                end
            elseif ~isempty(strfind(GIC_TX_data_R{i,12},'Dyn'))||~isempty(strfind(GIC_TX_data_R{i,12},'Yyn')) % Delta-wye-ground connection (GSU)
                if GIC_TX_data_R{i,10}==0
                    TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});	% GIC Flow through Secondary to ground ( = secondary bus into the TX)
                    TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});   
                    TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                	Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                    GIC_Neutral(i,1) = 3*TX_update(i,4);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = 3*TX_update(i,5);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = 3*TX_update(i,6);    % Neutral, total, 3-phase
                end
            end
        else    % 3-winding TX
            if strfind(GIC_TX_data_R{i,12},'Na')  % Auto Transformer
                TX_update(i,1) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),5)-Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5))/GIC_TX_data_R{i,6}; % GIC Flow through Rs from High voltage side to low side
                TX_update(i,2) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),6)-Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6))/GIC_TX_data_R{i,6}; 
                TX_update(i,3) = TX_update(i,1)+TX_update(i,2);
                if GIC_TX_data_R{i,9}==0&&GIC_TX_data_R{i,10}==0               
                    TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16}));	% GIC Flow through Rc to ground
                    TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16}));   
                    TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                    GIC_Neutral(i,1) = 3*TX_update(i,4);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = 3*TX_update(i,5);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = 3*TX_update(i,6);    % Neutral, total, 3-phase
%                     TX_update(i,4) = TX_update(i,4) - TX_update(i,1);   % GIC Flow from secondary bus into the TX
%                     TX_update(i,5) = TX_update(i,5) - TX_update(i,2);
%                     TX_update(i,6) = TX_update(i,6) - TX_update(i,3);                    
                end
                if ~isempty(strfind(GIC_TX_data_R{i,12},'yn'))&&GIC_TX_data_R{i,11}==0    % Tertiary in wye
                    TX_update(i,7) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});	% GIC Flow through Rt to ground
                    TX_update(i,8) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});   
                    TX_update(i,9) = TX_update(i,7)+TX_update(i,8);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,7);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,8);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                    GIC_Neutral(i,1) = GIC_Neutral(i,1)+3*TX_update(i,7);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = GIC_Neutral(i,2)+3*TX_update(i,8);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = GIC_Neutral(i,2)+3*TX_update(i,9);    % Neutral, total, 3-phase
                end 
            else
                if ~isempty(strfind(GIC_TX_data_R{i,12},'YN'))&&GIC_TX_data_R{i,9}==0 % Primary Wye-ground connection; Consider GIC blocking conditions
                    TX_update(i,1) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});	% GIC Flow through Primary to ground
                    TX_update(i,2) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,1}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,6}+GIC_TX_data_R{i,15});   
                    TX_update(i,3) = TX_update(i,1)+TX_update(i,2);
                    Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,1);
                    Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,2);
                    Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                    GIC_Neutral(i,1) = 3*TX_update(i,1);    % Neutral, NS, 3-phase
                    GIC_Neutral(i,2) = 3*TX_update(i,2);    % Neutral, EW, 3-phase
                    GIC_Neutral(i,3) = 3*TX_update(i,3);    % Neutral, total, 3-phase
                end
                temp2 = strfind(GIC_TX_data_R{i,12},'yn');
                if ~isempty(temp2)
                    if length(temp2)==2 % Secondary and Tertiary Wye-ground connection    
                        if GIC_TX_data_R{i,10}==0
                            TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});	% GIC Flow through Secondary to ground
                            TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});   
                            TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                            Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                            Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                            Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2); 
                            GIC_Neutral(i,1) = GIC_Neutral(i,1)+3*TX_update(i,4);    % Neutral, NS, 3-phase
                            GIC_Neutral(i,2) = GIC_Neutral(i,2)+3*TX_update(i,5);    % Neutral, EW, 3-phase
                            GIC_Neutral(i,3) = GIC_Neutral(i,3)+3*TX_update(i,6);    % Neutral, total, 3-phase
                        end
                        if GIC_TX_data_R{i,11}==0
                            TX_update(i,7) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});	% GIC Flow through Rc to ground
                            TX_update(i,8) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});   
                            TX_update(i,9) = TX_update(i,7)+TX_update(i,8);
                            Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,7);
                            Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,8);
                            Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                            GIC_Neutral(i,1) = GIC_Neutral(i,1)+3*TX_update(i,7);    % Neutral, NS, 3-phase
                            GIC_Neutral(i,2) = GIC_Neutral(i,2)+3*TX_update(i,8);    % Neutral, EW, 3-phase
                            GIC_Neutral(i,3) = GIC_Neutral(i,3)+3*TX_update(i,9);    % Neutral, total, 3-phase                          
                        end
                    elseif length(temp2)==1 % Secondary and Tertiary Wye-ground-delta/delta-Wye-ground connection
                        if temp2==4&&GIC_TX_data_R{i,10}==0
                            TX_update(i,4) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});	% GIC Flow through Secondary to ground
                            TX_update(i,5) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,2}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,7}+GIC_TX_data_R{i,16});   
                            TX_update(i,6) = TX_update(i,4)+TX_update(i,5);
                            Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,4);
                            Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,5);
                            Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                            GIC_Neutral(i,1) = GIC_Neutral(i,1)+3*TX_update(i,4);    % Neutral, NS, 3-phase
                            GIC_Neutral(i,2) = GIC_Neutral(i,2)+3*TX_update(i,5);    % Neutral, EW, 3-phase
                            GIC_Neutral(i,3) = GIC_Neutral(i,3)+3*TX_update(i,6);    % Neutral, total, 3-phase                            
                        elseif temp2==7&&GIC_TX_data_R{i,11}==0
                            TX_update(i,7) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),5)-Bus_update(Sub1+Bus_Num,5))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});	% GIC Flow through Rc to ground
                            TX_update(i,8) = (Bus_update(find(Bus_order==GIC_TX_data_R{i,3}),6)-Bus_update(Sub1+Bus_Num,6))/(GIC_TX_data_R{i,8}+GIC_TX_data_R{i,17});   
                            TX_update(i,9) = TX_update(i,7)+TX_update(i,8);
                            Sub_update(Sub1,1) = Sub_update(Sub1,1)+TX_update(i,7);
                            Sub_update(Sub1,2) = Sub_update(Sub1,2)+TX_update(i,8);
                            Sub_update(Sub1,3) = Sub_update(Sub1,1)+Sub_update(Sub1,2);
                            GIC_Neutral(i,1) = GIC_Neutral(i,1)+3*TX_update(i,7);    % Neutral, NS, 3-phase
                            GIC_Neutral(i,2) = GIC_Neutral(i,2)+3*TX_update(i,8);    % Neutral, EW, 3-phase
                            GIC_Neutral(i,3) = GIC_Neutral(i,3)+3*TX_update(i,9);    % Neutral, total, 3-phase                               
                        end
                    end
                end
            end
        end
    end
end
GIC_TX_data_R(:,length(GIC_TX_data_R(1,:))+1:length(GIC_TX_data_R(1,:))+9) = num2cell(TX_update);
for i = 1:TX_Num
    for j = length(GIC_TX_data_R(1,:))-8:length(GIC_TX_data_R(1,:))
        if GIC_TX_data_R{i,j}~=0&&abs(GIC_TX_data_R{i,j})<10^-6
            GIC_TX_data_R{i,j} = 0;
        end
    end
end

SR_currents = zeros(SR_Num,1);  % Shunt Reactor bank currents in 3-phase
for i = 1:SR_Num
    if GIC_SR_data_R{i,3}==1    % in service
        PriBus_order = find(Bus_order==GIC_SR_data_R{i,1});
        V_Bus = Bus_update(PriBus_order,7);
        V_Grd = Bus_update(Bus_Num+GIC_SR_data_R{i,5},7);
        SR_currents(i,1) = (V_Bus-V_Grd)/GIC_SR_data_R{i,2}*3;      % in 3-phase
        GIC_Neutral(i+TX_Num,3) = SR_currents(i,1);    % Neutral, total, 3-phase
    end
end

Sub_update = Sub_update*3;  % SUB_UPDATE VALUE IN 3PHASE 

%% Prepare outputs 
GIC_TX_data_2 = [cell2mat(GIC_TX_data_R(:,19:28)) GIC_Neutral(1:TX_Num,:)];
GIC_Calculation.TXUpdate = GIC_TX_data_2;
GIC_Calculation.SubUpdate = Sub_update;
GIC_Calculation.SRUpdate = SR_currents;
GIC_Calculation.BusUpdate = Bus_update;
GIC_Calculation.BranchUpdate = Branch_update(:,end-6:end);

end