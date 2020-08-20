% =============================================
% =           GIC Matrix Formation            =
% =   Rui Sun, Dominion Technical Solutions   =
% =============================================

% =============================================
% ver perfect 1.0
% Last update: 7-2-2018 
% Strcuture level: 3
% =============================================

function [GIC_Calculation,GIC_SystemData] = st03_GIC_MatrixFormation(Loop,GIC_GlobalSettings,GIC_SystemData,GIC_Calculation)

%% Calculation Constants
SkinFactor = GIC_GlobalSettings.CalcSkinEffFactor;
T_factor = (234.5+GIC_GlobalSettings.CalcTXTemp)/(234.5+75);
Bus_Num = GIC_Calculation.BusNum;
Sub_Num = GIC_Calculation.SubNum;
GIC_TX_data_R = GIC_SystemData.GIC_TXData;
Sub_order = GIC_Calculation.GIC_SubOrder;
Branch_update = [];

for i = 1:length(GIC_SystemData.GIC_LineData(:,1))
    Branch_update(i,:) = cell2mat(GIC_SystemData.GIC_LineData(i,[1,2,4,5,6]));    % Unit: p.u.
end
for i = 1:GIC_Calculation.LineNum  % Switch to ohm 
    PriBus_order = find(GIC_Calculation.GIC_BusOrder==Branch_update(i,1));
    PriBus_V = GIC_SystemData.GIC_BusDataRaw{PriBus_order,3};
    Rbase = PriBus_V^2/GIC_SystemData.SystemBaseMVA;
    Branch_update(i,3) = Branch_update(i,3)* Rbase*SkinFactor;    
    Branch_update(i,4) = Branch_update(i,4)* Rbase; % at 60HZ
    if Branch_update(i,1)==314901 || Branch_update(i,2)==314901	
        Branch_update(i,4) = -1; % lines who have SERIES CAPACITORS will not generate GIC
    end
end

%% Form the Line Admittance matrix (Y), unit: mho
GIC_Resistance_AMatrix = zeros(Bus_Num); 
for i = 1:Bus_Num
    RowNum = GIC_SystemData.GIC_BusDataRaw{i,1};
    Branch_update1 = Branch_update(find(Branch_update(:,1)==RowNum),[2 3 4 5]);   
    for j = 1:length(Branch_update1(:,1))
        Branch_update1(j,5) = find(GIC_Calculation.GIC_BusOrder==Branch_update1(j,1));
    end
    Branch_update2 = Branch_update(find(Branch_update(:,2)==RowNum),[1 3 4 5]);
    for j = 1:length(Branch_update2(:,1))
        Branch_update2(j,5) = find(GIC_Calculation.GIC_BusOrder==Branch_update2(j,1));
    end
    for j = 1:length(Branch_update1(:,1))
        if Branch_update1(j,4)==1	% Lines in service
            if Branch_update1(j,2)>0  
                if Branch_update1(j,3)<0 % This option is to distinguish lines who have SERIES CAPACITORS 
                else
                    GIC_Resistance_AMatrix(i,i) = GIC_Resistance_AMatrix(i,i)+ 1/Branch_update1(j,2);       
                    GIC_Resistance_AMatrix(i,Branch_update1(j,5)) = GIC_Resistance_AMatrix(i,Branch_update1(j,5))-1/Branch_update1(j,2);
                    GIC_Resistance_AMatrix(Branch_update1(j,5),i) = GIC_Resistance_AMatrix(Branch_update1(j,5),i)-1/Branch_update1(j,2);
                end
            end
        end
    end
    for j = 1:length(Branch_update2(:,1))
        if Branch_update2(j,4)==1	% Lines in service
            if Branch_update2(j,2)
                if Branch_update2(j,3)<0
                else
                    GIC_Resistance_AMatrix(i,i) = GIC_Resistance_AMatrix(i,i)+ 1/Branch_update2(j,2);
                    GIC_Resistance_AMatrix(i,Branch_update2(j,5)) = GIC_Resistance_AMatrix(i,Branch_update2(j,5))-1/Branch_update2(j,2);
                    GIC_Resistance_AMatrix(Branch_update2(j,5),i) = GIC_Resistance_AMatrix(Branch_update2(j,5),i)-1/Branch_update2(j,2);
                end
            end
        end
    end    
    Branch_update1 = 0;
    Branch_update2 = 0;
