function mod_nortek_create_profiles(Meta_Data,min_depth,crit_depth)


[ADCPprofiles.up,ADCPprofiles.down,ADCPprofiles.dataup,ADCPprofiles.datadown] = getcastnortek(Meta_Data,min_depth,crit_depth);

% do we wnat to save or change the speed and filter criteria
answer1=input('save? (yes,no)','s');

%save
switch answer1
    case 'yes'
        print('-dpng2',[Meta_Data.adcppath 'Profiles_Pr.png'])
        filepath=fullfile(Meta_Data.adcppath,['Profiles_' Meta_Data.deployment '.mat']);
        fprintf('Saving data in %s \n',filepath)
        save(filepath,'ADCPprofiles','-v7.3');
        
        Meta_Data.nbprofileup=numel(ADCPprofiles.up);
        Meta_Data.nbprofiledown=numel(ADCPprofiles.down);
        Meta_Data.maxdepth=max(cellfun(@(x) max(x.Burst_Pressure),ADCPprofiles.dataup));
        save(fullfile(Meta_Data.adcppath,'Meta_Data.mat'),'Meta_Data')
end


