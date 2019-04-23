% process aquadopp with new protocole



%% USER PART (define by user)
WWmeta.root_data='/Users/aleboyer/ARNAUD/SCRIPPS/';
WWmeta.root_script='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
WWmeta.Cruise_name='NISKINE'; % 
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

WWmeta.rbrpath=sprintf('%s%s/%s/%s/rbr/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);
WWmeta.epsipath=sprintf('%s%s/%s/%s/epsi/',WWmeta.root_data,...
    WWmeta.Cruise_name,...
    WWmeta.WW_name,...
    WWmeta.deployement);

WWmeta.name_rbr=[WWmeta.WW_name '_rbr_' WWmeta.deployement];

WWmeta.figure_path=[WWmeta.root_data 'FIGURES/'];
WWmeta.gpsFile='/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/WW_location_log3.csv';


addpath(fullfile(WWmeta.root_script,'Toolbox/'))
addpath(fullfile(WWmeta.root_script,'Toolbox/rsktools'))
addpath(fullfile(WWmeta.root_script,'Toolbox/seawater'))


%% process rbr
process_rbr(WWmeta)
create_profiles_rbr(WWmeta)
load([WWmeta.rbrpath 'Profiles_' WWmeta.name_rbr],'RBRprofiles')
Lprofile=cellfun(@(x) length(x.time),RBRprofiles);
indok=find(Lprofile>1);
RBRprofiles=RBRprofiles(indok);
save([WWmeta.rbrpath 'Profiles_' WWmeta.name_rbr],'RBRprofiles')
create_grid_rbr(WWmeta)

%% process aqd
process_aqd_2G(WWmeta)
create_profiles_aqd_2G(WWmeta)
create_grid_aqd_2G(WWmeta)
add_drift_soda(WWmeta)

% process epsi
% from ctd T time series
%switch on epsi 
% May 24 09:11:23
load('/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/d2/rbr/WW_rbr_d2.mat')
Epsi=load('/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/d2/epsi/epsi_ep_test_20170101_000000_1_EPSI.mat');
ax(1)=subplot(211); 
plot(WW_rbr_d2.T)
ax(2)=subplot(212);
plot(Sensor2(1:10:end))
%cursor_start_rbr.Position(1)=218442
%cursor_end_rbr.Position(1)=283421
%cursor_start_epsi.Position(1)=2058410 
%cursor_end_epsi.Position(1)=9580480
timeepsi=linspace(WW_rbr_d2.time(218442),WW_rbr_d2.time(283421),9580480-2058410+1);
ax(1)=subplot(211); 
plot(WW_rbr_d2.time(218442:283421),WW_rbr_d2.T(218442:283421))
ax(2)=subplot(212);
plot(timeepsi,Epsi.Sensor2(2058410:9580480))
linkaxes(ax,'x')


begin_sample_epsi=2058410;
end_sample_epsi=9580480;
delta_ind=end_sample_epsi-begin_sample_epsi;
% FYI: Sampling freq 325.48 Hz

Epsi1.EPSItime=timeepsi;
Epsi1.Sensor1=Epsi.Sensor1(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor2=Epsi.Sensor2(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor3=Epsi.Sensor3(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor4=Epsi.Sensor4(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor6=Epsi.Sensor6(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor7=Epsi.Sensor7(begin_sample_epsi:end_sample_epsi);
Epsi1.Sensor8=Epsi.Sensor8(begin_sample_epsi:end_sample_epsi);
Epsi1.nbsample=Epsi.nbsample(begin_sample_epsi:end_sample_epsi);

epsifilesync = 'epsi_rbrsync_EPSI.mat';
Sensor1=Epsi1.Sensor1;
Sensor2=Epsi1.Sensor2;
Sensor3=Epsi1.Sensor3;
Sensor4=Epsi1.Sensor4;
Sensor5=Epsi1.Sensor4*0;
Sensor6=Epsi1.Sensor6;
Sensor7=Epsi1.Sensor7;
Sensor8=Epsi1.Sensor8;
EPSItime=Epsi1.EPSItime;
nbsample=Epsi1.nbsample;

save([WWmeta.epsipath epsifilesync],'EPSItime',...
                             'nbsample',...   
                             'Sensor1',...
                             'Sensor2',...
                             'Sensor3',...
                             'Sensor4',...
                             'Sensor5',...
                             'Sensor6',...
                             'Sensor7',...
                             'Sensor8',...
                             '-v7.3')


addpath EPSILON/toolbox/misc                         
create_profiles_EPSIWW;



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




