function create_grid_aqd(Meta_Data)

load(fullfile(Meta_Data.adcppath,['Profiles_' Meta_Data.deployment '.mat']),'ADCPProfiles')
%get the normal upcast (mean P of the upcast ~ median P of all the mean P)

Paqd=cellfun(@(x) nanmean(x.Burst_Pressure),ADCPProfiles.dataup);
timeaqd=cellfun(@(x) mean(x.Burst_MatlabTimeStamp),ADCPProfiles.dataup);

critp= max(cellfun(@(x) max(x.Burst_Pressure),ADCPProfiles.dataup))-.5*std(Paqd);
critm= min(cellfun(@(x) min(x.Burst_Pressure),ADCPProfiles.dataup))+.5*std(Paqd);
indOK=(Paqd>critm & Paqd<critp);

PaqdOK=Paqd(indOK);
timeaqdOK=timeaqd(indOK);
ADCPProfiles.dataupOK=ADCPProfiles.dataup(indOK);

zaxis=0:.25:max(cellfun(@(x) max(x.Burst_Pressure),ADCPProfiles.dataupOK));
Z=length(zaxis);

fields=fieldnames(ADCPProfiles.dataup{1});
for f=1:length(fields)
    wh_field=fields{f};
    ADCPgrid.(wh_field)=zeros([Z,sum(indOK)]);
    for t=1:length(timeaqdOK)
        F=ADCPProfiles.dataupOK{t}.(wh_field);
        [Psort,I]=sort(ADCPProfiles.dataupOK{t}.Burst_Pressure,'descend');
        P_temp=(interp_sort(Psort));
        ADCPgrid.(wh_field)(:,t)=interp1(P_temp,medfilt1(F(I),10),zaxis);
    end
end
ADCPgrid.z=zaxis;
ADCPgrid.time=timeaqdOK;
if exist(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'file')
    load(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid')
    save(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid','ADCPgrid')
else
    save(fullfile(Meta_Data.adcppath,[Meta_Data.deployment '_grid.mat']),'ADCPgrid')
end


