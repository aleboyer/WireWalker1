% process aquadopp with new protocole

addpath(fullfile(cd,'Toolbox/'))
addpath(fullfile(cd,'Toolbox/rsktools'))
addpath(fullfile(cd,'Toolbox/seawater'))
addpath(fullfile(cd,'/Users/aleboyer/ARNAUD/SCRIPPS/'))


%% USER PART (define by user)
WWmeta.root_data='/Volumes/DataDrive/';
WWmeta.root_script='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
WWmeta.Cruise_name='SODA'; % 
WWmeta.WW_name='WW'; % 
WWmeta.deployement='d2';

%% create path
WWmeta.WWpath=sprintf('%s/%s/%s/%s/L1/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.aqdpath=sprintf('%s%s/%s/%s/aqd/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.name_aqd=[WWmeta.WW_name '_aqd_' WWmeta.deployement];

WWmeta.rbrpath=sprintf('%s%s/%s/%s/ctd/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.name_rbr=[WWmeta.Cruise_name '_rbr_' WWmeta.deployement];

WWmeta.figure_path=[WWmeta.root_data 'FIGURES/'];
WWmeta.gpsFile='/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/WW_location_log2.csv';

%% process rbr
process_rbr(WWmeta)
%load('/Volumes/DataDrive/SODA/WW/d2/ctd/SODA_rbr_d2.mat')

create_profiles_rbr(WWmeta)
load([WWmeta.rbrpath 'Profiles_' WWmeta.name_rbr],'RBRprofiles')
create_grid_rbr(WWmeta)

%% process aqd
process_aqd_2G(WWmeta)
create_profiles_aqd_2G(WWmeta)
add_drift_soda(WWmeta)
create_grid_aqd_2G(WWmeta)

% process epsi
% from ctd T time series
%TODO make a function out of create_profile EPSIWW
load('/Volumes/DataDrive/SODA/WW/d2/sd_raw/Meta_SODA_d2.mat')
starttime=datenum('2018-09-13-07:00:08');
Meta_Data.starttime=starttime;

create_profiles_EPSIWW;
Meta_Data.CALIpath='/Users/aleboyer/ARNAUD/SCRIPPS/EPSILOMETER/CALIBRATION/ELECTRONICS/';
EPSI_batchprocess_TdiffWW(Meta_Data)


% ship adcp
datadir='/Users/aleboyer/ARNAUD/SCRIPPS/SP1810/MET/currents/proc';
wh_adcp='nb300';
adcp = load_getmat(fullfile(datadir, wh_adcp, 'contour', 'allbins_'));
cd(datadir)
cd ../
save('adcp_gridded.mat','adcp') 
hmmask=adcp.pflag;
hmmask(adcp.pflag>2)=nan;
hmmask(~isnan(hmmask))=1;

ax(1)=subplot(211);
colormap redblue
pcolor(adcp.dday,nanmean(adcp.depth,2),adcp.u.*hmmask);
shading flat;
ylabel('Depth /m','fontsize',15)
title('u, pflag<=2','fontsize',15)
axis ij
caxis([-.2 .2])
cax=colorbar;
set(gca,'fontsize',15)
ylabel(cax,'m/s','fontsize',15)
ax(2)=subplot(212);
pcolor(adcp.dday,nanmean(adcp.depth,2),adcp.v.*hmmask);
shading flat;
title('v, pflag<=2','fontsize',15)
ylabel('Depth /m','fontsize',15)
xlabel('year day','fontsize',15)
caxis([-.2 .2])
cax=colorbar;
ylabel(cax,'m/s','fontsize',15)
set(gca,'fontsize',15)
axis ij
print('Pflag2_sp_adcp.png','-dpng2')




