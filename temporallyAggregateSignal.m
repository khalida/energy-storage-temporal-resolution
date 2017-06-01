function [ sgl_kWh ] = temporallyAggregateSignal( sgl_kW, intervalsToJoin)

%temporallyAggregateSignal: Convert a kW (1-min resolution) signal to a
%                           kWh-over-the-interval based on intervalsToJoin

%% 1) Convert to kWh (at 1-min input resolution)
sgl_kWh = sgl_kW./60;

%% 2) Aggregate the timeseries by req'd no. of intervals:
sgl_kWh = sumEachN(sgl_kWh, intervalsToJoin);

end
