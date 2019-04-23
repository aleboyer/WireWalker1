% process aquadopp with new protocole
WWpath='~/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
Meta_Data.path_mission='/Volumes/DataDrive';
addpath(genpath(fullfile(WWpath)))


%% USER PART (define by user)
Meta_Data.path_mission='/Volumes/DataDrive';
Meta_Data.WW_script=WWpath;
Meta_Data.mission='WW_AQDTUTO'; % 
Meta_Data.vehicle_name='FOO'; % 
Meta_Data.deployment='d1';

%% create path
Meta_Data.L1path=fullfile(Meta_Data.path_mission,Meta_Data.mission,...
    Meta_Data.vehicle_name,...
    Meta_Data.deployment,'L1');

Meta_Data.adcppath=fullfile(Meta_Data.path_mission,...
    Meta_Data.mission,...
    Meta_Data.vehicle_name,...
    Meta_Data.deployment,...
    'nortek');
Meta_Data.name_adcp=[Meta_Data.vehicle_name '_ntk_' Meta_Data.deployment];

Meta_Data.CTDpath=fullfile(Meta_Data.path_mission,...
    Meta_Data.mission,...
    Meta_Data.vehicle_name,...
    Meta_Data.deployment,...
    'ctd');
Meta_Data.name_ctd=[Meta_Data.vehicle_name '_ctd_' Meta_Data.deployment];

%% process rbr
process_ctd(Meta_Data);
% define casts using CTD data

[CTDProfile.up,CTDProfile.down,CTDProfile.dataup,CTDProfile.datadown] = ...
                           mod_getcastctd(Meta_Data,.5,3);

create_grid_ctd(Meta_Data)

%% process adcp

process_aqd_2G(Meta_Data)
create_profiles_aqd_2G(Meta_Data)
add_drift_soda(Meta_Data)
create_grid_aqd_2G(Meta_Data)