end
GIC_Resistance_AMatrix = (diag(diag(GIC_Resistance_AMatrix))+GIC_Resistance_AMatrix)/2;  % Each off-diagonal element is counted twice, halfed here
mat1 = zeros(Bus_Num+Sub_Num); % Enlarge the Matrix to include Substation Nodes
mat1(1:Bus_Num,1:Bus_Num) = GIC_Resistance_AMatrix;
GIC_Resistance_AMatrix = mat1;

%% Form the Transformer Grounding Admittance matrix (Z), unit: mho
GIC_Resistance_GMatrix = zeros(Bus_Num+Sub_Num); 
for i = 1:length(GIC_TX_data_R(:,1))
    if GIC_TX_data_R{i,19}~=0   % TX in service
        if GIC_TX_data_R{i,3}==0  % 2-winding TX               
            PriBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_TX_data_R{i,1});
            SecBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_TX_data_R{i,2});
            PriBus_V = GIC_SystemData.GIC_BusDataRaw{PriBus_order,3};
            SecBus_V = GIC_SystemData.GIC_BusDataRaw{SecBus_order,3};
            if strfind(GIC_TX_data_R{i,12},'Na')  % Auto Transformer
                if SecBus_V>PriBus_V    % Sometimes wrong order for auto transformers
                    num1 = GIC_TX_data_R{i,1};
                    GIC_TX_data_R{i,1} = GIC_TX_data_R{i,2};
                    GIC_TX_data_R{i,2} = num1;
                    num1 = GIC_TX_data_R{i,6};
                    GIC_TX_data_R{i,6} = GIC_TX_data_R{i,7};
                    GIC_TX_data_R{i,7} = num1;
                    num1 = PriBus_V;
                    PriBus_V = SecBus_V;
                    SecBus_V = num1;
                    num1 = PriBus_order;
                    PriBus_order = SecBus_order;
                    SecBus_order = num1;
                    num1 = GIC_TX_data_R{i,15};
                    GIC_TX_data_R{i,15} = GIC_TX_data_R{i,16};
                    GIC_TX_data_R{i,16} = num1;
                end           
                Rs = GIC_TX_data_R{i,6}*T_factor;   % Rs per phase, unit: ohm
                Rc = GIC_TX_data_R{i,7}*T_factor;   % Rc per phase, unit: ohm
                Rtg2 = max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16});  % Common winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2));
                GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/Rs; % Bus Node
                GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/Rs;
                GIC_Resistance_GMatrix(PriBus_order,SecBus_order) = GIC_Resistance_GMatrix(PriBus_order,SecBus_order)-1/Rs;    
                GIC_Resistance_GMatrix(SecBus_order,PriBus_order) = GIC_Resistance_GMatrix(SecBus_order,PriBus_order)-1/Rs;
                if GIC_TX_data_R{i,9}==0&&GIC_TX_data_R{i,10}==0   % GIC blocking condition
                    GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rc+Rtg2); % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rc+Rtg2); % Substation node
                    GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rc+Rtg2);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rc+Rtg2);
                end
            elseif strfind(GIC_TX_data_R{i,12},'YNyn') % Wye-ground wye-ground connection        
                Rt1 = GIC_TX_data_R{i,6}*T_factor;   % Rt1 per phase, unit: ohm
                Rt2 = GIC_TX_data_R{i,7}*T_factor;   % Rt2 per phase, unit: ohm
                Rtg1 = GIC_TX_data_R{i,15}*T_factor;  % Primary winding grounding, unit: ohm
                Rtg2 = GIC_TX_data_R{i,16}*T_factor;  % Secondary winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2)); 
                if GIC_TX_data_R{i,9}==0   % Consider GIC blocking conditions
                    GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/(Rt1+Rtg1);    % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt1+Rtg1);    % Substation node
                    GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1)-1/(Rt1+Rtg1);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order)-1/(Rt1+Rtg1);
                end
                if GIC_TX_data_R{i,10}==0
                    GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rt2+Rtg2);    % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt2+Rtg2);    % Substation node
                    GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rt2+Rtg2);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rt2+Rtg2);
                end
            elseif ~isempty(strfind(GIC_TX_data_R{i,12},'YNd'))||~isempty(strfind(GIC_TX_data_R{i,12},'YNy')) % Wye-ground-delta connection
                Rt1 = GIC_TX_data_R{i,6}*T_factor;   % Rt1 per phase, unit: ohm
                Rt2 = GIC_TX_data_R{i,7}*T_factor;   % Rt2 per phase, unit: ohm
                Rtg1 = GIC_TX_data_R{i,15}*T_factor;  % Primary winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2));
                if GIC_TX_data_R{i,9}==0   % Consider GIC blocking conditions
                    GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/(Rt1+Rtg1);   % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt1+Rtg1);     % Substation node
                    GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1)-1/(Rt1+Rtg1);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order)-1/(Rt1+Rtg1);
                end
            elseif ~isempty(strfind(GIC_TX_data_R{i,12},'Dyn'))||~isempty(strfind(GIC_TX_data_R{i,12},'Yyn')) % Delta-wye-ground connection (GSU)
                Rt1 = GIC_TX_data_R{i,6}*T_factor;   % Rt1 per phase, unit: ohm
                Rt2 = GIC_TX_data_R{i,7}*T_factor;   % Rt2 per phase, unit: ohm
                Rtg2 = GIC_TX_data_R{i,16}*T_factor;  % Secondary winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2));
                if GIC_TX_data_R{i,10}==0   % Consider GIC blocking conditions
                    GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rt2+Rtg2);   % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt2+Rtg2);     % Substation node
                    GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rt2+Rtg2);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rt2+Rtg2);
                end
            end
        else    % 3-winding TX
            PriBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_TX_data_R{i,1});
            SecBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_TX_data_R{i,2});
            TerBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_TX_data_R{i,3});
            PriBus_V = GIC_SystemData.GIC_BusDataRaw{PriBus_order,3};
            SecBus_V = GIC_SystemData.GIC_BusDataRaw{SecBus_order,3};
            TerBus_V = GIC_SystemData.GIC_BusDataRaw{TerBus_order,3};
            if strfind(GIC_TX_data_R{i,12},'Na')  % Auto Transformer
                if SecBus_V>PriBus_V    % Sometimes wrong order for auto transformers
                    num1 = GIC_TX_data_R{i,1};
                    GIC_TX_data_R{i,1} = GIC_TX_data_R{i,2};
                    GIC_TX_data_R{i,2} = num1;
                    num1 = GIC_TX_data_R{i,6};
                    GIC_TX_data_R{i,6} = GIC_TX_data_R{i,7};
                    GIC_TX_data_R{i,7} = num1;
                    num1 = PriBus_V;
                    PriBus_V = SecBus_V;
                    SecBus_V = num1;
                    num1 = PriBus_order;
                    PriBus_order = SecBus_order;
                    SecBus_order = num1;
                    num1 = GIC_TX_data_R{i,15};
                    GIC_TX_data_R{i,15} = GIC_TX_data_R{i,16};
                    GIC_TX_data_R{i,16} = num1;
                end
                Rs = GIC_TX_data_R{i,6}*T_factor;   % Rs per phase, unit: ohm
                Rc = GIC_TX_data_R{i,7}*T_factor;   % Rc per phase, unit: ohm
                Rtg2 = max(GIC_TX_data_R{i,15},GIC_TX_data_R{i,16})*T_factor;  % Common winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2));
                GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/Rs; % Bus Node
                GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/Rs;
                GIC_Resistance_GMatrix(PriBus_order,SecBus_order) = GIC_Resistance_GMatrix(PriBus_order,SecBus_order)-1/Rs;    
                GIC_Resistance_GMatrix(SecBus_order,PriBus_order) = GIC_Resistance_GMatrix(SecBus_order,PriBus_order)-1/Rs;
                if GIC_TX_data_R{i,9}==0&&GIC_TX_data_R{i,10}==0   % GIC blocking condition
                    GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rc+Rtg2); % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rc+Rtg2); % Substation node
                    GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rc+Rtg2);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rc+Rtg2);
                end
                if ~isempty(strfind(GIC_TX_data_R{i,12},'yn'))&&GIC_TX_data_R{i,10}==0   % Tertiary in wye, Consider GIC blocking conditions
                    Rt3 = GIC_TX_data_R{i,7}*T_factor; %Rt per phase, unit: ohm
                    Rtg3 = GIC_TX_data_R{i,16}*T_factor;
                    GIC_Resistance_GMatrix(TerBus_order,TerBus_order) = GIC_Resistance_GMatrix(TerBus_order,TerBus_order)+1/(Rt3+Rtg3);    % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt3+Rtg3);    % Substation node
                    GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1)-1/(Rt3+Rtg3);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order)-1/(Rt3+Rtg3);
                end 
            else
                Rt1 = GIC_TX_data_R{i,6}*T_factor;   % Rt1 per phase, unit: ohm          
                Rt2 = GIC_TX_data_R{i,7}*T_factor;   % Rt2 per phase, unit: ohm
                Rt3 = GIC_TX_data_R{i,8}*T_factor;   % Rt3 per phase, unit: ohm
                Rtg1 = GIC_TX_data_R{i,15}*T_factor;  % Primary winding grounding, unit: ohm
                Rtg2 = GIC_TX_data_R{i,16}*T_factor;  % Secondary winding grounding, unit: ohm
                Rtg3 = GIC_TX_data_R{i,17}*T_factor;  % Tertiary winding grounding, unit: ohm
                Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(SecBus_order,2));
                if ~isempty(strfind(GIC_TX_data_R{i,12},'YN'))&&GIC_TX_data_R{i,9}==0 % Primary Wye-ground connection; Consider GIC blocking conditions  
                    GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/(Rt1+Rtg1);    % Bus Node
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt1+Rtg1);    % Substation node
                    GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1)-1/(Rt1+Rtg1);
                    GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order)-1/(Rt1+Rtg1);
                end
                temp2 = strfind(GIC_TX_data_R{i,12},'yn');
                if ~isempty(temp2)
                    if length(temp2)==2 % Secondary and Tertiary Wye-ground connection    
                        if GIC_TX_data_R{i,10}==0
                            GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rt2+Rtg2);    % Bus Node
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt2+Rtg2);    % Substation node
                            GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rt2+Rtg2);
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rt2+Rtg2);
                        end
                        if GIC_TX_data_R{i,11}==0
                            GIC_Resistance_GMatrix(TerBus_order,TerBus_order) = GIC_Resistance_GMatrix(TerBus_order,TerBus_order)+1/(Rt3+Rtg3);    % Bus Node
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt3+Rtg3);    % Substation node
                            GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1)-1/(Rt3+Rtg3);
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order)-1/(Rt3+Rtg3);
                        end
                    elseif length(temp2)==1 % Secondary and Tertiary Wye-ground-delta/delta-Wye-ground connection
                        if (temp2==3||temp2==4)&&GIC_TX_data_R{i,10}==0
                            GIC_Resistance_GMatrix(SecBus_order,SecBus_order) = GIC_Resistance_GMatrix(SecBus_order,SecBus_order)+1/(Rt2+Rtg2);    % Bus Node
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt2+Rtg2);    % Substation node
                            GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(SecBus_order,Bus_Num+Sub1)-1/(Rt2+Rtg2);
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,SecBus_order)-1/(Rt2+Rtg2);
                        elseif (temp2==5||temp2==6)&&GIC_TX_data_R{i,11}==0
                            GIC_Resistance_GMatrix(TerBus_order,TerBus_order) = GIC_Resistance_GMatrix(TerBus_order,TerBus_order)+1/(Rt3+Rtg3);    % Bus Node
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(Rt3+Rtg3);    % Substation node
                            GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(TerBus_order,Bus_Num+Sub1)-1/(Rt3+Rtg3);
                            GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,TerBus_order)-1/(Rt3+Rtg3);
                        end
                    end
                end
            end        
        end
    end
