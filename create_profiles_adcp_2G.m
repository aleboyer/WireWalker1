function create_profiles_adcp_2G(Meta_Data)


load([Meta_Data.adcppath WWmeta.name_adcp '.mat'], Meta_Data.name_adcp)
eval(['[up,down,ADCPprofiles.dataup,ADCPprofiles.datadown] = getcastnortek(' Meta_Data.name_adcp ',5);'])

save([Meta_Data.adcppath 'Profiles_' WWmeta.name_adcp],'ADCPprofiles','-v7.3')

