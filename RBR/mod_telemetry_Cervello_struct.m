function Cervello = mod_telemetry_Cervello_struct(filename, startRow, endRow)
% get data lat lon in Cervello file from rbr website
% create a Cervello. structure
% 
% Cervello..lat 
% Cervello..lon    

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';
formatInfo = '%s%s%s%s%s%s%s%[^\n\r]';
%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
info=textscan(fileID, formatInfo, 1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%% Close the text file.
fclose(fileID);
%% make a cell with channel description
info=info(:);
Cervello.info=cellfun(@(x) x{1},info,'UniformOutput',false);
%% get data

Cervello.time     =dataArray{1};
Cervello.lat      =dataArray{2};
Cervello.lon      =dataArray{3};
Cervello.HDOP     =dataArray{4};
Cervello.Bat_int  =dataArray{5};
Cervello.Bat_ext  =dataArray{6};
Cervello.Bat_buoy =dataArray{7};

