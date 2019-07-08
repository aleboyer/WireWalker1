function create_grid_signature(Meta_Data)

load(fullfile(Meta_Data.adcppath,['Profiles_' Meta_Data.deployment '.mat']),'ADCPProfiles')
%get the normal upcast (mean P of the upcast ~ median P of all the mean P)

Paqd=cellfun(@(x) nanmean(x.Burst_Pressure),ADCPProfiles.dataup);
timeaqd=cellfun(@(x) mean(x.Burst_Time),ADCPProfiles.dataup);

critp= max(cellfun(@(x) max(x.Burst_Pressure),ADCPProfiles.dataup))-.5*std(Paqd);
critm= min(cellfun(@(x) min(x.Burst_Pressure),ADCPProfiles.dataup))+.5*std(Paqd);
indOK=(Paqd>critm & Paqd<critp);

PaqdOK=Paqd(indOK);
timeaqdOK=timeaqd(indOK);
ADCPProfiles.dataupOK=ADCPProfiles.dataup(indOK);

zaxis=0:.25:max(cellfun(@(x) max(x.Burst_Pressure),ADCPProfiles.dataupOK));
Z=length(zaxis);

fields=fieldnames(ADCPProfiles.dataup{1});
for f=2:length(fields) % loop start at 2 because the first field is the time
    wh_field=fields{f};
    Size_field=size(double(ADCPProfiles.dataupOK{1}.(wh_field)));
    ADCPgrid.(wh_field)=squeeze(zeros([Z,Size_field(2),sum(indOK)]));
    for t=1:length(timeaqdOK)
        F=double(ADCPProfiles.dataupOK{t}.(wh_field));
        if length(size(F))==3;F=F(:,:,1);end
        [Psort,~]=sort(ADCPProfiles.dataupOK{t}.Burst_Pressure,'descend');
        [P_temp,IA,~]=unique(Psort);
        if size(F,2)==1
            ADCPgrid.(wh_field)(:,t)=interp1(P_temp,medfilt1(F(IA,:),10),zaxis);
        else
            ADCPgrid.(wh_field)(:,:,t)=interp1(P_temp,medfilt1(F(IA,:),10),zaxis);
        end
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


