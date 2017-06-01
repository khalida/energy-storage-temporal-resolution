%% testCalculateBatteryValue.m

% Simple unit testing script to confirm 'calculateBatteryValue.m' function
% working as expected.

netDemand = rand(1e4, 1)-0.5;
capacity = 0.5;
etaD = 0.96;
etaC = 0.96;
C_rate = 2;
P_import = 0.3;
P_export = 0.05;
intLength = 1;


% Test out the mex'd version for speed
tic;
[ batteryValue, costNoBattery, costWithBattery, costBigBattery] = ...
    calculateBatteryValue( netDemand, capacity, etaD, etaC, C_rate,...
    P_import, P_export, intLength);

toc;

disp('batteryValue: '); disp(batteryValue);
disp('costNoBattery: '); disp(costNoBattery);
disp('costWithBattery: '); disp(costWithBattery);
disp('costBigBattery: '); disp(costBigBattery);

