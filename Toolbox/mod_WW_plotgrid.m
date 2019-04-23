function mod_WW_plotgrid(CTDgrid,ADCPgrid,Meta_Data)



sgth=CTDgrid.rho-1000;
dnum=CTDgrid.time;
z=CTDgrid.z;


level_sig=linspace(min(nanmean(sgth,2)),max(nanmean(sgth,2)),100);
for dt=1:numel(dnum)
    indnan=~isnan(sgth(:,dt));
    eta(:,dt)=interp1(sgth(indnan,dt),z(indnan),level_sig);
end
dvals2=floor(nanmean(eta,2)./2);
dmeta2=diff(dvals2);
eta2m=eta(dmeta2>0,:);


% epsilon 1 
fontsize=25;
figure(1);
colormap('parula')
pcolor(dnum,z,CTDgrid.T);shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([min(CTDgrid.T(:)),max(CTDgrid.T(:))])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'Temperature','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)

fig=gcf;
fig.PaperPosition = [0 0 12 8];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'Temperature_map.png'),'-dpng2')





% epsilon 1 
fontsize=25;
z=ADCPgrid.z;
dnum1=ADCPgrid.time;
figure(2);
colormap('parula')
pcolor(dnum1,z,ADCPgrid.Burst_VelEast);shading flat;axis ij
hold on
plot(dnum,eta2m,'Color',[.1,.1,.1,.6],'linewidth',1)
colorbar
caxis([min(ADCPgrid.Burst_VelEast(:)),max(ADCPgrid.Burst_VelEast(:))])
set(gca,'XTickLabelRotation',25)
datetick
cax=colorbar;
xlabel(['Start date :' datestr(dnum1(1),'mm-dd-yyyy')],'fontsize',fontsize)
set(gca,'fontsize',fontsize)
ylabel(cax,'Vel East relative to WW','fontsize',fontsize)
ylabel('Depth (m)','fontsize',fontsize)

fig=gcf;
fig.PaperPosition = [0 0 12 8];
fig.PaperOrientation='Portrait';
print(fullfile(Meta_Data.L1path,'VelEastWW_map.png'),'-dpng2')
