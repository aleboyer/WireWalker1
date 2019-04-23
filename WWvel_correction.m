load('/Users/aleboyer/ARNAUD/SCRIPPS/DEV/NAVO/Profiles_NAVO_aqd_d1.mat')

L=cellfun(@(x) length(x.IBurstHR_Roll),AQDprofiles)

close all
subplot(211)
hold on
for j=25:30
    plot(AQDprofiles{j}.Burst_Velocity_XYZ(:,1,5)+(j-25)/2)
end
    
subplot(212)
hold on
for j=25:30
    plot(AQDprofiles{j}.Burst_Accelerometer(:,1)+(j-25)/10)
end
