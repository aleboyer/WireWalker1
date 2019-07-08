function CTD = telemetry_Concerto_struct(filename, startRow, endRow)
% get data in concerto file from rbr website
% create a CTD structure
% 
% CTD.time 
% CTD.P    
% CTD.T    
% CTD.C    
% CTD.Chla 
% CTD.bs   
% CTD.CDOM 
% CTD.PAR  
% CTD.Irr1 
% CTD.Irr2 
% CTD.Irr3 

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
CTD.info=cellfun(@(x) x{1},info,'UniformOutput',false);
%% get data

CTD.time =dataArray{1};
CTD.P    =dataArray{4};
CTD.T    =dataArray{3};
CTD.C    =dataArray{2};
CTD.Chla =dataArray{6};
CTD.bs   =dataArray{5};
CTD.CDOM =dataArray{7};
CTD.PAR  =dataArray{8};
CTD.Irr1 =dataArray{9};
CTD.Irr2 =dataArray{10};
CTD.Irr3 =dataArray{11};


CTD.lat  =
CTD.lon  =
