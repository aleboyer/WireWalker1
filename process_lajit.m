% process aquarius with new protocole

% [pathstr,name,ext] = fileparts(mfilename);

addpath(fullfile(cd,'Toolbox/'))
addpath(fullfile(cd,'Toolbox/rsktools'))
addpath(fullfile(cd,'Toolbox/seawater'))


%% USER PART (define by user)
% WWmeta.root_data='/Volumes/LaJIT/Moorings/';
% WWmeta.root_script='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
% WWmeta.Cruise_name='LAJIT2016'; % 
% WWmeta.WW_name='JohnWesleyPowell'; % 
% WWmeta.deployement='d17';

% AHUA MUST BE MOUNTED: !bash ~/cronjobs/mount_ahua
WWmeta.root_data= '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/LaJIT/Moorings/';
WWmeta.root_script=cd;
WWmeta.Cruise_name='LAJIT2016'; % 
WWmeta.WW_name='JohnWesleyPowell'; % 
WWmeta.deployement='d19';
WWmeta.data_path = fullfile(WWmeta.root_data,WWmeta.Cruise_name,'WW',WWmeta.WW_name);
WWmeta.sn = 'RBR-65798';
topfolder = '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/LaJIT/Moorings/LAJIT2016/WW/JohnWesleyPowell/';


%% create paths
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

%% Create or Update Index
% assumes that there are NN deployments in directories labeled dNN
ndeploy = str2num(WWmeta.deployement(2:end));
if ~exist(fullfile(topfolder,'Index.mat'),'file')
    %create and populate the index file
    for ii = 1:ndeploy
        try 
            load(fullfile(topfolder,['d',num2str(ii)],'L1',[WWmeta.WW_name,'_grid.mat']),'RBRgrid')
            Index.start(ii) = RBRgrid.time(1);
            Index.end(ii) = RBRgrid.time(end);
            Index.nprofiles(ii) = length(RBRgrid.time);
        catch ME
            Index.start(ii) = NaN;
            Index.end(ii) = NaN;
            Index.nprofiles(ii) = NaN;
        end
    end
else
    %list the deployments that have not been processed and added, and add
    %the current deployment to the index  
    load(fullfile(topfolder,'Index.mat'))
            id = find(isnan(Index.start));
            if ~isempty(id)
            disp(['Deployments ',num2str(id), 'have not been processed'])
            end
end

save(fullfile(topfolder,'Index.mat'),'Index')


%% process rbr
process_rbr(WWmeta)
create_profiles_rbr(WWmeta)
create_grid_rbr(WWmeta)

%% process aqd
process_aqd(WWmeta)
create_profiles_aqd(WWmeta)
create_grid_aqd(WWmeta)

%% create combined grids with processed fields for each deployment; update Index accordingly
combine_addfields_WW_deployments(WWmeta,1:19)

%% AFTER RUNNING ANY NEW PROCESSING, BE SURE TO GENERATE A NEW MASTER FILE 
% AND SAVE IT ON KIPAPA!!!!
WWgrid_final = get_WW_data(WWmeta,Index.start(1),Index.end(end));
save(fullfile(WWmeta.data_path,'WWgrid_final.mat'),'WWgrid_final')

%%
% these compile scripts still exist, but are obsolete
% compile_deployement(WWmeta,1:length(Index.start))
% add_AQD_to_combined(WWmeta,1:10)

