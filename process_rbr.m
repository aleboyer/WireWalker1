function process_rbr(Meta_Data)


% adding path 


% used in process_WW should be the name after the folder WW in dirName ;

Meta_Data.ctdfile=dir(fullfile(Meta_Data.ctdpath,'*.rsk'));
if length(Meta_Data.ctdfile)>2;
    fprintf('Watch out \nThere is more than one rsk file\n')
    for j=1:length(filedir); disp(Meta_Data.ctdfile(j).name);end
end
fprintf('read rbr file is %s\n',Meta_Data.ctdfile(1).name)

disp('RSK_wrapper--- It may take a while --- coffee time?')

RSKfile= fullfile(Meta_Data.ctdpath,Meta_Data.ctdfile(1).name);
RSKdb=RSKopen(RSKfile);
RSKread=RSKreaddata(RSKdb);
rsk_struct_raw=RSK_struct(RSKread);
eval([Meta_Data.name_ctd '=rsk_struct_raw;'])

save(fullfile(Meta_Data.ctdpath,[Meta_Data.name_ctd '.mat']),Meta_Data.name_ctd);



