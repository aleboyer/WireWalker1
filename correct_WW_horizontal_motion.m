%% correct WW motion

% example with NISKINE d2
load('/Users/aleboyer/ARNAUD/SCRIPPS/NISKINE/WW/d2/aqd/Profiles_WW_aqd_d2.mat')

% variable used
timeaxis=AQDprofiles{100}.Burst_Time;
dt=diff(AQDprofiles{100}.Burst_Time*86400);
mdt=nanmean(dt);
Accel1=double(AQDprofiles{100}.Burst_Accelerometer(:,1));
Accel2=double(AQDprofiles{100}.Burst_Accelerometer(:,2));
Accel3=double(AQDprofiles{100}.Burst_Accelerometer(:,3));
P=AQDprofiles{100}.Burst_Pressure;

% plot dP/dt to get an idea of the vertical veloctiti
ax(1)=subplot(211)
plot(timeaxis(1:end-1),diff(P)./dt)

% plot integral of filtered acceleration
fc=.2;  % start with .2 Hz bofu's value
fnb=1/(2*mdt)  ;        % nyquist freq , dt in s
[b, a]   = butter(3,fc/fnb,'high');
fAccel1=filtfilt(b,a,Accel1);
fAccel2=filtfilt(b,a,Accel2);
fAccel3=filtfilt(b,a,Accel3);

WWspeed1=cumsum(fAccel1*mdt);
WWspeed2=cumsum(fAccel2*mdt);
WWspeed3=cumsum(fAccel3*mdt);

ax(2)=subplot(212);
hold on
plot(timeaxis,WWspeed1);
plot(timeaxis,WWspeed2);
plot(timeaxis,WWspeed3);
hold off
linkaxes(ax,'x')


figure
plot(timeaxis(1:end-1),diff(P)./dt)
hold on
plot(timeaxis,WWspeed1);



