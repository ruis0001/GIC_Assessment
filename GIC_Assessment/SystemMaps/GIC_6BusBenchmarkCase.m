% === GIC Benchmark Case - From GIC Appilcation Guide 2013 - NERC GIC Workgroup ===

%% System Std.
GIC_GlobalSettings.CalcPSSEFileName = 'GIC_6BusBenchmarkCase';
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
     6,'BUS6        ',  21.0000
    };

%% Line data
% FromBus | ToBus | Circuit# | LineRpu | LineXpu | Line_Status | Line_Length
GIC_Line_data = {
     2,     3,'1 ', 2.961E-3/0.9, 1.00000E1,   1,   121.03
     4,     5,'1 ', 1.866E-3/0.9, 1.00000E1,   1,   160.18
    };

%% Transformer data
% PriBus | SecBus | TerBus | TX ID# | TXName | PriR | SecR | TerR | GICblockingPri | GICblockingSec | GICblockingTer | Connection | CoreType | Kfactor | PriGrdingR | SecGrdingR | TerGrdingR | NoUse | InService | Relevant to Study (If Dominion owned)| Make
GIC_TX_data = {
     2,     1,     0,'1 ','T1          ',0.5 , 0.0 , 0.0, 0, 0, 0,  'YNd1',0,0.6,0,0,0,0,1,1,1
     3,     4,     0,'1 ','T2          ',0.2 , 0.2 , 0.0, 0, 0, 0,  'YNa0',0,1.18,0,0,0,0,1,1,1
     5,     6,     0,'2 ','T3          ',0.5 , 0.0 , 0.0, 0, 0, 0,  'YNd1',0,0.6,0,0,0,0,1,1,1 
    };

%% Bussubstation data
% Bus# | Substation#
GIC_BusSubstation_data = [
     1, 1
     2, 1
     3, 2
     4, 2
     5, 3
     6, 3
];   

%% Substation data
% Substation# | SubstationName | Latitude | Longitude | GroundingR
GIC_Substation_data = {
1,' SUBSTATION1', 0, 33.6135, -87.3737, 0.2
2,' SUBSTATION2', 0, 34.3104, -86.3658, 0.2
3,' SUBSTATION3', 0, 33.9551, -84.6794, 0.2
};

%% Boundary Substation data
% Substation# | SubstationName | Bus# | EquiLineR | in-service (1/0)
GIC_BoundarySub_data = [];

%% Reactor bank data
% Bus# | ReactorR | Inservice | Name | Substation#
GIC_SR_data = [];