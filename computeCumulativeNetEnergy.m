function [cumNetEnergy_kWh] = ...
    computeCumulativeNetEnergy(dem_kW, gen_kW, intervalLength)

% INPUTS:
% dem_kW:           1-minute resolution demand time-series
% gen_kW:           1-minute reoslution PV time-series
% intervalLength:   Interger no. of intervals to consider at once

% OUTPUTS:
% cumNetEnergy_kWh: Cumulative net energy imports and exports and the total
                    % net energy import at resolution of interest

%% 1) Convert to kWh
dem_kWh = dem_kW./60;
gen_kWh = gen_kW./60;

                    
%% 2) Average the timeseries by req'd no. of intervals:
dem_kWh_sum = sumEachN(dem_kWh, intervalLength);
gen_kWh_sum = sumEachN(gen_kWh, intervalLength);


%% 3.1) Find cumulative net imports
cumNetEnergy_kWh = zeros(1, 2);
cumNetEnergy_kWh(1) = sum(max((dem_kWh_sum - gen_kWh_sum), 0));

%% 3.2) Find cumulative net exports
cumNetEnergy_kWh(2) = sum(max((gen_kWh_sum - dem_kWh_sum), 0));

%% 3.3) Find the total net import
cumNetEnergy_kWh(3) = sum(dem_kWh_sum) - sum(gen_kWh_sum);

end