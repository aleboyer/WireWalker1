%after downloading the csv file from Xeos.online
%read_Xeos_csv;
function read_Xeos_csv_perso(Meta_Data)
%filename = '/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/WW_location_log2.csv';
filename=Meta_Data.gpsfile;
delimiter = ',';
startRow = 2;
% For more information, see the TEXTSCAN documentation.
%formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');


timestamp=datenum(vertcat(dataArray{4}{:}));
data1=dataArray{5};
data2=dataArray{6};
Longitude=zeros(length(data1));
Latitude=zeros(length(data1));
for i=1:length(data1)
    Longitude(i)=str2double(data1{i}(2:end-1));
    Latitude(i) =str2double(data2{i}(2:end-1));
end


toto=Longitude;


