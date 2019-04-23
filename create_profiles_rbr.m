function create_profiles_rbr(Meta_Data)


load([Meta_Data.rbrpath Meta_Data.name_rbr])
eval(['[RBRprofiles.up,RBRprofiles.down,RBRprofiles.dataup,RBRprofiles.datadown] = getcastrbr(' Meta_Data.name_rbr ',.2);'])

% dup=diff(up);
% ind_prof=find(dup>1);
% RBRprofiles=struct([]);
% fields=fieldnames(dataup);
% tdata=dataup.time;
% for i=1:length(ind_prof)-1
%     for f=1:length(fields)
%         wh_field=fields{f};
%         if (length(tdata)==length(dataup.(wh_field)))
%             c{i}.(wh_field)=dataup.(wh_field)(ind_prof(i)+1:ind_prof(i+1));
%             RBRprofiles{i}.info=dataup.info;
%         end
%     end
% end
%% compute N2

disp('find depths and displacements of a few selected isopycnals')
for i=1:length(RBRprofiles.dataup)
    if length(RBRprofiles.dataup{i}.T)>3
%         RBRprofiles{i}.rho=sw_dens(RBRprofiles{i}.S,...
%             RBRprofiles{i}.T,...
%             RBRprofiles{i}.P);
        [n2,~,p_ave] = sw_bfrq(RBRprofiles.dataup{i}.S,...
            RBRprofiles.dataup{i}.T,...
            RBRprofiles.dataup{i}.P);
        [p_ave, IA]=unique(p_ave);
        RBRprofiles.dataup{i}.n2=interp1(p_ave,n2(IA),RBRprofiles.dataup{i}.P);
    else
        RBRprofiles.dataup{i}.n2=RBRprofiles.dataup{i}.T*nan;
    end
end

disp('find depths and displacements of a few selected isopycnals')
for i=1:length(RBRprofiles.datadown)
    if length(RBRprofiles.datadown{i}.T)>3
%         RBRprofiles{i}.rho=sw_dens(RBRprofiles{i}.S,...
%             RBRprofiles{i}.T,...
%             RBRprofiles{i}.P);
        [n2,~,p_ave] = sw_bfrq(RBRprofiles.datadown{i}.S,...
            RBRprofiles.datadown{i}.T,...
            RBRprofiles.datadown{i}.P);
        [p_ave, IA]=unique(p_ave);
        RBRprofiles.datadown{i}.n2=interp1(p_ave,n2(IA),RBRprofiles.datadown{i}.P);
    else
        RBRprofiles.datadown{i}.n2=RBRprofiles.datadown{i}.T*nan;
    end
end


save([Meta_Data.rbrpath 'Profiles_' Meta_Data.name_rbr],'RBRprofiles')




