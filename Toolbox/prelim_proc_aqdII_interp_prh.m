function prelim_proc_aqdII_interp_prh(WWmeta)
% prelim processing of the AQDII data from

%load and transform aqdII data
disp(WWmeta.aqdpath)
f=dir([WWmeta.aqdpath '*ad2cp*.mat']);
fprintf('be carefull at the order of file in dir(%s*ad2cp*.mat) \n',WWmeta.aqdpath)
beg=zeros(1,length(f));
cell_Data=struct([]);
for l=1:length(f)
    load([WWmeta.aqdpath f(l).name])
    beg(l)=Data.Burst_MatlabTimeStamp(1);
    cell_Data{l}=Data;
    cell_Config{l}=Config;
end
[beg,I]=sort(beg);

temp = calcHPR_YUPDOWN(cell_Data{I(1)}, cell_Config{I(1)});
temp=Signature_beam2xyz2enu(temp);
eval([WWmeta.name_aqd '=temp;']);
for i=2:length(I)
    disp([num2str(i) '-' num2str(length(I))])
    temp = calcHPR_YUPDOWN(cell_Data{I(i)}, cell_Config{I(i)});
    temp=Signature_beam2xyz2enu(temp);
    eval([WWmeta.name_aqd '=mergefields(' WWmeta.name_aqd ',temp,1,1);']);
end
save([WWmeta.aqdpath WWmeta.name_aqd '.mat'],WWmeta.name_aqd, '-v7.3')
