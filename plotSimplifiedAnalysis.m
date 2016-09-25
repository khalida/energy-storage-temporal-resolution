%% plotSimplifiedAnalysis.m
% As sanity check on the more involved analysis; do a simple analysis on
% the raw 1-min resolution data:

% 1. At increasing interval lengths sum the cumulative net import, and
% cumulative net export

% 2. These should change substantially; and be closely related to the
% change in battery values with increasing interval length.

%% Running Seetings:
dataDir = ['C:\LocalData\Documents\Documents\PhD\18_DataSets\'...
    'PecanStreet_Dataport\2013\'];

intervalLengths = [1 2 5 10 30 60 120];
nIntervalLengths = length(intervalLengths);
nMinsImport = 364*24*60;

%% Import Data & Perform averaging / cumulative summing:
    
% Get a sorted list of filenames
fileNames = getSortedFileNames(dataDir);
nCustomers = length(fileNames);

% Pre-allocate cell-array to contain final results
% Each customer's results in a cell
netEnergyResults = cell(nCustomers, 1);     
% within each cell is matrix [nIntervalLengths x 3]; with columns having
% the cumulative net imports, cumulative net exports, and total net import

for ii = 1:nCustomers
    [localDateNum,  dem_kW, gen_kW] = ...
        importSinglePecanStreetCustomer([dataDir fileNames{ii}], 2,...
        nMinsImport+1);
    
    netEnergyResults{ii} = zeros(nIntervalLengths, 3);
    
    for jj = 1:nIntervalLengths
        thisInterval = intervalLengths(jj);
        netEnergyResults{ii}(jj, :) = computeCumulativeNetEnergy(dem_kW,...
            gen_kW, thisInterval);
    end
end

%% Plot the resulting data, normalized to results at 1-min interval
figure();
hold on;
for ii = 1:nCustomers
    subplot(3, 1, 1);
    plot(intervalLengths, netEnergyResults{ii}(:, 1)./...
        repmat(netEnergyResults{ii}(1, 1), [nIntervalLengths, 1]), '.-');
    hold on;
    
    subplot(3, 1, 2);
    plot(intervalLengths, netEnergyResults{ii}(:, 2)./...
        repmat(netEnergyResults{ii}(1, 2), [nIntervalLengths, 1]), '.-');
    hold on;
    
    subplot(3, 1, 3);
    plot(intervalLengths, netEnergyResults{ii}(:, 3)./...
        repmat(netEnergyResults{ii}(1, 3), [nIntervalLengths, 1]), '.-');
    hold on;
end

subplot(3,1,1);
xlabel('Interval Length [min]');
ylabel('Relative Cumulative Net Import');
grid on;

subplot(3,1,2);
xlabel('Interval Length [min]');
ylabel('Relative Cumulative Net Export');
grid on;
legend(fileNames);

subplot(3,1,3);
xlabel('Interval Length [min]');
ylabel('Relative Total Net Import [kWh]');
grid on;

%% Histograms of Relative Cumulative Net Export, Sorted by aggregation level
% First collect results
relativeNetExports = zeros(nIntervalLengths, nCustomers);
for ii = 1:nCustomers
    relativeNetExports(:, ii) = netEnergyResults{ii}(:, 2)./...
        repmat(netEnergyResults{ii}(1, 2), [nIntervalLengths, 1]);
end

figure();
hold on;
axHandles = zeros(nIntervalLengths-1, 1);
for ii = 2:nIntervalLengths
    axHandles(ii-1) = subplot(nIntervalLengths-1, 1, ii-1);
    hist(relativeNetExports(ii, :));
    ylabel([num2str(intervalLengths(ii)) '-min interval']);
end
xlabel('Net Export, Relative to 1-minute Net Export []');
linkaxes(axHandles,'x');