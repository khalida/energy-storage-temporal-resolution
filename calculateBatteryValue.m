function [ battValue, costNoBatt, costWithBatt, kWhThroughPut] = ...
    calculateBatteryValue( netDemand, unixTimes, battery, tariff,...
    intLength)

% calculateBatteryValue: Determine the cost-saving offered by battery,
%                           given the inputs outlined below.

%% INPUTS:
% netDemand: [T x 1] vector of net demand (demand - PV). T intervals long.
%                       [kWh over the interval]
% battery:   structure containing info about the battery (capacity, 
%            etaD, etaC, C_rate)
% tariff:    structure containing info about tariff structure
%            (P_import_hi, P_import_lo, P_export, hour_hi_start,
%            hour_hi_stop);
% intLength: duration of an interval in hours

nIntervals = size(netDemand, 1);

%% Create import and export price vectors:
P_export = ones(nIntervals, 1).*tariff.P_export;
P_import = ones(nIntervals, 1).*tariff.P_import_lo;
dateVectors = datevec(unixTimes); % [Yr, Mnth, Day, Hour, Min, Sec]
hourNumbers = dateVectors(:, 4);
P_import(hourNumbers >= tariff.hour_hi_start & ...
    hourNumbers <= tariff.hour_hi_stop) = tariff.P_import_hi;

%% Calculate cost without a battery available:
costNoBatt = sum(P_import.*max(netDemand, 0) - ...
    P_export.*max(-netDemand, 0));


%% For more realistic battery run through time-series, assuming we start
% at zero SoC

% Unpack battery structure:
capacity = battery.capacity;
C_rate = battery.C_rate;
etaD = battery.etaD;
etaC = battery.etaC;

SoC = 0.5*capacity;
SoC_ts = zeros(nIntervals+1, 1);
SoC_ts(1) = SoC;
totalCost = 0.0;
kWhThroughPut = 0.0;
maxCharge = capacity*C_rate*intLength;

for tt = 1:nIntervals
    thisNetDemand = netDemand(tt);
    
    if thisNetDemand > 0
        % Use from battery if possible, otherwise import
        energyFromBattery = min(thisNetDemand/etaD, min(maxCharge, SoC));
        energyFromGrid = thisNetDemand - energyFromBattery*etaD;
        SoC = SoC - energyFromBattery;
        totalCost = totalCost + energyFromGrid*P_import(tt);
        kWhThroughPut = kWhThroughPut + abs(energyFromBattery);
    else
        % Charge up battery if possible, otherwise export
        energyToBattery = min(-thisNetDemand*etaC, min(maxCharge, ...
            capacity - SoC));
        
        energyToGrid = -thisNetDemand - energyToBattery/etaC;
        SoC = SoC + energyToBattery;
        totalCost = totalCost - energyToGrid*P_export(tt);
        kWhThroughPut = kWhThroughPut + abs(energyToBattery);
    end
    SoC_ts(tt+1) = SoC;
end

costWithBatt = totalCost;
battValue = costNoBatt - totalCost;

end
