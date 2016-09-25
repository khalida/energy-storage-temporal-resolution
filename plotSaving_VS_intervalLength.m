folderName = '.\20160922_collecting_TR_5kWh\';

fileNames = getSortedFileNames(folderName);

nFiles = length(fileNames);

battValues = cell(nFiles, 1);

%% Load data into long table
allBattValues = [];
for ii = 1:nFiles
    battValues{ii} = importSingleBatteryValue([folderName fileNames{ii}]);
    allBattValues = [battValues{ii}; allBattValues]; %#ok<AGROW>
end

%% Normalise performance to that of shortest interval length
uniqueCustomers = unique(allBattValues.CustNo);
nUniqueCustomers = length(uniqueCustomers);

uniqueIntervalLengths = unique(allBattValues.TimeResMin);
nIntervalLengths = length(uniqueIntervalLengths);

battSavingRelative = ones(nUniqueCustomers, nIntervalLengths).*NaN;

for ii = 1:nUniqueCustomers
    thisCustId = uniqueCustomers(ii);
    thisCustFinestInterval = min(allBattValues(allBattValues.CustNo == ...
        thisCustId, :).TimeResMin);
    
    thisCustFinestCostSaving = allBattValues(allBattValues.CustNo == ...
        thisCustId & allBattValues.TimeResMin == ...
        thisCustFinestInterval, :).CostSavingA;
    
    for jj = 1:nIntervalLengths
        thisIntervalLength = uniqueIntervalLengths(jj);
        if thisIntervalLength < thisCustFinestInterval
            continue;
        else
            battSavingRelative(ii, jj) = allBattValues(...
                allBattValues.CustNo == thisCustId & ...
                allBattValues.TimeResMin == thisIntervalLength...
                , :).CostSavingA / thisCustFinestCostSaving;
        end
    end
end

%% Plot the results, one line per customer
plot(uniqueIntervalLengths, battSavingRelative, '.-');
xlabel('Interval Length [minutes]');
ylabel('Cost saved relative to 1-minute Interval');
grid on;


%% Plot the results, a histogram for each aggregation level
figure();
hold on;
axHandles = zeros(nIntervalLengths-1, 1);
for ii = 2:nIntervalLengths
    axHandles(ii-1) = subplot(nIntervalLengths-1, 1, ii-1);
    hist(battSavingRelative(:, ii));
    ylabel([num2str(uniqueIntervalLengths(ii)) '-min']);
end
xlabel('5kWh Battery Value, Relative to 1-min interval value []');
linkaxes(axHandles,'x');
xlim([min(battSavingRelative(:)), max(battSavingRelative(:))]);
