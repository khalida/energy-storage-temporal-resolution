%% PecanStreet_run_TimSeries_Analysis:

% Run a simplified version of the analysis locally in Matlab to avoid the
% head-ache and over-head of the JAVA code which has way more functionality
% than is required.
tic;

%% Running Settings:
readDataFromMatFile = true;
matFileName = '2016_09_25_matlabFormatData.mat';

% Replace with your own data-directory
dataDir = 'C:\LocalData\Documents\Documents\PhD\18_DataSets\PecanStreet_Dataport\2013\';
resultsDir = [pwd filesep 'plots\'];

intervalLengths = [1 2 5 10 30 60];
nIntervalLengths = length(intervalLengths);

batteryCapacities = [5.0 10.0];%[0.041 5.4 1 5 10];
batteryCrates = [1.0 1.0]; %[2880 1.5 1.0 1.0 1.0];
nBatteryCapacities = length(batteryCapacities);

nMinsImport = 364*24*60;

%% Battery Properties:
battery.etaD = 0.96;
battery.etaC = 0.96;
battery.C_rate = 1.0;       % kW / kWh

%% Tariff Properties:
tariff.P_import_hi = 0.4;     % $/kWh
tariff.P_import_lo = 0.2;     % $/kWh
tariff.P_export = 0.05;       % $/kWh
tariff.hour_hi_start = 7;
tariff.hour_hi_stop = 22;


%% Import Data & Perform averaging / cumulative summing:

% Get a sorted list of filenames
fileNames = getSortedFileNames(dataDir);
nCustomers = length(fileNames);

% Pre-allocate cell-array to contain final results
% Each customer's results in a cell
batteryValueResults = cell(nCustomers, nBatteryCapacities);
% within each cell is matrix [nIntervalLengths x 4]; with columns having:
% [battValue, costNoBatt, costWithBatt, kWhThroughPut]

% Cell structure to store all of the data & results
localDateNum = cell(nCustomers, 1);
dem_kW = cell(nCustomers, 1);
gen_kW = cell(nCustomers, 1);

relativeBatteryValue = cell(nBatteryCapacities, 1);
absBatteryValue = cell(nBatteryCapacities, 1);
kWhThrouhput = cell(nBatteryCapacities, 1);

for capacityIdx = 1:nBatteryCapacities;     % kWh
    
    battery.capacity = batteryCapacities(capacityIdx);
    battery.Crate = batteryCrates(capacityIdx);
    
    if readDataFromMatFile
        load(matFileName);
        nCustomers = size(gen_kW, 1);
    else
        for ii = 1:nCustomers %#ok<UNRCH>
            [localDateNum{ii},  dem_kW{ii}, gen_kW{ii}] = ...
                importSinglePecanStreetCustomer([dataDir fileNames{ii}], 2,...
                nMinsImport+1);
        end
    end
    
    for ii = 1:nCustomers
        batteryValueResults{ii, capacityIdx} = zeros(nIntervalLengths, 4);
        
        for jj = 1:nIntervalLengths
            thisInterval = intervalLengths(jj);
            
            % Aggregated the demand and PV signals
            unixTimes = temporallyAverageSignal(localDateNum{ii}, thisInterval);
            dem_kWh = temporallyAggregateSignal(dem_kW{ii}, thisInterval);
            gen_kWh = temporallyAggregateSignal(gen_kW{ii}, thisInterval);
            netDemand = dem_kWh - gen_kWh;
            
            [batteryValueResults{ii, capacityIdx}(jj, 1), ...
                batteryValueResults{ii, capacityIdx}(jj, 2), ...
                batteryValueResults{ii, capacityIdx}(jj, 3), ...
                batteryValueResults{ii, capacityIdx}(jj, 4)] = ...
                calculateBatteryValue( netDemand, unixTimes, battery, ...
                tariff, thisInterval);
        end
    end
    
    %% Plot the resulting data, normalized to results at 1-min interval
    figure();
    hold on;
    for ii = 1:nCustomers
        plot(intervalLengths, batteryValueResults{ii, capacityIdx}(:, 1)./...
            repmat(batteryValueResults{ii, capacityIdx}(1, 1), [nIntervalLengths, 1]),...
            '.-');
    end
    
    xlabel('Interval Length [min]');
    ylabel({'Battery Value', 'relative to 1-minute value'});
    grid on;
    plotAsTikz([resultsDir 'intervalLength_VS_value_' num2str(battery.capacity) 'kWh.tikz']);
    print(gcf, '-dpdf', [resultsDir 'intervalLength_VS_value_' num2str(battery.capacity) 'kWh.pdf']);
    
    %% Histograms of Relative Value, sorted by aggregation level
    % First collect results
    relativeBatteryValue{capacityIdx} = zeros(nIntervalLengths, nCustomers);
    absBatteryValue{capacityIdx} = zeros(nIntervalLengths, nCustomers);
    for ii = 1:nCustomers
        relativeBatteryValue{capacityIdx}(:, ii) = batteryValueResults{...
            ii, capacityIdx}(:, 1)./repmat(batteryValueResults{ii,...
            capacityIdx}(1, 1), [nIntervalLengths, 1]);
        
        absBatteryValue{capacityIdx}(:, ii) = batteryValueResults{ii,...
            capacityIdx}(:, 1);
    end
    
    figure();
    hold on;
    axHandles = zeros(nIntervalLengths-1, 1);
    for ii = 2:nIntervalLengths
        axHandles(ii-1) = subtightplot(nIntervalLengths-1, 1, ii-1);
        [counts,bins] = hist(relativeBatteryValue{capacityIdx}(ii, :));
        bar(bins, counts, 1); % the "1" makes the bars have full width, as is the case in a histogram
        ylabel([num2str(intervalLengths(ii)) '-min']);
        xlim([min(relativeBatteryValue{capacityIdx}(:)) ...
            max(relativeBatteryValue{capacityIdx}(:))]);
        if ii < nIntervalLengths
            set(gca, 'XTickLabel', '');
        end
        grid on;
    end
    xlabel({[num2str(battery.capacity) 'kWh Battery Value'], 'relative to value at 1-minute Interval'});
    linkaxes(axHandles,'x');
    plotAsTikz([resultsDir 'intervalLength_VS_value_histograms_' num2str(battery.capacity) 'kWh.tikz']);
    print(gcf, '-dpdf', [resultsDir 'intervalLength_VS_value_histograms_' num2str(battery.capacity) 'kWh.pdf']);
    
    %% Histograms of Battery kWh Throughput sorted by aggregation level
    % First collect results
    kWhThrouhput{capacityIdx} = zeros(nIntervalLengths, nCustomers);
    for ii = 1:nCustomers
        kWhThrouhput{capacityIdx}(:, ii) = batteryValueResults{ii, capacityIdx}(:, 4);
    end
    
    figure();
    hold on;
    axHandles = zeros(nIntervalLengths, 1);
    for ii = 1:nIntervalLengths
        axHandles(ii) = subtightplot(nIntervalLengths, 1, ii);
        [counts,bins] = hist(kWhThrouhput{capacityIdx}(ii, :));
        bar(bins, counts, 1); % the "1" makes the bars have full width, as is the case in a histogram
        ylabel([num2str(intervalLengths(ii)) '-min']);
        xlim([min(kWhThrouhput{capacityIdx}(:)) max(kWhThrouhput{capacityIdx}(:))]);
        if ii < nIntervalLengths
            set(gca, 'XTickLabel', '');
        end
        grid on;
    end
    xlabel([num2str(battery.capacity) 'kWh Battery Annual Throughput [kWh]']);
    plotAsTikz([resultsDir 'intervalLength_VS_kWhThroughput_' num2str(battery.capacity) 'kWh.tikz']);
    print(gcf, '-dpdf', [resultsDir 'intervalLength_VS_kWhThroughput_' num2str(battery.capacity) 'kWh.pdf']);
    linkaxes(axHandles,'x');
end

%% Plot time-series data for the customer with the most/least relative value
% hidden at higher temporal resolution, use 1kWh data
refIdx = (batteryCapacities == 5);
nTrain = 45;
nBins = 9;
rng(13);

if sum(refIdx) > 0
    [~, mostIdx] = min(relativeBatteryValue{refIdx}(end, :));
    [~, leastIdx] = max(relativeBatteryValue{refIdx}(end, :));
    summerIndexes = localDateNum{mostIdx} >= datenum('2013/08/01') & ...
        localDateNum{mostIdx} < datenum('2013/08/02');
    
    winterIndexes = localDateNum{mostIdx} >= datenum('2013/02/01') & ...
        localDateNum{mostIdx} < datenum('2013/02/02');
    
    dateVectors = datevec(localDateNum{mostIdx}(summerIndexes));
    fractionalHours = dateVectors(:, 4) + dateVectors(:, 5)./60;
    
    figure();
    subtightplot(2, 1, 1);
    plot(fractionalHours, [dem_kW{mostIdx}(summerIndexes),...
        gen_kW{mostIdx}(summerIndexes)]);
    
    set(gca, 'XTickLabel', '');
    ylabel('Power [kW]');
    subtightplot(2, 1, 2);
    plot(fractionalHours, [dem_kW{leastIdx}(summerIndexes),...
        gen_kW{leastIdx}(summerIndexes)]);
    
    ylabel('Power [kW]');
    xlabel('Time [Hrs]');
    legend('Demand', 'PV Output');
    plotAsTikz([resultsDir 'time_series_plot_summer.tikz']);
    print('-dpdf', [resultsDir 'time_series_plot_summer.pdf']);
    
    figure();
    subtightplot(2, 1, 1);
    plot(fractionalHours, [dem_kW{mostIdx}(winterIndexes),...
        gen_kW{mostIdx}(winterIndexes)]);
    
    set(gca, 'XTickLabel', '');
    ylabel('Power [kW]');
    subtightplot(2, 1, 2);
    plot(fractionalHours, [dem_kW{leastIdx}(winterIndexes),...
        gen_kW{leastIdx}(winterIndexes)]);
    
    ylabel('Power [kW]');
    xlabel('Time [Hrs]');
    plotAsTikz([resultsDir 'time_series_plot_winter.tikz']);
    print('-dpdf', [resultsDir 'time_series_plot_winter.pdf']);
    
    
    %% Attempt to fit linear regression model from coarse data to finer:
    % Convert everything to value relative to that given at 30-minute
    % interval
    batteryValueRel30min = absBatteryValue{refIdx}./repmat(...
        absBatteryValue{refIdx}(intervalLengths==30, :),...
        [nIntervalLengths, 1]);
    
    features = batteryValueRel30min(intervalLengths>=30 &...
        intervalLengths<=60, :)'; % [value at intervals of 10-min or longer]
    response = batteryValueRel30min(1, :)';                   % [value at 1-min]
    
    % get rid of NaNs:
    features = features(~isnan(features(:, 1)), :);
    response = response(~isnan(response(:, 1)), :);
    
    nObs = size(features, 1);
    if nObs ~= size(response, 1); error('nObs must be same!'); end;
    
    randIdxs = randperm(nObs);
    trainIdxs = randIdxs(1:nTrain);
    testIdxs = randIdxs((nTrain+1):end);
    
    coeffs = features(trainIdxs, :)\response(trainIdxs, :);
    
    figure();
    plotregression(response(testIdxs,:), features(testIdxs,:)*coeffs);
    title('Test Performance');
    
    figure();
    plotregression(response(trainIdxs,:), features(trainIdxs,:)*coeffs);
    title('Train Performance');
    
    % Finally for the test customers, plot the relative errors using estimates
    % of value at 10-minute only, and using the regression model
    errorsFrom30minData = (features(testIdxs, 1) - response(testIdxs, :))./...
        response(testIdxs, :);
    
    errorsFromRegModel = (features(testIdxs,:)*coeffs - response(testIdxs, :))./...
        response(testIdxs, :);
    
    figure();
    [counts,bins] = hist([errorsFrom30minData, errorsFromRegModel], nBins);
    bar(bins, counts, 1); % the "1" makes the bars have full width, as is the case in a histogram
    legend('30-min Data', 'Regression Model');
    xlabel({'Battery Value Error',' relative to 1-minute Value []'});
    ylabel('No. of Occurences (test set)');
    plotAsTikz([resultsDir 'errors_with_regression.tikz']);
    print('-dpdf', [resultsDir 'errors_with_regression.pdf']);
    disp('30-min error mean:'); disp(mean(errorsFrom30minData));
    disp('30-min error std:'); disp(std(errorsFrom30minData));
    disp('Regression error mean:'); disp(mean(errorsFromRegModel));
    disp('Regression error std:'); disp(std(errorsFromRegModel));
    
end

%% Summary results for battery and super-capacitor
meanBattValue = nanmean(absBatteryValue{2}, 2)';
meanBattThroughput = nanmean(kWhThrouhput{2}, 2)';
meanBattDegradation = (meanBattThroughput./(2*5.4*5000));
meanBattDepreciation = meanBattDegradation.*7700;
meanBattNetValue = meanBattValue - meanBattDepreciation;
meanBattROI = (meanBattNetValue./7700)*100;

% Print out code for latex table rows:
fprintf('Battery value [\\$] & %.0f & %.0f & %.0f & %.0f & %.0f \\\\ \\hline \n',...
    meanBattValue(1:5));

fprintf('Battery throughput [kWh] & %.0f & %.0f & %.0f & %.0f & %.0f  \\\\ \\hline \n',...
    meanBattThroughput(1:5));

fprintf('Battery degradation [] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanBattDegradation(1:5));

fprintf('Battery depreciation [\\$] & %.0f & %.0f & %.0f & %.0f & %.0f \\\\ \\hline \n',...
    meanBattDepreciation(1:5));

fprintf('Battery net value [\\$] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanBattNetValue(1:5));

fprintf('Battery ROI [\\%%] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \\hline \n',...
    meanBattROI(1:5));

meanCapValue = nanmean(absBatteryValue{1}, 2)';
meanCapThroughput = nanmean(kWhThrouhput{1}, 2)';
meanCapDegradation = (meanCapThroughput./(2*0.041*1000000));
meanCapDepreciation = meanCapDegradation.*1700;
meanCapNetValue = meanCapValue - meanCapDepreciation;
meanCapROI = (meanCapNetValue./1700)*100;

fprintf('Capacitor value [\\$] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanCapValue(1:5));

fprintf('Capacitor throughput [kWh] & %.0f & %.0f & %.0f & %.0f & %.0f \\\\ \\hline \n',...
    meanCapThroughput(1:5));

fprintf('Capacitor degradation [] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanCapDegradation(1:5));

fprintf('Capacitor depreciation [\\$] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanCapDepreciation(1:5));

fprintf('Capacitor net value [\\$] & %.2g & %.2g & %.2g & %.2g & %.2g  \\\\ \\hline \n',...
    meanCapNetValue(1:5));

fprintf('Capacitor ROI [\\%%] & %.2g & %.2g & %.2g & %.2g & %.2g \\\\ \\hline \n',...
    meanCapROI(1:5));

toc;
