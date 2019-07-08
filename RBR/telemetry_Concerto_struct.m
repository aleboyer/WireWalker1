function Concerto = telemetry_Concerto_struct(filename, startRow, endRow)
% get data in concerto file from rbr website
% create a Concerto. structure
% 
% Concerto.time 
% Concerto.P    
% Concerto.T    
% Concerto.C    
% Concerto.Chla 
% Concerto.bs   
% Concerto.CDOM 
% Concerto.PAR  
% Concerto.Irr1 
% Concerto.Irr2 
% Concerto.Irr3 

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
formatInfo = '%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
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
Concerto.info=cellfun(@(x) x{1},info,'UniformOutput',false);
%% get data

Concerto.time =dataArray{1};
Concerto.P    =dataArray{4};
Concerto.T    =dataArray{3};
Concerto.C    =dataArray{2};
Concerto.Chla =dataArray{6};
Concerto.bs   =dataArray{5};
Concerto.CDOM =dataArray{7};
Concerto.PAR  =dataArray{8};
Concerto.Irr1 =dataArray{9};
Concerto.Irr2 =dataArray{10};
Concerto.Irr3 =dataArray{11};

