function [ sgl_avg ] = temporallyAverageSignal( sgl, intervalsToJoin)

%temporallyAggregateSignal: Convert a kW (1-min resolution) signal to a
%                           kWh-over-the-interval based on intervalsToJoin

%% 1) Sum  the timeseries by req'd no. of intervals:
sgl_sum = sumEachN(sgl, intervalsToJoin);

%% 2) Divide by required No. of intervals to get average:
sgl_avg = sgl_sum./intervalsToJoin;

end
