function add_drift(Meta_Data)

%% add positions of deployment
%% add positions of WW_name
fprintf('Add WW trajectory\n')
GPS = import_wwGPS(Meta_Data.gpsfile);
load(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'ADCPgrid')

WW_pos(:,1)=GPS.Longitude;
WW_pos(:,2)=GPS.Latitude;
WW_pos(:,3)=GPS.Timestamp;
[~,iU] = unique(GPS.Timestamp);
WW_pos = sortrows(WW_pos(iU,:),3);

% There's no gpsQuality in the GPS data Harper downloaded on SODA as ww.csv
% (Meta_Data.gpsFile). Comment this part out
%     lon=WW_pos(GPS.([Meta_Data.WW_name '_pos']).gpsQuality==3,1);
%     lat=WW_pos(GPS.([Meta_Data.WW_name '_pos']).gpsQuality==3,2);
%     time1=WW_pos(GPS.([Meta_Data.WW_name '_pos']).gpsQuality==3,3);
lon = WW_pos(:,1);
lat = WW_pos(:,2);
time1 = WW_pos(:,3);

ADCPgrid.lat=interp1(time1,lat,ADCPgrid.time);
ADCPgrid.lon=interp1(time1,lon,ADCPgrid.time);


[dist1,az]=m_lldist_az(ADCPgrid.lon, ADCPgrid.lat);
dist1=[0 dist1'];
az=[0 az'];
dist1=cumsum(dist1);

ADCPgrid.dist=dist1;
ADCPgrid.drift=nan(size(ADCPgrid.dist));
ADCPgrid.drift(2:end)=diff(ADCPgrid.dist*1000)./(diff(ADCPgrid.time)*86400);
ADCPgrid.drift(1)=ADCPgrid.drift(2);
ADCPgrid.n_drift=ADCPgrid.drift.*cosd(az);
ADCPgrid.e_drift=ADCPgrid.drift.*sind(az);

ADCPgrid.n_drift=conv2(ADCPgrid.n_drift,gausswin(12)'./sum(gausswin(12)),'same');
ADCPgrid.e_drift=conv2(ADCPgrid.e_drift,gausswin(12)'./sum(gausswin(12)),'same');

[n1,n2,n3] = size(ADCPgrid.Burst_VelEast);
if n3==1 %aqd case
e_drift1 = repelem(ADCPgrid.e_drift,n1);
e_drift2 = reshape(e_drift1,[n1,n2]);
n_drift1 = repelem(ADCPgrid.n_drift,n1);
n_drift2 = reshape(n_drift1,[n1,n2]);

else
e_drift1 = repelem(ADCPgrid.e_drift,n1*n2);
e_drift2 = reshape(e_drift1,[n1,n2,n3]);
n_drift1 = repelem(ADCPgrid.n_drift,n1*n2);
n_drift2 = reshape(n_drift1,[n1,n2,n3]);
end
ADCPgrid.e_abs=ADCPgrid.Burst_VelEast+e_drift2;
ADCPgrid.n_abs=ADCPgrid.Burst_VelNorth+n_drift2;


    if exist(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'file')
        load(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid')
        save(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid','ADCPgrid')
    else
        save(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'ADCPgrid')
    end

end
    
