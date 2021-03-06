function prelim_proc_adcpII_2G(WWmeta)
% prelim processing of the AQDII data from

%load and transform adcpII data
disp(WWmeta.adcppath)
%f=dir([WWmeta.adcppath '*' WWmeta.WW_name '*.mat']);
f=dir(fullfile(WWmeta.adcppath,'*.mat'));
fprintf('be carefull at the order of file in dir(%s*ad2cp*.mat) \n',WWmeta.adcppath)
beg=zeros(1,length(f));
cell_Data=struct([]);
for l=1:length(f)
    load(fullfile(WWmeta.adcppath, f(l).name))
    if isfield(Data,'Burst_Time')
        beg(l)=Data.Burst_Time(1);
    else
        beg(l)=Data.Burst_MatlabTimeStamp(1);
    end
    cell_Data{l}=Data;
    cell_Config{l}=Config;
end
[~,I]=sort(beg);
Fields=fields(Data);
AllData=[cell_Data{I}];

AllData1=struct();
for f=1:length(Fields)
    field=Fields{f};
    AllData1.(field)=vertcat(AllData(:).(field));
end
    

if ~isfield(AllData1,'Burst_VelEast')
    AllData1 = Aqd_beam2xyz2enu( AllData1);
end



eval([WWmeta.name_adcp '=AllData1;']);
save(fullfile(WWmeta.adcppath,[WWmeta.name_adcp '.mat']),WWmeta.name_adcp, '-v7.3')