end
GIC_SystemData.GIC_TXData = GIC_TX_data_R;

if GIC_Calculation.SRNum>0
    for i = 1:length(GIC_SystemData.GIC_SwitchReactorData(:,1))  % Reactor bank provide path to ground
        if GIC_SystemData.GIC_SwitchReactorData{i,3}==1  % SR in service
            PriBus_order = find(GIC_Calculation.GIC_BusOrder==GIC_SystemData.GIC_SwitchReactorData{i,1});
            Sub1 = find(Sub_order==GIC_SystemData.GIC_BusSubstationData(PriBus_order,2));
            GIC_Resistance_GMatrix(PriBus_order,PriBus_order) = GIC_Resistance_GMatrix(PriBus_order,PriBus_order)+1/(GIC_SystemData.GIC_SwitchReactorData{i,2}*T_factor);   % Bus Node
            GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1) = GIC_Resistance_GMatrix(Bus_Num+Sub1,Bus_Num+Sub1)+1/(GIC_SystemData.GIC_SwitchReactorData{i,2}*T_factor);   % Substation node
            GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1) = GIC_Resistance_GMatrix(PriBus_order,Bus_Num+Sub1)-1/(GIC_SystemData.GIC_SwitchReactorData{i,2}*T_factor);
            GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order) = GIC_Resistance_GMatrix(Bus_Num+Sub1,PriBus_order)-1/(GIC_SystemData.GIC_SwitchReactorData{i,2}*T_factor);
        end
    end
