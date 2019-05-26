function create_grid_ctd(Meta_Data)

load(fullfile(Meta_Data.L1path,['Profiles_' Meta_Data.deployment '.mat']),'CTDProfiles')


%get the normal upcast (mean P of the upcast ~ median P of all the mean P)
Profiles=CTDProfiles.dataup;

Prbr=cellfun(@(x) mean(x.P),Profiles);
critp= max(cellfun(@(x) max(x.P),Profiles))-.5*std(Prbr);
critm= min(cellfun(@(x) min(x.P),Profiles))+.5*std(Prbr);


timerbr=cellfun(@(x) mean(x.ctdtime),Profiles);
timerbrOK=timerbr(Prbr>critm & Prbr<critp);
indOK=(Prbr>critm & Prbr<critp);
Profiles=Profiles(indOK);
zaxis=0:.25:max(cellfun(@(x) max(x.P),Profiles));
Z=length(zaxis);

fields=fieldnames(Profiles{1});
for f=1:length(fields)
    wh_field=fields{f};
    if ~strcmp(wh_field,'info')
        CTDgrid.(wh_field)=zeros([Z,sum(indOK)]);
        for t=1:length(timerbrOK)
            F=Profiles{t}.(wh_field);
            [Psort,I]=sort(Profiles{t}.P,'descend');
            P_temp=(interp_sort(Psort));
            CTDgrid.(wh_field)(:,t)=interp1(P_temp,F(I),zaxis);
        end
    end
end
CTDgrid.z=zaxis;
CTDgrid.ctdtime=timerbrOK;
CTDgrid.info=CTDProfiles.info;

if exist(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'file')
    load(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'ADCPgrid')
    save(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid','ADCPgrid')
else
    save(fullfile(Meta_Data.L1path,[Meta_Data.deployment '_grid.mat']),'CTDgrid')
end

