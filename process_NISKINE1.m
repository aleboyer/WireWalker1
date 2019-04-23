% process aquadopp with new protocole

addpath(fullfile(cd,'Toolbox/'))
addpath(fullfile(cd,'Toolbox/rsktools'))
addpath(fullfile(cd,'Toolbox/seawater'))


%% USER PART (define by user)
WWmeta.root_data='/Users/aleboyer/ARNAUD/SCRIPPS/';
WWmeta.root_script='/Users/aleboyer/ARNAUD/SCRIPPS/WireWalker/WireWalker_master/';
WWmeta.Cruise_name='NISKINE'; % 
WWmeta.WW_name='WW'; % 
WWmeta.deployement='d1';

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
WWmeta.name_rbr=[WWmeta.WW_name '_rbr_' WWmeta.deployement];

WWmeta.figure_path=[WWmeta.root_data 'FIGURES/'];
WWmeta.gpsFile='/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/WW_location_log2.csv';

%% process rbr
process_rbr(WWmeta)
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
begintime_rbr=datenum('17-Apr-2018 15:25:46'); % first downcast
endtime_rbr=datenum('19-Apr-2018 01:12:14');   % last upcast
begin_sample_epsi=14955786;
end_sample_epsi=54532226;
delta_ind=end_sample_epsi-begin_sample_epsi;
% FYI: Sampling freq 325.48 Hz
% FYI: Note book epsi power in '16-Apr-2018 19:30:30' PCT;

Epsi1.EPSItime=linspace(begintime_rbr,endtime_rbr,delta_ind+1);
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
Sensor5=Epsi.Sensor5;
Sensor6=Epsi1.Sensor6;
Sensor7=Epsi1.Sensor7;
Sensor8=Epsi1.Sensor8;
EPSItime=Epsi1.EPSItime;
nbsample=Epsi1.nbsample;

save([epsipath epsifilesync],'EPSItime',...
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
create_profiles_EPSIWW;
EPSI_batchprocess_WW(Meta_Data)


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




