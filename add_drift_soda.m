function add_drift_soda(WWmeta)

%% add positions of WW_name
fprintf('Add WW trajectory\n')
GPS = import_wwGPS(WWmeta.gpsFile);
load([WWmeta.WWpath WWmeta.WW_name '_grid.mat'],'AQDgrid')

WW_pos(:,1)=GPS.Longitude;
WW_pos(:,2)=GPS.Latitude;
WW_pos(:,3)=GPS.Timestamp;
[~,iU] = unique(GPS.Timestamp);
WW_pos = sortrows(WW_pos(iU,:),3);

% There's no gpsQuality in the GPS data Harper downloaded on SODA as ww.csv
% (WWmeta.gpsFile). Comment this part out
%     lon=WW_pos(GPS.([WWmeta.WW_name '_pos']).gpsQuality==3,1);
%     lat=WW_pos(GPS.([WWmeta.WW_name '_pos']).gpsQuality==3,2);
%     time1=WW_pos(GPS.([WWmeta.WW_name '_pos']).gpsQuality==3,3);
lon = WW_pos(:,1);
lat = WW_pos(:,2);
time1 = WW_pos(:,3);

AQDgrid.lat=interp1(time1,lat,AQDgrid.time);
AQDgrid.lon=interp1(time1,lon,AQDgrid.time);


[dist1,az]=m_lldist_az(AQDgrid.lon, AQDgrid.lat);
dist1=[0 dist1'];
az=[0 az'];
dist1=cumsum(dist1);

AQDgrid.dist=dist1;
AQDgrid.drift=nan(size(AQDgrid.dist));
AQDgrid.drift(2:end)=diff(AQDgrid.dist*1000)./(diff(AQDgrid.time)*86400);
AQDgrid.drift(1)=AQDgrid.drift(2);
AQDgrid.n_drift=AQDgrid.drift.*cosd(az);
AQDgrid.e_drift=AQDgrid.drift.*sind(az);

AQDgrid.n_drift=conv2(AQDgrid.n_drift,gausswin(12)'./sum(gausswin(12)),'same');
AQDgrid.e_drift=conv2(AQDgrid.e_drift,gausswin(12)'./sum(gausswin(12)),'same');

[n1,n2,n3] = size(AQDgrid.Burst_VelEast);
e_drift1 = repelem(AQDgrid.e_drift,n1*n2);
e_drift2 = reshape(e_drift1,[n1,n2,n3]);
AQDgrid.e_abs=AQDgrid.Burst_VelEast+e_drift2;
n_drift1 = repelem(AQDgrid.n_drift,n1*n2);
n_drift2 = reshape(n_drift1,[n1,n2,n3]);
AQDgrid.n_abs=AQDgrid.Burst_VelNorth+n_drift2;

if exist([WWmeta.WWpath WWmeta.WW_name '_grid.mat'],'file')
    load([WWmeta.WWpath WWmeta.WW_name '_grid.mat'],'RBRgrid')
    RBRgrid.lat=interp1(time1,lat,RBRgrid.time);
    RBRgrid.lon=interp1(time1,lon,RBRgrid.time);
    save([WWmeta.WWpath WWmeta.WW_name '_grid.mat'],'RBRgrid','AQDgrid','-v7.3')
else
    save([WWmeta.WWpath WWmeta.WW_name '_grid.mat'],'AQDgrid','-v7.3')
end
end