end

for i = 1:Sub_Num
    Rg = 3*GIC_SystemData.GIC_SubstationData{find(cell2mat(GIC_SystemData.GIC_SubstationData(:,1))==Sub_order(i,1),1),6};
    GIC_Resistance_GMatrix(Bus_Num+i,Bus_Num+i) = GIC_Resistance_GMatrix(Bus_Num+i,Bus_Num+i)+1/Rg;
    Sub_G(i,1) = Rg;    % per phase
end

GIC_Resistance_Matrix = GIC_Resistance_AMatrix+GIC_Resistance_GMatrix;  % Final Admittance matrix AM = Y+Z, unit: mho

%%
GIC_Resistance_Matrix2 = zeros(Bus_Num+Sub_Num+GIC_Calculation.BoundaryNum);   % Build boundary Substations from external into admittance matrix
GIC_Resistance_Matrix2(1:Bus_Num+Sub_Num,1:Bus_Num+Sub_Num) = GIC_Resistance_Matrix;
for i = 1:GIC_Calculation.BoundaryNum
    if GIC_SystemData.GIC_BoundarySubData{i,5}==1
        BusC = find(GIC_Calculation.GIC_BusOrder==GIC_SystemData.GIC_BoundarySubData{i,3},1);
        GIC_Resistance_Matrix2(BusC,BusC) = GIC_Resistance_Matrix2(BusC,BusC)+1/GIC_SystemData.GIC_BoundarySubData{i,4};
        GIC_Resistance_Matrix2(Bus_Num+Sub_Num+i,Bus_Num+Sub_Num+i) = GIC_Resistance_Matrix2(Bus_Num+Sub_Num+i,Bus_Num+Sub_Num+i)+1/GIC_SystemData.GIC_BoundarySubData{i,4};       
        GIC_Resistance_Matrix2(BusC,Bus_Num+Sub_Num+i) = GIC_Resistance_Matrix2(BusC,Bus_Num+Sub_Num+i)-1/GIC_SystemData.GIC_BoundarySubData{i,4};
        GIC_Resistance_Matrix2(Bus_Num+Sub_Num+i,BusC) = GIC_Resistance_Matrix2(BusC,Bus_Num+Sub_Num+i);
    end
end    

%%
if Loop==1
    Branch_update = [Branch_update,GIC_Calculation.BranchDistanceInfo(:,end-6:end)];
    GIC_Calculation.BranchDistanceInfo = Branch_update;
end
GIC_Calculation.GIC_AdmitanceMatrix = GIC_Resistance_Matrix2;

end