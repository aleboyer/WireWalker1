% process aquarius with new protocole


addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master
addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/Toolbox/
addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/Toolbox/rsktools/
addpath /Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/Toolbox/seawater/


%% USER PART (define by user)
WWmeta.root_data='/Volumes/LaJIT/Moorings/';
WWmeta.root_script='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
WWmeta.Cruise_name='LAJIT2016'; % 
WWmeta.WW_name='JohnWesleyPowell'; % 
WWmeta.deployement='d17';


%% create path
WWmeta.WWpath=sprintf('%s/%s/WW/%s/%s/L1/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.aqdpath=sprintf('%s%s/WW/%s/%s/aqd/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.name_aqd=[WWmeta.WW_name '_aqd_' WWmeta.deployement];

WWmeta.rbrpath=sprintf('%s%s/WW/%s/%s/rbr/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.name_rbr=[WWmeta.WW_name '_rbr_' WWmeta.deployement];

WWmeta.telemetrypath=sprintf('%s%s/WW/%s/downloaded_data/data_mat/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name);

WWmeta.compilepath=sprintf('%s%s/WW/%s/compile_deployment/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name);




WWmeta.figure_path=[WWmeta.root_data 'FIGURES/LAJIT/'];


%% process rbr
process_rbr(WWmeta)
create_profiles_rbr(WWmeta)
create_grid_rbr(WWmeta)

%% process aqd
process_aqd(WWmeta)
create_profiles_aqd(WWmeta)
create_grid_aqd(WWmeta)


%compile
compile_deployement(WWmeta,1:17)

