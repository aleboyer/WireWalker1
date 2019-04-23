function create_profiles_aqd_2G(WWmeta)

addpath([WWmeta.root_script 'Toolbox/seawater/'])

load([WWmeta.aqdpath WWmeta.name_aqd '.mat'], WWmeta.name_aqd)
eval(['[up,~,AQDprofiles,~] = getcastnortek(' WWmeta.name_aqd ',5);'])

save([WWmeta.aqdpath 'Profiles_' WWmeta.name_aqd],'AQDprofiles','-v7.3')

