function [localDateNum,dem_kW,gen_kW] = ...
    importSinglePecanStreetCustomer(fName, startRow, endRow)

%importfile: Import a single user's data from pecan-street database. Data
%               is in semi-colon separated value format, with a single
%               header row:
%               "localminute";"use";"gen"
%               and subsequent rows containing the associated data

%% Initialize variables.
delimiter = ';';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%q)
%	column2: double (%f)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(fName,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1,...
    'Delimiter', delimiter, 'HeaderLines', startRow(1)-1,...
    'ReturnOnError', false);

for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec,...
        endRow(block)-startRow(block)+1, 'Delimiter', delimiter,...
        'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
% localDateNum is formatted from the input date-time string:
localDateNum = datenum(dataArray{:, 1}, 'yyyy-mm-dd HH:MM:SS');
dem_kW = dataArray{:, 2};
gen_kW = dataArray{:, 3};

end