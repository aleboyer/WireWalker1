function [dnum,z1,epsiLT,epsiAPE]=mod_ww_thorpescale_grid(Profiles,Meta_Data)

z1=1:.1:max(cellfun(@(x) max(x.P),Profiles));
df=1/nanmean(diff(Profiles{1}.time))/86400;
fc=1/5; % 60 sec
Nb=3;
[b, a]   = butter(Nb,2*fc/df,'low');

dnum=cell2mat(cellfun(@(x) mean(x.time),Profiles,'un',0));
try
t=cellfun(@(x) interp1(filtfilt(b,a,x.P),filtfilt(b,a,x.T),z1),Profiles,'un',0);
s=cellfun(@(x) interp1(filtfilt(b,a,x.P),filtfilt(b,a,x.S),z1),Profiles,'un',0);
catch
    error('Pressure is not monotonic enough')
end
t=cell2mat(t.');
s=cell2mat(s.');
sgth=smoothdata(sw_dens(s,t,z1),'movmean',5).';
%sgth=sw_dens(s,t,z1).';
level_sig=linspace(min(nanmean(sgth,2)),max(nanmean(sgth,2)),100);

eta=repmat(level_sig,[size(sgth,2) 1]).'*nan;
for dt=1:size(sgth,2)
    indnan=find(~isnan(sgth(:,dt)));
    if ~isempty(indnan)
        eta(:,dt)=interp1(sgth(indnan,dt).',z1(indnan),level_sig).';
    end
end
dvals2=floor(nanmean(eta,2)./2);
dmeta2=diff(dvals2);
eta2m=eta(dmeta2>0,:);


epsiLT=cellfun(@(x) interp1(x.depthLT,x.epsiLT,z1),Profiles,'un',0);
epsiLT=cell2mat(epsiLT.');
epsiLT(log10(epsiLT)<-15)=nan;

epsiAPE=cellfun(@(x) interp1(x.depthLT,x.epsiAPE,z1),Profiles,'un',0);
epsiAPE=cell2mat(epsiAPE.');
epsiAPE(log10(epsiAPE)<-15)=nan;

figure
ax(1)=subplot(211);
pcolor(ax(1),dnum,z1,log10(epsiLT.'));
shading(ax(1),'flat');
cax=colorbar();
ylabel(cax,'epsilon LT','fontsize',20)
hold(ax(1),'on')
plot(ax(1),dnum,eta2m,'k')
axis(ax(1),'ij')
caxis(ax(1),[-10 -5])
ylabel(ax(1),'Depth','fontsize',20)
ax(1).XTickLabel='';

ax(2)=subplot(212);
pcolor(ax(2),dnum,z1,log10(epsiAPE.'));
shading(ax(2),'flat');
cax=colorbar();
ylabel(cax,'epsilon APE','fontsize',20)
hold(ax(2),'on')
plot(ax(2),dnum,eta2m,'k')
axis(ax(2),'ij')
caxis(ax(2),[-10 -5])
ax(2).XTick=dnum(1):6/24:dnum(end);
ax(2).XTickLabel=datestr(dnum(1):6/24:dnum(end),'HH:MM:SS');
ax(2).XTickLabelRotation=45;
xlabel(ax(2),datestr(dnum(1),'dd-mm-yyyy'),'fontsize',20)
fig=gcf;fig.PaperPosition=[0 0 15 15];
title(ax(1),Meta_Data.mission,'fontsize',20)
ylabel(ax(2),'Depth','fontsize',20)
print('-dpng2',fullfile(Meta_Data.L1path,'EpsiLT.png'))
