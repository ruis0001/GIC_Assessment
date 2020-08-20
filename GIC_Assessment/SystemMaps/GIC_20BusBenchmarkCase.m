% === GIC Benchmark Case - From GIC Appilcation Guide 2013 - NERC GIC Workgroup ===

%% System Std.
GIC_GlobalSettings.CalcPSSEFileName = 'GIC_20BusBenchmarkCase';
System_base_MVA = 100;
System_base_Freq = 60;

%% Bus data
% Bus# | Bus Name | Bus Voltage
GIC_Bus_data = {
     1,'BUS1        ',  21.0000
     2,'BUS2        ', 345.0000
     3,'BUS3        ', 345.0000
     4,'BUS4        ', 500.0000
     5,'BUS5        ', 500.0000
     6,'BUS6        ', 500.0000
     7,'BUS7        ', 500.0000
     8,'BUS8        ', 500.0000
    11,'BUS11       ', 500.0000
    12,'BUS12       ', 500.0000
    13,'BUS13       ',  21.0000
    14,'BUS14       ',  21.0000
    15,'BUS15       ', 500.0000
    16,'BUS16       ', 345.0000
    17,'BUS17       ', 345.0000
    18,'BUS18       ',  21.0000
    19,'BUS19       ',  21.0000
    20,'BUS20       ', 345.0000
    };

%% Line data
% FromBus | ToBus | Circuit# | LineRpu | LineXpu | Line_Status | Line_Length
GIC_Line_data = {
     2,     3,'1 ', 2.95060E-3, 1.00000E-1,   1,    121.03
     2,    17,'1 ', 2.96160E-3, 1.00000E-1,   1,    160.18
     4,     5,'1 ', 9.38000E-4, 1.00000E-1,   1,    0
     4,     5,'2 ', 9.38000E-4, 1.00000E-1,   1,    0
     4,     6,'1 ', 1.86640E-3, 1.00000E-1,   1,    0
     4,    15,'1 ', 7.94400E-4, 1.00000E-1,   1,    0
     5,     6,'1 ', 1.19000E-3, 1.00000E-1,   1,    0
     5,    11,'1 ', 1.40360E-3,-3.90000E-1,   1,    0
     6,    11,'1 ', 5.77600E-4, 1.00000E-1,   1,    0
     6,    15,'1 ', 1.16960E-3, 1.00000E-1,   1,    0
     6,    15,'2 ', 1.16960E-3, 1.00000E-1,   1,    0
    11,    12,'1 ', 9.29600E-4, 1.00000E-1,   1,    0
    16,    17,'1 ', 3.91930E-3, 1.00000E-1,   1,    0
    16,    20,'1 ', 3.40180E-3, 1.00000E-1,   1,    0
    17,    20,'1 ', 5.83070E-3, 1.00000E-1,   1,    0
    };

%% Transformer data
% PriBus | SecBus | TerBus | TX ID# | TXName | PriR | SecR | TerR | GICblockingPri | GICblockingSec | GICblockingTer | Connection | CoreType | Kfactor | PriGrdingR | SecGrdingR | TerGrdingR | NoUse | InService | Relevant to Study (If Dominion owned)| Make
GIC_TX_data = {
     2,     1,      0, '1 ', 'T1          ',0.1 , 0.0 , 0.0, 1, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1     
     4,     3,      0, '1 ', 'T2          ',0.2 , 0.1 , 0.0, 0, 0, 0,  'YNyn0', 0, 1,0,0,0,0,1,1,1     
    17,     18,     0, '1 ', 'T3          ',0.1 , 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1     
    17,     19,     0, '1 ', 'T4          ',0.1 , 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1     
    16,     15,     0, '1 ', 'T5          ',0.06, 0.04, 0.0, 0, 0, 0,  'YNa0' , 0, 1,0,0,0,0,1,1,1     
     6,     7,      0, '1 ', 'T6          ',0.15, 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1     
     6,     8,      0, '1 ', 'T7          ',0.15, 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1     
     5,     20,     0, '1 ', 'T8          ',0.04, 0.06, 0.0, 0, 0, 0,  'YNyn0', 0, 1,0,0,0,0,1,1,1    
     5,     20,     0, '2 ', 'T9          ',0.04, 0.06, 0.0, 0, 0, 0,  'YNyn0', 0, 1,0,0,0,0,1,1,1    
    12,     13,     0, '1 ', 'T10         ',0.1 , 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1   
    12,     14,     0, '1 ', 'T11         ',0.1 , 0.0 , 0.0, 0, 0, 0,  'YNd1' , 0, 1,0,0,0,0,1,1,1   
     4,     3,      0, '2 ', 'T12         ',0.04, 0.06, 0.0, 0, 0, 0,  'YNa0' , 0, 1,0,0,0,0,1,1,1   
     4,     3,      0, '3 ', 'T13         ',0.2 , 0.1 , 0.0, 0, 0, 0,  'YNyn0', 0, 1,0,0,0,0,1,1,1   
     4,     3,      0, '4 ', 'T14         ',0.04, 0.06, 0.0, 0, 0, 0,  'YNa0' , 0, 1,0,0,0,0,1,1,1  
    15,     16,     0, '2 ', 'T15         ',0.04, 0.06, 0.0, 0, 0, 0,  'YNa0' , 0, 1,0,0,0,0,1,1,1  
     };

%% Bussubstation data
% Bus# | Substation#
GIC_BusSubstation_data = [
 1, 1
 2, 1
 3, 4
 4, 4
 5, 5
 6, 6
 7, 6
 8, 6
11, 7
12, 8
13, 8
14, 8
15, 3
16, 3
17, 2
18, 2
19, 2
20, 5
];   

%% Substation data
% Substation# | SubstationName | Latitude | Longitude | GroundingR
GIC_Substation_data = {
1,' SUBSTATION1', 0, 33.6135, -87.3737, 0.2
2,' SUBSTATION2', 0, 34.3104, -86.3658, 0.2
3,' SUBSTATION3', 0, 33.9551, -84.6794, 0.2
4,' SUBSTATION4', 0, 33.5479, -86.0746, 1.0
5,' SUBSTATION5', 0, 32.7051, -84.6634, 0.1
6,' SUBSTATION6', 0, 33.3773, -82.6188, 0.1
7,' SUBSTATION7', 0, 34.2522, -82.8363, 1.0 % in the model the resistance is not given
8,' SUBSTATION8', 0, 34.1956, -81.0980, 0.1
};

%% Boundary Substation data
% Substation# | SubstationName | Bus# | EquiLineR | in-service (1/0)
GIC_BoundarySub_data = [];

%% Reactor bank data
% Bus# | ReactorR | Inservice | Name | Substation#
GIC_SR_data = [];